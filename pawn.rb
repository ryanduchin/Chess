class Pawn < Piece

  def move_dir
    @color == :black ? 1 : -1
  end

  def moves
    moves = []

    one_forward = pos_in_front(@pos)
    two_forward = pos_in_front(one_forward)
    unless @board.occupied?(one_forward)
      moves << one_forward
      unless @board.occupied?(two_forward) || @moved
        moves << two_forward
      end
    end

    capture_positions.each do |cap_pos|
      if @board.occupied?(cap_pos) &&
         @board.piece_at(cap_pos).color != self.color
        moves << cap_pos
      end
    end

    moves
  end

  def symbol
    piece_symbol = "♟"
    piece_symbol.colorize(convert_color(@color))
  end

  private

  def pos_in_front(current_pos)
    [current_pos.first + move_dir, current_pos.last]
  end

  def capture_positions
    [[@pos.first + move_dir, @pos.last + 1],
    [@pos.first + move_dir, @pos.last - 1]]
  end

end
