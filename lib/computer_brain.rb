class ComputerBrain
  attr_accessor :attacked_keys, :available_keys, :validated_keys

  def initialize(user_board, cpu_board)
    @user_board = user_board
    @cpu_board = cpu_board
    @attacked_keys = []
    @attacked_keys_directions = []
    @available_keys = @user_board.cells.keys
    @validated_keys = []
  end

  ##Computer place methods
  def cpu_place_ships(ships)
    valid_ship_counter = 0
    @validated_keys = []
    validated_ships = []
    ships.each do |ship|
      potential_array = make_limited_placement_array(ship)
      first_key = potential_array.sample
      if !@validated_keys.include?(first_key)
        search_direction = [:horizontal, :vertical].sample
        potential_keys = directional_validation(first_key, search_direction, ship)
        if potential_keys != false
          @validated_keys << potential_keys
          @validated_keys = @validated_keys.flatten
          validated_ships << {ship => potential_keys}
          valid_ship_counter += 1
        end
      end
    end
    if valid_ship_counter == ships.count
      validated_ships.each do |hash|
        hash.each do |ship, keys|
          keys.each do |key|
            @cpu_board.cells[key].place_ship(ship)
          end
        end
      end
    else
      cpu_place_ships(ships)
    end
  end

  def make_limited_placement_array(ship)
    length = ship.length
    max_width = @cpu_board.width - length + 1
    max_height = (@cpu_board.height - length + 65).chr

    potential_first_keys = []
    ("A"..max_height).to_a.each do |letter|
      (1..max_width).to_a.each do |number|
        potential_first_keys << "#{letter}#{number}"
      end
    end
    return potential_first_keys
  end

  def directional_validation(coordinate, direction, ship)
    letter = coordinate.split("")[0]
    number = [coordinate.split("")[1], coordinate.split("")[2]].join.to_i

    if direction == :vertical
      potential_keys = vertical_directional_keys(letter, number, ship)
      if valid_potential_keys?(potential_keys) == true
        return potential_keys
      else
        return false
      end
    elsif direction == :horizontal
      potential_keys = horizontal_directional_keys(letter, number, ship)
      if valid_potential_keys?(potential_keys) == true
        return potential_keys
      else
        return false
      end
    end
  end

  def vertical_directional_keys(letter, number, ship)
    potential_keys = []
    end_letter = (letter.ord + ship.length - 1).chr
    test_range = (letter..end_letter).to_a
    test_range.each do |dyn_letter|
      potential_keys << "#{dyn_letter}#{number}"
    end
    return potential_keys
  end

  def horizontal_directional_keys(letter, number, ship)
    potential_keys = []
    end_number = number + ship.length - 1
    test_range = (number..end_number).to_a
    test_range.each do |dyn_number|
      potential_keys << "#{letter}#{dyn_number}"
    end
    return potential_keys
  end

  def valid_potential_keys?(potential_keys)
    potential_keys.none? do |key|
      @validated_keys.include?(key)
    end
  end

  ##Computer attack methods
  def computer_attacks(key = generate_smarter_attack_key)
    @user_board.cells[key].fire_upon
    @available_keys.delete(key)
    @attacked_keys << key
    @user_board.attacked_cells << key
  end

  def generate_smart_attack_key
    last_key = find_last_hit
    if @attacked_keys.empty? || last_key == nil || @user_board.cells[last_key].render == "X"
      generate_random_attack_key
    elsif @user_board.cells[last_key].render == "H"
      move_up(split_last_key_letter(last_key), split_last_key_number(last_key))
    end
  end

  def generate_smarter_attack_key
    last_key = find_last_hit
    if @attacked_keys.empty? || last_key == nil || @user_board.cells[last_key].render == "X"
      generate_random_attack_key
    elsif @user_board.cells[last_four_shots_array[0]].render == "M" && shot_was_a_hit?(1) && shot_was_a_hit?(2) && shot_was_a_hit?(3)
      last_key = last_four_shots_array[3]
      reverse_direction(split_last_key_letter(last_key), split_last_key_number(last_key))
    elsif @user_board.cells[last_four_shots_array[0]].render == "M" && shot_was_a_hit?(1) && shot_was_a_hit?(2)
      last_key = last_four_shots_array[2]
      reverse_direction(split_last_key_letter(last_key), split_last_key_number(last_key))
      #try to fix later
    # elsif last_four_shots_array[1] && last_four_shots_array[2] &&
    #       (@user_board.cells[last_four_shots_array[1]].render == "M" && shot_was_a_hit?(0) && shot_was_a_hit?(2)) ||
    #       (@user_board.cells[last_four_shots_array[1]].render == "M" && @user_board.cells[last_four_shots_array[2]].render == "M" && shot_was_a_hit?(0) && shot_was_a_hit?(3))
    #   keep_direction(split_last_key_letter(last_key), split_last_key_number(last_key))
    else
      move_up(split_last_key_letter(last_key), split_last_key_number(last_key))
    end
  end

  def find_last_hit
    last_hit = last_four_shots_array.find do |key|
      @user_board.cells[key].render == "H"
    end
    last_hit
  end

  def last_four_shots_array
    @attacked_keys.reverse[0..3]
  end

  def split_last_key_letter(key)
    key.split("")[0].ord
  end

  def split_last_key_number(key)
    [key.split("")[1], key.split("")[2]].join.to_i
  end

  def shot_was_a_hit?(index)
    if last_four_shots_array[index] == nil
      return false
    elsif @user_board.cells[last_four_shots_array[index]].render == "H"
      return true
    else
      false
    end
  end

  def last_shot_direction
    @attacked_keys_directions.last
  end

  def reverse_direction(last_letter, last_number)
    if last_shot_direction == :up
      move_down(last_letter, last_number)
    elsif last_shot_direction == :down
      move_up(last_letter, last_number)
    elsif last_shot_direction == :left
      move_right(last_letter, last_number)
    elsif last_shot_direction == :right
      move_left(last_letter, last_number)
    end
  end

  def keep_direction(last_letter, last_number)
    if last_shot_direction == :down
      move_down(last_letter, last_number)
    elsif last_shot_direction == :up
      move_up(last_letter, last_number)
    elsif last_shot_direction == :right
      move_right(last_letter, last_number)
    elsif last_shot_direction == :left
      move_left(last_letter, last_number)
    end
  end

  def generate_random_attack_key
    key_index = rand(@available_keys.size) - 1
    @available_keys[key_index]
  end

  def move_up(last_letter, last_number)
    if last_letter > 65
      next_letter = (last_letter - 1).chr
      next_key = "#{next_letter}#{last_number}"
      if !@attacked_keys.include?(next_key)
        @attacked_keys_directions << :up
        return next_key
      else
        move_down(last_letter, last_number)
      end
    else
      move_down(last_letter, last_number)
    end
  end

  def move_down(last_letter, last_number)
    if last_letter < (@user_board.height + 63)
    next_letter = (last_letter + 1).chr
    next_key = "#{next_letter}#{last_number}"
      if !@attacked_keys.include?(next_key)
        @attacked_keys_directions << :down
        return next_key
      else
        move_left(last_letter, last_number)
      end
    else
      move_left(last_letter, last_number)
    end
  end

  def move_left(last_letter, last_number)
    if last_number > 1
    next_number = last_number - 1
    next_key = "#{last_letter.chr}#{next_number}"
      if !@attacked_keys.include?(next_key)
        @attacked_keys_directions << :left
        return next_key
      else
        move_right(last_letter, last_number)
      end
    else
      move_right(last_letter, last_number)
    end
  end

  def move_right(last_letter, last_number)
    if last_number < (@user_board.width)
      next_number = last_number + 1
      next_key = "#{last_letter.chr}#{next_number}"
      if !@attacked_keys.include?(next_key)
        @attacked_keys_directions << :right
        return next_key
      else
        generate_random_attack_key
      end
    else
      generate_random_attack_key
    end
  end

end
