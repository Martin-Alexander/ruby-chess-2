require_relative "tests"

pawn_test_setup = [
  [-6, 0, 0, 1, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [-1, 0, 0, 0, 0, 0, 0, 0],
  [0, 1, 0, 0, 0, 0, 0, 0],
  [1, 1, 1, 0, 0, 0, 0, 0],
  [6, 0, 0, 0, 0, 0, 0, 0]
]

pawn_board = ChessBoard.new(
  board: pawn_test_setup,
  white_to_move: true,
  castling: {
    white_king: false,
    white_queen: false,
    black_king: false,
    black_queen: false
  }
)

board_visualization(pawn_board)

full_board_test(pawn_board, 1)
