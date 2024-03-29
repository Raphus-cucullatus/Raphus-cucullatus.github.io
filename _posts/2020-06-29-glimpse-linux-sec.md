---
layout: post
title:  "A Glimpse Into Linux Security Teams"
date:   2020-06-29 00:00:00 +0800
categories: tech kernel
comments: true
---

At the time I am writing this, *the bug* has been assigned CVE id
[CVE-2020-10757][CVE] (with [7.8/10 CVSS score][CVSS]), fixed at
commit [5bfea2d9b17f][COMMIT], and published at [oss-security][OSS]
for public discussion.

When I was writing a program, I found a Linux kernel bug which, under
exploit, can allow a less-than-70-line C code to access any physical
address.  This bug was introduced 4 years ago, as early as version
4.5.  The emergency handling procedure took 15 people, 79 email
messages, and 7 days, to finally resulted in patching
the mainline and 6 stable trees.

Since it is related to a kind of emerging hardware, nvdimm, which is
only commercially available 1 year ago, although the exploit result is
severe, the actual impact coverage is limited.  Nonetheless, I am so
appreciated to be able to take part in the security private channels,
to have a glimpse of what usually hides behind the scenes.  This is
also what motivates me to write it down: to let people know

1.  how a security bug is discussed and fixed,
2.  how security teams from multiple parties cooperate to minimize the
    possible damages, and more generally,
3.  what is the proper procedure to report a security bug,
4.  what is the role, in security, of kernel security group,
    linux-distros, oss-security, and the Common Vulnerabilities and
    Exposures (CVE) system, and
5.  how should we consider trust and disclosure.

However, perhaps you would better not take it seriously, since it is
only one of the hundreds commits getting into the kernel every day,
and kernel is evolving, as well as its security policies and
procedures.  Anyway, hope you enjoy reading this.

*The full report will be released soon.*

[CVE]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-10757
[CVSS]: https://nvd.nist.gov/vuln/detail/CVE-2020-10757
[COMMIT]: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=5bfea2d9b17f1034a68147a8b03b9789af5700f9
[OSS]: https://www.openwall.com/lists/oss-security/2020/06/04/4
