#include "qconfig.h"
    .global _start
    .section .text
    .type   _start, @function

_start:
.option push
.option norelax
1:auipc gp, %pcrel_hi(__global_pointer$)
  addi  gp, gp, %pcrel_lo(1b)
.option pop

    csrr a0, mhartid

    la sp, _stack_start
    slli t0, a0, (THREAD_STACK_SHIFT)
    add sp, sp, t0
    addi sp, sp, -16    /* 对齐堆栈指针（16 字节对齐） */

    bnez a0, .wait_bss_init

    /* 2. 清零 .bss 段 */
    la a1, __bss_start  /* 获取 .bss 段起始地址 */
    la a2, __bss_end         /* 获取 .bss 段结束地址 */
    beq a1, a2, .bss_clear_done  /* 如果 .bss 为空，跳过清零步骤 */

.bss_clear_loop:
    sw zero, 0(a1)      /* 将 0 写入当前地址 */
    addi a1, a1, 4      /* 移动到下一个 8 字节位置 */
    bne a1, a2, .bss_clear_loop  /* 循环直到 .bss 结束 */
.bss_clear_done:

    /* 写入同步标志， 表示.bss初始化完成*/
    la t0, __bss_init_done
    li t1, 1
    sw t1, 0(t0)

.wait_bss_init:
    la  t0, __bss_init_done
.bss_poll:
    lw  t1, 0(t0)
    beqz t1, .bss_poll

    /* 4. 调用 main() 函数 */
    mv a0, a0
    jal ra, main
_exit:
    /* 5. 无限循环（防止程序返回） */
    /*j _exit*/
    li a7, 93
    li a0, 0
    ecall

.section .data
__bss_init_done:
    .word 0
