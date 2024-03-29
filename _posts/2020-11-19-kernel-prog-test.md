---
layout: post
title:  "My Linux Kernel Programming Test"
date:   2020-11-19 00:00:00 +0800
categories: tech kernel
comments: true
---

Test (Linux) kernel programming skills by trying to answer the following questions!


### Question 1: Memory translation

Assume you're writing a kernel module which interacts with userspace
programs with a series of `ioctl` APIs.  In one of the `ioctl` API,
you need to do virtual-to-physical memory translation for a given
memory region that user provided.  How will you implement this?


### Question 2: Huge page in kernel

Assume that in a customized network driver module, you plan to use
huge pages as in-kernel DMA buffers for better performance.  Which
kernel API(s) will you choose to implement a huge-page DMA buffer
pool?


### Question 3: Kernel memory pool interface

You're writing a kernel module which manages a memory pool for a
specific purpose.  The pool is exposed to userspace programs who can
acquire, use, and release the memory resources.  Please describe a
clean and elegant kernel-user interface that you plan to use for this
feature.


### About

The questions above comes from the non-trivial problems I've
encountered in my kernel programming practice or heard from my
colleagues.  The list may be updated constantly.

