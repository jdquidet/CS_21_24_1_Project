.data
WELCOME: 	.asciiz "Choose:\n[1] New Game\n[2] Start from a State\n[X] Quit\n"
BOARD_CONFIG:	.asciiz "Enter a board configuration (Invalid input = back to Main menu):\n"
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
MOVE:		.word	
ORIGIN_GRID: 	.word 	0:9  		# Array to store 9 original values

.text
main:
	li 	$v0, 4
	la 	$a0, WELCOME
	syscall
	
	li	$v0, 8
	la	$a0, MOVE
	li	$a1, 100
	syscall
	
	lw	$t0, MOVE
	beq 	$t0, 0xa31, input_new
	beq 	$t0, 0xa32, input_state
	beq	$t0, 0xa58, terminate	# X = Quit
main_loop:
	jal	print_grid
	jal	is_win
	jal	is_lose
input_move:	
	li 	$v0, 4 		
    	la 	$a0, ENTER_MOVE
    	syscall

	li	$v0, 8
	la	$a0, MOVE
	li	$a1, 100
	syscall
	
	lw	$t0, MOVE
	beq	$t0, 0xa58, terminate	# X = Quit
	
	jal	store_origin
	beq	$t0, 0xa57, move_up	# W = move up
	beq	$t0, 0xa41, move_left	# A = move left
	beq	$t0, 0xa53, move_down	# S = move down
	beq	$t0, 0xa44, move_right	# D = move right
	
	beq	$t0, 0xa33, rng_disable	# 3 = disable RNG
	beq	$t0, 0xa34, rng_enable	# 4 = enable RNG
invalid_move:	
	li 	$v0, 4 		
    	la 	$a0, INVALID_MOVE
    	syscall
	j	input_move

input_new:				# NEW GAME 1
	li 	$t0, 0
input_random_loop:
    	jal 	zero_or_two
    	move 	$t1, $v0   
    	jal 	zero_or_two
    	move 	$t2, $v0    	
    	jal 	zero_or_two
    	move 	$t3, $v0    	
    	jal 	zero_or_two
    	move 	$t4, $v0    	
    	jal 	zero_or_two
    	move 	$t5, $v0    	
    	jal 	zero_or_two
    	move 	$t6, $v0    	
    	jal 	zero_or_two
    	move 	$t7, $v0    	
    	jal 	zero_or_two
    	move 	$t8, $v0    	
    	jal 	zero_or_two
    	move 	$t9, $v0
    	
    	blt	$t0, 2, input_random_loop
    	
    	j 	main_loop		# proceeds to game loop

	# Used Functions for randomized zero or two #
zero_or_two:
	li 	$a1, 2 
    	li 	$v0, 42			# Randomizer syscall  
    	syscall

	beq 	$a0, 0, zero
	beq 	$a0, 1, two
zero:
	li 	$v0, 0	
	
	jr 	$ra
two:
	bge	$t0, 2, zero
	li 	$v0, 2
	addi 	$t0, $t0, 1
	
	jr 	$ra
	# End #

input_state:				# NEW GAME 2
	li 	$v0, 4 	
    	la 	$a0, BOARD_CONFIG
    	syscall
    	
	li 	$v0, 5
	syscall
	move 	$t1, $v0
	move	$a0, $t1
	jal	check_integer
	
	li 	$v0, 5
	syscall
	move 	$t2, $v0
	move	$a0, $t2
	jal	check_integer
	
	li 	$v0, 5
	syscall
	move 	$t3, $v0
	move	$a0, $t3
	jal	check_integer
	
	li 	$v0, 5
	syscall
	move 	$t4, $v0
	move	$a0, $t4
	jal	check_integer
	
	li 	$v0, 5
	syscall
	move 	$t5, $v0
	move	$a0, $t5
	jal	check_integer
	
	li 	$v0, 5
	syscall
	move 	$t6, $v0
	move	$a0, $t6
	jal	check_integer
	
	li 	$v0, 5
	syscall
	move 	$t7, $v0
	move	$a0, $t7
	jal	check_integer
	
	li 	$v0, 5
	syscall
	move 	$t8, $v0
	move	$a0, $t8
	jal	check_integer
	
	li 	$v0, 5
	syscall
	move 	$t9, $v0
	move	$a0, $t9
	jal	check_integer
	
	j 	main_loop		# proceeds to game loop

check_integer:
	beq	$a0, 0, valid_integer
	beq	$a0, 2, valid_integer
	beq	$a0, 4, valid_integer
	beq	$a0, 8, valid_integer
	beq	$a0, 16, valid_integer
	beq	$a0, 32, valid_integer
	beq	$a0, 64, valid_integer
	beq	$a0, 128, valid_integer
	beq	$a0, 256, valid_integer
	beq	$a0, 512, valid_integer
	
	li 	$v0, 4 		
    	la 	$a0, INVALID_INT
    	syscall
    	
    	j	main
valid_integer:
	jr	$ra
	
print_grid:				# GRID PRINTING
	##### preamble #####
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	##### preamble #####

	jal	print_line
	
	jal	print_vertical		# Row 1
	move 	$a0, $t1
	jal 	print_integer
	jal	print_vertical
	move	$a0, $t2
	jal 	print_integer
	jal	print_vertical
	move	$a0, $t3
	jal 	print_integer
	jal	print_vertical
	jal 	print_newline
	
	jal	print_line
	
	jal	print_vertical		# Row 2
	move 	$a0, $t4
	jal 	print_integer
	jal	print_vertical
	move	$a0, $t5
	jal 	print_integer
	jal	print_vertical
	move	$a0, $t6
	jal 	print_integer
	jal	print_vertical
	jal 	print_newline
	
	jal	print_line
	
	jal	print_vertical		# Row 3
	move 	$a0, $t7
	jal 	print_integer
	jal	print_vertical
	move	$a0, $t8
	jal 	print_integer
	jal	print_vertical
	move	$a0, $t9
	jal 	print_integer
	jal	print_vertical
	jal 	print_newline
	
	jal	print_line
   
   	##### end #####
   	lw	$ra, 0($sp)
   	addi	$sp, $sp, 4
   	##### end #####
    	jr 	$ra

	# Used Functions for grid printing #
print_line:
	li 	$v0, 4 		
    	la 	$a0, LINE
    	syscall
    	
    	jr 	$ra	
print_vertical:
	li 	$v0, 4
	la	$a0, VERTICAL
	syscall	
	
	jr	$ra
print_integer:
	##### preamble #####
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	##### preamble #####
		
	jal	get_integer
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
	
print_newline:
	li	$v0, 4
	la	$a0, NEWLINE
	syscall
	
	jr $ra
	# End #
	
is_win:
	beq 	$t1, 512, win
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
	li 	$v0, 4 		
    	la 	$a0, WIN
    	syscall
    	
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
	li 	$v0, 4 		
    	la 	$a0, LOSE
    	syscall
    	
    	j exit
False:
	jr	$ra

terminate:
	li 	$v0, 4 		
    	la 	$a0, QUIT
    	syscall
			
exit:
	li 	$v0, 10
	syscall

store_origin:
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
			
move_up:
	move	$a0, $t1
	move	$a1, $t4
	move	$a2, $t7
	jal 	compress
	jal	merge
	jal 	compress
	move	$t1, $a0
	move	$t4, $a1
	move	$t7, $a2
	
	move	$a0, $t2
	move	$a1, $t5
	move	$a2, $t8
	jal 	compress
	jal	merge
	jal 	compress
	move	$t2, $a0
	move	$t5, $a1
	move	$t8, $a2
	
	move	$a0, $t3
	move	$a1, $t6
	move	$a2, $t9
	jal 	compress
	jal	merge
	jal 	compress
	move	$t3, $a0
	move	$t6, $a1
	move	$t9, $a2
	
	j	add_random_tile
move_left:
	move	$a0, $t1
	move	$a1, $t2
	move	$a2, $t3
	jal 	compress
	jal	merge
	jal 	compress
	move	$t1, $a0
	move	$t2, $a1
	move	$t3, $a2
	
	move	$a0, $t4
	move	$a1, $t5
	move	$a2, $t6
	jal 	compress
	jal	merge
	jal 	compress
	move	$t4, $a0
	move	$t5, $a1
	move	$t6, $a2
	
	move	$a0, $t7
	move	$a1, $t8
	move	$a2, $t9
	jal 	compress
	jal	merge
	jal 	compress
	move	$t7, $a0
	move	$t8, $a1
	move	$t9, $a2
	
	j	add_random_tile
move_down:
	move	$a0, $t7
	move	$a1, $t4
	move	$a2, $t1
	jal 	compress
	jal	merge
	jal 	compress
	move	$t7, $a0
	move	$t4, $a1
	move	$t1, $a2
	
	move	$a0, $t8
	move	$a1, $t5
	move	$a2, $t2
	jal 	compress
	jal	merge
	jal 	compress
	move	$t8, $a0
	move	$t5, $a1
	move	$t2, $a2
	
	move	$a0, $t9
	move	$a1, $t6
	move	$a2, $t3
	jal 	compress
	jal	merge
	jal 	compress
	move	$t9, $a0
	move	$t6, $a1
	move	$t3, $a2
	
	j	add_random_tile
move_right:
	move	$a0, $t3
	move	$a1, $t2
	move	$a2, $t1
	jal 	compress
	jal	merge
	jal 	compress
	move	$t3, $a0
	move	$t2, $a1
	move	$t1, $a2
	
	move	$a0, $t6
	move	$a1, $t5
	move	$a2, $t4
	jal 	compress
	jal	merge
	jal 	compress
	move	$t6, $a0
	move	$t5, $a1
	move	$t4, $a2
	
	move	$a0, $t9
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
	bnez	$a1, compress_1
	move	$a1, $a2
	li	$a2, 0
compress_1:
	bnez	$a0, compress_2
	move	$a0, $a1
	li	$a1, 0
compress_2:
	bnez	$a1, compress_end
	move	$a1, $a2
	li	$a2, 0
compress_end:
	jr	$ra

merge:
	bne	$a0, $a1, merge_1
	add	$a0, $a0, $a1
	li	$a1, 0
merge_1:
	bne	$a1, $a2, merge_end
	add	$a1, $a1, $a2
	li	$a2, 0
merge_end:
	jr 	$ra
			
add_random_tile:
	jal 	check_origin		# Checks if grid changed

	beq	$s0, 3, main_loop

	li 	$a1, 9 
    	li 	$v0, 42			# Randomizer syscall  
    	syscall
	
	beq	$a0, 0, tile_t1
	beq	$a0, 1, tile_t2
	beq	$a0, 2,	tile_t3
	beq	$a0, 3,	tile_t4
	beq	$a0, 4,	tile_t5
	beq	$a0, 5,	tile_t6
	beq	$a0, 6,	tile_t7
	beq	$a0, 7,	tile_t8
	beq	$a0, 8,	tile_t9

check_origin:
	##### preamble #####
	addi	$sp, $sp, -16
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
check_t1:
    	bne 	$s2, $t1, grid_changed
    	j 	continue_loop
check_t2:
    	bne 	$s2, $t2, grid_changed
    	j 	continue_loop
check_t3:
    	bne 	$s2, $t3, grid_changed
    	j 	continue_loop
check_t4:
    	bne 	$s2, $t4, grid_changed
    	j 	continue_loop
check_t5:
    	bne 	$s2, $t5, grid_changed
    	j 	continue_loop
check_t6:
    	bne 	$s2, $t6, grid_changed
    	j 	continue_loop
check_t7:
    	bne 	$s2, $t7, grid_changed
    	j 	continue_loop
check_t8:
    	bne 	$s2, $t8, grid_changed
    	j 	continue_loop
check_t9:
    	bne 	$s2, $t9, grid_changed
    	j 	continue_loop
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
			
tile_t1:
	bnez	$t1, add_random_tile
	li	$t1, 2
	j	main_loop
tile_t2:
	bnez	$t2, add_random_tile
	li	$t2, 2
	j	main_loop
tile_t3:
	bnez	$t3, add_random_tile
	li	$t3, 2
	j	main_loop
tile_t4:
	bnez	$t4, add_random_tile
	li	$t4, 2
	j	main_loop
tile_t5:
	bnez	$t5, add_random_tile
	li	$t5, 2
	j	main_loop
tile_t6:
	bnez	$t6, add_random_tile
	li	$t6, 2
	j	main_loop
tile_t7:
	bnez	$t7, add_random_tile
	li	$t7, 2
	j	main_loop
tile_t8:
	bnez	$t8, add_random_tile
	li	$t8, 2
	j	main_loop
tile_t9:
	bnez	$t9, add_random_tile
	li	$t9, 2
	j	main_loop
																
rng_disable:
	li	$s0, 3	
	
	li 	$v0, 4 		
    	la 	$a0, RNG_DISABLED
    	syscall
    	
    	j	input_move
rng_enable:	
	li	$s0, 4	
	
	li 	$v0, 4 		
    	la 	$a0, RNG_ENABLED
    	syscall
    	
    	j	input_move