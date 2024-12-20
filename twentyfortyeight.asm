.data
		.align	2
WELCOME: 	.asciiz "Main Menu:\n[1] New Game\n[2] Start from a State\n[X] Quit\n"
GRID_SIZE:	.asciiz	"Input the size of the board: \n"
BOARD_CONFIG:	.asciiz "Enter a board configuration (Invalid input = back to Main menu):\n"
INVALID_INPUT:	.asciiz "Invalid input.\n"
QUIT:		.asciiz "Program Terminated."
BORDER:      	.asciiz "+----"
CORNER:         .asciiz "+\n"
HEDGE: 		.asciiz "|"
EDGE:		.asciiz "|\n"
NUMBER_0:	.asciiz "    "
NUMBER_2:	.asciiz "  2 "
NUMBER_4:	.asciiz	"  4 "
NUMBER_8:	.asciiz "  8 "
NUMBER_16:	.asciiz " 16 "
NUMBER_32:	.asciiz " 32 "
NUMBER_64:	.asciiz " 64 "
NUMBER_128:	.asciiz " 128"
NUMBER_256:	.asciiz " 256"
NUMBER_512:	.asciiz " 512"
NUMBER_1024:	.asciiz "1024"
NUMBER_2048:	.asciiz "2048"
WIN:		.asciiz "Congratulations! You have reached the 2048 tile!"
LOSE: 		.asciiz "Game Over."
ENTER_MOVE:	.asciiz "Enter a move (W=Up, A=Left, S=Down, D=Right, X=Quit, 3=Disable RNG, 4=Enable RNG):\n"
MOVE:		.word	0:1		# We store user input here
N:		.word	0:1		# We store the indicated number N for the NxN grid
NxN:		.word	0:1		# value of NxN
GRID_BASE:	.word	0:1		# grid base address
PREV_GRID:	.word	0:1		# prev grid base address

# ---------------------- MACROS TO REDUCE REDUNDANCY ----------------------
# Print String
    .macro print_str %str
        li $v0, 4
        la $a0, %str
        syscall
    .end_macro
# Read String 
    .macro read_str %address
        li      $v0, 8            	# Syscall for reading string
        la      $a0, %address     	# Address of buffer to store input
        li      $a1, 100  	  	# Maximum length of input
        syscall                   	# Read input from user
    .end_macro
# Read Integer
    .macro read_int %address
        li      $v0, 5            	# Syscall for reading string
        syscall                   	# Read input from user
        sw	$v0, %address
    .end_macro
# Randomizer
    .macro randomize %upperbound
    	li 	$a1, %upperbound	# Upperbound when generating a num 
    	li 	$v0, 42			# Randomizer syscall  
    	syscall
    .end_macro
# Incrementer
    .macro increment %reg
    	addi	%reg, %reg, 1
    .end_macro
# Input the state of a tile
    .macro set_tile %reg
	li 	$v0, 5
	syscall
	move 	$a0, $v0
	jal	check_integer
	sw	$a0, (%reg)
    .end_macro

# ---------------------- MAIN PROGRAM ----------------------
.text
# First Load Initialize the Board
main:
	print_str WELCOME		# Print MAIN MENU PROMPT
	read_str MOVE			# Read User Input STORE IN MOVE
	print_str GRID_SIZE		# Ask for the grid size N
	read_int N			# Read User Input STORE IN N
	
	lw	$a0, N
	jal	grid_malloc		# memory allocation function
	sw	$v0, GRID_BASE	
	sw	$v1, NxN
	
	lw	$a0, MOVE		# load MOVE to a0
	beq 	$a0, 0xa31, input_new	# If NEW GAME
	beq 	$a0, 0xa32, input_state # If Start from a STATE
	beq	$a0, 0xa58, terminate	# X = Quit
	
	print_str INVALID_INPUT		# otherwise, Print INVALID INPUT
	j	main			# Loop back to main (main menu)

# ---------------------- FUNCTIONS ----------------------
grid_malloc:
	move	$s0, $a0
	mul 	$s1, $s0, $s0
	mul	$s2, $s1, 4

	li	$v0, 9
	move	$a0, $s2		# Memory allocation for the NxN grid in heap 
	syscall
	move	$v1, $s1		# $v1 = NxN

	jr	$ra
	
# ---- terminate -----
terminate:
	print_str QUIT
exit:
	li 	$v0, 10
	syscall
# ---------------------- END ----------------------	
			
# ======= NEW GAME ==========
input_new:				# NEW GAME 1
	li 	$t0, 0			# counter so that there will be only two 2-tiles in the grid
	lw	$s0, NxN		# value of NxN
	lw	$s1, GRID_BASE		# grid base address
grid_position_reset:
	li	$t1, 0			# grid position counter
zero_or_two_loop:
	sll 	$t2, $t1, 2       	# Multiply index by 4 for word offset
    	add 	$t2, $t2, $s1     	# Get address of current element
	jal 	zero_or_two		# Call zero_or_two function 
	sw	$v0, ($t2)		# address will now have value of 0 or 2
	
	increment $t1
	beq	$t0, 2, main_loop 		# If $t0 = 2, tile is ready to be printed
	beq 	$t1, $s0, grid_position_reset 	# If reached (N, N) in the grid, restart back to (0, 0)
	j	zero_or_two_loop 		# loop back if conditions are not met

# ---------------------- FUNCTIONS ----------------------
zero_or_two:
	randomize 2			# randomize a number in [0,1]
	beq 	$a0, 0, zero		# if num == 0 return zero
	beq 	$a0, 1, two		# if num == 1 return two
zero:
	li 	$v0, 0		
	jr 	$ra			# return 0
two:
	bge	$t0, 2, zero	 
	li 	$v0, 2
	increment $t0			# increment $t0 >> there are now $t0 tiles in the board
	jr 	$ra			# return 2
# ---------------------- END ----------------------

# ======= NEW GAME FROM STATE ==========
input_state:				# NEW GAME 2
	print_str BOARD_CONFIG
	li	$t0, 0			# grid position counter
	lw	$s0, NxN		# value of NxN
	lw	$s1, GRID_BASE		# grid base address
board_config_loop:
	sll 	$t1, $t0, 2       	# Multiply index by 4 for word offset
    	add 	$t1, $t1, $s1     	# Get address of current position
	set_tile $t1
	
	increment $t0
	blt	$t0, $s0, board_config_loop
	
	j	main_loop

# ---------------------- FUNCTIONS ----------------------
check_integer:
	beq	$a0, 0, valid_integer	# check if integers are valid
	beq	$a0, 2, valid_integer
	beq	$a0, 4, valid_integer
	beq	$a0, 8, valid_integer
	beq	$a0, 16, valid_integer
	beq	$a0, 32, valid_integer
	beq	$a0, 64, valid_integer
	beq	$a0, 128, valid_integer
	beq	$a0, 256, valid_integer
	beq	$a0, 512, valid_integer
	beq	$a0, 1024, valid_integer
	beq	$a0, 2048, valid_integer
	print_str INVALID_INPUT
	j	main
valid_integer:
	jr	$ra
# ---------------------- END ----------------------

# ===== Main Loop - print grid - check win state - get input =====
main_loop:	# Print the Grid
	jal	print_grid		# Print the Grid
	jal	is_win			# Check if win
	jal	is_lose			# Check if lose
input_move:	# Get User Input
	print_str ENTER_MOVE		# Prompt Move
	read_str MOVE			# Get Input
	
	lw	$t0, MOVE
	beq	$t0, 0xa58, terminate	# X = Quit
	
	jal	store_previous
	beq	$t0, 0xa57, move_up	# W = move up
	beq	$t0, 0xa41, move_left	# A = move left
	beq	$t0, 0xa53, move_down	# S = move down
	beq	$t0, 0xa44, move_right	# D = move right

# Skipped if move is valid -- else we jump here if board changed
invalid_move:	
	print_str INVALID_INPUT		# Print INVALID INPUT
	j	input_move		# Loop back to input_move

	j	exit
		
# ---------------------- FUNCTIONS ----------------------	
print_grid:				# GRID PRINTING
	##### preamble #####
	addi	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$t0, 4($sp)
	sw	$s0, 8($sp)
	##### preamble #####
	jal	print_border
	jal	print_rows
	
	##### end #####
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	##### end #####
	jr	$ra
	
print_border:
	##### preamble #####
	addi	$sp, $sp, -8
	sw	$s0, 0($sp)
	sw	$t0, 4($sp)
	##### preamble #####
	li 	$t0, 0			# grid position counter 
	lw	$s0, N			# value of N
border_loop:
	print_str BORDER
	increment $t0
	blt	$t0, $s0, border_loop
	print_str CORNER

	##### end #####
	lw	$s0, 0($sp)
	lw	$t0, 4($sp)
	addi	$sp, $sp, 8
	##### end #####	
	jr	$ra
	
print_rows:
	##### preamble #####
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	##### preamble #####
	li	$t0, 0			# grid position counter
	lw	$s0, N			# value of N
	lw	$s1, NxN		# value of NxN
	lw	$s2, GRID_BASE		# grid base address
row_loop:
	print_str HEDGE
	sll 	$t1, $t0, 2       	# Multiply index by 4 for word offset
    	add 	$t1, $t1, $s2     	# Get address of current position
    	lw 	$a0, ($t1)         	# Load current element
	jal	print_integer
	
	addi	$t1, $t0, 1
	div	$t1, $s0
	mfhi	$t2
	bnez	$t2, is_not_edge
	print_str EDGE
	jal	print_border
is_not_edge:	
	increment $t0
	blt	$t0, $s1, row_loop
	
	##### end #####
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	##### end #####		
	jr	$ra
	
print_integer:
	##### preamble #####
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	##### preamble #####
	jal	get_integer		# Get integer to Print
	move	$a0, $v0	
	li	$v0, 4
	syscall

	##### end #####
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	##### end #####	
	jr $ra
get_integer:
	beq	$a0, 0, print_0
	beq	$a0, 2, print_2
	beq	$a0, 4, print_4
	beq	$a0, 8, print_8
	beq	$a0, 16, print_16
	beq	$a0, 32, print_32
	beq	$a0, 64, print_64
	beq	$a0, 128, print_128
	beq	$a0, 256, print_256
	beq	$a0, 512, print_512
	beq	$a0, 512, print_1024
	beq	$a0, 512, print_2048
print_0:
	la	$v0, NUMBER_0
	jr 	$ra
print_2:
	la	$v0, NUMBER_2
	jr 	$ra
print_4:
	la	$v0, NUMBER_4
	jr 	$ra
print_8:
	la	$v0, NUMBER_8
	jr 	$ra
print_16:
	la	$v0, NUMBER_16
	jr 	$ra
print_32:
	la	$v0, NUMBER_32
	jr 	$ra
print_64:
	la	$v0, NUMBER_64
	jr 	$ra
print_128:
	la	$v0, NUMBER_128
	jr 	$ra
print_256:
	la	$v0, NUMBER_256
	jr 	$ra
print_512:
	la	$v0, NUMBER_512
	jr	$ra
print_1024:
	la	$v0, NUMBER_1024
	jr	$ra
print_2048:
	la	$v0, NUMBER_2048
	jr	$ra
	
is_win:
	li	$t0, 0			# grid position counter
	lw	$s0, NxN		# value of NxN
	lw	$s1, GRID_BASE		# grid base address
is_win_loop:
	sll 	$t1, $t0, 2       	# Multiply index by 4 for word offset
    	add 	$t1, $t1, $s1     	# Get address of current position
    	lw 	$t2, ($t1)         	# Load current element
    	beq	$t2, 2048, win
    	
    	increment $t0
    	blt	$t0, $s0, is_win_loop	
	
	jr	$ra
win:
	print_str WIN			# End if WIN!
    	j 	exit

is_lose:
	li	$t0, 0			# grid position counter
	lw	$s0, N			
	lw	$s1, NxN		# value of NxN
	lw	$s2, GRID_BASE		# grid base address 	
is_lose_loop:
	sll 	$t1, $t0, 2       	# Multiply index by 4 for word offset
    	add 	$t1, $t1, $s2     	# Get address of current position
    	lw 	$t2, ($t1)         	# Load current element
    	beqz	$t2, False		# Check if there's an empty tile
    	
    	# check right
    	addi	$t3, $t0, 2		# check right position
    	div	$t3, $s0
	mfhi	$t3
    	bgt 	$t3, $s0, check_down  	# Skip if out of bounds
    	lw 	$t4, 4($t1) 		# Load right value
    	beq	$t2, $t4, False
check_down:
	mflo	$t3			# get y coordinate 
	bge 	$t3, $s0, skip_down 	# Skip if out of bounds
	mul  	$t3, $s0, 4       	# N * 4
	add	$t3, $t1, $t3		# adds offset to original position's address
	lw	$t4, ($t3)		# Load down value
	beq	$t2, $t4, False	
skip_down:	
	increment $t0
	blt	$t0, $s0, is_lose_loop
    	
game_over:	
	print_str LOSE
    	j exit
False:
	jr	$ra

store_previous:
	##### preamble #####
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	##### preamble #####
	lw	$a0, N
	jal	grid_malloc		# memory allocation function
	sw	$v0, PREV_GRID
	
	li	$t0, 0			# grid position counter
	lw	$s0, NxN		# value of NxN
	lw	$s1, GRID_BASE		# grid base address
	lw	$s2, PREV_GRID		# previous grid base address
store_loop:
	sll 	$t1, $t0, 2       	# Multiply index by 4 for word offset
    	add 	$t2, $t1, $s1     	# Get address of current position
    	lw 	$t3, ($t2)         	# Load current element
    	add 	$t4, $t1, $s2     	
    	sw	$t3, ($t4)
    	
    	increment $t0
    	blt	$t0, $s0, store_loop
    	
    	##### end #####
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	##### end #####	
    	jr	$ra

move_up:
move_left:
move_down:
move_right:	
	
    	
# ---------------------- END ----------------------