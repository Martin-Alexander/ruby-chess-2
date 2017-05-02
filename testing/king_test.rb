require_relative "tests"

king_test_setup = [
  [-6, 0, 0, 0, 0, 0, 0, 0],
  [1, 1, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, -1, -1, 1, 0, 0, 0],
  [0, 0, 1, 6, 0, 0, 0, 0],
  [0, 0, 1, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0]
]

king_board = ChessBoard.new(
  board: king_test_setup,
  white_to_move: true,
  castling: {
    white_king: false,
    white_queen: false,
    black_king: false,
    black_queen: false
  }
)

board_visualization(king_board)

full_board_test(king_board, 6)
