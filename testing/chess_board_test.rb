require_relative "../classes/ChessBoard"

PAWN_TEST_SETUP = [
  [-6, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [-1, 0, 0, 0, 0, 0, 0, 0],
  [0, 1, 0, 0, 0, 0, 0, 0],
  [1, 1, 1, 0, 0, 0, 0, 0],
  [6, 0, 0, 0, 0, 0, 0, 0]
]

PAWN_TEST_BOARD = ChessBoard.new(
  pieces: PAWN_TEST_SETUP,
  white_to_move: true,
  castling: {
    white_king: false,
    white_queen: false,
    black_king: false,
    black_queen: false
  }
)

def board_visualization(chess_board)
  if !chess_board.is_a? ChessBoard
    raise ArgumentError.new "board_visualization must be passed arguement of type ChessBoard"
  end
  chess_board.pieces.each do |row|
    row.each { |square| print square < 0 ? "#{square} " : " #{square} " }
    puts
  end
end

