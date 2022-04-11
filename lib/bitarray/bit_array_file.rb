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

  # Iterate over each bit
  def each
    return to_enum(:each) unless block_given?
    @size.times { |position| yield self[position] }
  end

  # Returns the field as a string like "0101010100111100," etc.
  def to_s
    seek_to(0)
    if @reverse_byte
      @io.each_byte.collect { |ea| ("%08b" % ea).reverse }.join[0, @size]
    else
      @io.each_byte.collect { |ea| ("%08b" % ea) }.join[0, @size]
    end
  end

  # Iterates over each byte
  def each_byte
    seek_to(0)
    return to_enum(:each_byte) unless block_given?
    @io.each_byte { |byte| yield byte }
  end

  # Returns the total number of bits that are set
  # Use Brian Kernighan's way, see
  # https://graphics.stanford.edu/~seander/bithacks.html#CountBitsSetKernighan
  def total_set
    seek_to(0)
    @io.each_byte.inject(0) { |a, byte| (a += 1; byte &= byte - 1) while byte > 0 ; a }
  end

  def byte_position(position)
    @reverse_byte ? position : 7 - position
  end
end
