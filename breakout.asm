################ CSC258H1F Fall 2022 Assembly Final Project ##################
# This file contains our implementation of Breakout.
#
# Student 1: Name, Student Number
# Student 2: Charlie Tao, 1008251589
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   256
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
WHITE:
    .word 0xffffff
BLACK:
    .word 0x000000
GRAY:
    .word 0x888888
PADDLE_COLOUR:
    .word 0xfa19bc

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
    lw $t0, ADDR_DSPL  # $t0 = base address for display
    add $t1, $t0, 3776         # $t1 = ball position at any time
    add $t2, $t0, 3896         # $t2 = paddle position at any time
    lw $t3, ADDR_KBRD  # $t3 = base address for keyboard
    add $t4, $t2, -4 # $t4 = PIXEL ADDRESS TO DELETE
    li $t5, 0x00000000 # counter for functions
    li $t6, 0x00000020 # end of counter
    lw $t7, GRAY       # TEMP COLOUR (but always set first)
    li $t8, 0x00000000 # keyboard input saver
    li $t9, 0          # NOT IN USE
    
    # Initialize the game
    jal reset_red_brick_row
    jal paint_brick_row
    jal reset_green_brick_row
    jal paint_brick_row
    jal reset_blue_brick_row
    jal paint_brick_row
    
    jal draw_screen
    jal game_loop
    
    j exit
    
draw_screen:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    jal reset_to_top
    jal paint_hline
    jal reset_to_left
    jal paint_vline
    jal reset_to_right
    jal paint_vline
    jal reset_paddle
    jal paint_paddle
    jal paint_ball

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
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 3844
    beq $t2, $t0, return
    add $t4, $t2, 16
    addi $t2, $t2, -4
    jr $ra
respond_to_d:
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 3944
    beq $t2, $t0, return
    add $t4, $t2, $zero
    addi $t2, $t2, 4
    jr $ra
reset_to_top:
    lw $t0, ADDR_DSPL
    li $t5, 0
    li $t6, 32 # Length of top
    lw $t7, GRAY
    jr $ra
reset_to_left:
    lw $t0, ADDR_DSPL
    li $t5, 0
    li $t6, 32 # Length of left
    lw $t7, GRAY
    jr $ra
reset_to_right:
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 124
    li $t5, 0
    li $t6, 32 # Length of right
    lw $t7, GRAY
    jr $ra
reset_paddle:
    lw $t7, BLACK
    sw $t7, 0($t4)
    li $t5, 0
    li $t6, 5
    add $t0, $t2, $zero
    lw $t7, PADDLE_COLOUR 
    jr $ra
reset_red_brick_row:
    lw $t7, RED
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 0x180 # 3 Rows down
    addi $t0, $t0, 16     # 4 Pixels right
    li $t5, 0
    li $t6, 5
    jr $ra
reset_green_brick_row:
    lw $t7, GREEN
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 0x280  # 5 Rows down
    addi $t0, $t0, 16     # 4 Pixels right
    li $t5, 0
    li $t6, 5
    jr $ra
reset_blue_brick_row:
    lw $t7, BLUE
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 0x380  # 7 Rows down
    addi $t0, $t0, 16     # 4 Pixels right
    li $t5, 0
    li $t6, 5
    jr $ra
    
paint_hline: # Paints horizontal line with $t6 pixels at $t0
    beq $t5, $t6, return
    sw $t7, 0($t0)
    addi $t0, $t0, 4
    addi $t5, $t5, 1
    j paint_hline

paint_vline: # Paints vertical line with $t6 pixels at $t0
    beq $t5, $t6, return
    sw $t7, 0($t0)
    addi $t0, $t0, 128
    addi $t5, $t5, 1
    j paint_vline
    
paint_brick_row:  
    beq $t5, $t6, return
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    jal paint_brick
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    addi $t0, $t0, 4
    addi $t5, $t5, 1
    j paint_brick_row

paint_brick: # Paints 4 pixel brick at $t0, $t0 is then the address of the last pixel
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $t5, 4($sp)
    sw $t6, 8($sp)
    
    li $t5, 0
    li $t6, 4
    jal paint_hline
    
    lw $ra, 0($sp)
    lw $t5, 4($sp)
    lw $t6, 8($sp)
    addi $sp, $sp, 12
    jr $ra
    
paint_paddle:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    jal paint_hline
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

paint_ball:
    lw $t7, WHITE
    sw $t7, 0($t1)
    jr $ra

return:
    jr $ra
exit:
    li $v0, 10              # terminate the program gracefully
    syscall


