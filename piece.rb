class Piece
  attr_reader :color
  attr_accessor :pos, :moved, :board

  def initialize(color, pos, board, moved = false)
    @color = color
    @pos = pos
    @board = board
    @moved = moved
    @type = self.class
  end

  def convert_color(color)
    color == :black ? :light_blue : :red
  end

  def deeper_dup(new_board)
    self.class.new(color, pos.dup, new_board, moved)
  end

  def move_into_check?(end_pos)
    dup_board = board.deep_dup
    dup_board.move!(pos, end_pos, color)
    dup_board.in_check?(color)
  end

  def valid_moves
    moves.reject {|end_pos| move_into_check?(end_pos)}
  end

  def moves
    raise NotImplementedError.new("moves method not implemented")
  end

  def symbol
    raise NotImplementedError.new("symbol method not implemented")
  end

end
