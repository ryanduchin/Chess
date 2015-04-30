class SlidingPiece < Piece

  def moves
    moves = []
    move_dirs.each do |(dx, dy)|
      moves += moves_in_direction(dx, dy)
    end

    moves
  end

  private

  def moves_in_direction(dx, dy)
    moves_in_direction = []
    steps = 1
    loop do
      x, y = pos
      new_pos = [x + dx * steps, y + dy * steps]

      if !@board.on_board?(new_pos)
        return moves_in_direction
      elsif !@board.piece_at(new_pos)
        moves_in_direction << new_pos
      elsif same_color?(new_pos)
        return moves_in_direction
      else #diff color
        return moves_in_direction << new_pos
      end

      steps += 1
    end
  end

  def same_color?(new_pos)
     @board.piece_at(new_pos).color == color
  end

end

class Rook < SlidingPiece

  def move_dirs
    [[0,1], [0,-1], [-1,0], [1,0]]
  end

  def symbol
    piece_symbol = "♜"
    piece_symbol.colorize(convert_color(@color))
  end
end


class Bishop < SlidingPiece

  def move_dirs
    [[1,1], [1,-1], [-1,1], [-1,-1]]
  end

  def symbol
    piece_symbol = "♝"
    piece_symbol.colorize(convert_color(@color))
  end
end

class Queen < SlidingPiece

  def move_dirs
    [[1,1], [1,-1], [-1,1], [-1,-1], [0,1], [0,-1], [-1,0], [1,0]]
  end

  def symbol
    piece_symbol = "♛"
    piece_symbol.colorize(convert_color(@color))
  end
end
