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
    sw          $zero, 68($t0)

    bnez        $s0, _HeadnotNull
        la      $s0, 0($t0)
        la      $s1, 0($t0)
        b       _loop_for_input

_HeadnotNull:
    # Sort
    # $s0 is head
    # $s1 is tail
    # $t0 is the new input node
    # $t1 is the current node
    # $t2 is the previous node
    # $t3 is the compare result

    # Previous = NULL
    li      $t2, 0
    move    $t1, $s0        # $t1 begins from head
    _sort_loop:
        beqz    $t1, _insert_at_last

        # Call compare function
        addi    $sp, $sp, -4
        sw      $ra, 0($sp)

        move    $a0, $t0
        move    $a1, $t1
        jal     comp_two_pizza

        move    $t3, $v0

        lw      $ra, 0($sp)
        addi    $sp, $sp, 4

        # if $t0 > $t1 ($t3 == 1)
        bne     $t3, 1, _else_not_one
            sw      $t1, 68($t0)        # t0.next = t1
            beqz    $t2, _previous_is_null
                sw      $t0, 68($t2)    # (t2)previous.next = t0(new input)
                b       _sort_end_loop

            _previous_is_null:
                sw      $t1, 68($t0)        # t0.next = t1
                move    $s0, $t0            # set $t0 as head
                b       _sort_end_loop

        _else_not_one:
            # t2 = t1
            move    $t2, $t1
            # t1 = t1.next
            lw      $t1, 68($t1)
            b       _sort_loop

    _insert_at_last:
        # t2.next = t0
            sw      $t0, 68($t2)
        # s1 = t0
            move    $s1, $t0

    _sort_end_loop:

    # sw          $t0, 68($s1)
    # la          $s1, 0($t0)
b   _loop_for_input

_loop_out_input:
    # Loop the linked list and print
    # $s0 is head
    # $t0 is this node
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
    b           _loop_linked_list


    _end_print:

    jr $ra
.end main




comp_two_pizza:
    # Use registers, $s0, $s1, $s2, $s3
    addi    $sp, $sp, -16
    sw      $s0, 0($sp)
    sw      $s1, 4($sp)
    sw      $s2, 8($sp)
    sw      $s3, 12($sp)


    l.s    $f4, 64($a0)    # $f4 = ppd_0
    l.s    $f5, 64($a1)    # $f5 = ppd_1
    # if ppd_0 > ppd_1
    c.le.s  $f4, $f5
    bc1t    _else
        b       _return_1

    # else (ppd_0 <= ppd_1):
    _else:
        # if ppd_0 == ppd_1:
        c.lt.s      $f4, $f5
        bc1t        _else_smaller
            # Loop from the name
            # Load two names, $s0, $s1
            la      $s0, 0($t0)
            la      $s1, 0($t1)

            # For loop
            _name_sort_loop:
            # Load bytes for s0, s1, they are s2, s3
            lb      $s2, 0($s0)
            lb      $s3, 0($s1)
            # if s2 != null
            beqz    $s2, _return_1
                # if s3 != null
                beqz    $s3, _return_minus_1
                    # if s2 < s3
                    bge    $s2, $s3, _elseif_bigger_orEqual
                        b       _return_1
                    
                    _elseif_bigger_orEqual:
                        # if s2 >= s3
                        bne     $s2, $s3, _elseelseif_bigger
                            # s2 == s3
                            b   _continue_name_sort

                        # if s2 > s3
                        _elseelseif_bigger:
                            b       _return_minus_1


            _continue_name_sort:
                addi    $s0, $s0, 4
                addi    $s1, $s1, 4
                b       _name_sort_loop


            # _end_name_sort_loop:

        # else if ppd_0 < ppd_1
        _else_smaller:
            b       _return_minus_1

    # _end_if:

    _return_1:
        li      $v0, 1
        b       _return

    _return_minus_1:
        li      $v0, -1
        b       _return

    _return:

    lw      $s0, 0($sp)
    lw      $s1, 4($sp)
    lw      $s2, 8($sp)
    lw      $s3, 12($sp)
    addi    $sp, $sp, 16
    jr      $ra


.data
pizza_name_str: .asciiz "Pizza name: "
pizza_dia_str:  .asciiz "Pizza diameter: "
pizza_cost_str: .asciiz "Pizza cost: "
PI:             .float  3.14159265358979323846
space:          .asciiz " "
nln:            .asciiz "\n"
done_str:       .asciiz "DONE"
