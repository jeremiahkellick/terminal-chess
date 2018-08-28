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
    (0...8).each do |row|
      (0...8).each do |col|
        if @cursor.cursor_pos == [row, col]
          print @board[[row, col]].to_s.red
        else
          print @board[[row, col]]
        end
        print " "
      end
      puts
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
