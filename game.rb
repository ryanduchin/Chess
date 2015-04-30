require_relative 'piece.rb'
require_relative 'sliding_piece.rb'
require_relative 'stepping_piece.rb'
require_relative 'pawn.rb'
require_relative 'board.rb'
require_relative 'errors.rb'
require_relative 'keypress.rb'
require_relative 'players.rb'
require 'colorize'

class Game

  def initialize(player1 = HumanPlayer.new("Ryan"), player2 = HumanPlayer.new("Dan"))
    @player1, @player2 = player1, player2
    @player1.color = :white
    @player2.color = :black
    @current_player = player1
    @board = Board.new(true)
    @over_message = ''
  end

  def play
    @board.render
    until over?

      if @board.in_check?(@current_player.color)
        puts "You are in check!!!".red
      end

      if @current_player.is_a?(HumanPlayer)
        execute_move
      else
        computer_execute_move
      end
      @current_player = other_player
    end

    @board.render
    puts "#{@over_message}! #{other_player.name} wins!"
  end


  private

  def display_player
    name = @current_player.name
    color = @current_player.convert_color
    @board.messages[0] = "#{name} (#{color}): enter move"
  end

  def execute_move
    begin
      display_player

      move_start = cursor_input.dup
      @board.valid_start?(move_start, @current_player.color)
      @board.start_cursor = @board.cursor.dup

      move_end = cursor_input.dup
      @board.start_cursor = nil
      @board.move(move_start, move_end, @current_player.color)

    rescue InvalidMoveError => e
      @board.messages << e.message
      retry
    rescue InputError => e
      @board.messages << e.message
      retry
    rescue NotImplementedError => e
      @board.messages << e.message
    rescue MissingPieceError => e
      @board.messages << e.message
    end
  end

  def computer_execute_move
    #Later: iterate through pieces, if any can check or checkmate, do
    #Later: iterate again, if any can take a piece, randomly do one of them
    #choose random piece, choose random move (Only this implemented)

    #computer crashes if playing itself, not sure why
    #possibly due to checking off-board potential moves?
    computer_pieces = @board.grid.flatten.compact.select do |piece|
      piece.color == @current_player.color
    end
    loop do
      piece = computer_pieces.sample
      start_pos = piece.pos.dup
      end_pos = piece.valid_moves.sample
      restore_cursor = @board.cursor
      if end_pos
        sleep 0.05
        @board.start_cursor = piece.pos
        @board.render
        sleep 0.04
        @board.cursor = end_pos
        @board.render
        sleep 0.04
        @board.start_cursor = nil
        @board.cursor = restore_cursor
        @board.move(start_pos, end_pos, @current_player.color)
        @board.messages << "Computer moves #{piece.symbol} from #{convert_pos(start_pos)} to #{convert_pos(end_pos)}"
        return
      end
    end
  end

  def convert_pos(pos)
    row = (8 - pos.first).to_s
    col = ('a'..'h').to_a[pos.last]
    row + col
  end

  def other_player
    @current_player == @player1 ? @player2 : @player1
  end

  def over?
    if @board.checkmate?(@current_player.color)
      @over_message = "Checkmate"
      true
    elsif
      @board.stalemate?(@current_player.color)
      @over_message = "Stalemate"
      true
    end
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


g = Game.new(ComputerPlayer.new("Ryan"), ComputerPlayer.new("Hal"))
# g = Game.new
g.play
