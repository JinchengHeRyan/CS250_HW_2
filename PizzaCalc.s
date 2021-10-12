# [0]  name, string 64 bytes
# [64] ppd,  float 4bytes
# [68] next, ptr 4 bytes
# size = 72


.text

# Remove '\n' for the name
_remove_nln:
    # used register: t0, t1
    addi    $sp, $sp, -8
    sw      $t1, 0($sp)
    sw      $t0, 4($sp)

    li      $t0, 0

    _loop:
        lb      $t1, 0($a0)
        beq     $t1, '\n', _out_loop
        addi    $a0, $a0, 1
        b       _loop

    _out_loop:
        sb      $zero, 0($a0)

    lw      $t0, 4($sp)
    lw      $t1, 0($sp)
    addi    $sp, $sp, 8
    jr      $ra



.globl main
main:
    li      $s0, 0      # head is NULL
    li      $s1, 0      # tail is NULL

_loop_for_input:
    # malloc 72 bytes and stores in $t0
    li      $v0, 9
    li      $a0, 72
    syscall
    move    $t0, $v0

    # Print "Pizza name: "
    li      $v0, 4
    la      $a0, pizza_name_str
    syscall

    # Read string buffer
    la      $a0, 0($t0)
    li      $a1, 64
    li      $v0, 8
    syscall

    # Remove \n at the last of the name
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)

    la      $a0, 0($t0)
    jal     _remove_nln

    lw      $ra, 0($sp)
    addi    $sp, $sp, 4

    # Compare with DONE
    la      $t4, 0($t0)
    la      $t1, done_str       # $t1 is "DONE"
    _comp_loop:
    lb      $t2, 0($t4)         # $t4 is name
    lb      $t3, 0($t1)
    beq     $t2, $t3, _continue_comp
    b       _isNotDone


    _continue_comp:
    beq     $t3, $zero, _loop_out_input
    addi    $t1, $t1, 1
    addi    $t4, $t4, 1
    b       _comp_loop


_isNotDone:
    # Print "Pizza diameter: "
    li      $v0, 4
    la      $a0, pizza_dia_str
    syscall

    # Read pizza diameter, stores in $f4
    li      $v0, 6
    syscall
    mov.s    $f4, $f0

    # Print "Pizza cost: "
    li      $v0, 4
    la      $a0, pizza_cost_str
    syscall

    # Read pizza cost, float and stores in $f5
    li          $v0, 6
    syscall
    mov.s       $f5, $f0

    # # Print out the float from the $f5
    # li          $v0, 2
    # mov.s       $f12, $f5
    # syscall

    # See if diameter or cost is 0
    li.s        $f0, 0.0
    c.eq.s      $f4, $f0
    bc1t _out_zero
    c.eq.s      $f5, $f0
    bc1t _out_zero

    # Load PI into $f6
    l.s         $f6, PI

    # Compute ppd, ppd = (dia/2)^2*PI / cost, stores into $f4
    li.s         $f7, 2.0   # load 2.0 into $f7
    div.s       $f4, $f4, $f7
    mul.s       $f4, $f4, $f4
    mul.s       $f4, $f4, $f6
    div.s       $f4, $f4, $f5
    b _not_zero

    # Store the result into struct $t0
    _out_zero:
        li.s        $f4, 0.0
    _not_zero:
    s.s         $f4, 64($t0)

    bnez        $s0, _HeadnotNull
        la      $s0, 0($t0)
        la      $s1, 0($t0)

_HeadnotNull:
    sw          $t0, 68($s1)
    la          $s1, 0($t0)
b   _loop_for_input

_loop_out_input:
    # Print out result
    # li          $v0, 4
    # la          $a0, 0($s0)
    # syscall
    # li          $v0, 4
    # la          $a0, space
    # syscall
    # li          $v0, 2
    # l.s         $f12, 64($s0)
    # syscall

    # Loop the linked list and print
    move        $t0, $s0
    _loop_linked_list:
    beqz        $t0, _end_print
    li          $v0, 4
    la          $a0, 0($t0)
    syscall
    li          $v0, 4
    la          $a0, space
    syscall
    li          $v0, 2
    l.s         $f12, 64($t0)
    syscall
    li          $v0, 4
    la          $a0, nln
    syscall

    lw          $t0, 68($t0)
    b _loop_linked_list


    _end_print:




    # Need to sort the list




    jr $ra
.end main

.data
pizza_name_str: .asciiz "Pizza name: "
pizza_dia_str:  .asciiz "Pizza diameter: "
pizza_cost_str: .asciiz "Pizza cost: "
PI:             .float  3.14159265358979323846
space:          .asciiz " "
nln:            .asciiz "\n"
done_str:       .asciiz "DONE"
