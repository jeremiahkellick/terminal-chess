require_relative "board"
require_relative "display"

class Game
  def initialize
    @board = Board.new
    @display = Display.new(@board)
    @assist_mode = true
  end

  def play
    until [:white, :black].any? { |color| @board.checkmate?(color) }
      selected_pos = nil
      until selected_pos
        @display.render
        input = @display.cursor.get_input
        if input.is_a?(Array) && !@board[input].null? && !@board[input].valid_moves.empty?
          selected_pos = input
        end
      end
      @display.highlighted = @board[selected_pos].valid_moves if @assist_mode
      piece = @board[selected_pos]
      move_to_pos = nil
      until move_to_pos
        @display.render
        input = @display.cursor.get_input
        move_to_pos = input if input.is_a?(Array) && piece.valid_moves.include?(input)
      end
      @board.move_piece(selected_pos, move_to_pos)
      @display.highlighted = []
    end
    @display.render
    puts @board.checkmate?(:white) ? "Black wins!" : "White wins!"
  end
end

if __FILE__ == $PROGRAM_NAME
  Game.new.play
end
