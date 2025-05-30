
.section .text
.global loop10inst
.global loop100inst
.type test_loop, @function

loop10inst:
    mv      t0,a0          # 设置循环次数为 500，总指令数为 500 × 2 = 1000
loop10start:
    addi    t0, t0, -1       # 减 1
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    bnez    t0, loop10start
    ret

loop100inst:
    mv      t0,a0          # 设置循环次数为 500，总指令数为 500 × 2 = 1000
loop100start:
    addi    t0, t0, -1       # 减 1
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    bnez    t0, loop100start
    ret
