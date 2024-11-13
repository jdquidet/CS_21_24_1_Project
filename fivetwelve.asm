.data
WELCOME: 	.asciiz "Choose [1] or [2]:\n[1] New Game\n[2] Start from a State\n"
BOARD_CONFIG:	.asciiz "Enter a board configuration:\n"
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
ENTER_MOVE:	.asciiz "Enter a move (W=Up, A=Left, S=Down, D=Right, X=Exit):\n"

.text
main:
	li 	$v0, 4
	la 	$a0, WELCOME
	syscall
	
	li 	$v0, 5
	syscall
	move 	$t0, $v0
	
	beq 	$t0, 1, input_random
	beq 	$t0, 2, input_defined

input_random:				# NEW GAME
	li 	$t0, 0
    	
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
    	
    	j 	print_grid		# proceeds to grid printing

	# Used Functions for randomized zero or two #
zero_or_two:
	li 	$a1, 2 
    	li 	$v0, 42  
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

input_defined:				# START FROM A STATE
	li 	$v0, 4 	
    	la 	$a0, BOARD_CONFIG
    	syscall
    	
	li 	$v0, 5
	syscall
	move 	$t1, $v0
	
	li 	$v0, 5
	syscall
	move 	$t2, $v0
	
	li 	$v0, 5
	syscall
	move 	$t3, $v0
	
	li 	$v0, 5
	syscall
	move 	$t4, $v0
	
	li 	$v0, 5
	syscall
	move 	$t5, $v0
	
	li 	$v0, 5
	syscall
	move 	$t6, $v0
	
	li 	$v0, 5
	syscall
	move 	$t7, $v0
	
	li 	$v0, 5
	syscall
	move 	$t8, $v0
	
	li 	$v0, 5
	syscall
	move 	$t9, $v0
	
	j 	print_grid		# proceeds to grid printing

print_grid:				# GRID PRINTING
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
	
	li 	$v0, 4 		
    	la 	$a0, ENTER_MOVE
    	syscall
    	
    	j 	user_move

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
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
		
	jal	get_integer
	move	$a0, $v0
	li	$v0, 4
	syscall
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 8
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
	
user_move:
	
	