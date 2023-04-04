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
PADDLE:
    .word 0x10008F38 # position of the paddle
    
BALL:
    .word 0x10008EC0 # 0:   Position of the ball
    .word 16         # 4:   x-coord of the ball
    .word 29         # 8:   y-coord of the ball
    .word 0          # 12:  x-velocity of the ball
    .word 0          # 16:  y-velocity of the ball
    .word 0x10008FC0 # 20:  Collision address
    .word 0x10008EC0 # 24:  Previous position

    

##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Brick Breaker game.
main:
    # Variable definitions
    lw $t1, PADDLE # temporary load
    add $s4, $t1, -4 # $s4 = PADDLE ADDRESS TO DELETE (Local variable that all functions can access)
    
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
    
    # can't we also just draw the walls once
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
    lw $t3, ADDR_KBRD               # $t3 = base address for keyboard
    lw $t8, 0($t3)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	jal update_ball
	# 3. Draw the screen
	jal draw_screen
	# 4. Sleep 0.01 second (0.05 second and above has keyboard problems)
	li $v0, 32
	li $a0, 10
	syscall
    # 5. Go back to 1
    b game_loop
    
#########
# Helper labels/functions
#########
coords_to_address: # Takes $a0 and $a1 as x and y coordinates respectively. Returns address in $a3.
    li $a3, 4
    mult $a0, $a3       # Converting x coord to address offset
    mflo $a0
    mult $a1, $a3       # Converting y coord to address offset
    mflo $a1
    li $a3, 32
    mult $a1, $a3
    mflo $a1
    
    lw $a3, ADDR_DSPL
    add $a3, $a3, $a0 # x offset
    add $a3, $a3, $a1 # y offset
    
    jr $ra
    
update_ball:
    addi $sp, $sp, -4 # Jal-safe
    sw $ra, 0($sp)
        
    # Performing collision check
    # jal ball_collision_check
    la $t4, BALL    # Loading Ball struct address
    lw $t5, 0($t4)  # Loading Ball address
    lw $t0, 4($t4)  # Loading x-coord
    lw $t1, 8($t4)  # Loading y-coord
    lw $t2, 12($t4) # Loading x-velocity
    lw $t3, 16($t4) # Loading y-velocity


    add $t0, $t0, $t2 # Updating x-coord
    add $t1, $t1, $t3 # Updating y-coord
    
    
    # Converting coordinates to address and storing prev
    add $a0, $t0, $zero
    add $a1, $t1, $zero
    jal coords_to_address
    sw $t5, 24($t4)
    add $t5, $a3, $zero

    sw $t5, 0($t4)  # Store Ball address
    sw $t0, 4($t4)  # Store x-coord
    sw $t1, 8($t4)  # Store y-coord
    sw $t2, 12($t4) # Store x-velocity
    sw $t3, 16($t4) # Store y-velocity
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
ball_collision_check: # Checks for collision and appropriately changes the velocity of ball, assumes 
    la $t4, BALL      # Loading Ball struct
    lw $t5, 0($t4)    # Loading Ball address
    lw $t0, 4($t4)    # Loading x-coord
    lw $t1, 8($t4)    # Loading y-coord
    lw $t2, 12($t4)   # Loading x-velocity
    lw $t3, 16($t4)   # Loading y-velocity

    # Check cardinals
    add $t5, $t0, $zero     # Loading pixel above
    addi $t6, $t1, -1
    
    add $t5, $t0, $zero     # Loading pixel below 
    addi $t6, $t1,  1
    
    addi $t5, $t0, -1       # Loading pixel left 
    add $t6, $t1, $zero
    
    addi $t5, $t0, 1        # Loading pixel right 
    add $t6, $t1, $zero
    
    # Check diagonals
    beq $t9, $zero, return  # If no collisions in cardinals
    addi $t5, $t0, -1       # Loading pixel top-left
    addi $t6, $t1, -1
    
    addi $t5, $t0, 1        # Loading pixel top-right
    addi $t6, $t1,  1
    
    addi $t5, $t0, -1       # Loading pixel bot-left
    addi $t6, $t1, -1
    
    addi $t5, $t0, 1        # Loading pixel bot-right 
    addi $t6, $t1, -1
    
    jr $ra
    
keyboard_input:
    addi $sp, $sp, -4       # Allocating 4 bytes into stack
    sw $ra, 0($sp)

    lw $a0, 4($t3)    # Load second word from keyboard
    beq $a0, 0x61, respond_to_a    # Check if the key a was pressed (move paddle left)
    beq $a0, 0x64, respond_to_d    # Check if the key d was pressed (move paddle right)
    beq $a0, 0x71, respond_to_q    # Check if the key q was pressed (exit game)
    # li $v0, 1                    # ask system to print $a0
    # syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
    

respond_to_a:
    lw $t2, PADDLE
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 3844
    
    beq $t2, $t0, return
    add $s4, $t2, 16
    addi $t2, $t2, -4
    sw $t2, PADDLE
    
    jr $ra
    
respond_to_d:
    lw $t2, PADDLE
    lw $t0, ADDR_DSPL
    
    addi $t0, $t0, 3944
    beq $t2, $t0, return
    add $s4, $t2, $zero
    addi $t2, $t2, 4
    sw $t2, PADDLE
    
    jr $ra
    
respond_to_q:
    j exit
    
reset_to_top:
    lw $a2, ADDR_DSPL
    li $a0, 0
    li $a1, 32 # Length of top
    lw $a3, GRAY
    jr $ra
    
reset_to_left:
    lw $a2, ADDR_DSPL
    li $a0, 0
    li $a1, 32 # Length of left
    lw $a3, GRAY
    jr $ra
    
reset_to_right:
    lw $a2, ADDR_DSPL
    addi $a2, $a2, 124
    li $a0, 0
    li $a1, 32 # Length of right
    lw $a3, GRAY
    jr $ra
    
reset_paddle:
    lw $t7, BLACK
    sw $t7, 0($s4)
    li $a0, 0
    li $a1, 5
    lw $t6, PADDLE
    add $a2, $t6, $zero
    lw $a3, PADDLE_COLOUR
    
    jr $ra
reset_red_brick_row:
    li $a0, 0 # set counter for drawing bricks
    li $a1, 5 # set end counter
    lw $a3, RED # set color
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 0x180 # 3 Rows down
    addi $t0, $t0, 16     # 4 Pixels right
    move $a2, $t0
    
    jr $ra
    
reset_green_brick_row:
    li $a0, 0 # set counter for drawing bricks
    li $a1, 5 # set end counter
    lw $a3, GREEN # set color
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 0x280 # 3 Rows down
    addi $t0, $t0, 16     # 4 Pixels right
    move $a2, $t0
    
    jr $ra
    
reset_blue_brick_row:
    li $a0, 0 # set counter for drawing bricks
    li $a1, 5 # set end counter
    lw $a3, BLUE # set color
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 0x380 # 3 Rows down
    addi $t0, $t0, 16     # 4 Pixels right
    move $a2, $t0
    
    jr $ra
    
paint_hline: # Paints horizontal line with $t6 pixels at $t0
    add $t5, $a0, $zero # counter
    add $t6, $a1, $zero # end of counter
    add $t0, $a2, $zero # left-most pixel of starting line
    add $t7, $a3, $zero # color
    
    loop_hline:
        beq $t5, $t6, return
        sw $t7, 0($t0)
        addi $t0, $t0, 4
        addi $a2, $a2, 4
        addi $t5, $t5, 1
        j loop_hline

paint_vline: # Paints vertical line with $t6 pixels at $t0
    add $t5, $a0, $zero # counter
    add $t6, $a1, $zero # end of counter
    add $t0, $a2, $zero # left-most pixel of starting line
    add $t7, $a3, $zero # color

    loop_vline: 
        beq $t5, $t6, return
        sw $t7, 0($t0)
        addi $t0, $t0, 128
        addi $t5, $t5, 1
        j loop_vline
    
paint_brick_row:
    add $t5, $a0, $zero # counter
    add $t6, $a1, $zero # end of counter
    # note that color stored in the argument $a3
    
    loop_brick_row:
        beq $t5, $t6, return
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        
        jal paint_brick
        
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        addi $a2, $a2, 4
        addi $t5, $t5, 1
        j loop_brick_row

paint_brick: # Paints 4 pixel brick at $t0, $t0 is then the address of the last pixel
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $t5, 4($sp)
    sw $t6, 8($sp)
    
    li $a0, 0
    li $a1, 4
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

paint_ball: # Erases previous position then paints current position
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    la $t0, BALL
    lw $a0, 4($t0)
    lw $a1, 8($t0)
    jal coords_to_address   # $a3 contains position of ball
    lw $t1, 24($t0)         # $t1 contains position of prev
    
    beq $a3, $t1, paint_ball_normally # If prev and ball are the same, dont erase
    lw $t7, BLACK
    sw $t7, 0($t1)
    
    paint_ball_normally:
        lw $t7, WHITE
        sw $t7, 0($a3)
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

return:
    jr $ra
exit:
    li $v0, 10              # terminate the program gracefully
    syscall


