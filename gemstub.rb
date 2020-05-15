GEMSTUB = Gem::Specification.new do |s|
  s.name = "mozlz4"
  s.summary = "mozlz4 archiver"
  s.description = "mozlz4 archiver library and tool"
  ver = File.read(File.join(__dir__, "README.md")).scan(/^\s*[\-\*] version:\s*(\d+(?:\.\d+)+)/i).flatten[-1]
  s.version = ver || "0.0.0.1.AN.EARLY.CONCEPT"
  s.license = "BSD-2-Clause"
  s.author = "dearblue"
  s.email = "dearblue@users.osdn.me"
  s.homepage = "https://github.com/dearblue/ruby-mozlz4"

  s.add_runtime_dependency "extlz4", "~> 0"
  s.add_runtime_dependency "tty-pager", "~> 0"
end
