require_relative "Board"
require_relative "Move"

module MovesToString
	def print_moves
		self.each { |i| puts i.to_s }
	end
end
Array.send(:include, MovesToString)

promotion_test_board = [
	[-4, -2, -3, -5, -6, 0, -2, -4],
	[-1, 1, -1, -1, -1, 1, -1, -1],
	[0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0],
	[1, 1, 1, 1, 1, 1, -1, 1],
	[4, 2, 3, 5, 6, 3, 0, 4]
]

promotion_test = Board.new(board_data: promotion_test_board)

promotion_test.move("11005").board_visualization