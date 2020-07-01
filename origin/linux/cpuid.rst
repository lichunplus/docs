.. SPDX-License-Identifier: GPL-2.0

==============
KVM CPUID bits
==============
1. 目前KVM仅支持0x40000000和0x40000001两个半虚拟化Leaf
2. guest执行 #cpuid 0x40000000 ，返回 EAX=0x40000001(兼容考虑：0视为0x40000001)，最大仅支持到0x40000001
                                   EBX|ECX|EDX="KVMKVMKVM"
3. QEMU可能会屏蔽掉部分或者全部KVM特性，因此KVM-Guest也无法保证这些内容完全和文档一致
   -#qemu ... -cpu host,kvm=on,屏蔽掉0x40000001中的KVM特性
   -#qemu ... -cpu host,hv-xxx，修改Hypervisor签名

4. guest执行 #cpuid 0x40000001, 返回EAX和EDX,各个位解释如下：
EAX-bit-00: KVM_FEATURE_CLOCKSOURCE,可使用通过两个MSRs(0x11和0x12)提供的时钟信息（启动时间和运行时间）
EAX-bit-01: KVM_FEATURE_NOP_IO_DELAY,告诉Guest不需要执行IO Delay动作
                                     IO Delay概念: IBM-PC连续执行两个i/o(in/out)指令第二条会报错，依赖适当的延时
                                     linux提供了4个解决方法(make menuconfig Kernel hacking->IO delay type):
                                       -0x80端口(推荐，使用15年后在HP-dv9000z-laptop,AMD64运行奔溃)
                                       -0xed端口(0x80异常后的备选方案)
                                       -udelay(最安全，但浪费性能,用于没有0xed的时候)
                                       -none, 新的PC已经不需要delay了.但i440fx虚拟机除外,q35未知,虚拟化即使是旧machine也无需delay.
                                     参考: http://lkml.iu.edu/hypermail/linux/kernel/0802.2/0766.html
EAX-bit-02: KVM_FEATURE_MMU_OP,已废弃使用，
EAX-bit-03: KVM_FEATURE_CLOCKSOURCE2,新的时钟MSR已经从0x11和0x12挪动到0x4b564d00和0x4b564d01了
EAX-bit-04: KVM_FEATURE_ASYNC_PF,Guest可以访问MSR_KVM_ASYNC_PF_EN获取ASYNC-PF基本功能
EAX-bit-05: KVM_FEATURE_STEAL_TIME,Guest可以从MSR_KVM_STEAL_TIME中获取vCPU被抢占的时间，KVM计算后写入.
EAX-bit-06: KVM_FEATURE_PV_EOI, Guest处理完中断后可以通过写MSR_KVM_EOI_EN来给出EOI
                                注：有些中断控制器还需要CPU在处理完irq后对控制器发出eoi指令（end of interrupt）
EAX-bit-07: KVM_FEATURE_PV_UNHALT,Guest可以使用KVM_HC_KICK_CPU hypercall唤醒处于HALT状态的vCPU.
EAX-bit-08: 无
EAX-bit-09: KVM_FEATURE_PV_TLB_FLUSH, Guest可以通过Hypercall来执行TLB-Flush请求.
EAX-bit-10: KVM_FEATURE_ASYNC_PF_VMEXIT,Guest可以访问MSR_KVM_ASYNC_PF_EN获取ASYNC-PF高级功能
EAX-bit-11: KVM_FEATURE_PV_SEND_IPI, Guest可以通过Hypercall来执行SEND IPI请求.
EAX-bit-12: KVM_FEATURE_POLL_CONTROL,Guest可以访问MSR_KVM_POLL_CONTROL，用于配置KVM Polling-HLT行为
EAX-bit-13: KVM_FEATURE_PV_SCHED_YIELD, 系统调用sched_yield:如果一个线程执行sched_yield(),那么会主动转让一次CPU.
                                        调度器会在适当的时候重新调度该线程.
                                        相似地, vCPU线程可以主动运行PV_SCHED_YIELD,请求Hypervisor主动转让CPU,让其他vCPU优先运行
                                        Hypervisor在适当的时候重新调度该vCPU.
                                        使用：pv-guest给一组vcpu发送ipi后，可以判断目标vCPUs是否有被强制而无法及时响应IPI的vCPU.
                                        如果有的话可以主动调用PV_SCHED_YIELD是否CPU资源, 这样被强制的vCPU可能可以及早被调度去处理IPI.
EAX-bit-14: KVM_FEATURE_ASYNC_PF_INT,Guest可以访问MSR_KVM_ASYNC_PF_INT|MSR_KVM_ASYNC_PF_ACK获取ASYNC-PF高级功能
EAX-bit-15: KVM_FEATURE_MSI_EXT_DEST_ID
EAX-bit-24: KVM_FEATURE_CLOCKSOURCE_STABLE_BIT

EDX-bit-00: KVM_HINTS_REALTIME

-------------------------------------------------------------------------------------------------------

:Author: Glauber Costa <glommer@gmail.com>

A guest running on a kvm host, can check some of its features using
cpuid. This is not always guaranteed to work, since userspace can
mask-out some, or even all KVM-related cpuid features before launching
a guest.

KVM cpuid functions are:

function: KVM_CPUID_SIGNATURE (0x40000000)

returns::

   eax = 0x40000001
   ebx = 0x4b4d564b
   ecx = 0x564b4d56
   edx = 0x4d

Note that this value in ebx, ecx and edx corresponds to the string "KVMKVMKVM".
The value in eax corresponds to the maximum cpuid function present in this leaf,
and will be updated if more functions are added in the future.
Note also that old hosts set eax value to 0x0. This should
be interpreted as if the value was 0x40000001.
This function queries the presence of KVM cpuid leafs.

function: define KVM_CPUID_FEATURES (0x40000001)

returns::

          ebx, ecx
          eax = an OR'ed group of (1 << flag)

where ``flag`` is defined as below:

================================== =========== ================================
flag                               value       meaning
================================== =========== ================================
KVM_FEATURE_CLOCKSOURCE            0           kvmclock available at msrs
                                               0x11 and 0x12

KVM_FEATURE_NOP_IO_DELAY           1           not necessary to perform delays
                                               on PIO operations

KVM_FEATURE_MMU_OP                 2           deprecated

KVM_FEATURE_CLOCKSOURCE2           3           kvmclock available at msrs
                                               0x4b564d00 and 0x4b564d01

KVM_FEATURE_ASYNC_PF               4           async pf can be enabled by
                                               writing to msr 0x4b564d02

KVM_FEATURE_STEAL_TIME             5           steal time can be enabled by
                                               writing to msr 0x4b564d03

KVM_FEATURE_PV_EOI                 6           paravirtualized end of interrupt
                                               handler can be enabled by
                                               writing to msr 0x4b564d04

KVM_FEATURE_PV_UNHALT              7           guest checks this feature bit
                                               before enabling paravirtualized
                                               spinlock support

KVM_FEATURE_PV_TLB_FLUSH           9           guest checks this feature bit
                                               before enabling paravirtualized
                                               tlb flush

KVM_FEATURE_ASYNC_PF_VMEXIT        10          paravirtualized async PF VM EXIT
                                               can be enabled by setting bit 2
                                               when writing to msr 0x4b564d02

KVM_FEATURE_PV_SEND_IPI            11          guest checks this feature bit
                                               before enabling paravirtualized
                                               send IPIs

KVM_FEATURE_POLL_CONTROL           12          host-side polling on HLT can
                                               be disabled by writing
                                               to msr 0x4b564d05.

KVM_FEATURE_PV_SCHED_YIELD         13          guest checks this feature bit
                                               before using paravirtualized
                                               sched yield.

KVM_FEATURE_ASYNC_PF_INT           14          guest checks this feature bit
                                               before using the second async
                                               pf control msr 0x4b564d06 and
                                               async pf acknowledgment msr
                                               0x4b564d07.

KVM_FEATURE_MSI_EXT_DEST_ID        15          guest checks this feature bit
                                               before using extended destination
                                               ID bits in MSI address bits 11-5.

KVM_FEATURE_CLOCKSOURCE_STABLE_BIT 24          host will warn if no guest-side
                                               per-cpu warps are expected in
                                               kvmclock
================================== =========== ================================

::

      edx = an OR'ed group of (1 << flag)

Where ``flag`` here is defined as below:

================== ============ =================================
flag               value        meaning
================== ============ =================================
KVM_HINTS_REALTIME 0            guest checks this feature bit to
                                determine that vCPUs are never
                                preempted for an unlimited time
                                allowing optimizations
================== ============ =================================
