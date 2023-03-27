##############################################################################
# Example: Displaying Pixels
#
# This file demonstrates how to draw pixels with different colours to the
# bitmap display.
##############################################################################

######################## Bitmap Display Configuration ########################
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
##############################################################################
    .data
ADDR_DSPL:
    .word 0x10008000

    .text
    .globl main

main:

    li $t1, 0xff0000        # $t1 = red
    li $t2, 0x00ff00        # $t2 = green
    li $t3, 0x0000ff        # $t3 = blue
    li $t4, 0x888888        # $t4 = grey

    lw $t0, ADDR_DSPL       # $t0 = base address for display
    # sw $t1, 0($t0)          # paint the first unit (i.e., top-left) red
    # sw $t2, 4($t0)          # paint the second unit on the first row green
    # sw $t3, 128($t0)        # paint the first unit on the second row blue

    li $t5, 0x00000000
    li $t6, 0x00000020 # stores 32
    
    jal paint_top_wall
    jal reset_to_left
    jal paint_left_wall
    jal reset_to_right
    jal paint_right_wall
    jal reset_to_brick
    jal paint_brick
    jal exit
    

return: 
    jr $ra
    
paint_top_wall:
    beq $t5, $t6, return
    sw $t4, 0($t0)          # paint the first unit (i.e., top-left) red
    addi $t0, $t0, 4
    addi $t5, $t5, 1
    j paint_top_wall

reset_to_left:
    li $t5, 0 
    li $t6, 28

paint_left_wall:
    # li $v0, 32
    # li $a0, 1000
    # syscall               # Sleep for 1 second
    beq $t5, $t6, return
    li $t4, 0x888888
    sw $t4, 0($t0)
    addi $t0, $t0, 128
    addi $t5, $t5, 1
    j paint_left_wall
    
reset_to_right:
    lw $t0, ADDR_DSPL
    li $t5, 0 
    li $t6, 29
    addi $t0, $t0, 124

paint_right_wall:
    # li $v0, 32
    # li $a0, 1000
    # syscall               # Sleep for 1 second
    beq $t5, $t6, return
    sw $t4, 0($t0)          # Colour the pixel at $t0 with $t4
    addi $t0, $t0, 128
    addi $t5, $t5, 1
    j paint_right_wall
    
reset_to_brick:
    lw $t0, ADDR_DSPL       
    addi $t0, $t0, 0x180      # First non-wall empty space
    addi $t0, $t0, 4
    li $t5, 0
    li $t6, 4               # Length of brick

paint_brick:
    beq $t5, $t6, return
    li $t4, 0xff0000
    sw $t4, 0($t0)
    addi $t0, $t0, 4        # Moves 4 bytes (to the next pixel)
    addi $t5, $t5, 1
    j paint_brick
    
paint_brick_row:
    addi $sp, $sp, -4       # Allocating 4 bytes into stack
    sw $ra, 0($sp)
    
    
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    j return                # Returns to $ra
    
exit:
    li $v0, 10              # terminate the program gracefully
    syscall