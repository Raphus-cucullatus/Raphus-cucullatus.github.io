---
layout: post
title:  "A Case When Guests' Used Persistent Memory Exceeds the Capacity of Host"
date:   2020-03-11 00:00:00 +0800
categories: tech kernel
comments: true
---

Because of the lazy allocation of file system, we can start virtual
machines such that the sum of their DAX-file-backed persistent memory
size exceeds the capacity of host.  I found the virtual machine hangs
with 100% CPU when guests' used persistent memory exceeds the capacity
of host.

Say I `mount` a EXT4-DAX file system on a `pmem` device
(`/dev/pmem1.6`) of 64GiB on `/mnt/mem`.  Then two VMs, each with
50GiB nvdimm device, are started.  These nvdimm devices are backed by
files `VM-50G-0`, `VM-50G-1` under `/mnt/mem`.  This overcommitment of
persistent memory is achieved because of the lazy allocation of the
file system.  `df -h /mnt/mem` shows current used space at host is 15G
rather than 100G (50G + 50G) since the guests have not yet touched all
their persistent memory.

When a VM is touching persistent memory while the available space in
the host file system is used-up, the VM hangs with the following symptoms.

1.  `htop` in host shows 100% CPU usage.
2.  Guest reports "`watchdog: BUG: soft lockup`".
3.  After some space in host is freed, the guest proceeds.

Some details are given below.

`dmesg` in guest shows the call trace when the soft lockup happened:

    [  295.549969] watchdog: BUG: soft lockup - CPU#0 stuck for 23s! [t:1012]
    [  295.551647] Modules linked in: hfsplus hfs vfat fat isofs ip6t_REJECT nf_reject_ipv6 ip6t_rpfilter ipt_REJECT nf_reject_ipv4 xt_conntrack ebtable_nat ebtable_broute ip6table_r
    [  295.551675] CPU: 0 PID: 1012 Comm: t Tainted: G           OEL    5.3.7-301.fc31.x86_64 #1
    [  295.551676] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.12.0-59-gc9ba5276e321-prebuilt.qemu.org 04/01/2014
    [  295.551681] RIP: 0010:__memcpy_flushcache+0x97/0x180
    [  295.551683] Code: 8d 6b e0 4c 8d 62 20 48 89 cf 48 89 ee 48 29 d7 48 83 e6 e0 4c 01 e6 48 8d 04 17 4c 8b 02 4c 8b 4a 08 4c 8b 52 10 4c 8b 5a 18 <4c> 0f c3 00 4c 0f c3 48 08 42
    [  295.551684] RSP: 0000:ffffbb448095f8b8 EFLAGS: 00010286 ORIG_RAX: ffffffffffffff13
    [  295.551686] RAX: ffff8fd6dc38e000 RBX: 0000000000001000 RCX: ffff8fd6dc38e000
    [  295.551686] RDX: ffff8fd292ba3000 RSI: ffff8fd292ba4000 RDI: 00000004497eb000
    [  295.551687] RBP: 0000000000000fe0 R08: 0000000000000000 R09: 0000000000000000                                                                                                  
    [  295.551687] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8fd292ba3020
    [  295.551688] R13: ffff8fd6dc38e000 R14: ffff8fd376b8a640 R15: 0000000000001000
    [  295.551689] FS:  00007f76263bd740(0000) GS:ffff8fd37ba00000(0000) knlGS:0000000000000000
    [  295.551690] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033                
    [  295.551691] CR2: 000000009eb75000 CR3: 00000001102c2006 CR4: 0000000000760ef0
    [  295.551694] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
    [  295.551695] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
    [  295.551695] PKRU: 55555554
    [  295.551696] Call Trace:
    [  295.551702]  write_pmem+0x64/0x90 [nd_pmem]
    [  295.551705]  pmem_do_bvec+0x190/0x410 [nd_pmem]
    [  295.551709]  ? do_get_write_access+0x2f9/0x420
    [  295.551711]  ? jbd2_journal_dirty_metadata+0x194/0x230
    [  295.551713]  pmem_make_request+0xdd/0x2a0 [nd_pmem]
    [  295.551715]  generic_make_request+0xcf/0x320
    [  295.551717]  submit_bio+0x3c/0x160
    [  295.551719]  ? _cond_resched+0x15/0x30
    [  295.551722]  ? __blkdev_issue_zero_pages+0x155/0x1a0
    [  295.551725]  submit_bio_wait+0x53/0x80
    [  295.551727]  blkdev_issue_zeroout+0x141/0x220
    [  295.551728]  ? 0xffffffffb7000000
    [  295.551732]  ext4_issue_zeroout+0x42/0x60
    [  295.551733]  ext4_map_blocks+0x4b3/0x5f0
    [  295.551735]  ? __switch_to_asm+0x34/0x70
    [  295.551736]  ? _cond_resched+0x15/0x30
    [  295.551740]  ? ext4_journal_check_start+0xe/0x80
    [  295.551742]  ext4_iomap_begin+0x13f/0x460
    [  295.551744]  ? grab_mapping_entry+0x144/0x210
    [  295.551745]  dax_iomap_pte_fault.isra.0+0x16f/0x8b0
    [  295.551747]  ? start_this_handle+0xfb/0x450
    [  295.551750]  ext4_dax_huge_fault+0x13e/0x1f0
    [  295.551753]  __do_fault+0x36/0x180
    [  295.551755]  __handle_mm_fault+0xfeb/0x1ab0
    [  295.551757]  ? __switch_to_asm+0x34/0x70
    [  295.551758]  ? apic_timer_interrupt+0xa/0x20
    [  295.551760]  handle_mm_fault+0xc4/0x1e0
    [  295.551763]  do_user_addr_fault+0x1c4/0x440
    [  295.551765]  do_page_fault+0x31/0x110
    [  295.551767]  async_page_fault+0x3e/0x50
    [  295.551768] RIP: 0033:0x7f76265c2c10
    [  295.551770] Code: 00 0f 86 93 03 00 00 48 8d 81 00 ff ff ff 4c 8d 05 61 b5 01 00 45 31 c9 30 c0 48 8d b4 07 00 01 00 00 48 8d 44 24 40 0f 1f 00 <66> 0f e7 07 66 0f e7 47 10 67
    [  295.551770] RSP: 002b:00007ffd216e0180 EFLAGS: 00010287
    [  295.551771] RAX: 00007ffd216e01c0 RBX: 00007f76265de158 RCX: 0000000340000000
    [  295.551772] RDX: 0000000340000000 RSI: 00007f7600000000 RDI: 00007f75adb8e000
    [  295.551772] RBP: 0000000000000000 R08: 00007f76265de15c R09: 0000000000000000
    [  295.551773] R10: 0000000000000000 R11: 00007f76265b5790 R12: 00007f72c0000000
    [  295.551773] R13: 00007ffd216e04b0 R14: 0000000000000000 R15: 0000000000000000

`ftrace` the following functions at host:

    sync_pf_execute
    kvm_setup_async_pf
    kvm_arch_async_page_not_present
    kvm_arch_async_page_present
    kvm_arch_async_page_ready
    ext4_dax_huge_fault
    ext4_dax_fault
    ext4_issue_zeroout
    ext4_map_blocks
    kvm_mmu_page_fault
    vmx_vcpu_run

gives the repeating `function` tracing result:

    qemu-system-x86-9119  [031] d... 5266999.615460: vmx_vcpu_run <-kvm_arch_vcpu_ioctl_run
    qemu-system-x86-9119  [031] .... 5266999.615751: kvm_mmu_page_fault <-kvm_arch_vcpu_ioctl_run
    qemu-system-x86-9119  [031] .... 5266999.615751: ext4_dax_fault <-do_wp_page
    qemu-system-x86-9119  [031] .... 5266999.615751: ext4_dax_huge_fault <-do_wp_page
    qemu-system-x86-9119  [031] .... 5266999.615752: ext4_map_blocks <-ext4_iomap_begin
    qemu-system-x86-9119  [031] .... 5266999.615755: kvm_setup_async_pf <-try_async_pf
    qemu-system-x86-9119  [031] .N.. 5266999.615756: kvm_arch_async_page_not_present <-kvm_setup_async_pf
    	  <...>-34960 [031] .... 5266999.615757: async_pf_execute <-process_one_work
    	  <...>-34960 [031] .... 5266999.615758: ext4_dax_fault <-do_wp_page
    	  <...>-34960 [031] .... 5266999.615758: ext4_dax_huge_fault <-do_wp_page
    	  <...>-34960 [031] .... 5266999.615758: ext4_map_blocks <-ext4_iomap_begin
    qemu-system-x86-9119  [031] .... 5266999.615762: kvm_arch_async_page_ready <-kvm_check_async_pf_completion
    qemu-system-x86-9119  [031] .... 5266999.615762: kvm_arch_async_page_present <-kvm_check_async_pf_completion
    qemu-system-x86-9119  [031] d... 5266999.615763: vmx_vcpu_run <-kvm_arch_vcpu_ioctl_run
    qemu-system-x86-9119  [031] d... 5266999.615772: vmx_vcpu_run <-kvm_arch_vcpu_ioctl_run
    qemu-system-x86-9119  [031] .... 5266999.616067: kvm_mmu_page_fault <-kvm_arch_vcpu_ioctl_run
    qemu-system-x86-9119  [031] .... 5266999.616068: ext4_dax_fault <-do_wp_page
    qemu-system-x86-9119  [031] .... 5266999.616068: ext4_dax_huge_fault <-do_wp_page
    qemu-system-x86-9119  [031] .... 5266999.616069: ext4_map_blocks <-ext4_iomap_begin
    qemu-system-x86-9119  [031] .... 5266999.616072: kvm_setup_async_pf <-try_async_pf
    qemu-system-x86-9119  [031] .N.. 5266999.616073: kvm_arch_async_page_not_present <-kvm_setup_async_pf
    	  <...>-34960 [031] .... 5266999.616075: async_pf_execute <-process_one_work
    	  <...>-34960 [031] .... 5266999.616075: ext4_dax_fault <-do_wp_page
    	  <...>-34960 [031] .... 5266999.616075: ext4_dax_huge_fault <-do_wp_page
    	  <...>-34960 [031] .... 5266999.616076: ext4_map_blocks <-ext4_iomap_begin
    qemu-system-x86-9119  [031] .... 5266999.616079: kvm_arch_async_page_ready <-kvm_check_async_pf_completion
    qemu-system-x86-9119  [031] .... 5266999.616080: kvm_arch_async_page_present <-kvm_check_async_pf_completion
    qemu-system-x86-9119  [031] d... 5266999.616081: vmx_vcpu_run <-kvm_arch_vcpu_ioctl_run

