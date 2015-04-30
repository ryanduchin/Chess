require "colorize"

class Board
  attr_accessor :removed_pieces, :grid, :cursor, :start_cursor, :messages

  def initialize(seed = false)
    @grid = Array.new(8) { Array.new(8) }
    @removed_pieces = {:black => [], :white => []}
    initialize_pieces if seed
    @cursor = [6,3]
    @start_cursor = nil
    @messages = []

  end

  def [](pos)
    @grid[pos.first][pos.last]
  end

  def []=(pos, piece)
    @grid[pos.first][pos.last] = piece
  end

  def deep_dup
    new_board = Board.new

    @grid.each do |row|
      row.compact.each do |piece|
        new_piece = piece.deeper_dup(new_board)
        new_board[new_piece.pos] = new_piece
      end
    end

    new_board
  end

  def checkmate?(color)
    return false if !in_check?(color)
    @grid.flatten.compact.all? do |piece|
      if piece.color == color
        piece.valid_moves.empty?
      else
        true
      end
    end
  end

  def stalemate?(color)
    @grid.flatten.compact.all? do |piece|
      if piece.color == color
        piece.valid_moves.empty?
      else
        true
      end
    end
  end

  def valid_start?(start, color)
    unless occupied?(start)
      raise InvalidMoveError.new("No piece at start position")
    end
    piece = self[start]
    unless piece.color == color
      raise InvalidMoveError.new("Not your color!")
    end
  end

  def move(start, end_pos, color)
    piece = self[start]
    unless piece.moves.include?(end_pos)
      raise InvalidMoveError.new("Piece can't move there")
    end

    if piece.valid_moves.include?(end_pos)
      move!(start, end_pos, color)
    else
      raise InvalidMoveError.new("invalid move")
    end
  end

  def move!(start, end_pos, color)
    piece = self[start]
    piece.pos = end_pos
    self[start] = nil
    defeated_piece = self[end_pos]
    if defeated_piece
      @removed_pieces[defeated_piece.color] << defeated_piece.symbol
    end
    self[end_pos] = piece
    piece.moved = true
  end

  def on_board?(pos)
    pos.first.between?(0,7) &&
    pos.last.between?(0,7)
  end

  def occupied?(pos)
    !!self[pos]
  end

  def piece_at(pos)
    self[pos]
  end


  def in_check?(color)
    @grid.flatten.compact.each do |piece|
      if piece.color != color
        return true if piece.moves.include?(king_position(color))
      end
    end

    false
  end

  def king_position(color)
    @grid.flatten.each do |piece|
      if piece.is_a?(King) && piece.color == color
        return piece.pos
      end
    end

    raise MissingPieceError.new("#{color} King is missing!")
  end

  def render
    system 'clear'
    puts
    removed_pieces[:white].each {|piece| print piece}
    puts; print_grid; puts
    removed_pieces[:black].each {|piece| print piece}
    puts
    @messages.each { |message| puts message }
    @messages = [@messages[0]]
  end

  private

  def print_grid
    square_color = :black

    @grid.each_with_index do |row, rindex|
      print "#{8-rindex}: "
      row.each_with_index do |piece, cindex|
        item = piece ? piece.symbol : " "
        print (item + " ")
          .colorize(:background =>
            (background_color(rindex, cindex) || square_color))
        square_color = switch_color(square_color)
      end
      print "\n"
      square_color = switch_color(square_color)
    end

    print "   "
    ('a'..'h').each { |el| print el + " " }
  end

  def background_color(rindex, cindex)
    if @cursor == [rindex, cindex]
      :white
    elsif @start_cursor == [rindex, cindex]
      :green
    end
  end

  def switch_color(square_color)
    square_color == :black ? :yellow : :black
  end

  def initialize_pieces
    8.times do |col|
      @grid[1][col] = Pawn.new(:black, [1, col], self)
      @grid[6][col] = Pawn.new(:white, [6, col], self)
    end

    @grid[0][0] = Rook.new(:black, [0, 0], self)
    @grid[0][1] = Knight.new(:black, [0, 1], self)
    @grid[0][2] = Bishop.new(:black, [0, 2], self)
    @grid[0][3] = Queen.new(:black, [0, 3], self)
    @grid[0][4] = King.new(:black, [0, 4], self)
    @grid[0][5] = Bishop.new(:black, [0, 5], self)
    @grid[0][6] = Knight.new(:black, [0, 6], self)
    @grid[0][7] = Rook.new(:black, [0, 7], self)
    @grid[7][0] = Rook.new(:white, [7, 0], self)
    @grid[7][1] = Knight.new(:white, [7, 1], self)
    @grid[7][2] = Bishop.new(:white, [7, 2], self)
    @grid[7][3] = Queen.new(:white, [7, 3], self)
    @grid[7][4] = King.new(:white, [7, 4], self)
    @grid[7][5] = Bishop.new(:white, [7, 5], self)
    @grid[7][6] = Knight.new(:white, [7, 6], self)
    @grid[7][7] = Rook.new(:white, [7, 7], self)
  end
end
