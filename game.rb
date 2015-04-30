require_relative 'piece.rb'
require_relative 'sliding_piece.rb'
require_relative 'stepping_piece.rb'
require_relative 'pawn.rb'
require_relative 'board.rb'
require_relative 'errors.rb'
require_relative 'keypress.rb'
require_relative 'players.rb'
require 'colorize'

require 'byebug'

class Game
  attr_accessor :over_message
  attr_reader :current_player, :board

  def initialize(player1 = HumanPlayer.new("Dan"), player2 = HumanPlayer.new("Ryan"))
    @player1, @player2 = player1, player2
    @player1.color = :white
    @player2.color = :black
    @current_player = player1
    @board = Board.new(true)
    @over_message = ''
  end

  def play
    board.render
    until over?

      if board.in_check?(current_player.color)
        puts "You are in check!!!".red
      end

      if current_player.is_a?(HumanPlayer)
        execute_move
      else
        computer_execute_move
      end

      end_of_turn
    end

    board.render
    puts "#{@over_message}! #{other_player.name} wins!"
  end


  private

  def end_of_turn
    @board.pawn_to_queen_check
    @current_player = other_player
    @board.error_messages = []
  end

  def execute_move
    begin
      display_player

      move_start = cursor_input.dup
      board.valid_start?(move_start, current_player.color)
      board.start_cursor = board.cursor.dup

      move_end = cursor_input.dup
      board.start_cursor = nil
      # debugger
      start_piece = board.pieces.select { |piece| piece.pos == move_start}.first
      end_piece = board.pieces.select { |piece| piece.pos == move_end}.first

      board.move(move_start, move_end, current_player.color)

      update_status_message(move_start, move_end, start_piece, end_piece)

    rescue InvalidMoveError => e
      board.error_messages << e.message
      retry
    rescue InputError => e
      board.error_messages << e.message
      retry
    rescue NotImplementedError => e
      board.error_messages << e.message
    rescue MissingPieceError => e
      board.error_messages << e.message
    end
  end

  def display_player
    name = current_player.name
    color = current_player.convert_color
    board.turn_message = "#{name} (#{color})'s turn"
  end

  def computer_execute_move
    #choose random piece, choose random move (Only this implemented)
    #Later: iterate through pieces, if any can check or checkmate, do
    #Later: iterate again, if any can take a piece, randomly do one of them

    display_player
    cursor_start = board.cursor

    computer_pieces = board.grid.flatten.compact.select do |piece|
      piece.color == current_player.color
    end
    loop do
      piece = computer_pieces.sample
      start_pos = piece.pos.dup
      end_pos = piece.valid_moves.sample
      if end_pos
        cursor_delay(start_pos, end_pos)
        board.cursor = cursor_start

        board.move(start_pos, end_pos, current_player.color)
        update_status_message(start_pos, end_pos, piece)
        return
      end
    end
  end

  def cursor_delay(start_pos, end_pos)
    x = 0.001
    sleep x
    @board.start_cursor = start_pos
    @board.render
    sleep 2*x
    @board.cursor = end_pos
    @board.render
    sleep 2*x
    @board.start_cursor = nil
  end

  def convert_pos(pos)
    row = (8 - pos.first).to_s
    col = ('a'..'h').to_a[pos.last]
    row + col
  end

  def other_player
    current_player == @player1 ? @player2 : @player1
  end

  def over?
    if @board.checkmate?(current_player.color)
      @over_message = "Checkmate"
      true
    elsif
      @board.stalemate?(current_player.color)
      @over_message = "Stalemate"
      true
    end
  end

  def update_status_message(start_pos, end_pos, piece, captured_piece)
    @board.status_message = ("#{current_player.name} " +
                        (captured_piece ? "captures with " : "moves ") +
                        "#{piece.symbol} " +
                        "from #{convert_pos(start_pos)} " +
                        "to #{convert_pos(end_pos)}")
  end


  def cursor_input
    loop do
      @board.render
      case show_single_key
      when "UP ARROW"
        @board.cursor[0] -= 1 unless @board.cursor[0] <= 0
      when "DOWN ARROW"
        @board.cursor[0] += 1 unless @board.cursor[0] >= 7
      when "LEFT ARROW"
        @board.cursor[1] -= 1 unless @board.cursor[1] <= 0
      when "RIGHT ARROW"
        @board.cursor[1] += 1 unless @board.cursor[1] >= 7
      when "RETURN"
        return @board.cursor
      end
    end
  end
end


# g = Game.new(ComputerPlayer.new("Ryan"), ComputerPlayer.new("Hal"))
# g = Game.new(ComputerPlayer.new("Hal"))
g = Game.new
g.play
