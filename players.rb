class Player
  attr_reader :name
  attr_accessor :color

  def initialize(name)
    @name = name
  end

  def convert_color
    @color == :black ? "blue" : "red"
  end
end

class HumanPlayer < Player
end

class ComputerPlayer < Player
end
