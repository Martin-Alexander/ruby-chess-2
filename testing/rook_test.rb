require_relative "tests"

rook_test_setup = [
  [0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, -1, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [0, 1, 0, 4, 0, 0, -1, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 1, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0]
]

rook_board = ChessBoard.new(
  board: rook_test_setup,
  white_to_move: true,
  castling: {
    white_king: false,
    white_queen: false,
    black_king: false,
    black_queen: false
  }
)

board_visualization(rook_board)

full_board_test(rook_board, 4)
