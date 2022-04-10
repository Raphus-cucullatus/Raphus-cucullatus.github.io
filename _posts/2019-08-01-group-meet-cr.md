---
layout: post
title: "CR: Pitfalls of the researches on performance optimization"
date: 2019-08-01 00:00:00 +0800
categories: research
comments: true
---

On 2019/08/01, HGS gave a report on his query repair concurrency
control.  After the speech, CR left an inspiring comment on the
presentation, the work, and about general research as well.  Here is a
summary on the pitfalls of the researches on performance optimization
by CR.


### Pitfall 1: Begin implementing without solid, preliminary data support

If there is no supporting data for your idea/claims, it is 90% that
the project would fail.  It is necessary to give:

1.  Define the most beneficial case of your optimization.
2.  Declare the scenario/use-case where the most beneficial case is
    common.


### Pitfall 2: Aimlessly apply an optimization

Hu used predicate lock to optimize the false conflict issue in MySQL
gap lock.  But

1.  It seems unrelated to query repair (the project key point).
2.  If applied, it brings a further question that what's the impact of
    predicate lock on query repair.  What if using predicate lock
    boosts the baseline while has little effect on your version?


### Pitfall 3: Can not identify the trade-offs of an optimization

Hu decided to use query plan optimization to reduce the repair
operations in the repair phase so that blocking time can be reduced.
However, query plan optimization was originally used for execution
performance.  If you use a query plan that is *good* for your repair
phase but is different from the query plan *optimal* for execution,
you are actually trading common-case performance for that in special
cases.

