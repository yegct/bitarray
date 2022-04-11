class BitArrayFile
  HEADER_LENGTH = BitArray::HEADER_LENGTH

  attr_reader :io, :reverse_byte, :size

  def initialize(filename: nil, io: nil)
    if io
      @io = io
    elsif filename
      @io = File.open(filename, "r")
    else
      raise ArgumentError.new("Must specify a filename or io argument")
    end

    @io.seek(0)
    @size = @io.read(8).unpack("Q").first
    @reverse_byte = @io.read(1).unpack("C").first == 1
  end

  private def seek_to(position)
    @io.seek(position + HEADER_LENGTH)
  end

  # Read a bit (1/0)
  def [](position)
    seek_to(position >> 3)
    (@io.getbyte & (1 << (byte_position(position) % 8))) > 0 ? 1 : 0
  end

  def byte_position(position)
    @reverse_byte ? position : 7 - position
  end
end
