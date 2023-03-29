################ CSC258H1F Fall 2022 Assembly Final Project ##################
# This file contains our implementation of Breakout.
#
# Student 1: Name, Student Number
# Student 2: Charlie Tao, 1008251589
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       1
# - Unit height in pixels:      1
# - Display width in pixels:    32
# - Display height in pixels:   32
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
    
# Standard Colours
RED:
    .word 0xff0000
GREEN:
    .word 0x00ff00
BLUE:
    .word 0x0000ff

##############################################################################
# Mutable Data
##############################################################################
    
##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Brick Breaker game.
main:
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    li $t1, 64        # $t1 = ball position
    li $t2, 56        # $t2 = paddle position
    lw $t3, ADDR_KBRD        # $t3 = base address for keyboard
    li $t4, 0x888888        # $t4 = grey
    li $t5, 0x00000000 # counter for functions
    li $t6, 0x00000020 # stores 32
    
    # Initialize the game
    jal draw_screen
    jal game_loop
    
    j exit
    
draw_screen:
    addi $sp, $sp, -4       # Allocating 4 bytes into stack
    sw $ra, 0($sp)
    
    jal paint_top_wall
    jal reset_to_left
    jal paint_left_wall
    jal reset_to_right
    jal paint_right_wall
    
    lw $t7, RED # set t7 to be red for the paint_brick_row
    lw $t0, ADDR_DSPL # reset display address
    addi $t0, $t0, 256
    addi $t0, $t0, 16 # set starting point
    li $t5, 0 
    li $t6, 5
    jal paint_brick_row
    
    lw $t7, GREEN # set t7 to be green for the paint_brick_row
    lw $t0, ADDR_DSPL # reset display address
    addi $t0, $t0, 512
    addi $t0, $t0, 16 # set starting point
    li $t5, 0 
    li $t6, 5
    jal paint_brick_row
    
    lw $t7, BLUE # set t7 to be blue for the paint_brick_row
    lw $t0, ADDR_DSPL # reset display address
    addi $t0, $t0, 768
    addi $t0, $t0, 16 # set starting point
    li $t5, 0 
    li $t6, 5
    jal paint_brick_row
    
    li $t7, 0xfa19bc # set t7 to be  for the paint_paddle
    lw $t0, ADDR_DSPL # reset display address
    addi $t0, $t0, 3840
    add $t0, $t0, $t2 # set starting point
    jal paint_paddle
    
    li $t7, 0xffffff # set t7 to be white for the paint_ball
    lw $t0, ADDR_DSPL # reset display address
    addi $t0, $t0, 3712
    add $t0, $t0, $t1 # set starting point
    jal paint_ball
    
    # Reset $ra
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
#########
# Helper labels/functions
#########
game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep
    # 5. Go back to 1
    
    # 1a. Check if key has been pressed
    lw $t3, ADDR_KBRD               # $t3 = base address for keyboard
    lw $t8, 0($t3)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	jal draw_screen
	# 4. Sleep
	
    # 5. Go back to 1
    b game_loop
    
# 
    
keyboard_input:
    addi $sp, $sp, -4       # Allocating 4 bytes into stack
    sw $ra, 0($sp)

    lw $a0, 4($t3)    # Load second word from keyboard
    beq $a0, 0x61, respond_to_a    # Check if the key a was pressed (move paddle left)
    beq $a0, 0x64, respond_to_d    # Check if the key d was pressed (move paddle right)
    # li $v0, 1                       # ask system to print $a0
    # syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
    
respond_to_a:
    sub $t2, $t2, 4
    beq $t2, 4, hit_left_max
    jr $ra
hit_left_max:
    li $t2, 4
    jr $ra

respond_to_d:
    add $t2, $t2, 4
    beq $t2, 104, hit_right_max
    jr $ra
hit_right_max:
    li $t2, 104
    jr $ra

return: 
    jr $ra
    
paint_top_wall:
    beq $t5, $t6, return
    sw $t4, 0($t0)          # paint the first unit (i.e., top-left) red
    addi $t0, $t0, 4
    addi $t5, $t5, 1
    j paint_top_wall

reset_to_left:
    lw $t0, ADDR_DSPL
    li $t5, 0 
    li $t6, 32

paint_left_wall:
    beq $t5, $t6, return
    li $t4, 0x888888
    sw $t4, 0($t0)
    addi $t0, $t0, 128
    addi $t5, $t5, 1
    j paint_left_wall
    
reset_to_right:
    lw $t0, ADDR_DSPL
    li $t5, 0 
    li $t6, 32
    addi $t0, $t0, 124

paint_right_wall:
    beq $t5, $t6, return
    sw $t4, 0($t0)
    addi $t0, $t0, 128
    addi $t5, $t5, 1
    j paint_right_wall

paint_brick_row:
    beq $t5, $t6, return
    addi $sp, $sp, -4       # Allocating 4 bytes into stack
    sw $ra, 0($sp)
    
    jal paint_brick
    addi $t0, $t0, 4
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    addi $t5, $t5, 1
    j paint_brick_row
    
    
paint_brick:
    # t7 is set to a color set in main 
    sw $t7, 0($t0)
    addi $t0, $t0, 4
    sw $t7, 0($t0)
    addi $t0, $t0, 4 
    sw $t7, 0($t0)
    addi $t0, $t0, 4 
    sw $t7, 0($t0)
    addi $t0, $t0, 4 
    
    jr $ra
    
paint_paddle:
    sw $t7, 0($t0)
    addi $t0, $t0, 4
    sw $t7, 0($t0)
    addi $t0, $t0, 4
    sw $t7, 0($t0)
    addi $t0, $t0, 4
    sw $t7, 0($t0)
    addi $t0, $t0, 4
    sw $t7, 0($t0)
    addi $t0, $t0, 4
    
    jr $ra
    
paint_ball:
    sw $t7, 0($t0)
    jr $ra

exit:
    li $v0, 10              # terminate the program gracefully
    syscall


