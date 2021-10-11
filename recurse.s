.text
.globl main
main:
    addi	$sp, $sp, -4        # $sp = $sp - 8, move stack lower
    sw      $ra, 0($sp)         # Store $ra into stack

    # addi    $sp, $sp, -4
    # sw      $t0, 0($sp)         # Store $t0 into stack

    # Print the prompt message
    la      $a0, ask_msg		# Load the adress of the message into $a0
    li      $v0, 4              # $t0 = 4, let syscall to print
    syscall

    # Get the input value to $t0
    li      $v0, 5              # Read an integer
    syscall
    move    $t0, $v0            # Store the input into $t0

    move    $a0, $t0
    addi    $sp, $sp, -4
    sw      $t0, 0($sp)         # Store t0 into stack

    jal func_f

    lw      $t0, 0($sp)         # Restore t0 from stack
    addi    $sp, $sp, 4

    move    $a0, $v0
    li      $v0, 1
    syscall

    lw      $ra, 0($sp)
    addi    $sp, $sp, 4

    jr      $ra


.end main


func_f:
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)
    # li      $v0, 1
    # syscall

    # t0 = N
    move    $t0, $a0        # t0 stores the input value, caller-saved

    # if (t0 == 0) reutrn 0
    beqz    $t0, return_0
    
    addi    $sp, $sp, -4
    sw      $t0, 0($sp)

    # t0 -== 1
    addi    $t0, $t0, -1
    move    $a0, $t0
    jal     func_f

    lw      $t0, 0($sp)
    addi    $sp, $sp, 4

    # t1 = f(N-1)
    move    $t1, $v0        # t1 stores the returned value from f(N-1)

    addi    $t0, $t0, -1
    li      $t2, 3
    mul     $t0, $t0, $t2
    add     $t0, $t0, $t1
    addi    $t0, $t0, 1
    move    $v0, $t0
    j exit_func_f

    return_0:
        li      $v0, 2
        j exit_func_f

    exit_func_f:
        lw      $ra, 0($sp)
        addi    $sp, $sp, 4
        jr      $ra


.data
ask_msg: .asciiz "Input N: \n"
