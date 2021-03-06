require './lib/cell'
require './lib/valid_placement'

class Board
  attr_accessor :cells, :height, :width, :ships, :attacked_cells

  def initialize(size = 4)
    @width = size #width is for numbers
    @height = size #height is for letters
    @cells = cells_hash
    @ships = []
    @attacked_cells = []
  end

  def cells_hash
    cells_hash = {}
    letters_array.each do |letter|
      numbers_array.each do |number|
        temp_key = "#{letter}#{number.to_s}"
        cells_hash[temp_key] = Cell.new(temp_key)
      end
    end
    return cells_hash
  end

  def numbers_array
    (1..@width).to_a
  end

  def letters_array
    end_letter = (@height + 64).chr
    ("A"..end_letter).to_a
  end

  def render(show_ship = false)
    render_array(show_ship).join.to_s
  end

  def render_array(show_ship)
    render_array = []
    render_array << " "
    numbers_array.each do |number|
      if numbers_array.count > 9
        if number < 9
          render_array << " " + number.to_s + " "
        else
          render_array << " " + number.to_s
        end
      else
        render_array << " " + number.to_s
      end
    end
    render_array << " \n"

    letters_array.each do |letter|
      render_array << letter + " "
      numbers_array.each do |number|
        if numbers_array.count > 9
          temp_key = "#{letter}#{number.to_s}"
          render_array << cells[temp_key].render(show_ship) + " "
          render_array << " "
        else
          temp_key = "#{letter}#{number.to_s}"
          render_array << cells[temp_key].render(show_ship) + " "
        end
      end
      render_array << "\n"
    end
    return render_array
  end

  def place(ship, coordinates)
    coordinates.each do |coordinate|
      cells[coordinate].place_ship(ship)
    end
    @ships << ship
  end

  def valid_placement?(ship, coordinates)
    if all_coordinates_on_board?(coordinates)
      ValidPlacement.new.valid_placement?(ship, coordinates) && overlapping_ships?(coordinates)
    else
      false
    end
  end

  def all_coordinates_on_board?(coordinates)
    coordinates.all? do |coord|
      valid_coordinate?(coord)
    end
  end

  def valid_coordinate?(coordinate)
    cells.member?(coordinate)
  end

  def overlapping_ships?(coordinates)
    coordinates.all? do |coordinate|
      cells[coordinate].empty?
    end
  end

end
