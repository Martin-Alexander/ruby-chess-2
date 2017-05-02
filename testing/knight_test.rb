require_relative "tests"

knight_test_setup = [
  [-2, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 1, 0, 0, 0, 0, 0],
  [0, -1, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 2, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [6, 0, 0, 0, 0, 0, 0, 0]
]

knight_board = ChessBoard.new(
  board: knight_test_setup,
  white_to_move: true,
  castling: {
    white_king: false,
    white_queen: false,
    black_king: false,
    black_queen: false
  }
)

board_visualization(knight_board)

full_board_test(knight_board, 2)
