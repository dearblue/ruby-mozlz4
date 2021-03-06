require "mozlz4"
require "optparse"

operator = "z"
level = 1
outstd = false
keepfiles = false
force_overwrite = false
verbosery = 0
recursively = false
ext = MozLZ4::FILEEXT

case File.basename($0, ".*")
when "unmozlz4"
  operator = "d"
when "mozlz4cat"
  operator = "d"
  outstd = true
  keepfiles = true
when "jsonlz4cat"
  operator = "J"
  outstd = true
  keepfiles = true
end

OptionParser.new(nil, 10, " ").instance_eval do
  begin
    separator "Operators:"
    on("-d", "decompress files") { operator = "d" }
    on("-l", "list compress file contents") { operator = "l" }
    on("-t", "test files") { operator = "t" }
    on("-z", "compress files") { operator = "z" }
    on("-J", "print as pretty json (with auto ``-c'' switch)") { operator = "J"; outstd = true; keepfiles = true }
    on("-V", "print program version") { operator = "V" }

    separator ""
    separator "Modifiers:"
    on("-[1-9]", "set compression level (always ignored)") { |x| level = x.to_i }
    on("-c", "write to stdout (with auto ``-k'' switch)") { outstd = true; keepfiles = true }
    on("-f", "force overwrite") { force_overwrite = true }
    on("-k", "keep given files (don't delete)") { keepfiles = true }
    on("-q", "quiet verbosery level") { verbosery = 0 }
    on("-r", "recursively directories") { recursively = true }
    on("-v", "increase verbosery level") { verbosery += 1 }
    on("-S .ext", "declare file ext (default: #{ext})", /\A\.[^\.\0]+\z/) { |x| ext = x }

    order!
  rescue OptionParser::InvalidOption
    $stderr.puts <<-ERR
#{File.basename $0}: #$! (#{$!.class})
    ERR
    exit 1
  end
end

module MozLZ4
  refine MozLZ4.singleton_class do
    # @api private
    def process_file(input, output, force_overwrite: false, keepfiles: true)
      if (st1 = File.stat(input) rescue false) && (st2 = File.stat(output) rescue false) &&
          (st1.dev == st2.dev && st1.ino == st2.ino)
        raise "Cannot specify the same file"
      end

      d = yield(File.binread(input))
      mode = File::CREAT | File::WRONLY | File::BINARY
      mode |= File::EXCL unless force_overwrite
      File.binwrite(output, d, mode: mode)

      begin
        t = File.mtime(input)
        File.utime t, t, output
      rescue SystemCallError
        # do nothing
      end
      File.unlink input rescue nil unless keepfiles
    end

    # @api private
    def traverse_path(path, recursively)
      case
      when path == "-"
        yield path
      when File.directory?(path)
        require "find"

        Find.find(path) do |pt|
          yield pt if File.file?(pt)
        end
      else
        yield path
      end
    end
  end
end

using MozLZ4

case operator
when "d"
  if outstd
    operator = ->(path) {
      if path == "-"
        $stdin.binmode
        bin = $stdin.read
      else
        bin = File.binread(path)
      end
      $stdout << bin.unmozlz4
    }
  else
    opts = { force_overwrite: force_overwrite, keepfiles: keepfiles }
    operator = ->(path) {
      if path == "-"
        $stdin.binmode
        $stdout.binmode
        $stdout << $stdin.read.unmozlz4
      else
        dest = File.join(File.dirname(path), File.basename(path, ext))
        MozLZ4.process_file(path, dest, **opts) { |d|
          d.unmozlz4
        }
      end
    }
  end
when "l"
  operator = ->(path) {
    if path == "-"
      path = "<stdin>"
      $stdin.binmode
      bin = $stdin.read
    else
      bin = File.binread(path, 12)
    end
    (datasize, *) = MozLZ4.unpack_component(bin)
    puts "%10d  %10d  %s\n" % [File.size(path), datasize, path]
  }
when "t"
  operator = ->(path) {
    if path == "-"
      print "<stdin>..." if verbosery > 0
      $stdin.binmode
      $stdin.read.unmozlz4
    else
      print "#{path}..." if verbosery > 0
      File.binread(path).unmozlz4
    end
    puts "ok.\n" if verbosery > 0
  }
when "z"
  opts = { force_overwrite: force_overwrite, keepfiles: keepfiles }
  operator = ->(path) {
    if path == "-"
      $stdin.binmode
      $stdout.binmode
      $stdout << $stdin.read.to_mozlz4
    else
      dest = path + ext
      MozLZ4.process_file(path, dest, **opts) { |d|
        d.to_mozlz4
      }
    end
  }
when "J"
  require "json"
  require "tty-pager"

  operator = ->(path) {
    if path == "-"
      $stdin.binmode
      mozlz4 = $stdin.read
    else
      mozlz4 = File.binread(path)
    end
    bin = mozlz4.unmozlz4
    json = JSON.load(bin)
    pager = TTY::Pager.new
    begin
      pager.page JSON.pretty_generate(json)
    rescue Errno::EPIPE
      # do nothing
    end
  }
when "V"
  ver = Gem.finish_resolve.find { |e| e.name == "mozlz4" }&.version&.to_s
  ver &&= "-#{ver}"

  $stdout << <<-VERSION
#{File.basename $0, ".*"}#{ver} with #{RUBY_ENGINE}-#{RUBY_ENGINE_VERSION}p#{RUBY_PATCHLEVEL}
  VERSION

  exit 0
else
  raise "[BUG]"
end

status = 0

ARGV << "-" if ARGV.empty? && !$stdin.tty?

ARGV.each do |path|
  begin
    MozLZ4.traverse_path(path, recursively) do |pt|
      begin
        operator[pt]
      rescue SystemCallError, RuntimeError
        status = 1
        $stderr.puts <<-ERR
#{File.basename $0}: #{pt} - #$! (#{$!.class})
        ERR
      end
    end
  rescue SystemCallError, RuntimeError
    status = 1
    $stderr.puts <<-ERR
#{File.basename $0}: #{path} - #$! (#{$!.class})
    ERR
  end
end

exit status
