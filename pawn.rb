class Pawn < Piece

  def move_dir
    @color == :black ? 1 : -1
  end

  def moves
    moves = []

    one_forward = pos_in_front(@pos)
    two_forward = pos_in_front(one_forward)
    if pawn_can_move(one_forward)
      moves << one_forward
      moves << two_forward if !@moved && pawn_can_move(two_forward)
    end

    capture_positions.each do |cap_pos|
      moves << cap_pos if pawn_can_attack(cap_pos)
    end

    moves
  end


  def symbol
    piece_symbol = "♟"
    piece_symbol.colorize(convert_color(@color))
  end

  def pawn_can_move(pos)
    @board.on_board?(pos) && !@board.occupied?(pos)
  end

  def pawn_can_attack(pos)
    @board.on_board?(pos) &&
    @board.occupied?(pos) &&
    @board.piece_at(pos).color != self.color
  end

  private

  def pos_in_front(ref_pos)
    [ref_pos.first + move_dir, ref_pos.last]
  end

  def capture_positions
    [[@pos.first + move_dir, @pos.last + 1],
    [@pos.first + move_dir, @pos.last - 1]]
  end

end
