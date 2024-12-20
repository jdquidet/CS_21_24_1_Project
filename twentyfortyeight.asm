.data
WELCOME: 	.asciiz "Main Menu:\n[1] New Game\n[2] Start from a State\n[X] Quit\n"
GRID_SIZE:	.asciiz	"Input the size of the board: \n"
BOARD_CONFIG:	.asciiz "Enter a board configuration (Invalid input = back to Main menu):\n"
INVALID_INPUT:	.asciiz "Invalid input.\n"
QUIT:		.asciiz "Program Terminated."
MOVE_NUMBER:	.asciiz	"Moves:"
SCORE:		.asciiz " Score:"
NEWLINE:	.asciiz "\n"
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
ENTER_MOVE:	.asciiz "Enter a move (W=Up, A=Left, S=Down, D=Right, X=Quit, 3=Disable RNG, 4=Enable RNG, z=Undo):\n"
RNG_DISABLED:	.asciiz "RNG Disabled.\n"
RNG_ENABLED:	.asciiz "RNG Enabled.\n"
		.align 	2
MOVE:		.space	4		# We store user input here
N:		.space	4		# We store the indicated number N for the NxN grid
NxN:		.space	4		# value of NxN
GRID_BASE:	.space	4		# grid base address
PREV_GRID:	.space	4		# prev grid base address
TEMP_GRID:	.space	4		# temporary grid for rotate and reverse functions
RNG_FLAG:	.word	4		# 3 = disabled, 4 = enabled
CURRENT_MOVES:	.word   0
CURRENT_SCORE:	.word	0

# ---------------------- MACROS TO REDUCE REDUNDANCY ----------------------
# Print String
    .macro print_str %str
        li 	$v0, 4
        la 	$a0, %str
        syscall
    .end_macro
# Read String 
    .macro read_str %address
        li      $v0, 8            	# Syscall for reading string
        la      $a0, %address     	# Address of buffer to store input
        li      $a1, 100  	  	# Maximum length of input
        syscall                   	# Read input from user
    .end_macro
# Print Integer
    .macro print_int %int
    	li	$v0, 1
    	lw	$a0, %int
    	syscall
    .end_macro
# Read Integer
    .macro read_int %address
        li      $v0, 5            	# Syscall for reading string
        syscall                   	# Read input from user
        sw	$v0, %address
    .end_macro
# Randomizer
    .macro randomize %upperbound_reg
    	move 	$a1, %upperbound_reg	# Upperbound when generating a num 
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
	
	jal	make_history_grid
	jal	make_temp_grid
main_move:	
	lw	$a0, MOVE		# load MOVE to a0
	beq 	$a0, 0xa31, input_new	# If NEW GAME
	beq 	$a0, 0xa32, input_state # If Start from a STATE
	beq	$a0, 0xa58, terminate	# X = Quit
	
	print_str INVALID_INPUT		# otherwise, Print INVALID INPUT
	j	main_move		# Loop back to main (main menu)

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
make_history_grid:
	##### preamble #####
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	##### preamble #####
	lw	$a0, N
	jal	grid_malloc		# memory allocation function
	sw	$v0, PREV_GRID
	##### end #####
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	##### end #####	
	jr	$ra
make_temp_grid:
	##### preamble #####
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	##### preamble #####
	lw	$a0, N
	jal	grid_malloc		# memory allocation function
	sw	$v0, TEMP_GRID
	##### end #####
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	##### end #####	
	jr	$ra
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
	li	$t3, 2
	randomize $t3			# randomize a number in [0,1]
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

# ---- terminate -----
terminate:
	print_str QUIT
exit:
	li 	$v0, 10
	syscall

# ===== Main Loop - print grid - check win state - get input =====
main_loop:
	jal	calculate_score
	jal	print_grid		# Print the Grid
	jal	is_win			# Check if win
	jal	is_lose			# Check if lose
input_move:	# Get User Input
	print_str ENTER_MOVE		# Prompt Move
	read_str MOVE			# Get Input
	
	lw	$t0, MOVE
	beq	$t0, 0xa58, terminate	# X = Quit
	beq	$t0, 0xa33, rng_disable	# 3 = RNG disable
	beq	$t0, 0xa34, rng_enable	# 4 = RNG enable
	beq	$t0, 0xa7a, undo	# z = undo
	
	jal	store_current
	beq	$t0, 0xa57, move_up	# W = move up
	beq	$t0, 0xa41, move_left	# A = move left
	beq	$t0, 0xa53, move_down	# S = move down
	beq	$t0, 0xa44, move_right	# D = move right
	
# Skipped if move is valid -- else we jump here if board changed
invalid_move:	
	print_str INVALID_INPUT		# Print INVALID INPUT
	j	input_move		# Loop back to input_move
		
# ---------------------- FUNCTIONS ----------------------	
calculate_score:
	li	$t0, 0			# grid position counter
	lw	$s0, NxN		# value of NxN
	lw	$s1, GRID_BASE		# grid base address
	li	$s2, 0			# score total
calculate_loop:
	sll 	$t1, $t0, 2       	# Multiply index by 4 for word offset
    	add 	$t2, $t1, $s1     	# Get address of current position
    	lw 	$t3, ($t2)         	# Load current element
    	add 	$s2, $s2, $t3
    	
    	increment $t0
    	blt	$t0, $s0, calculate_loop

	sw	$s2, CURRENT_SCORE
    	jr	$ra
	

print_grid:				# GRID PRINTING
	##### preamble #####
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	##### preamble #####
	print_str MOVE_NUMBER
	print_int CURRENT_MOVES
	print_str SCORE
	print_int CURRENT_SCORE
	print_str NEWLINE
	
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
    	addi	$t3, $t0, 1		# check right position
    	div	$t3, $s0
	mfhi	$t3
    	blt 	$t3, $t0, check_down  	# Skip if out of bounds
    	lw 	$t4, 4($t1) 		# Load right value
    	beq	$t2, $t4, False
check_down:
	add	$t3, $t0, $s0		# get y coordinate 
	bge 	$t3, $s1, skip_down 	# Skip if out of bounds
	sll  	$t3, $t3, 2       	# N * 4
	add	$t3, $t3, $s2		# adds offset to original position's address
	lw	$t4, ($t3)		# Load down value
	beq	$t2, $t4, False	
skip_down:	
	increment $t0
	blt	$t0, $s1, is_lose_loop
	
	print_str LOSE			# otherwise, game over
    	j exit
False:
	jr	$ra

store_current:
	##### preamble #####
	addi	$sp, $sp, -4
	sw	$t0, 0($sp)
	##### preamble #####
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
	lw	$t0, 0($sp)
	addi	$sp, $sp, 4
	##### end #####
    	jr	$ra
# ---------------------- END ----------------------
move_up:
	jal	rotate_right
	jal	rotate_right
	jal	rotate_right
	
	jal 	compress
	jal	merge
	jal	compress
	
	jal	rotate_right
	j	add_random_tile		# Add a random tile
move_left:
	jal 	compress
	jal	merge
	jal	compress
	
	j	add_random_tile		# Add a random tile
move_down:
	jal	rotate_right
	
	jal 	compress
	jal	merge
	jal	compress
	
	jal	rotate_right
	jal	rotate_right
	jal	rotate_right
	j	add_random_tile		# Add a random tile
move_right:
	jal	reverse
	
	jal 	compress
	jal	merge
	jal	compress
	
	jal	reverse
	j	add_random_tile		# Add a random tile
rng_disable:
	li	$s0, 3
	sw	$s0, RNG_FLAG
	print_str RNG_DISABLED
	j	input_move
rng_enable:
	li	$s0, 4
	sw	$s0, RNG_FLAG
	print_str RNG_ENABLED
	j	input_move
undo:
	jal	check_previous

	lw	$s0, CURRENT_MOVES
	beqz	$s0, invalid_move
	addi	$s0, $s0, -1
	sw	$s0, CURRENT_MOVES

	li	$t0, 0			# grid position counter
	lw	$s0, NxN		# value of NxN
	lw	$s1, PREV_GRID		# previous grid base address
	lw	$s2, GRID_BASE		# current grid base address
undo_loop:
	sll 	$t1, $t0, 2       	# Multiply index by 4 for word offset
    	add 	$t2, $t1, $s1     	# Get address of current position
    	lw 	$t3, ($t2)         	# Load current element
    	add 	$t4, $t1, $s2     	
    	sw	$t3, ($t4)
    	
    	increment $t0
    	blt	$t0, $s0, undo_loop

    	j	main_loop
# ---------------------- FUNCTIONS ----------------------
compress:
	li	$t0, 0			# grid position counter
	lw	$s0, GRID_BASE		# grid base address
	lw	$s1, NxN		# value of NxN
	li	$s2, 0			# nonzero position counter
	lw	$s3, N			# value of N
compress_loop:	
	addi	$t4, $t0, 1
	div	$t4, $s3
	mfhi	$t4			# index mod N = row counter

    	# Load current element
    	sll 	$t1, $t0, 2       	# Multiply index by 4 for word offset
    	add 	$t1, $t1, $s0     	# Get address of current element
    	lw 	$t2, ($t1)         	# Load current element
    	
    	# Check if current element is non-zero
    	beqz 	$t2, zero_tile        	# If zero, skip to next element
    	
    	# If non-zero, place at leftmost available position
    	sll 	$t3, $s2, 2       	# Get offset for non-zero position
    	add 	$t3, $t3, $s0     	# Get address for placement
    	sw 	$t2, ($t3)         	# Store non-zero element
    	increment $s2		      	# Increment non-zero position counter
zero_tile:
    	increment $t0      		# Increment loop counter
    	beqz 	$t4, autofill_loop    	# If reached end of row, fill rest with zeros
    	j 	compress_loop
autofill_loop:
	div	$s2, $s3
	mfhi	$t4			# index mod N = row counter
	beqz 	$t4, compress_next_row  # If reached end of row, go to next row

    	sll 	$t1, $s2, 2       	# Get offset
    	add 	$t1, $t1, $s0     	# Get address
    	sw 	$zero, ($t1)      	# Store zero
    	increment $s2      		# Increment counter
    	
    	j 	autofill_loop
compress_next_row:	
	move	$s2, $t0
	blt	$t0, $s1, compress_loop
	jr	$ra

merge:
	li	$t0, 0			# grid position counter
	lw	$s0, GRID_BASE		# grid base address
	lw	$s1, NxN		# value of NxN
	lw	$s2, N			# value of N
merge_loop:
	div	$t0, $s2
	mfhi	$t7			# index mod N = row counter
	
	addi	$t1, $t0, 1
	div	$t1, $s2
	mfhi	$t8			# index mod N = next counter
	
    	bgt 	$t7, $t8, skip  	# If current row index is end, next row

	# Load current and next elements
    	sll 	$t2, $t0, 2     	# Current index * 4
    	add 	$t2, $t2, $s0   	# Current address
    	lw 	$t3, ($t2)       	# Current value
    	
    	sll 	$t4, $t1, 2     	# Next index * 4
    	add 	$t4, $t4, $s0   	# Next address
    	lw 	$t5, ($t4)       	# Next value
    	
    	# Compare values
    	bne 	$t3, $t5, skip   	# If not equal, skip
    	
    	# Merge equal values
    	add 	$t6, $t3, $t5    	# Add values
    	sw 	$t6, ($t2)        	# Store sum in first position
    	sw 	$zero, ($t4)      	# Store zero in second position
skip:
	increment $t0
	blt	$t0, $s1, merge_loop
	jr	$ra
	
rotate_right:
	lw 	$s0, GRID_BASE    	# Grid base address
    	lw 	$s1, TEMP_GRID    	# Temp array base address
    	lw 	$s2, N       		# N (size)

	li 	$t0, 0       		# row counter
transfer_row_loop:
    	li 	$t1, 0       		# column counter
transfer_col_loop:
    	# Calculate source index: row * N + col
    	mul 	$t2, $t0, $s2
    	add 	$t2, $t2, $t1
    	sll 	$t2, $t2, 2     	# multiply by 4 for word offset
    	add 	$t2, $t2, $s0
    	lw 	$t3, ($t2)       	# load value
    	
    	# Calculate destination index: col * N + (N-1-row)
    	mul 	$t4, $t1, $s2
    	sub 	$t5, $s2, 1
    	sub 	$t5, $t5, $t0
    	add 	$t4, $t4, $t5
    	sll 	$t4, $t4, 2
    	add 	$t4, $t4, $s1
    	sw 	$t3, ($t4)       	# store in temp array
    	
    	increment $t1    		# increment col
    	blt 	$t1, $s2, transfer_col_loop
    	
    	increment $t0    		# increment row
    	blt 	$t0, $s2, transfer_row_loop
# Copy back to original array
    	mul 	$t7, $s2, $s2   	# total elements
    	li 	$t0, 0           	# counter
copy_loop:
    	sll 	$t1, $t0, 2
    	add 	$t2, $s1, $t1   	# temp address
    	add 	$t3, $s0, $t1   	# grid address
    	lw 	$t4, ($t2)       	# load from temp
    	sw 	$t4, ($t3)       	# store in grid
    	increment $t0
    	blt 	$t0, $t7, copy_loop

    	jr	$ra
    	
reverse:
	lw 	$s0, GRID_BASE    	# Grid base address
    	lw 	$s1, TEMP_GRID    	# Temp array base address
    	lw 	$s2, N       		# N (size)
    	li 	$t0, 0           	# row counter
rev_row:
    	li 	$t1, 0           	# left column
    	sub 	$t2, $s2, 1     	# right column
rev_col:
    	bge 	$t1, $t2, rev_next_row  # Check if left >= right

    	# Calculate left index
    	mul 	$t3, $t0, $s2
    	add 	$t3, $t3, $t1
    	sll 	$t3, $t3, 2
    	add 	$t3, $t3, $s0
    
    	# Calculate right index
    	mul 	$t4, $t0, $s2
    	add 	$t4, $t4, $t2
    	sll 	$t4, $t4, 2
    	add 	$t4, $t4, $s0
    
    	# Swap values
    	lw 	$t5, ($t3)       	# left value
    	lw 	$t6, ($t4)       	# right value
    	sw 	$t6, ($t3)       	# store right in left
    	sw 	$t5, ($t4)       	# store left in right
    
    	addi 	$t1, $t1, 1    		# increment left
    	sub 	$t2, $t2, 1     	# decrement right
    	j 	rev_col
rev_next_row:    
    	addi 	$t0, $t0, 1    		# next row
    	blt 	$t0, $s2, rev_row
    	
    	jr	$ra

check_previous:
	li	$t0, 0			# grid position counter
	lw	$s0, NxN		# value of NxN
	lw	$s1, GRID_BASE		# new grid base address
	lw	$s2, PREV_GRID		# stored grid base address
check_previous_loop:
	# Load current and previous index's value
    	sll 	$t1, $t0, 2     	# Current index * 4
    	
    	add 	$t2, $t1, $s1   	# Current grid address
    	lw 	$t3, ($t2)       	# Current value
    	
    	add 	$t4, $t1, $s2   	# prev grid address
    	lw 	$t5, ($t4)       	# prev value
    	
    	# Compare values
    	bne 	$t3, $t5, grid_changed  # If not equal, grid changed
    	
    	increment $t0
    	blt	$t0, $s0, check_previous_loop
    	j	invalid_move
grid_changed:
	jr	$ra
# ---------------------- END ----------------------
add_random_tile:
	jal 	check_previous	    	# Checks if grid changed
	jal	increment_move_tally
	
	lw	$s0, RNG_FLAG
	beq	$s0, 3, main_loop   	# If $s0 is 3 - RNG disabled no need to add_random_tile
randomize_N:
	li	$t0, 0			# grid position counter
	lw	$s0, GRID_BASE		# grid base address
	lw	$s1, NxN		# size
	randomize $s1
random_tile_loop:
	bne	$a0, $t0, next_index

	sll 	$t1, $t0, 2     	# Current index * 4
    	add 	$t1, $t1, $s0   	# Current address
    	lw 	$t2, ($t1)       	# Current value
    	bnez	$t2, randomize_N
    	
    	li	$t3, 2	
    	sw	$t3, ($t1)
    	j	main_loop
next_index:
	increment $t0
	j	random_tile_loop    	
# ---------------------- FUNCTIONS ----------------------	
increment_move_tally:
	lw	$s0, CURRENT_MOVES
	increment $s0
	sw	$s0, CURRENT_MOVES
	jr	$ra
# ---------------------- END ----------------------