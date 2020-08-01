require "extlz4"

using LZ4

module MozLZ4
  refine String do
    # ruby-2.7 以前では、リファインメント内で外側の using が有効にならない
    using LZ4

    #
    # @overload to_mozlz4(dest) -> dest
    # @overload to_mozlz4(destmax = nil, dest = nil) -> dest
    # @return [dest, string]
    #
    def to_mozlz4(*args, **opts)
      MozLZ4.pack_component(bytesize, to_lz4block(*args))
    end

    #
    # @overload unmozlz4(dest) -> dest
    # @overload unmozlz4(destmax = nil, dest = nil) -> dest
    # @return [dest, string]
    #
    def unmozlz4(*args, **opts)
      (datasize, lz4block) = MozLZ4.unpack_component(self)
      lz4block.unlz4block(datasize, *args)
    end
  end

  using MozLZ4

  #
  # @return [string]
  #
  def MozLZ4.binread(path)
    File.binread(path).unmozlz4
  end

  #
  # @return [nil]
  #
  def MozLZ4.binwrite(path, binary)
    File.binwrite(path, binary.to_mozlz4)
    nil
  end

  #
  # @overload encode(src, dest) -> dest
  # @overload encode(src, destmax = nil, dest = nil) -> dest
  # @return [dest, string]
  #
  def MozLZ4.encode(src, *args, **opts)
    src.to_mozlz4(*args, **opts)
  end

  #
  # @overload decode(src, dest) -> dest
  # @overload decode(src, destmax = nil, dest = nil) -> dest
  # @return [dest, string]
  #
  def MozLZ4.decode(src, *args, **opts)
    src.unmozlz4(*args, **opts)
  end

  class << MozLZ4
    alias compress encode
    alias decompress decode
    alias uncompress decode
  end

  # @api private
  MAGICNUMBER = "mozLz40\x00".b

  # @api private
  FILEEXT = ".mozlz4"

  # @api private
  PACK_FORMAT = "a8Va*"

  # @api private
  def MozLZ4.validate_magic?(magic)
    magic.b == MAGICNUMBER ? true : false
  end

  # @api private
  def MozLZ4.test_magic(magic)
    unless validate_magic?(magic)
      raise "wrong magic for mozlz4"
    end

    nil
  end

  # @api private
  def MozLZ4.unpack_component(binary)
    ex = binary.unpack(PACK_FORMAT)
    test_magic(ex.shift)
    ex
  end

  # @api private
  def MozLZ4.pack_component(datasize, lz4block)
    [MAGICNUMBER, datasize, lz4block].pack(PACK_FORMAT)
  end
end
