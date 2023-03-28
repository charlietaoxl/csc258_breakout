##############################################################################
# Example: Displaying Pixels
#
# This file demonstrates how to draw pixels with different colours to the
# bitmap display.
##############################################################################

######################## Bitmap Display Configuration ########################
# - Unit width in pixels: 1
# - Unit height in pixels: 1
# - Display width in pixels: 32
# - Display height in pixels: 32
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
    
    add $t7, $t1, $zero # set t7 to be red for the paint_brick_row
    lw $t0, ADDR_DSPL # reset display address
    addi $t0, $t0, 256
    addi $t0, $t0, 16 # set starting point
    li $t5, 0 
    li $t6, 5
    jal paint_brick_row
    
    add $t7, $t2, $zero # set t7 to be green for the paint_brick_row
    lw $t0, ADDR_DSPL # reset display address
    addi $t0, $t0, 512
    addi $t0, $t0, 16 # set starting point
    li $t5, 0 
    li $t6, 5
    jal paint_brick_row
    
    add $t7, $t3, $zero # set t7 to be blue for the paint_brick_row
    lw $t0, ADDR_DSPL # reset display address
    addi $t0, $t0, 768
    addi $t0, $t0, 16 # set starting point
    li $t5, 0 
    li $t6, 5
    jal paint_brick_row
    
    li $t7, 0xfa19bc # set t7 to be  for the paint_paddle
    lw $t0, ADDR_DSPL # reset display address
    addi $t0, $t0, 3840
    addi $t0, $t0, 56 # set starting point
    jal paint_paddle
    
    li $t7, 0xffffff # set t7 to be white for the paint_ball
    lw $t0, ADDR_DSPL # reset display address
    addi $t0, $t0, 3712
    addi $t0, $t0, 64 # set starting point
    jal paint_ball

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
    li $t6, 31

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
    li $t6, 32
    addi $t0, $t0, 124

paint_right_wall:
    # li $v0, 32
    # li $a0, 1000
    # syscall               # Sleep for 1 second
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