require 'minitest/autorun'
require 'minitest/pride'
require './lib/ship'
require './lib/cell'
require './lib/board'
require './lib/valid_placement'
require 'pry'



def test_valid_size
  assert_equal false, @board.valid_size?(@cruiser,["A1", "A2"])
  assert_equal false, @board.valid_size?(@submarine,["A2", "A3", "A4"])
  assert_equal true, @board.valid_size?(@submarine,["A2", "A3"])
end

def test_split_letters
  test_array = ["A2", "B2", "C2", "D2"]
  assert_equal ["A", "B", "C", "D"], @board.split_letters(test_array)
end

def test_split_numbers
  test_array = ["A3", "A1", "A2", "A4"]
  assert_equal [3, 1, 2, 4], @board.split_numbers(test_array)
end

def test_matching_letters
  test_array1 = ["A3", "A1", "A2", "A4"]
  test_letters1 = @board.split_letters(test_array1)
  assert_equal true, @board.matching?(test_letters1)
  test_array2 = ["A2", "A2", "C2", "D2"]
  test_letters2 = @board.split_letters(test_array2)
  assert_equal false, @board.matching?(test_letters2)
end

def test_matching_numbers
  test_array1 = ["A3", "A1", "A2", "A4"]
  test_numbers1 = @board.split_numbers(test_array1)
  assert_equal false, @board.matching?(test_numbers1)
  test_array2 = ["A2", "A2", "C2", "D2"]
  test_numbers2 = @board.split_numbers(test_array2)
  assert_equal true, @board.matching?(test_numbers2)
end

def test_consecutive
  test_array1 = ["A1", "A2", "A3", "A4"]
  test_numbers1 = @board.split_numbers(test_array1)
  assert_equal true, @board.consecutive?(test_numbers1)
  test_array2 = ["A3", "A1", "A2", "A4"]
  test_numbers2 = @board.split_numbers(test_array2)
  assert_equal true, @board.consecutive?(test_numbers2)
  test_array3 = ["A2", "B2", "C2", "D2"]
  test_numbers3 = @board.split_numbers(test_array3)
  assert_equal false, @board.consecutive?(test_numbers3)
end

def test_invalid_placement_not_correct_length
  assert_equal false, @board.valid_placement?(@cruiser,["A1", "A2"])
  assert_equal false, @board.valid_placement?(@submarine,["A2", "A3", "A4"])
end

def test_invalid_placement_not_consecutive
  cruiser = Ship.new("Cruiser", 3)
  submarine = Ship.new("Submarine", 2)
  assert_equal false, @board.valid_placement?(cruiser,["A1", "A2", "A4"])
  assert_equal false, @board.valid_placement?(submarine,["A1", "C1"])
  assert_equal false, @board.valid_placement?(cruiser,["A3", "A2", "A1"])
  assert_equal false, @board.valid_placement?(submarine,["C1", "B1"])
end

def test_invalid_placement_diagonal
  cruiser = Ship.new("Cruiser", 3)
  submarine = Ship.new("Submarine", 2)
  assert_equal false, @board.valid_placement?(cruiser,["A1", "B2", "C3"])
  assert_equal false, @board.valid_placement?(submarine,["C2", "D3"])
end

# def test_valid_placement
#   cruiser = Ship.new("Cruiser", 3)
#   submarine = Ship.new("Submarine", 2)
#   assert_equal true, @board.valid_placement?(submarine,["A1", "A2"])
#   assert_equal true, @board.valid_placement?(cruiser,["B1", "C1", "D1"])
# end

def test_valid_placement_components
  ship = Ship.new("Submarine", 3)
  coordinates = ["A1", "A2", "A3"]
  assert_equal true, @board.valid_size?(ship, coordinates)
  assert_equal true, @board.matching?(@board.split_letters(coordinates)) && !@board.matching?(@board.split_numbers(coordinates)) && @board.consecutive?(@board.split_numbers(coordinates))

  # assert_equal true, !@board.matching?(@board.split_letters(coordinates)) && @board.matching?(@board.split_numbers(coordinates)) && @board.consecutive?(@board.split_letters(coordinates))

  assert_equal true, !@board.matching?(@board.split_letters(coordinates))
  assert_equal true, @board.matching?(@board.split_numbers(coordinates))
  assert_equal true, @board.consecutive?(@board.split_letters(coordinates))
end