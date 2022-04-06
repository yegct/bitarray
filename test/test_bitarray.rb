require "minitest/autorun"
require "tempfile"
require_relative "../lib/bitarray"

class TestBitArray < Minitest::Test
  def setup
    @public_ba = BitArray.new(1000)
  end

  def test_basic
    assert_equal 0, BitArray.new(100)[0]
    assert_equal 0, BitArray.new(100)[99]
  end

  def test_setting_and_unsetting
    @public_ba[100] = 1
    assert_equal 1, @public_ba[100]
    @public_ba[100] = 0
    assert_equal 0, @public_ba[100]
  end

  def test_random_setting_and_unsetting
    100.times do
      index = rand(1000)
      @public_ba[index] = 1
      assert_equal 1, @public_ba[index]
      @public_ba[index] = 0
      assert_equal 0, @public_ba[index]
    end
  end

  def test_multiple_setting
    1.upto(999) do |pos|
      2.times do
        @public_ba[pos] = 1
        assert_equal 1, @public_ba[pos]
      end
    end
  end

  def test_multiple_unsetting
    1.upto(999) do |pos|
      2.times do
        @public_ba[pos] = 0
        assert_equal 0, @public_ba[pos]
      end
    end
  end

  def test_size
    assert_equal 1000, @public_ba.size
  end

  def test_to_s
    ba = BitArray.new(35)
    [1, 5, 6, 7, 10, 16, 33].each { |i| ba[i] = 1}
    assert_equal "01000111001000001000000000000000010", ba.to_s
  end

  def test_field
    ba = BitArray.new(35)
    [1, 5, 6, 7, 10, 16, 33].each { |i| ba[i] = 1}
    assert_equal "1110001000000100000000010000000000000010", ba.field.unpack('B*')[0]
  end

  def test_initialize_with_field
    ba = BitArray.new(15, ["0100011100100001"].pack('B*'))

    assert_equal [0, 1, 2, 6, 8, 13], 0.upto(15).select { |i| ba[i] == 1 }

    ba[2] = 1
    ba[12] = 1
    assert_equal [0, 1, 2, 6, 8, 12, 13], 0.upto(15).select { |i| ba[i] == 1 }
  end

  def test_total_set
    ba = BitArray.new(10)
    ba[1] = 1
    ba[5] = 1
    ba[9] = 1
    assert_equal 3, ba.total_set
  end

  def test_dump_load
    ba_dump = BitArray.new(35)
    [1, 5, 6, 7, 10, 16, 33].each { |i| ba_dump[i] = 1}
    Tempfile.create("bitarray.dat") do |io|
      ba_dump.dump(io)
      io.rewind
      ba_load = BitArray.load(io)

      assert_equal ba_dump, ba_load
    end
  end
end

class TestBitArrayWhenNonReversedByte < Minitest::Test
  def test_to_s
    ba = BitArray.new(35, nil, reverse_byte: true)
    [1, 5, 6, 7, 10, 16, 33].each { |i| ba[i] = 1}
    assert_equal "01000111001000001000000000000000010", ba.to_s
  end

  def test_field
    ba = BitArray.new(35, nil, reverse_byte: false)
    [1, 5, 6, 7, 10, 16, 33].each { |i| ba[i] = 1}
    assert_equal "0100011100100000100000000000000001000000", ba.field.unpack('B*')[0]
  end

  def test_initialize_with_field
    ba = BitArray.new(15, ["0100011100100001"].pack('B*'), reverse_byte: false)

    assert_equal [1, 5, 6, 7, 10, 15], 0.upto(15).select { |i| ba[i] == 1 }

    ba[2] = 1
    ba[12] = 1
    assert_equal [1, 2, 5, 6, 7, 10, 12, 15], 0.upto(15).select { |i| ba[i] == 1 }
  end
end
