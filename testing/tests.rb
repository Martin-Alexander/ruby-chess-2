require_relative "../classes/ChessBoard"
require_relative "../classes/ChessMove"

def board_visualization(chess_board)
  if !chess_board.is_a? ChessBoard
    raise ArgumentError.new "board_visualization must be passed arguement of type ChessBoard"
  end
  chess_board.board.each_with_index do |row, i|
    row.each { |square| print square < 0 ? "#{square} " : " #{square} " }
    puts
  end
end

def full_board_test(test_board, piece)
  for rank in 0..7
    for file in 0..7
      if test_board.board[rank][file].abs == piece
        test_board.legal_moves(rank, file).each { |i| p i.to_s }
      end
    end
  end
end

def single_piece_test(rank, file, test_board)
  test_board.legal_moves(rank, file).each { |i| p i.to_s }
end
