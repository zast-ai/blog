---
title: "The Truth Beneath the Iceberg: The CVE Review Gridlock"
description: "In July 2026 VulDB passed 0 of 1,163 submissions through review. AI-scale discovery broke manual CVE disclosure across NVD, GitHub, and vendor CNAs. Here is the evidence — and the fix."
keywords: "CVE review gridlock, vulnerability disclosure backlog, AI vulnerability discovery, VulDB July 2026, NVD rating gap, GitHub Advisory surge, AI batch reports, vulnerability verification, ZAST.AI, intelligent review infrastructure"
date: 2026-08-12
categories: ["Vulnerability Research", "Industry Analysis"]
tags:
  - "CVE disclosure"
  - "vulnerability review backlog"
  - "AI vulnerability discovery"
  - "VulDB"
  - "NVD"
  - "GitHub Advisory"
  - "ZAST.AI"
  - "intelligent review infrastructure"
  - "responsible disclosure"
author: ZAST Team
image: assets/img/logo-single.png
excerpt: "VulDB passed 0 of 1,163 vulnerability submissions through review in July 2026. This analysis shows how AI-scale discovery broke manual CVE disclosure — and why verified, PoC-backed reporting is the way out."
---

## Foreword: VulDB's July Numbers Are Only the Tip of the Iceberg

In July 2026, VulDB received a total of 1,163 vulnerability submissions platform-wide; backend status: **0 passed review**, with "passed review" at 0 for the entire month and a severe backlog in the manual review queue. ZAST.AI, as one of the continuous submitters, saw its own [sandbox-verified reports](https://zast.ai/blog/why-fast-verification-matters) stuck in the same queue. VulDB is not alone: NVD no longer provides in-depth rating for the vast majority of new vulnerabilities [1], GitHub CNA applications surged 10x [3], Apple imposed a 30-day cooldown [4], curl shut down its bounty [10], and Anthropic — after obtaining CNA status — scaled up its lead output [7]; the entire industry's review system is collapsing in sync.

![PoC Demo]({{ "/assets/img/cvestuck/vuldb.jpg" | relative_url }})

A clarification: VulDB's 1,163 zero-review-passes in July do not indicate low overall submission quality. Take ZAST.AI as an example — each of its reports is sandbox-reproduced before submission, with a complete reproducible PoC and trigger path attached. That is precisely what sets it apart from the flood of pure AI batch products: the former delivers verified, credible conclusions, while the latter delivers suspected leads. When the industry is overwhelmed by AI hallucination reports, PoC-backed verified reports are the cure, not a burden; yet stuck in the pile of pending approvals, its review progress stalled almost entirely for the month — which shows exactly that what the congestion swallowed was not AI noise, but the industry's real capacity, including verified credible reports.

After reviewing 2026's global CNAs, vulnerability databases, vendor announcements, and industry whitepapers, it can be confirmed: **every disclosure pipeline relying on manual line-by-line review is experiencing structural congestion**. The following lays out the evidence across six core channels.

## I. NIST NVD: Abandoning In-Depth Review for the Vast Majority of Vulnerabilities

NVD is the global vulnerability baseline database; enterprise scanners, compliance systems, and supply-chain tools all depend on its manually supplemented CVSS/CWE metadata. Once authoritative rating updates stall en masse, downstream tools face a flood of CVEs with "only an ID, no risk judgment," creating a supply-chain intelligence black hole.

- According to independent statistics, 48,185 CVEs were added in all of 2025; NIST itself admits its manual rating capacity has severely fallen behind the increment [1], with large numbers of new CVEs completing only basic registration.
- Policy adjustment on April 15, 2026: only three categories of high-risk vulnerabilities receive full manual enrichment; the remaining vast majority of new CVEs are directly flagged "no manual review scheduled" [1] and no longer receive authoritative rating.
- FIRST forecasts a median of **59,427** CVEs for all of 2026 [2], only about 23% up from 2025 (48,185) — not a peak in total vulnerability volume, but the ceiling that manual review can absorb. As manual queues across channels pile up several-fold and acceptance nearly stalls, the industry's actual demand for IDs and ratings may exceed the forecast by ten times. NVD's authoritative rating has degraded into covering only "the tip of the iceberg that was barely handled."

## II. GitHub Advisory: CVE Applications Surge 10x

GitHub holds an independent CNA qualification and is the core disclosure channel for the npm/maven/pypi/go ecosystems.

- In May 2026, CVE ID applications approached 4,000, a near **10x year-over-year surge** [3];
- Private security reports grew from 550 per week in January to 3,000 per week in May [3];
- In May it published 1,560 reviewed advisories (5x the normal volume) yet still could not keep up with inflow, and since April has been unable to meet its review timeliness commitment [3].

![PoC Demo]({{ "/assets/img/cvestuck/cve2github.png" | relative_url }})

## III. Vendor-Owned CNAs: Apple and Microsoft Both Throttle Intake

- **Apple** (first reported by FT on 2026-08-01): capped per-researcher submission limits, added a **30-day submission cooldown**, and significantly down-weighted pure AI reports without human reproduction while cutting their review hours [4]. Real case: Bynario used GPT-5.5 to find 50+ potential macOS vulnerabilities in three weeks, but once it triggered the cap was temporarily unable to report them [4][5].
- **Microsoft**: The MSRC portal still publicly accepts submissions with no quantity limit, but does not award bounties for batch unverified pure AI reports, mandating reproduction logs and stably reproducible PoCs [6].
- **Anthropic** (obtained U.S. CNA status in 2026): Project Glasswing scanned 1,000+ projects in the first half of the year, detecting 23,019 vulnerabilities (6,202 high/critical); six independent assessments of 1,752 findings showed a 90.6% true-positive rate [7]; yet publicly attributable CVE IDs numbered only a little over a hundred (a huge gap against the 23,019 raw leads), with massive valid leads still flowing into third-party CNA manual queues [7][8].

![PoC Demo]({{ "/assets/img/cvestuck/cve3.png" | relative_url }})

## IV. Third-Party Independent CNAs: Small Teams Drained of Manpower

- **Wordfence**: Its 2026 Q1 report shows WordPress plugin vulnerabilities reached 2,738 (up 24% QoQ), with review and remediation resources under continuous strain [9].
- **VulDB (July 2026 field measurement)**: An independent CNA with no big-tech budget, requiring at least 30 minutes of manual labor per vulnerability (reproduce → version mapping → CWE → CVSS → dedupe → standardize); facing 1,163 monthly submissions, it fell into "zero passed review."

## V. Open Source Projects / Bounty Platforms: Closing Intake Entirely

- **curl**: In February 2026 it permanently shut down its ~7-year-running HackerOne bounty program (launched 2019; in 2025, 95% of submissions were invalid AI reports) [10]; in July it suspended receiving all vulnerability reports for the entire month [10].
- **Bugcrowd**: Its review queue ballooned 334% in three weeks [11], entirely from unverified AI batch submissions, forcing new frequency and quantity limits [11].
- **Linux / Ghostty**, etc.: Linus publicly blasted AI erroneous reports for "almost making the kernel security reporting channel completely unmanageable" [13]; Ghostty banned batch AI submission accounts [14].

![PoC Demo]({{ "/assets/img/cvestuck/cve4curl.png" | relative_url }})

## VI. MITRE at the Top: Ticketing Under Pressure as CVE Enters the Quality-Control Era

MITRE, as the top-level CVE operator, itself admits it faced "major operational challenges" in 2026 due to AI capability expansion [15]; its backstop institution CNA-LR saw surging demand for CVE ID issuance while its capacity was severely squeezed. CISA formally declared in September 2025 that the CVE program is moving from the "era of growth" to the "era of quality control" [12]; top-level architectural transformation is already on the agenda.

## VII. Root Cause: AI-Industrialized Supply vs. Fixed Manual Review Capacity

- AI audit tools can scan hundreds of repositories per day and produce without limit; but pure AI batch, unreproduced reports are precisely the main noise consuming review resources (each ZAST.AI report is sandbox-verified with PoC attached — a verified product, distinct from suspected leads).
- A single report requires a minimum of 30 minutes of full-time manual labor; review manpower cannot scale linearly with AI submission volume.
- Industry data confirms the inflection point: HackerOne disclosed its vulnerability submission volume grew 76% YoY in March 2026, but the effectively exploitable share was only about 25%; Bugcrowd's queue ballooned over 334% in the same period [11]. Unverified AI batch reports (some with hallucinations, unreproducible) became the main noise consuming review resources, forcing review to triage before disposition — a vicious cycle.
- Disclosure behavior is also distorting: with AI assistance, vulnerability discovery efficiency has soared, but CVE review speed is not proportional; against this backdrop, some researchers have begun bypassing the "responsible vulnerability disclosure" process and directly publishing high-risk vulnerability PoCs. Starting June 2026, an anonymous researcher used exploitarium to publicly release 204 0day PoCs without notifying vendors [16][17], exposing exploit code to both attackers and defenders simultaneously and erasing the protection window that coordinated disclosure should have provided. When formal CNA channels are congested and IDs are slow to issue, public PoCs become a shortcut to compete for attribution and visibility, further weakening the disclosure system's filtering buffer and compounding with AI-batch noise.

![PoC Demo]({{ "/assets/img/cvestuck/cve5bikini.png" | relative_url }})

## VIII. Three Core Risks

1. **Supply-chain intelligence gap**: Thousands of real high-risk vulnerabilities stuck in pending queues, with no ID/rating/patch linkage; attackers learn exploitation first while defenders have no detection rules.
2. **Insufficient coverage of CVE risk assessment**: Real vulnerabilities stuck in pending queues struggle to obtain IDs; the value of CVE as the industry's baseline ID system has not wavered, but the coverage of "attached authoritative risk assessment" is declining — NVD no longer provides in-depth rating for the vast majority of new vulnerabilities, and CISA has formally declared CVE's transition from the growth era to the quality era.
3. **No remediation channel for open-source foundations**: Small and mid-sized open-source projects have no dedicated security staff; AI batch reports go unconfirmed for remediation long-term, expanding the underlying supply-chain attack surface.

## IX. Intelligent Review Infrastructure: Fighting Magic with Magic

1. **CNA pre-access trusted AI pre-review**: automatically reproduce PoCs, filter hallucinations, match CWE/CVSS, dedupe, and route by risk, concentrating humans on high-risk final review. This is precisely the premise on which ZAST.AI can be directly trusted by CNAs. With [Fast Verification](https://zast.ai/blog/why-fast-verification-matters), we complete the most labor-intensive "environment reproduction" on the tool side in advance; every report ships with a sandbox-verified PoC (see our [CVE-2026-3733 SSRF analysis in XXL-JOB](https://zast.ai/blog/cve-2026-3733-ssrf-in-xxl-job)), so reviewers only need to focus on rating. ZAST.AI's broader [security audit for agent environments](https://zast.ai/blog/openclaw-security-audit-is-now-available) applies the same verified-first principle. Between verified reports and batch products lies a fundamental divergence: from "creating review cost" to "compressing review cost."
2. **Two-tier disclosure**: AI pre-review-passed entries go into a "pre-disclosure library" (flagged pending human final review); after full human reproduction and rating they are upgraded to formal CVEs.
3. **Unified submission standards**: mandate reproduction logs / environment parameters / false-positive proof, with built-in strong false-positive filtering in tools, and limit the frequency and volume of pure AI reports (after some platforms implemented this, invalid submissions dropped significantly).
4. **Distributed shared review manpower pool**: cross-institution scheduling of senior researchers and tiered community volunteers to share the backlog.

![PoC Demo]({{ "/assets/img/cvestuck/CVEblogfinal.png" | relative_url }})

## X. Conclusion

VulDB's 1,163 submissions in July, with zero passed review, is not an accident of a single team's insufficient manpower, but an era inflection point for CVE disclosure infrastructure. The old purely manual pipeline has structurally failed; the breakthrough must synchronously build intelligent review infrastructure. For ZAST.AI, every vulnerability result ships with a reproducible PoC, not an unverified suspected lead — in an era of explosive CVE growth, there is a world of difference between PoC-backed credible conclusions and pure AI batch noise.

## References

- [1] [NIST announcement: NVD operations policy adjustment (2026-04-15)](https://www.nist.gov/news-events/news/2026/04/nist-updates-nvd-operations-address-record-cve-growth)
- [2] [FIRST: 2026 vulnerability count forecast median 59,427](https://www.first.org/blog/20260211-vulnerability-forecast-2026)
- [3] [GitHub official blog: Inside the Advisory Database and what happens when vulnerability volume breaks records](https://github.blog/security/supply-chain-security/inside-the-advisory-database-and-what-happens-when-vulnerability-volume-breaks-records/)
- [4] [FT: Apple imposes limits on AI-generated security reports](https://www.thenews.com.pk/latest/1411035-apple-imposes-limits-on-ai-generated-security-reports-ft-says)
- [5] [Phoenix New Media: Apple limits AI-generated security reports](https://tech.ifeng.com/c/8vGI4FqSBR5)
- [6] [Microsoft MSRC Bounty Guidelines](https://www.microsoft.com/en-us/msrc/bounty-guidelines)
- [7] [Resilient Cyber: The Receipts Are In (Anthropic Glasswing analysis)](https://www.resilientcyber.io/p/the-receipts-are-in)
- [8] [Forkast: Anthropic CNA designation marks the industrialization of vulnerability discovery](https://forkast.news/anthropics-cna-designation-marks-the-industrialization-of-vulnerability-discovery/)
- [9] [BNVD: WordPress plugins 2026 Q1 vulnerability stats (citing Wordfence)](https://bnvd.org/noticia/plugins-wordpress-acumulam-2738-falhas-no-t1-de-2026)
- [10] [CoderCops: curl bug bounty AI slop (post-mortem)](https://blog.codercops.com/blog/curl-bug-bounty-ai-slop-open-source-2026)
- [11] [Bugcrowd: Sloptimism is breaking any system built on human validation](https://www.bugcrowd.com?p=20503/)
- [12] [CISA: CVE Program Vision / quality era roadmap](https://www.cisa.gov/news-events/news/cisa-presents-vision-common-vulnerabilities-and-exposures-cve-program)
- [13] [Cyberpress: Linus Torvalds blasts AI erroneous reports for making kernel security list "almost completely unmanageable"](https://cyberpress.org/linus-torvalds-ai-bug-reports)
- [14] [Ghostty: AI_POLICY.md (bans batch AI submissions, permanent ban for repeat offenders)](https://github.com/ghostty-org/ghostty/blob/main/AI_POLICY.md)
- [15] [MITRE CNA-LR: 2026 major operational challenges from AI capability expansion](https://mitre.github.io/mitre-cve-roles/CNA-LR)
- [16] [FreeBuf (Hunan Cyberspace Security Association repost): Is responsible disclosure dead? Anonymous researcher publicly drops 204 0day PoCs with zero window](https://mp.weixin.qq.com/s/KhTKicO69fyYFuPdi-VhqA)
- [17] [GitHub: bikini/exploitarium public vulnerability PoC archive (204 0days, none pre-notified vendors)](https://github.com/bikini/exploitarium)
