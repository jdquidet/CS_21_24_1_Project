.data
WELCOME: 	.asciiz "Main Menu:\n[1] New Game\n[2] Start from a State\n[X] Quit\n"
BOARD_CONFIG:	.asciiz "Enter a board configuration (Invalid integer = back to Main menu):\n"
LINE:           .asciiz "+---+---+---+\n"
VERTICAL: 	.asciiz "|"
NUMBER_0:	.asciiz "   "
NUMBER_2:	.asciiz " 2 "
NUMBER_4:	.asciiz	" 4 "
NUMBER_8:	.asciiz " 8 "
NUMBER_16:	.asciiz " 16"
NUMBER_32:	.asciiz " 32"
NUMBER_64:	.asciiz " 64"
NUMBER_128:	.asciiz "128"
NUMBER_256:	.asciiz "256"
NUMBER_512:	.asciiz "512"
NEWLINE:	.asciiz "\n"
WIN:		.asciiz "Congratulations! You have reached the 512 tile!"
LOSE: 		.asciiz "Game Over."
QUIT:		.asciiz "Program Terminated."
ENTER_MOVE:	.asciiz "Enter a move (W=Up, A=Left, S=Down, D=Right, X=Quit, 3=Disable RNG, 4=Enable RNG):\n"
INVALID_MOVE:	.asciiz "Invalid move.\n"
INVALID_INT:	.asciiz "Invalid integer.\n"
RNG_DISABLED:	.asciiz "RNG Disabled.\n"
RNG_ENABLED:	.asciiz "RNG Enabled.\n"
MOVE:		.word			# We store user input here
ORIGIN_GRID: 	.word 	0:9  		# Array to store 9 original values
# ---------------------- MACROS TO REDUCE REDUNDANCY ----------------------
# -- Helper Macros
# Print String
    .macro print_str %str
        li $v0, 4
        la $a0, %str
        syscall
    .end_macro
# Read String 
    .macro get_input %address
        li      $v0, 8            # Syscall for reading string
        la      $a0, %address     # Address of buffer to store input
        li      $a1, 100  	  # Maximum length of input
        syscall                   # Read input from user
    .end_macro
# Randomizer
    .macro randomize %upperbound
    	li 	$a1, %upperbound	# Upperbound when generating a num 
    	li 	$v0, 42			# Randomizer syscall  
    	syscall
    .end_macro
# Print Rows of board
    .macro print_row %reg1 %reg2 %reg3
	print_str LINE
	print_str VERTICAL		
	move 	$a0, %reg1
	jal 	print_integer
	print_str VERTICAL
	move	$a0, %reg2
	jal 	print_integer
	print_str VERTICAL
	move	$a0, %reg3
	jal 	print_integer
	print_str VERTICAL
	print_str NEWLINE
     .end_macro
# -- Functional Macros
# Generate zero or two
    .macro call_zero_or_two %reg
	jal zero_or_two		  # Call zero_or_two function 
	move %reg, $v0		  # returns a zero or two
    .end_macro
# Input the state of a tile
	.macro set_tile %reg
		li 	$v0, 5
		syscall
		move 	%reg, $v0
		move	$a0, %reg
		jal	check_integer
	.end_macro
# Generate a 2 on tile
	.macro generate_tile %reg
		bnez	%reg, add_random_tile
		li	%reg, 2
		j	main_loop
	.end_macro
# Check if changed
	.macro check_tile_change %reg1 %reg2
		bne %reg1, %reg2, grid_changed
    	j 	continue_loop
	.end_macro

# ---------------------- MAIN PROGRAM ----------------------
.text
# First Load Initialize the Board
main:
	print_str WELCOME		# Print MAIN MENU PROMPT
	get_input MOVE			# Read User Input STORE IN MOVE
	
	lw	$t0, MOVE		# load MOVE to t0
	beq 	$t0, 0xa31, input_new	# If NEW GAME
	beq 	$t0, 0xa32, input_state # If Start from a STATE
	beq	$t0, 0xa58, terminate	# X = Quit
# ===== Main Loop - print grid - check win state - get input =====
main_loop:	# Print the Grid
	jal	print_grid	# Print the Grid
	jal	is_win		# Check if win
	jal	is_lose		# Check if lose
input_move:	# Get User Input
	print_str ENTER_MOVE	# Prompt Move
	get_input MOVE		# Get Input
	
	lw	$t0, MOVE
	beq	$t0, 0xa58, terminate	# X = Quit
	
	jal	store_origin
	beq	$t0, 0xa57, move_up	# W = move up
	beq	$t0, 0xa41, move_left	# A = move left
	beq	$t0, 0xa53, move_down	# S = move down
	beq	$t0, 0xa44, move_right	# D = move right
	
	beq	$t0, 0xa33, rng_disable	# 3 = disable RNG
	beq	$t0, 0xa34, rng_enable	# 4 = enable RNG
# Skipped if move is valid -- else we jump here if board changed
invalid_move:	
	print_str INVALID_MOVE		# Print INVALID MOVE
	j	input_move		# Loop back to input_move
# ======= NEW GAME ==========
input_new:				# NEW GAME 1
	li 	$t0, 0			
input_random_loop:
	call_zero_or_two $t1		# Calls the zero_or_two function (generates random 0 or 2) then store to t1
	call_zero_or_two $t2		# Store to t2
	call_zero_or_two $t3		# Store to t3
	call_zero_or_two $t4		# Store to t4
	call_zero_or_two $t5		# Store to t5
	call_zero_or_two $t6		# Store to t6
	call_zero_or_two $t7		# Store to t7
	call_zero_or_two $t8		# Store to t8
	call_zero_or_two $t9		# Store to t9
    	blt	$t0, 2, input_random_loop # If $t0 < 2 then input random loop again, the board has to have ATLEAST 2 "2" initialized tiles
    	j 	main_loop		# proceeds to game loop

# Used Functions for randomized zero or two #
zero_or_two:
	randomize 2		# randomize a number in [0,1]
	beq 	$a0, 0, zero	# if num == 0 return zero
	beq 	$a0, 1, two	# if num == 1 return two
zero:
	li 	$v0, 0		
	jr 	$ra		# return 0
two:
	bge	$t0, 2, zero	# 
	li 	$v0, 2
	addi 	$t0, $t0, 1	# increment $t0 >> there are now $t0 tiles in the board
	jr 	$ra
# End #
# ======= NEW GAME FROM STATE ==========
input_state:				# NEW GAME 2
	print_str BOARD_CONFIG
	set_tile $t1
	set_tile $t2
	set_tile $t3
	set_tile $t4
	set_tile $t5
	set_tile $t6
	set_tile $t7
	set_tile $t8
	set_tile $t9
	j 	main_loop		# proceeds to game loop
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
	print_str INVALID_INT		# Did not branch >> Invalid integer
    	j	main
valid_integer:
	jr	$ra
# ============== PRINT THE GRID BOARD =================
print_grid:				# GRID PRINTING
	##### preamble #####
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	##### preamble #####
	print_row $t1 $t2 $t3	# row 1
	print_row $t4 $t5 $t6	# row 2
	print_row $t7 $t8 $t9	# row 3
	print_str LINE		# bottom of the board
   	##### end #####
   	lw	$ra, 0($sp)
   	addi	$sp, $sp, 4
   	##### end #####
    	jr 	$ra

print_integer:
	##### preamble #####
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	##### preamble #####
	jal	get_integer	# Get integer to Print
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
# =========== CHECK WIN/LOSE CONDITION =============
is_win:
	beq 	$t1, 512, win	# Checks if 512
	beq 	$t2, 512, win
	beq 	$t3, 512, win
	beq 	$t4, 512, win
	beq 	$t5, 512, win
	beq 	$t6, 512, win
	beq 	$t7, 512, win
	beq 	$t8, 512, win
	beq 	$t9, 512, win
	jr	$ra
win:
	print_str WIN		# End if WIN!
    	j 	exit
    	
is_lose:
	beqz	$t1, False		# Check if there's an empty tile
	beqz	$t2, False
	beqz	$t3, False
	beqz	$t4, False
	beqz	$t5, False
	beqz	$t6, False
	beqz	$t7, False
	beqz	$t8, False
	beqz	$t9, False

	beq	$t1, $t2, False		# Check if adjacent tiles can combine
	beq	$t1, $t4, False
	beq	$t2, $t3, False
	beq	$t2, $t5, False
	beq	$t3, $t6, False
	beq	$t4, $t5, False
	beq	$t4, $t7, False
	beq	$t5, $t6, False
	beq	$t5, $t8, False
	beq	$t6, $t9, False
	beq	$t7, $t8, False
	beq	$t8, $t9, False
game_over:	
	print_str LOSE
    	j exit
False:
	jr	$ra
# ---- terminate -----
terminate:
	print_str QUIT
exit:
	li 	$v0, 10
	syscall

store_origin:				# store the state of the grid!
	sw 	$t1, ORIGIN_GRID
    	sw 	$t2, ORIGIN_GRID+4
    	sw 	$t3, ORIGIN_GRID+8
    	sw 	$t4, ORIGIN_GRID+12
    	sw 	$t5, ORIGIN_GRID+16
    	sw 	$t6, ORIGIN_GRID+20
    	sw 	$t7, ORIGIN_GRID+24
    	sw 	$t8, ORIGIN_GRID+28
    	sw 	$t9, ORIGIN_GRID+32
    	jr	$ra	

# ========= MOVEMENT ==========			
move_up:	
	move	$a0, $t1	# Merge and Compress Column 1 upward
	move	$a1, $t4
	move	$a2, $t7
	jal 	compress
	jal	merge
	jal 	compress
	move	$t1, $a0
	move	$t4, $a1
	move	$t7, $a2
	
	move	$a0, $t2	# Merge and Compress Column 2 upward
	move	$a1, $t5
	move	$a2, $t8
	jal 	compress
	jal	merge
	jal 	compress
	move	$t2, $a0
	move	$t5, $a1
	move	$t8, $a2
	
	move	$a0, $t3	# Merge and Compress Column 3 upward
	move	$a1, $t6
	move	$a2, $t9
	jal 	compress
	jal	merge
	jal 	compress
	move	$t3, $a0
	move	$t6, $a1
	move	$t9, $a2
	
	j	add_random_tile	# Add a random tile
move_left:
	move	$a0, $t1	# Merge and Compress Row 1 to the left
	move	$a1, $t2
	move	$a2, $t3
	jal 	compress
	jal	merge
	jal 	compress
	move	$t1, $a0
	move	$t2, $a1
	move	$t3, $a2
	
	move	$a0, $t4	# Merge and Compress Row 2 to the left
	move	$a1, $t5
	move	$a2, $t6
	jal 	compress
	jal	merge
	jal 	compress
	move	$t4, $a0
	move	$t5, $a1
	move	$t6, $a2
	
	move	$a0, $t7	# Merge and Compress Row 3 to the left
	move	$a1, $t8
	move	$a2, $t9
	jal 	compress
	jal	merge
	jal 	compress
	move	$t7, $a0
	move	$t8, $a1
	move	$t9, $a2
	
	j	add_random_tile	# Add a random tile
move_down:
	move	$a0, $t7	# Merge and Compress Column 1 downward
	move	$a1, $t4
	move	$a2, $t1
	jal 	compress
	jal	merge
	jal 	compress
	move	$t7, $a0
	move	$t4, $a1
	move	$t1, $a2
	
	move	$a0, $t8	# Merge and Compress Column 2 downward
	move	$a1, $t5
	move	$a2, $t2
	jal 	compress
	jal	merge
	jal 	compress
	move	$t8, $a0
	move	$t5, $a1
	move	$t2, $a2
	
	move	$a0, $t9	# Merge and Compress Column 3 downward
	move	$a1, $t6
	move	$a2, $t3
	jal 	compress
	jal	merge
	jal 	compress
	move	$t9, $a0
	move	$t6, $a1
	move	$t3, $a2
	
	j	add_random_tile # Add random tile
move_right:
	move	$a0, $t3	# Merge and Compress Row 1 to the right
	move	$a1, $t2
	move	$a2, $t1
	jal 	compress
	jal	merge
	jal 	compress
	move	$t3, $a0
	move	$t2, $a1
	move	$t1, $a2
	
	move	$a0, $t6	# Merge and Compress Row 2 to the right
	move	$a1, $t5
	move	$a2, $t4
	jal 	compress
	jal	merge
	jal 	compress
	move	$t6, $a0
	move	$t5, $a1
	move	$t4, $a2
	
	move	$a0, $t9	# Merge and Compress Row 3 to the right
	move	$a1, $t8
	move	$a2, $t7
	jal 	compress
	jal	merge
	jal 	compress
	move	$t9, $a0
	move	$t8, $a1
	move	$t7, $a2
	
	j	add_random_tile

compress:			
	bnez	$a1, compress_1	# If tile not empy
	move	$a1, $a2	# If tile empty move
	li	$a2, 0		
compress_1:
	bnez	$a0, compress_2 # If tile not empty
	move	$a0, $a1	# If tile empty move
	li	$a1, 0
compress_2:
	bnez	$a1, compress_end # If tile not empty
	move	$a1, $a2	  # If tile empty move
	li	$a2, 0
compress_end:
	jr	$ra		  # return
merge:
	bne	$a0, $a1, merge_1 # If adjacent tiles not equal
	add	$a0, $a0, $a1	  # Merge the first two tiles since equal >> add 
	li	$a1, 0
merge_1:
	bne	$a1, $a2, merge_end # If adjacent last two tiles not equal
	add	$a1, $a1, $a2	    # Merge the last two tiles since equal >> add
	li	$a2, 0
merge_end:
	jr 	$ra	
# ====== adding a random tile =======
add_random_tile:
	jal 	check_origin	    # Checks if grid changed
	beq	$s0, 3, main_loop   # If $s0 is 3 - RNG disabled no need to add_random_tile
	randomize 9		    # Choose a tile! from 1 to 9 >> (note zero indexed so choose a number in [0,8]
	beq	$a0, 0, tile_t1
	beq	$a0, 1, tile_t2
	beq	$a0, 2,	tile_t3
	beq	$a0, 3,	tile_t4
	beq	$a0, 4,	tile_t5
	beq	$a0, 5,	tile_t6
	beq	$a0, 6,	tile_t7
	beq	$a0, 7,	tile_t8
	beq	$a0, 8,	tile_t9
											
tile_t1: generate_tile $t1
tile_t2: generate_tile $t2
tile_t3: generate_tile $t3
tile_t4: generate_tile $t4
tile_t5: generate_tile $t5
tile_t6: generate_tile $t6
tile_t7: generate_tile $t7
tile_t8: generate_tile $t8
tile_t9: generate_tile $t9

# -------- CHECK BOARD STATE IF MOVE INPUT IS VALID ------------
check_origin:
	##### preamble #####
	addi	$sp, $sp, -16	# Load the origin board
	sw	$s0, 0($sp)
	sw	$s1, 4($sp)
	sw	$s2, 8($sp)
	sw	$ra, 12($sp)
	##### preamble #####
	li 	$s0, 0       		# Change flag (0 = unchanged, 1 = changed)
    	li 	$s1, 0       		# Loop counter
check_origin_loop:	
	# Calculate offset
    	mul 	$s2, $s1, 4  		# Multiply counter by 4 (word size)
    	# Load original and current values
    	lw 	$s2, ORIGIN_GRID($s2)  	# Original value
    	# Load current register value based on counter
    	beq 	$s1, 0, check_t1
    	beq 	$s1, 1, check_t2
    	beq 	$s1, 2, check_t3
    	beq 	$s1, 3, check_t4
    	beq 	$s1, 4, check_t5
    	beq 	$s1, 5, check_t6
    	beq 	$s1, 6, check_t7
    	beq 	$s1, 7, check_t8
    	beq 	$s1, 8, check_t9
check_t1: check_tile_change $s2, $t1 
check_t2: check_tile_change $s2, $t2 
check_t3: check_tile_change $s2, $t3 
check_t4: check_tile_change $s2, $t4 
check_t5: check_tile_change $s2, $t5 
check_t6: check_tile_change $s2, $t6 
check_t7: check_tile_change $s2, $t7 
check_t8: check_tile_change $s2, $t8 
check_t9: check_tile_change $s2, $t9

continue_loop:	
	# Increment counter
    	addi 	$s1, $s1, 1
    	blt 	$s1, 9, check_origin_loop

    	# If we get here, no changes detected
    	j 	check_result
grid_changed:
    	# Set change flag
    	li 	$s0, 1
check_result:
    	# Result based on change flag
    	beq 	$s0, 1, return_nothing
    	# Else 
    	j	return_invalid
return_nothing:
    	##### end #####
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$ra, 12($sp)
	addi	$sp, $sp, 16
	##### end #####

	jr	$ra
return_invalid:
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$ra, 12($sp)
	addi	$sp, $sp, 16
	##### end #####
	j	invalid_move


# ===== RNG =======																													
rng_disable:
	li	$s0, 3	
	print_str RNG_DISABLED
    	j	input_move
rng_enable:	
	li	$s0, 4	
	print_str RNG_ENABLED
    	j	input_move
