require_relative "board"
require_relative "display"
require_relative "player"

class Game
  def initialize(pvp = true)
    @board = Board.new(-> { get_promotion })
    @display = Display.new(@board)
    if pvp
      @players = [:white, :black].map do |color|
        HumanPlayer.new(color, @display)
      end
    else
      @players = [
        HumanPlayer.new(:white, @display),
        ComputerPlayer.new(:black, @display)
      ]
    end
  end

  def get_promotion
    current_player.get_promotion
  end

  def switch_players!
    @players.rotate!
  end

  def current_player
    @players[0]
  end

  def play
    until [:white, :black].any? { |color| @board.checkmate?(color) }
      break if @board.no_moves?(current_player.color)
      current_player.make_move(@board)
      switch_players!
    end
    @display.render(false)
    winner = @board.winner
    if winner
      puts "#{winner.capitalize} wins!"
    else
      puts "Stalemate"
    end
  end
end

class InvalidInputError < StandardError
end

if __FILE__ == $PROGRAM_NAME
  pvp = true
  begin
    puts "Would you like to play against a (h)uman or (c)omputer?"
    response = gets.chomp
    case response
    when "h"
      pvp = true
    when "c"
      pvp = false
    else
      raise InvalidInputError
    end
  rescue InvalidInputError
    puts "Invalid input"
    retry
  end
  Game.new(pvp).play
end
