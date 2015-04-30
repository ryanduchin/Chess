class SteppingPiece < Piece

  def moves
    moves = []
    move_diffs.each do |dir|
      new_pos = [pos.first + dir.first, pos.last + dir.last]

      next if !board.on_board?(new_pos)

      next if board.occupied?(new_pos) &&
              board.piece_at(new_pos).color == self.color
      moves << new_pos
    end

    moves
  end
end


class King < SteppingPiece
  def move_diffs
    [[0,1], [1,1], [1,0], [-1,1], [-1,0], [-1,-1], [0,-1], [1,-1]]
  end

  def symbol
    piece_symbol = "♚"
    piece_symbol.colorize(convert_color(color))
  end
end

class Knight < SteppingPiece
  def move_diffs
    [[1,2], [1,-2], [-1,2], [-1,-2], [2,1], [-2,1], [-2,-1], [2,-1]]
  end

  def symbol
    piece_symbol = "♞"
    piece_symbol.colorize(convert_color(color))
  end
end
