require_relative "Move"
require "byebug"

class Board
  attr_reader :ply, :board_data, :white_to_move, :castling, :en_passant

  module ChessPieces
    def piece
      if !(self.is_a? Integer)
        raise ArgumentError.new "arguement must be of type Integer"
      elsif !((-6..-1).to_a + (0..6).to_a).include? self
        raise ArgumentError.new "integer #{self} is out of range"
      end

      case self.abs
        when 6 then "king"
        when 5 then "queen"
        when 4 then "rook"
        when 3 then "bishop"
        when 2 then "knight"
        when 1 then "pawn"
        when 0 then nil
      end
    end

    def color
      if self < 0
        "black"
      elsif self > 0
        "white"
      else
        nil
      end
    end
  end

  Fixnum.send(:include, ChessPieces)

  def initialize(params = {})
    @ply = params[:ply] || 0
    @board_data = params[:board_data] || standard_board_setup
    @white_to_move = params[:white_to_move].nil? ? true : params[:white_to_move]
    @castling = params[:castling] || { white_king: true, white_queen: true, black_king: true, black_queen: true }
    @en_passant = params[:en_passant] || [[0, 0], [0, 0]]
  end

  def move(move)
    if move.is_a? String
      move = Move.new([move[0].to_i, move[1].to_i], [move[2].to_i, move[3].to_i], promotion: move[4].to_i)
    end
    legal = moves.any? do |legal_move|
      legal_move.start_square == move.start_square &&
      legal_move.end_square == move.end_square
    end
    if legal
      new_board_data = execute_move(@board_data, move)
      new_board = Board.new(ply: @ply + 1, board_data: new_board_data, white_to_move: !@white_to_move, castling: @castling.dup, en_passant: @en_passant.dup)
      new_board = castling_update(new_board, move)
    end
    return new_board
  end

  def moves
    output = []
    each_square do |rank, file|
      if right_color?(rank, file) 
        naive_moves = naive_moves(rank, file, @board_data, @castling)
        if !naive_moves.nil?
          naive_moves.each do |naive_move|
            if king_safe?(naive_move)
              output << naive_move
            end
          end
        end
      end
    end
    return output
  end

  def board_visualization
    @board_data.each_with_index do |row, i|
      row.each { |square| print square < 0 ? "#{square} " : " #{square} " }
      puts
    end
  end

  private

  def castling_update(board, move)
    castling_data = board.castling
    if move.start_square == [7, 4]
      castling_data[:white_king] = false 
      castling_data[:white_queen] = false
    elsif move.start_square == [0, 4]
      castling_data[:black_king] = false
      castling_data[:black_queen] = false
    elsif move.start_square == [7, 7] || move.end_square == [7, 7]
      castling_data[:white_king] = false
    elsif move.start_square == [7, 0] || move.end_square == [7, 0]
      castling_data[:white_queen] = false
    elsif move.start_square == [0, 0] || move.end_square == [0, 0]
      castling_data[:black_queen] = false
    elsif move.start_square == [0, 7] || move.end_square == [0, 7]
      castling_data[:black_king] = false
    end
    return board
  end

  def execute_move(board, move)
    board_copy = board.map { |i| i.dup }
    if board_copy[move.start_square[0]][move.start_square[1]] == "white"
      promoted_piece = move.promotion
    else 
      promoted_piece = move.promotion * -1
    end
    piece_on_arrival = move.promotion.zero? ? board_copy[move.start_square[0]][move.start_square[1]] : promoted_piece
    board_copy[move.end_square[0]][move.end_square[1]] = piece_on_arrival
    board_copy[move.start_square[0]][move.start_square[1]] = 0
    if move.start_square == [7, 4] && move.end_square == [7, 6]
        board_copy[7][7] = 0
        board_copy[7][5] = 4
    elsif move.start_square == [7, 4] && move.end_square == [7, 2]
        board_copy[7][0] = 0
        board_copy[7][4] = 4
    elsif move.start_square == [0, 4] && move.end_square == [0, 6]
        board_copy[0][7] = 0
        board_copy[0][5] = -4
    elsif move.start_square == [0, 4] && move.end_square == [0, 2]
        board_copy[0][0] = 0
        board_copy[0][3] = -4
    end
    return board_copy
  end

  def naive_moves(rank, file, board, castling)
    case board[rank][file].abs
      when 1 then naive_pawn_moves(rank, file, board)
      when 2 then naive_knight_moves(rank, file, board)
      when 3 then naive_bishop_moves(rank, file, board)
      when 4 then naive_rook_moves(rank, file, board)
      when 5 then naive_queen_moves(rank, file, board)
      when 6 then naive_king_moves(rank, file, board, castling)
    end
  end

  def find_king(board)
    right_color = @white_to_move ? "white" : "black"
    output = nil
    each_square do |rank, file|
      if !board[rank][file].zero? &&
        board[rank][file].piece == "king" &&
        board[rank][file].color == right_color
        output = [rank, file]
        break
      end
    end
    return output
  end

  def right_color?(rank, file)
    right_color = @white_to_move ? "white" : "black"
    @board_data[rank][file].color == right_color
  end

  def king_safe?(move)
    right_color = @white_to_move ? "black" : "white"
    test_board = execute_move(@board_data, move)
    king_location = find_king(test_board)
    safety = true
    catch :king_safety do
      if local_threats_to_king?(test_board, king_location[0], king_location[1])
        safety = false
        throw :king_safety
      end
      each_square do |rank, file|
        if ["rook", "bishop", "queen"].include?(test_board[rank][file].piece) &&
          test_board[rank][file].color == right_color
          naive_moves(rank, file, test_board, {}).each do |enemy_move|
            if enemy_move.end_square == king_location
              safety = false
              throw :king_safety
            end
          end
        end
      end
    end
    return safety
  end

  def local_threats_to_king?(board, rank, file)
    threat = false
    catch :king_safety do
      if @white_to_move
        king_color = "white"
        pawns = [[rank - 1, file - 1], [rank - 1, file + 1]]
      else
        king_color = "black"
        pawns = [[rank + 1, file - 1], [rank + 1, file + 1]]
      end

      pawns.each do |i|
        if board[i[0]] && board[i[0]][i[1]] &&
          board[i[0]][i[1]].piece == "pawn" &&
          board[i[0]][i[1]].color != king_color
          threat = true
          throw :king_safety
        end
      end

      knights = [
        [rank - 2, file + 1], [rank - 1, file + 2], [rank + 1, file + 2], [rank + 2, file + 1],
        [rank + 2, file - 1], [rank + 1, file - 2], [rank - 1, file - 2], [rank - 2, file - 1]
      ]

      knights.each do |i|
        if i[0] > 0 && i[1] > 0 &&
          board[i[0]] && board[i[0]][i[1]] &&
          board[i[0]][i[1]].piece == "knight" &&
          board[i[0]][i[1]].color != king_color
          threat = true
          throw :king_safety
        end
      end
    end
    return threat
  end

  def valid_pieces(pieces_array)
    pieces_array.length == 8 && pieces_array.all? { |i| i.length == 8 }
  end

  def valid_castling_hash(castling_hash)
    castling_hash.length == 4 &&
    !!castling_hash[:white_king] == castling_hash[:white_king] &&
    !!castling_hash[:white_queen] == castling_hash[:white_queen] &&
    !!castling_hash[:black_king] == castling_hash[:black_king] &&
    !!castling_hash[:black_queen] == castling_hash[:black_queen]
  end

  def valid_en_passant(en_passant_array)
    en_passant_array.length == 2 && en_passant_array.all? { |i| i.length == 2}
    # TODO: Make more robust en passant validation using game logic
  end

  def standard_board_setup
    [
      [-4, -2, -3, -5, -6, -3, -2, -4],
      [-1, -1, -1, -1, -1, -1, -1, -1],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [1, 1, 1, 1, 1, 1, 1, 1],
      [4, 2, 3, 5, 6, 3, 2, 4]
    ]
  end

  def naive_pawn_moves(rank, file, board)
    output = []
    piece = board[rank][file]
    v_direction = piece > 0 ? -1 : 1
    if !board[rank + 1 * v_direction].nil? &&
      board[rank + 1 * v_direction][file].zero? &&
      output << pawn_move_builder([rank, file], [rank + 1 * v_direction, file], piece)
      if !board[rank + 2 * v_direction].nil? &&
        board[rank + 2 * v_direction][file].zero? &&
        ((rank == 1 && piece.color == "black") || (rank == 6 && piece.color == "white"))
        output << pawn_move_builder([rank, file], [rank + 2 * v_direction, file], piece)
      end
    end
    if !board[rank + 1 * v_direction].nil? &&
      !board[rank + 1 * v_direction][file - 1].nil? &&
      !(board[rank + 1 * v_direction][file - 1]).zero? &&
      piece.color != board[rank + 1 * v_direction][file - 1].color
      output << pawn_move_builder([rank, file], [rank + 1 * v_direction, file - 1], piece)
    end
    if !board[rank + 1 * v_direction].nil? &&
      !board[rank + 1 * v_direction][file + 1].nil? &&
      !(board[rank + 1 * v_direction][file + 1]).zero? &&
      piece.color != board[rank + 1 * v_direction][file + 1].color
      output << pawn_move_builder([rank, file], [rank + 1 * v_direction, file + 1], piece)
    end
    remove_out_of_bounds(output.flatten)
  end

  def pawn_move_builder(start_square, end_square, piece)
    output = []
    if piece.color == "white" && end_square[0] == 0
      [2, 3, 4, 5].each { |i| output << Move.new(start_square, end_square, promotion: i) } 
    elsif piece.color == "black" && end_square[0] == 7
      [2, 3, 4, 5].each { |i| output << Move.new(start_square, end_square, promotion: i) }
    else 
      output << Move.new(start_square, end_square)
    end
    return output
  end

  def naive_king_moves(rank, file, board, castling)
    output = []
    piece = board[rank][file]
    [-1, 0, 1].each do |rank_inc|
      [-1, 0, 1].each do |file_inc|
        if !(rank_inc.zero? && file_inc.zero?) &&
          !board[rank + rank_inc].nil? && !board[rank + rank_inc][file + file_inc].nil? &&
          !(piece.color == board[rank + rank_inc][file + file_inc].color)
          output << Move.new([rank, file], [rank + rank_inc, file + file_inc])
        end
      end
    end
    if piece.color == "white"
      if castling[:white_king] && board[7][5].zero? && board[7][6].zero?
        output << Move.new([rank, file], [7, 6])
      end
      if castling[:white_queen] && board[7][3].zero? && board[7][2].zero? && board[7][1].zero?
        output << Move.new([rank, file], [7, 2])
      end
    else
      if castling[:black_king] && board[0][5].zero? && board[0][6].zero?
        output << Move.new([rank, file], [0, 6])
      end
      if castling[:black_queen] && board[0][3].zero? && board[0][2].zero? && board[0][1].zero?
        output << Move.new([rank, file], [0, 2])
      end
    end
    remove_out_of_bounds(output)
  end

  def naive_knight_moves(rank, file, board)
    output = []
    piece = board[rank][file]
    [[-2, 1], [-1, 2], [1, 2], [2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1]].each do |i|
      if !board[rank + i[0]].nil? &&
        !board[rank + i[0]][file + i[1]].nil? &&
        (board[rank + i[0]][file + i[1]].zero? ||
        piece.color != board[rank + i[0]][file + i[1]].color)
        output << Move.new([rank, file], [rank + i[0], file + i[1]])
      end
    end
    remove_out_of_bounds(output)
  end

  def naive_rook_moves(rank, file, board)
    output = []
    variables = [[-1, 0, rank], [1, 0, 7 - rank], [0, -1, file], [0, 1, 7 - file]]
    variables.each { |i| move_along(i[0], i[1], i[2], rank, file, output, board) }
    return output
  end

  def naive_bishop_moves(rank, file, board)
    output = []
    variables = [
      [-1, 1, [rank, 7 - file].min],
      [-1, -1, [rank, file].min],
      [1, -1, [7 - rank, file].min],
      [1, 1, [7 - rank, 7 - file].min]
    ]
    variables.each { |i| move_along(i[0], i[1], i[2], rank, file, output, board) }
    return output
  end

  def naive_queen_moves(rank, file, board)
    output = []
    output << naive_rook_moves(rank, file, board)
    output << naive_bishop_moves(rank, file, board)
    return output.flatten
  end


  def move_along (rank_mod, file_mod, sequence_builder, rank, file, output, board)
    piece = board[rank][file]
    (1..sequence_builder).each do |increment|
      move = Move.new([rank, file], [rank + increment * rank_mod, file + increment * file_mod])
      if board[rank + increment * rank_mod][file + increment * file_mod].zero?
        output << move
      elsif board[rank + increment * rank_mod][file + increment * file_mod].color != piece.color
        output << move
        break
      else
        break
      end
    end
  end

  def each_square
    (0..7).each do |rank|
      (0..7).each do |file|
        yield(rank, file)
      end
    end
  end

  def remove_out_of_bounds(output)
    output.select { |i| i.in_bounds }
  end
end
