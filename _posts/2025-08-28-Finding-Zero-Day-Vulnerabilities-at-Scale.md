---
title: "Finding Zero-Day Vulnerabilities at Scale: Our Journey with Zast.ai"
description: "Learn about our journey using Zast.ai to discover hundreds of zero-day vulnerabilities across the open-source ecosystem at scale, and the challenges we faced in responsibly disclosing them."
author: "Chris"
date: 2025-09-10
categories: [Security, AI, Open Source]
tags: [Zero-Day, Vulnerability Disclosure, Zast.ai, Log4Shell, Automation, CVE]
hidden: false
---

**Chris**,  
Co-founder, Zast.ai  
Sep. 10, 2025, Toronto

---

In our previous blog ***[Vulnerability Disclosure Challenges in Open Source Projects](https://blog.zast.ai/security/open%20source/vulnerability%20disclosure/Vulnerability-Disclosure-Challenges-in-Open-Source-Projects/){:target="_blank"}***, we used CVE-2025-46653 to discuss open source vulnerability disclosure hurdles and effort, aiming to boost collaboration. Today, we’re excited to share how we’ve put this technology to work in pursuit of a bold goal: assessing the entire open-source ecosystem to find the next Log4Shell.

## The Ambition: Assess the Entire Open Source Ecosystem

Our mission was ambitious: systematically assess thousands of open-source projects to uncover critical, previously unknown vulnerabilities. Inspired by the widespread impact of Log4Shell, we aimed to proactively identify similar threats before they could be exploited in the wild.

<center><img src="{{'/assets/img/Finding-Zero-Day-Vulnerabilities-at-Scale/xkcd.png' | relative_url }}" alt="xkcd" width="750" height="auto"></center>

<center><em>resource: https://xkcd.com/2347/</em></center>
<br/>

To achieve this, we developed a comprehensive automation pipeline leveraging Zast.ai's capabilities:<br>

<center><img src="{{'/assets/img/Finding-Zero-Day-Vulnerabilities-at-Scale/b2-1.png' | relative_url }}" alt="b2-1" width="750" height="auto"></center>

1. **Project Selection**: We curated a list of popular and widely-used open-source projects based on metrics like GitHub stars, download counts, and community activity.

2. **Cloning Repositories**: Automated scripts cloned selected repositories to our secure testing environment.

3. **Deployment Automation**: One of the biggest challenges was automatically deploying diverse projects with varying dependencies and configurations.

4. **Assessment with Zast.ai**: Each deployed project was assessed using Zast.ai to identify potential vulnerabilities.

5. **Result Aggregation**: Findings from individual assessments were collected and consolidated into comprehensive reports.

## Discovering Hundreds of Zero-Day Vulnerabilities

Through our systematic approach and the power of Zast.ai, we successfully identified hundreds of zero-day vulnerabilities across a wide range of open-source projects. These findings included critical issues in popular libraries, frameworks, and tools that are integral to modern software development.

Each vulnerability was verified with a working Proof of Concept (PoC) and a demonstrated exploit, ensuring the accuracy and impact of our discoveries.

<center><img src="{{'/assets/img/Finding-Zero-Day-Vulnerabilities-at-Scale/vuldb.png' | relative_url }}" alt="vuldb" width="750" height="auto"></center>

Following responsible disclosure practices, we are in the process of reporting these vulnerabilities through proper channels. For a complete list of vulnerabilities discovered by [Zast.ai](https://zast.ai/), that have completed the disclosure process, please see https://www.cve.org/CVERecord/SearchResults?query=zast.ai.

## The Disclosure Journey: Triumphs and Tibulations

Disclosing these vulnerabilities responsibly was a complex and often arduous process. We encountered numerous challenges along the way:

<center><img src="{{'/assets/img/Finding-Zero-Day-Vulnerabilities-at-Scale/b2-3.png' | relative_url }}" alt="b2-3" width="750" height="auto"></center>

- **Communication Barriers**: Reaching maintainers and coordinating disclosure timelines proved difficult for many projects.

- **Varying Response Times**: Some maintainers responded quickly and appreciatively, while others took weeks or months to acknowledge our reports.

- **Coordination with CNAs**: Working with CVE Numbering Authorities (CNAs) to assign identifiers and publish advisories requires careful coordination and adherence to strict timelines.

- **Public Awareness**: Ensuring that the broader community was aware of patched vulnerabilities without prematurely exposing unpatched ones was a delicate balance.

Despite these obstacles, these vulnerabilities are being publicly disclosed. We worked closely with project maintainers and security teams to ensure vulnerabilities were addressed promptly and transparently.

One particularly illustrative example of these challenges is detailed in our separate blog post, "[Vulnerability Disclosure Challenges in Open Source Projects](https://blog.zast.ai/security/open%20source/vulnerability%20disclosure/Vulnerability-Disclosure-Challenges-in-Open-Source-Projects/)," which delves deep into the complexities of disclosing a critical vulnerability in a widely-used component.

## Looking Forward: Building a More Secure Open Source Community

Our journey with Zast.ai has been both challenging and rewarding. Through automation and collaboration, we've taken significant steps toward proactively securing the open-source ecosystem. However, this is just the beginning.

We envision a future where:

- **Automated Security Testing** becomes a standard part of the development lifecycle for all open-source projects.

- **Collaborative Efforts** between security researchers, maintainers, and the broader community lead to faster vulnerability identification and remediation.

- **Shared Responsibility** drives continuous improvement in the security posture of open-source software.

We invite you to join us in this mission. Together, we can build a more secure digital world, one vulnerability at a time.

Stay connected with us on [X @zast_ai](https://twitter.com/zast_ai).

Let's make security as fast and efficient as AI-powered coding.
