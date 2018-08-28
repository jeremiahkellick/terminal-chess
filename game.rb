require_relative "board"
require_relative "display"
require_relative "player"

class Game
  def initialize
    @board = Board.new
    @display = Display.new(@board)
    @players = [:white, :black].map { |color| HumanPlayer.new(color, @display) }
  end

  def switch_players!
    @players.rotate!
  end

  def current_player
    @players[0]
  end

  def play
    until [:white, :black].any? { |color| @board.checkmate?(color) }
      current_player.make_move(@board)
      switch_players!
    end
    puts @board.checkmate?(:white) ? "Black wins!" : "White wins!"
  end
end

if __FILE__ == $PROGRAM_NAME
  Game.new.play
end
