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

castling_test_board = [
	[-4, -2, -3, -5, -6, -3, -2, -4],
	[-1, -1, -1, -1, -1, -1, -1, -1],
	[0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0],
	[1, 1, 1, 1, 1, 1, 1, 1],
	[4, 2, 3, 5, 6, 0, 0, 4]
]

castling_test = Board.new(board_data: castling_test_board)

castling_test.board_visualization

p castling_test.moves[-3]