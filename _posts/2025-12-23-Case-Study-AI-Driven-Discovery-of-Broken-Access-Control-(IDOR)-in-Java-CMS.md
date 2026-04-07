---
title: "Case Study: AI-Driven Discovery of Broken Access Control (IDOR) in Java CMS"
description: "Discover how ZAST.AI outperformed Burp Suite by identifying a critical IDOR vulnerability in a Java CMS with zero false positives through semantic AI analysis."
keywords: "AI security, IDOR discovery, Java CMS security, Automated Penetration Testing, ZAST.AI, Broken Access Control, OWASP Top 10, AI vs Burp Suite"
date: 2025-12-23
categories: ["Case Studies", "AI Security"]
tags:
  ["IDOR", "Java Security", "Artificial Intelligence", "Cybersecurity", "Vulnerability Assessment"
  ]
# 📌 添加：用于 SEO 和 Social Meta Tags
author: ZAST.AI
# 📌 用于生成 Schema 的 'image' 属性，必须包含一个特色图片的路径，这个路径应该指向你的特色图片，且图片宽度应大于 1200 像素，以满足 Google 要求。
image: assets/img/logo-single.png
# 📌 添加：更长的摘要用于 social media 和 Schema 'description'
excerpt: "Traditional tools like Burp Suite often return >90% false positive rates when testing for business logic flaws. This case study demonstrates how ZAST.AI utilizes autonomous assessment to isolate critical authorization bypasses in Java applications with pinpoint accuracy."
---


**ZAST.AI Team**,  

Dec. 23, 2025, Seattle

---


**Case Study: AI-Driven Discovery of Broken Access Control (IDOR) in Java CMS**

**Core Achievement**: [ZAST.AI](https://zast.ai) autonomously assessed a critical Incorrect Authorization (IDOR) vulnerability in an open-source Java CMS with **zero false positives**. In contrast, industry-standard tools like Burp Suite buried the same critical issue under a **\>90% false positive rate**, demonstrating AI's superior ability to instantly isolate true threats from operational noise.

**1. The Assessment Challenge: Business Logic**

Incorrect Authorization (OWASP Top 10 \#1) is notoriously difficult to detect because it relies on business logic rather than code patterns.

To demonstrate this, we look at this CRM system. The **Administrator** has a full sidebar menu with access to system settings:

<center><img src="{{'/assets/img/Case-Study-AI-Driven-Discovery-of-Broken-Access-Control-(IDOR)-in-Java-CMS/1.png' | relative_url }}" alt="1" width="1200" height="auto"></center>
<br>

In contrast, the **Normal User ("Chris")** sees a restricted interface with limited options:

<center><img src="{{'/assets/img/Case-Study-AI-Driven-Discovery-of-Broken-Access-Control-(IDOR)-in-Java-CMS/2.png' | relative_url }}" alt="2" width="1200" height="auto"></center>
<br>

While this distinction is visually obvious to a human, it represents a **semantic gap** for traditional scanners. They see the code, but fail to infer the implied security boundary: that the absence of a UI element dictates a prohibition on the backend.

**2. The AI Assessment Process**

[ZAST.AI](https://zast.ai) simplifies this semantic analysis. First, we upload the target Java archive to the platform.

<center><img src="{{'/assets/img/Case-Study-AI-Driven-Discovery-of-Broken-Access-Control-(IDOR)-in-Java-CMS/3.png' | relative_url }}" alt="3" width="1200" height="auto"></center>
<br>

We then configure the assessment by providing credentials for the two distinct roles (Admin and Normal User) to enable logic comparison.

<center><img src="{{'/assets/img/Case-Study-AI-Driven-Discovery-of-Broken-Access-Control-(IDOR)-in-Java-CMS/4.png' | relative_url }}" alt="4" width="1200" height="auto"></center>
<br>

**3. Automated Vulnerability Discovery**

[ZAST.AI](https://zast.ai) completed the analysis and identified a critical **Incorrect Authorization** vulnerability. It flagged a **Template Editing** function that should be restricted to admins but was accessible to normal users.

<center><img src="{{'/assets/img/Case-Study-AI-Driven-Discovery-of-Broken-Access-Control-(IDOR)-in-Java-CMS/5.png' | relative_url }}" alt="5" width="1200" height="auto"></center>
<br>

**4. Manual Verification: The Admin Context**

To verify the AI's finding, we first logged in as Admin to locate the vulnerable feature. We found the "Template files" editor under the Settings menu.

<center><img src="{{'/assets/img/Case-Study-AI-Driven-Discovery-of-Broken-Access-Control-(IDOR)-in-Java-CMS/6.png' | relative_url }}" alt="6" width="1200" height="auto"></center>
<br>

Using Chrome DevTools, we captured the network traffic when clicking "Save." This confirmed the endpoint structure and parameters used for the privileged operation.

<center><img src="{{'/assets/img/Case-Study-AI-Driven-Discovery-of-Broken-Access-Control-(IDOR)-in-Java-CMS/7.png' | relative_url }}" alt="7" width="1200" height="auto"></center>
<br>

**5. Manual Verification: The Exploitation**

We then switched to the Normal User account ("Chris"). As expected, the UI correctly hides the "Templates" settings, giving a false sense of security.

<center><img src="{{'/assets/img/Case-Study-AI-Driven-Discovery-of-Broken-Access-Control-(IDOR)-in-Java-CMS/8.png' | relative_url }}" alt="8" width="1200" height="auto"></center>
<br>

However, using the request structure captured earlier, we sent a direct HTTP POST request using the Normal User's session. The server responded with 200 OK and success: true.

<center><img src="{{'/assets/img/Case-Study-AI-Driven-Discovery-of-Broken-Access-Control-(IDOR)-in-Java-CMS/9.png' | relative_url }}" alt="9" width="1200" height="auto"></center>
<br>

**Impact**: This confirms the IDOR vulnerability. Despite UI restrictions, a normal user can overwrite system templates, potentially injecting malicious code to compromise the entire website.

**6. Comparative Analysis: [ZAST.AI](https://zast.ai) vs. Burp Suite**

To validate the efficiency of our approach, we benchmarked [ZAST.AI](https://zast.ai) against **Burp Suite (with Authz extension)**.

**The Burp Suite Test Process**

We set up a standard authorization test workflow:

1. Configured two test accounts (Admin and Normal User).

2. Captured the Low-Permission cookie for the Authz extension.

3. Logged in as Admin and performed actions (editing articles, managing pages).

4. Sent captured packets to Authz for analysis.


**The Results**

We tested over 30 endpoints. While Burp Suite **did successfully flag** the critical Template Editing vulnerability, the result was practically unusable due to noise:

- **Massive False Positives**: Except for one request (302 status), Burp flagged **every single endpoint** as an "Incorrect Authorization" vulnerability.
- **\>90% False Positive Rate**: The critical vulnerability was buried among 30+ false alarms.

- **Operational Burden**: To find the real bug, a security engineer would need to manually verify dozens of invalid alerts, wasting hours of time.

<center><img src="{{'/assets/img/Case-Study-AI-Driven-Discovery-of-Broken-Access-Control-(IDOR)-in-Java-CMS/10.png' | relative_url }}" alt="10" width="1200" height="auto"></center>
<br>

**Summary of Differences**

The table below highlights why AI-driven semantic analysis outperforms traditional proxy-based scanning:

| **Feature**      | **Burp Suite + Authz**                                       | **[ZAST.AI](http://ZAST.AI)**                                |
| ---------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Assessment Logic | Traffic-Based.  Relies on crawler or manual clicks; misses hidden API endpoints. | Code-Centric.  Analyzes the full application archive; finds hidden/dormant endpoints. |
| Accuracy         | Low.  >90% False Positives; cannot distinguish "Soft 200" errors from success. | High.  Zero False Positives; understands business context (Admin vs. User). |
| Workflow         | Manual.  Requires proxy setup, cookie capture, and manual verification. | Automated.  One-click assessment; AI handles role context automatically. |

**7. Conclusion:**

While Burp Suite buried the vulnerability in noise, [ZAST.AI](https://zast.ai) isolated it. By bridging the "semantic gap" and achieving zero false positives, [ZAST.AI](https://zast.ai) turns a verification bottleneck into an immediate fix.
