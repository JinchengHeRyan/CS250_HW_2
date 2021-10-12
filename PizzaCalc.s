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
    # malloc 72 bytes and stores in $s0
    li      $v0, 9
    li      $a0, 72
    syscall
    move    $s0, $v0

    # Print "Pizza name: "
    li      $v0, 4
    la      $a0, pizza_name_str
    syscall

    # Read string buffer
    la      $a0, 0($s0)
    li      $a1, 64
    li      $v0, 8
    syscall

    # Remove \n at the last of the name
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)

    la      $a0, 0($s0)
    jal     _remove_nln

    lw      $ra, 0($sp)
    addi    $sp, $sp, 4

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

    # Load PI into $f6
    l.s         $f6, PI

    # Compute ppd, ppd = (dia/2)^2*PI / cost, stores into $f4
    li.s         $f7, 2.0   # load 2.0 into $f7
    div.s       $f4, $f4, $f7
    mul.s       $f4, $f4, $f4
    mul.s       $f4, $f4, $f6
    div.s       $f4, $f4, $f5

    # Store the result into struct $s0
    s.s         $f4, 64($s0)

    li          $v0, 4
    la          $a0, 0($s0)
    syscall
    li          $v0, 4
    la          $a0, space
    syscall
    li          $v0, 2
    l.s         $f12, 64($s0)
    syscall


    jr $ra
.end main

.data
pizza_name_str: .asciiz "Pizza name: "
pizza_dia_str:  .asciiz "Pizza diameter: "
pizza_cost_str: .asciiz "Pizza cost: "
PI:             .float  3.14159265358979323846
space:          .asciiz " "
nln:            .asciiz "\n"
