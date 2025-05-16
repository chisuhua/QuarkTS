    .global _start
    .section .text
    .type   _start, @function

_start:
.option push
.option norelax
1:auipc gp, %pcrel_hi(__global_pointer$)
  addi  gp, gp, %pcrel_lo(1b)
.option pop

    # 设置栈指针 sp = _stack_end
    la sp, _stack_end
    addi sp, sp, -16    /* 对齐堆栈指针（16 字节对齐） */

    /* 2. 清零 .bss 段 */
    la a0, __bss_start  /* 获取 .bss 段起始地址 */
    la a1, _end         /* 获取 .bss 段结束地址 */
    beq a0, a1, .bss_done  /* 如果 .bss 为空，跳过清零步骤 */

.bss_clear_loop:
    sw zero, 0(a0)      /* 将 0 写入当前地址 */
    addi a0, a0, 4      /* 移动到下一个 8 字节位置 */
    bne a0, a1, .bss_clear_loop  /* 循环直到 .bss 结束 */
.bss_done:

    /* 4. 调用 main() 函数 */
    jal ra, main

    /* 5. 无限循环（防止程序返回） */
    j .
