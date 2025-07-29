---
title: "A Shared Pursuit: Introducing Zast.ai"
description: "Introducing Zast.ai - the world's first AI agent that can analyze code logic, identify vulnerabilities, create POCs, and verify exploitability with zero false positives. Join us in making software more secure."
keywords: "Zast.ai, AI security, vulnerability detection, zero-day vulnerabilities, application security testing, automated security, code analysis, PoC generation, cybersecurity, software security"
author: "Geng Yang"
date: 2025-07-29
categories: ["Security", "AI", "Vulnerability Assessment"]
tags:
  [
    "Zast.ai",
    "vulnerability detection",
    "AI security",
    "zero-day",
    "application security",
    "automated testing",
    "cybersecurity",
    "code analysis",
  ]
image: "/assets/img/logo-single.png"
image_alt: "Zast.ai Logo"
og_image: "/assets/img/logo-single.png"
twitter_image: "/assets/img/logo-single.png"
canonical_url: "https://zast.ai/blog/introducing-zast-ai"
last_modified_at: 2025-07-29
---

**Geng Yang**  
Co-founder & CEO, Zast.ai  
July 28, 2025, Seattle

---

In a world built on codes, our collective security hinges on a shared challenge: to find and fix vulnerabilities before they can be exploited maliciously. This isn't a race to be won by a single team, but a continuous effort that belongs to all security engineers.

Our mission is simple but powerful: **to find real, exploitable vulnerabilities with zero false positives at scale.**

We believe that security reports are cheap. Real impact requires proof. That's what **ZAST** stands for:

- **Zero-day** Application Security Testing
- **Zero false positives**: Every vulnerability we identify is verified with a working Proof of Concept (PoC) and a demonstrated exploit.

---

### Performance in the Real World

During its development, Zast.ai uncovered hundreds of zero-day vulnerabilities. Beginning July 14th 2025, we've been submitting these discoveries to [VulDB.com](https://vuldb.com/), an accredited CVE Numbering Authority (CNA).

The results of the last ten days have been humbling and affirming:

- As of July 28th, we have submitted **78** vulnerabilities.

  ![Vulnerability submissions growth on VulDB.com]({{'/assets/img/vuldb/growth.png' | relative_url }})

- This effort has made Zast.ai the **#1** global contributor to VulDB for the month of July, 2025.

  ![Zast.ai vulnerability submissions on VulDB.com]({{'/assets/img/vuldb/number1.png' | relative_url }})

- In just over a week, Zast.ai has reached **#31** among all-time global contributors on [VulDB.com](https://vuldb.com/).
  The impact of these discoveries extends far beyond numbers. Our vulnerability findings span from critical infrastructure components to popular development tools, representing some of the most widely-used open source projects in the world.

  ![Star count distribution of affected repositories]({{'/assets/img/vuldb/starpie.png' | relative_url }})

We don't share these numbers to boast, but to offer as a proof of concept: that an AI partner, focused with precision, can meaningfully enhance human expertise and help secure the code we all rely on.

---

### How It Works: A Three-Step Process

Zast.ai is designed to deliver proof, not just alerts:

1. **Candidate Generation:** It analyzes target code base to identify potential vulnerability "candidates."
2. **Automated PoC Generation:** For each candidate, it generates and executes a tailored Proof of Concept against a test environment.
3. **Verification & Reporting:** It verifies the execution results to confirm the exploit was successful. Only then is a vulnerability reported, eliminating false positives.

---

### How to Get Started

You can integrate Zast.ai into your workflow in minutes.

1. Deploy your code in a test environment or start a local debug session.
2. Visit [https://zast.ai](https://zast.ai) and follow the on-screen instructions to create an assessment task.
3. You'll receive an email notification when the assessment is completed.

---

### Current Limitations

Although Zast.ai is continuously improving every day, here are its current limitations:

- **Languages:** Zast.ai currently supports **Java** and **JavaScript/TypeScript**. Python is next in line (in beta test), and more languages are on our roadmap.
- **Vulnerability Types:** Zast.ai is better with grammar-based vulnerabilities. For semantic ones, it currently supports **IDOR** and certain types of **information leakage**.
- **Resource:** Zast.ai's GPU capacity is limited (we are a small start-up). If this blog generates significant demand for audits, we'll prioritize scaling our computational resources to meet your needs. If you find your job is in the queue, thank you for your patience.

---

### The Journey Ahead

We don't have all the answers. We humbly offer Zast.ai —and its findings —as a starting point and a conversation starter. Our deepest hope is that by making Zast.ai accessible, we can inspire our fellow security engineers, researchers, and builders to make our digital world more secure.

---

### Stay Connected & Shape the Future

Let's work together to make security as fast and efficient as AI-powered coding.

- **Get Access:** [Start assessing your project today!](https://zast.ai)
- **Report Issues**: For any issues, please file them on our [GitHub](https://github.com/zast-ai/zast/issues)
- **Follow Us:** Connect with our team on X: **@zast_ai**

The future of development is fast. With Zast.ai, security is too.
