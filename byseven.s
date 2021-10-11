.text
.globl main
main:
    addi	$sp, $sp, -8        # $sp = $sp - 8, move stack lower
    sw      $ra, 4($sp)         # Store $ra into stack
    sw      $t0, 0($sp)         # Store $t0 into stack

    la      $a0, ask_msg		# Load the adress of the message into $a0
    li      $v0, 4              # $t0 = 4, let syscall to print
    syscall

    li      $v0, 5              # Read an integer
    syscall
    move    $t0, $v0            # Store the input into $t0

    li      $t1, 1              # set $t1 as 1
    li      $t3, 7              # set $t3 as 7

    # For loop
_for_loop:
    blez    $t0, _out_loop

    _inner_for_loop:
        div		$t1, $t3          # $t1 / $t3 (7)
        mfhi	$t2             # $t2 = $t1 mod 2 

        beqz    $t2, _out_inner_for_loop

        addi    $t1, $t1, 1

        j		_inner_for_loop     # jump to _inner_for_loop

    _out_inner_for_loop:
        #   Print $t1
        li      $v0, 1              # Print an integer
        move    $a0, $t1            # Copy $t0 to $a0
        syscall

        li      $v0, 4              # Print an integer
        la      $t4, nln            # $t4 = address of new line
        move    $a0, $t4
        syscall
        addi    $t1, $t1, 1
    
    addi    $t0, $t0, -1

    j		_for_loop           # jump to _for_loop
    

_out_loop:


    lw      $t0, 0($sp)
    lw      $ra, 4($sp)
    addi    $sp, $sp, 8
    jr		$ra					# jump to $ra
.end main


.data
ask_msg: .asciiz "Input N: \n"
nln: .asciiz "\n"
buffer: .space 4