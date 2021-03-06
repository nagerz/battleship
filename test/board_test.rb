require 'minitest/autorun'
require 'minitest/pride'
require './lib/ship'
require './lib/cell'
require './lib/board'

class BoardTest < Minitest::Test

  def setup
    @board = Board.new
    @cruiser = Ship.new("Cruiser", 3)
    @submarine = Ship.new("Submarine", 2)
  end

  def test_board_exists
    assert_instance_of Board, @board
  end

  def test_cells_hash
    assert_equal Hash, @board.cells.class
    assert_equal 16, @board.cells.length
    assert_instance_of Cell, @board.cells["A1"]
  end

  def test_array_of_letters
    board2 = Board.new(6)
    assert_equal ["A", "B", "C", "D"], @board.letters_array
    assert_equal ["A", "B", "C", "D", "E", "F"], board2.letters_array
  end

  def test_valid_coordinate_default_board
    assert_equal true, @board.valid_coordinate?("A1")
    assert_equal true, @board.valid_coordinate?("D4")
    assert_equal false, @board.valid_coordinate?("A5")
    assert_equal false, @board.valid_coordinate?("E1")
    assert_equal false, @board.valid_coordinate?("A22")
  end

  def test_valid_coordinate_custom_board
    board2 = Board.new(7)
    assert_equal true, board2.valid_coordinate?("A1")
    assert_equal true, board2.valid_coordinate?("E5")
    assert_equal false, board2.valid_coordinate?("L2")
    assert_equal false, board2.valid_coordinate?("E8")
    assert_equal false, board2.valid_coordinate?("Z77")
  end

  def test_invalid_placement_coords_not_on_board
    assert_equal false, @board.valid_placement?(@cruiser,["Z1", "Z2"])
    assert_equal false, @board.valid_placement?(@submarine,["A22", "A23", "A24"])
  end

  def test_invalid_placement_not_correct_length
    assert_equal false, @board.valid_placement?(@cruiser,["A1", "A2"])
    assert_equal false, @board.valid_placement?(@submarine,["A2", "A3", "A4"])
  end

  def test_invalid_placement_not_consecutive
    assert_equal false, @board.valid_placement?(@cruiser,["A1", "A2", "A4"])
    assert_equal false, @board.valid_placement?(@submarine,["A1", "C1"])
  end

  def test_invalid_placement_diagonal
    assert_equal false, @board.valid_placement?(@cruiser,["A1", "B2", "C3"])
    assert_equal false, @board.valid_placement?(@submarine,["C2", "D3"])
  end

  def test_valid_placement
    assert_equal true, @board.valid_placement?(@submarine,["A1", "A2"])
    assert_equal true, @board.valid_placement?(@cruiser,["B1", "C1", "D1"])
    assert_equal true, @board.valid_placement?(@cruiser,["D1", "B1", "C1"])
  end

  def test_it_can_place_a_ship
    @board.place(@cruiser, ["A1", "A2", "A3"])
    cell_1 = @board.cells["A1"]
    cell_2 = @board.cells["A2"]
    cell_3 = @board.cells["A3"]

    assert_equal @cruiser, cell_1.ship
    assert_equal @cruiser, cell_2.ship
    assert_equal @cruiser, cell_3.ship
    assert_equal true, cell_3.ship == cell_2.ship
  end

  def test_it_doesnt_have_overlapping_ships
    @board.place(@cruiser, ["A1", "A2", "A3"])

    assert_equal false, @board.valid_placement?(@submarine, ["A1", "B1"])
  end

  def test_it_can_render_a_board
    @board.place(@cruiser, ["A1", "A2", "A3"])

    assert_equal "  1 2 3 4 \nA . . . . \nB . . . . \nC . . . . \nD . . . . \n", @board.render
    assert_equal "  1 2 3 4 \nA S S S . \nB . . . . \nC . . . . \nD . . . . \n", @board.render(true)

    @board.place(@submarine, ["B4", "C4"])
    assert_equal "  1 2 3 4 \nA S S S . \nB . . . S \nC . . . S \nD . . . . \n", @board.render(true)

    hit_cell = @board.cells["B4"]
    hit_cell.fire_upon
    miss_cell = @board.cells["B3"]
    miss_cell.fire_upon
    @board.place(@submarine, ["B4", "C4"])
    assert_equal "  1 2 3 4 \nA S S S . \nB . . M H \nC . . . S \nD . . . . \n", @board.render(true)

    hit_cell = @board.cells["C4"]
    hit_cell.fire_upon
    assert_equal "  1 2 3 4 \nA S S S . \nB . . M X \nC . . . X \nD . . . . \n", @board.render(true)
  end

  def test_it_knows_coordinates_are_on_board
    board2 = Board.new(4)

    assert_equal true, board2.all_coordinates_on_board?(["A1", "A2", "A3"])
    assert_equal false, board2.all_coordinates_on_board?(["Z1", "A2", "A3"])
    assert_equal false, board2.all_coordinates_on_board?(["A10", "A11", "A12"])
  end

end
