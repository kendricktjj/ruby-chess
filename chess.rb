# Data structure representing a single square on the chess board
class BoardSquare
  attr_accessor :row, :col, :occupant
  
  def initialize
    @row = -1
    @col = -1
    @occupant = nil
  end
end

# Data structure representing a single chess piece
# playerID : White = 1, Black = 2
# type: 1 = pawn, 2 = rook, 3 = knight, 4 = bishop, 5 = king, 6 = queen
class ChessPiece
  attr_accessor :type, :playerID, :number, :row, :col, :possible_moves, :alive
  
  def initialize
    @type = -1
    @playerID = -1
    @number = -1 # TODO might not be used
    @row = -1
    @col = -1
    @possible_moves = []
    @alive = true
  end
end

# Class representing a fully playable chess game
class Chess
  attr_accessor :board, :pawns, :rooks, :knights, :bishops, :kings, :queens
  
  def initialize
    @current_player = 1
    @board = []
    @pawns = []
    @rooks = []
    @knights = []
    @bishops = []
    @kings = []
    @queens = []
    
    initialize_board
    initialize_chess_pieces
    set_initial_locations
    #@board[6][7].occupant = nil # TODO REMOVE
    calculate_possible_moves
    
    #@rooks.each do |rook|
    #  puts "#{rook.possible_moves}"
    #end
  end
  
  # Initializes the game board
  def initialize_board
    8.times do
      temp = []
      8.times do
        temp += Array(BoardSquare.new)
      end
      
      @board << Array(temp)
    end
  end
  
  # Initializes all the chess pieces
  def initialize_chess_pieces
    temp = []
    num_times = -1
    half = -1
    (1..6).each do |i|
      if(i == 1)
        num_times = 16
        half = 8
      elsif(i > 1 && i < 5)
        num_times = 4 
        half = 2
      elsif(i == 5 || i == 6)
        num_times = 2 
        half = 1
      end
      
      initialize_piece_array(i, num_times, half)
    end
  end
  
  # Helper method used to initialize all the chess pieces
  def initialize_piece_array(type, num_times, half)
    
    num_times.times do |i|
      tempPiece = ChessPiece.new
    
      tempPiece.type = type
      
      # The 1st half of the array consists of white pieces, black for the 2nd half 
      if(i < half)
        tempPiece.playerID = 1
      elsif(i >= half)
        tempPiece.playerID = 2 
      end
      
      case type
        when 1
          @pawns += Array(tempPiece)
        when 2
          @rooks += Array(tempPiece)
        when 3
          @knights += Array(tempPiece)
        when 4
          @bishops += Array(tempPiece)
        when 5
          @kings += Array(tempPiece)
        when 6
          @queens += Array(tempPiece)
      end
      
    end
  end
  
  # Places each chess piece in its respective starting position at the beginning of the game
  def set_initial_locations
    # Pawns
    @pawns.each_with_index do |pawn, index|
      row = -1
      col = -1
      
      # White then black
      if(index < 8)
        row = 6
        col = index
      elsif(index >= 8)
        row = 1 
        col = index - 8
      end
      
      @board[row][col].occupant = @pawns[index]
      @pawns[index].row = row
      @pawns[index].col = col
    end
    
    # Rooks, knights, bishops, kings, queens
    (2..6).each do |i|
      initial_location_helper(i)
    end
  end
  
  # Helper method used to set the initial locations of the chess pieces
  def initial_location_helper(type)
    temp_arr = []
    row = -1
    col = -1
    col_1 = -1
    col_2 = -1
    
    case type
      when 2
        temp_arr = @rooks
        col_1 = 0
        col_2 = 7
      when 3
        temp_arr = @knights
        col_1 = 1
        col_2 = 6
      when 4
        temp_arr = @bishops
        col_1 = 2
        col_2 = 5
      when 5
        temp_arr = @kings
        col_1 = 4
      when 6
        temp_arr = @queens
        col_1 = 3
    end
    
    temp_arr.each_with_index do |piece, index|
      
      # White then black
      if(index == 0)
        row = 7
        col = col_1
      elsif(index == 1)
        row = 7 
        col = col_2
        if(type == 5 || type == 6)
          row = 0 
          col = col_1
        end
      elsif(index == 2)
        row = 0 
        col = col_1
      elsif(index == 3)
        row = 0 
        col = col_2
      end
      
      @board[row][col].occupant = temp_arr[index]
      temp_arr[index].row = row
      temp_arr[index].col = col
    end
    
  end
  
  # Calculates all possible moves for all chess pieces on the board
  def calculate_possible_moves
    calculate_pawn_moves
    calculate_rook_moves
  end
  
  # Calculates all possible moves for all the pawns on the chess board
  def calculate_pawn_moves
    @pawns.each_with_index do |pawn, index|
      # Does not calculate moves if the piece has been captured
      next if(!@pawns[index].alive)
      
      row = @pawns[index].row
      col = @pawns[index].col
      
      # White
      if(index < 8)
        # Forward
        @pawns[index].possible_moves << [row - 1, col] if(row > 0 && @board[row - 1][col].occupant == nil)
        # 2x Forward
        @pawns[index].possible_moves << [row - 2, col] if(row == 6 && @board[row - 2][col].occupant == nil)
        # Capture left
        @pawns[index].possible_moves << [row - 1, col - 1] if(row > 0 && col > 0 && @board[row - 1][col - 1].occupant != nil && @board[row - 1][col - 1].occupant.playerID == 2)
        # Capture right
        @pawns[index].possible_moves << [row - 1, col + 1] if(row > 0 && col < 7 && @board[row - 1][col + 1].occupant != nil && @board[row - 1][col + 1].occupant.playerID == 2)
      # Black
      elsif(index >= 8)
        # Forward
        @pawns[index].possible_moves << [row + 1, col] if(row < 7 && @board[row + 1][col].occupant == nil)
        # 2x Forward
        @pawns[index].possible_moves << [row + 2, col] if(row == 1 && @board[row + 2][col].occupant == nil)
        # Capture left
        @pawns[index].possible_moves << [row + 1, col - 1] if(row < 7 && col > 0 && @board[row + 1][col - 1].occupant != nil && @board[row + 1][col - 1].occupant.playerID == 1)
        # Capture right
        @pawns[index].possible_moves << [row + 1, col + 1] if(row < 7 && col < 7 && @board[row + 1][col + 1].occupant != nil && @board[row + 1][col + 1].occupant.playerID == 1)
      end
    end
  end
  
  # Calculates all possible moves for all the rooks on the chess board
  def calculate_rook_moves
    @rooks.each_with_index do |rook, index|
      next if(!@rooks[index].alive)
      
      row = @rooks[index].row
      col = @rooks[index].col
      
      # ULDR until an occupied square is reached
      # Do color check there
      # Up
      while(row > 0)
        @rooks[index].possible_moves << [row - 1, col] if(@board[row - 1][col].occupant == nil)
        if(@board[row - 1][col].occupant != nil)
          case @rooks[index].playerID
            when 1
              @rooks[index].possible_moves << [row - 1, col] if(@board[row - 1][col].occupant.playerID == 2)
            when 2
              @rooks[index].possible_moves << [row - 1, col] if(@board[row - 1][col].occupant.playerID == 1)
          end
          
          # Stop once an occupied square has been reached
          break
        end
        row -= 1
      end
      
    end
  end
  
  # Helper method used to calculate the possible moves of each rook in the UDLR directions
  def rook_direction_helper(direction)
    row_modifier = 0
    col_modifier = 0
    
    case direction
      when "U"
      
      when "D"
      
      when "L"
      
      when "R"
    end
    
    while(row > 0)
      @rooks[index].possible_moves << [row - 1, col] if(@board[row - 1][col].occupant == nil)
      if(@board[row - 1][col].occupant != nil)
        case @rooks[index].playerID
          when 1
            @rooks[index].possible_moves << [row - 1, col] if(@board[row - 1][col].occupant.playerID == 2)
          when 2
            @rooks[index].possible_moves << [row - 1, col] if(@board[row - 1][col].occupant.playerID == 1)
        end

        # Stop once an occupied square has been reached
        break
      end
      row -= 1
    end
  end
  
  # Calculates all possible moves for all the knights on the chess board
  def calculate_knight_moves
  end
  
  # Calculates all possible moves for all the bishops on the chess board
  def calculate_bishop_moves
  end
  
  # Calculates all possible moves for the kings on the chess board
  def calculate_king_moves
  end
  
  # Calculates all possible moves for the queens on the chess board
  def calculate_queen_moves
  end
  
  # Prompts the current player for a move
  def prompt
  
  end
  
  # Performs a check to see if the specified player's king is under check or checkmate status
  def checkmate_status(player)
    
  end
  
  # Saves the current game state
  def save_game
  end
  
  # Loads a previous saved game state
  def load_game
  end
  
  # Runs the entire chess game
  def run
    
  end
  
  # Prints out the current board state onto the console
  def display_board
    # Print x-axis grid markings
    8.times do |i|
      print "   (#{i})  "
    end
    puts ""
    
    # Print top border
    print_border
    
    8.times do |row|
      # Print 1st line
      print_blank_line
      
      # Print 2nd line
      8.times do |col|
        # Blank if no occupant, otherwise fetch the unicode string of the occupant
        occupant = " "
        occupant = get_chesspiece_unicode(@board[row][col].occupant.playerID, @board[row][col].occupant.type) if(@board[row][col].occupant != nil)
        print "|"
        print "   #{occupant}   "
      end
      print "|"
      
      # Print y-axis grid markings
      puts " (#{row})"
      
      # Print 3rd line
      print_blank_line
      
      # Print bottom border
      print_border();
      
    end
    
  end
  
  # Helper method that returns the unicode string of the specified chess piece
  def get_chesspiece_unicode(color, type)
    case color
      # White
      when 1
        case type
          when 1
            return "\u2659"
          when 2
            return "\u2656"
          when 3
            return "\u2658"
          when 4
            return "\u2657"
          when 5
            return "\u2654"
          when 6
            return "\u2655"
        end
      # Black
      when 2
        case type
          when 1
            return "\u265F"
          when 2
            return "\u265C"
          when 3
            return "\u265E"
          when 4
            return "\u265D"
          when 5
            return "\u265A"
          when 6
            return "\u265B"
        end
    end
  end
  
  # Prints the top/bottom border of the board
  def print_border
    65.times do
      print "*"
    end
    puts ""
  end
    
  # Prints a blank line on the board
  def print_blank_line
    8.times do
      print "|       "
    end
    puts "|"
  end
end

c = Chess.new
c.display_board