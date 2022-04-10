---
layout: post
title:  "Reading EuroSys’20 best paper: Don’t shoot down TLB shootdowns"
date:   2020-05-19 00:00:00 +0800
categories: research
comments: true
---

Personally, I had a chance to optimize TLB shootdown overhead in
2018 when I spent nearly one month evaluating TLB shootdown
performance.  I was asked to provide some supporting data for the
performance of some memory management operations on a
multi-socket machine.  I also read several papers on TLB
shootdown (which are also cited by this EuroSys’20 paper).

I had found the poor performance of TLB shootdown, I had read
related paper as background, and I had looked into the source
code TLB shootdown in Linux kernel, but why I was not the one who
do this kind of work?  I list the following reasons:
1. At that time we were rushing for a conference deadline.
   Looking deep into TLB shootdown and even optimizing it were
   not of high priority.
2. At that time, I thought the poor performance was due to slow
   IPI which is more hardware than software for us to solve.
   Actually this is partially true.  As the EuroSys’20 paper
   shows, what they optimized is not the dominant part (39%) when
   shooting 1 PTE.  But as the batching grows, the local ~invlpg~
   time takes more and their approach becomes more effective (58%
   for 10 PTE).

Here are lessons I’ve learned:
1. Note down observed problems and address them one day.
2. Most of the time, there should always be work to do, however
   small it seems.
3. Performance analysis: breakdown, *model*, analyze, then begin
   with the dominant.
4. Don’t simply make a guess, use experiment result to speak.
