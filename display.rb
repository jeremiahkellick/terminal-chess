require "colorize"
require_relative "cursor"
require_relative "board"

class Display
  def initialize(board)
    @board = board
    @cursor = Cursor.new([0, 0], board)
  end

  def render
    system("clear")
    black = false
    (8 * 3).times do |i|
      black = !black if i % 3 == 0
      (8 * 6).times do |j|
        pos = [i / 3, j / 6]
        piece = @board[pos]
        black = !black if j % 6 == 0
        bg = black ? :black : :light_black
        bg = :red if pos == @cursor.cursor_pos
        if (i - 1) % 3 == 0 && (j - 2) % 6 == 0
          print piece.to_s.colorize(color: :cyan, background: bg)
        else
          print " ".colorize(background: bg)
        end
      end
      print " \n".colorize(background: :default)
    end
  end

  def loop
    while true
      render
      @cursor.get_input
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  board = Board.new
  display = Display.new(board)
  display.loop
end
