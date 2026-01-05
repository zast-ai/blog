# The 2025 Bug Hunter Report: How ZAST.AI Uncovered 115+ Verified CVEs
By ZAST.AI Research Team | January 2026

2025 was a watershed year for ZAST.AI. While we recently announced our $6M Pre-A funding, the real story lies in the code.

Behind the scenes, our AI-powered agent was working 24/7—scanning, analyzing, and proving vulnerabilities. We didn’t just look for syntax errors; we hunted for exploitable realities.

The result? 400+ zero-day vulnerabilities discovered, with 115 official CVEs assigned.

This report breaks down our findings from 2025, categorizing them by impact and technology stack. It serves as both a transparency report and a testament to the power of Automated PoC Validation.

## 🏆 1. The "Big Game" Hunters: Enterprise Infrastructure
Our most significant achievements weren't just in small plugins, but in the foundational frameworks that power the global internet. Finding vulnerabilities here requires deep semantic understanding of complex codebases.
- **Microsoft Azure SDK (XXE)**: XML External Entity vulnerability in a core cloud SDK.
- **Apache Struts2 (XXE)**: A critical flaw in one of the world's most popular Java frameworks (Confirmed).
- **Alibaba Nacos (XXE)**: Vulnerability in the dynamic service discovery/configuration platform used by microservices everywhere.
- **Apache Commons Configuration (RCE)**: Remote Code Execution flaws in a ubiquitous Java library.

Why this matters: These are "Supply Chain" risks. A single flaw here ripples through thousands of enterprise applications. Our agent identified these before they could be weaponized.

## 🧠 2. Beyond Syntax: Logic & Semantic Vulnerabilities
Traditional Static Analysis (SAST) tools often miss bugs that require understanding "how the app works." In 2025, ZAST.AI demonstrated its ability to understand business logic.

### IDOR (Insecure Direct Object References)
- **Target**: jshERP <=3.5
- **Impact**: CVE-2025-7948 (Change Password), CVE-2025-7947 (Delete Account).
- **The Win**: The AI understood the relationship between user IDs and permissions, generating a PoC to hijack accounts—something regex-based tools simply cannot do.

### SSRF (Server-Side Request Forgery)
- **Targets**: Langfuse (LLM Engineering Platform), JeeSite, stirling-pdf, xxl-job.
- **The Win**: SSRF is notoriously hard to validate. Our agent successfully manipulated internal network requests in these platforms (e.g., CVE-2025-9799 in Langfuse), proving the risk of cloud metadata exposure.

## 💣 3. The "Crown Jewels": Remote Code Execution (RCE)
RCE is the highest severity vulnerability. In 2025, we uncovered multiple paths to total system compromise.
- **ChanCMS**: Multiple RCEs (CVE-2025-8266, CVE-2025-8227).
- **sim**: RCE via insecure handling (CVE-2025-10097).
- **Apache Commons**: As mentioned above.

## 📊 4. 2025 Vulnerability Distribution Analysis
Looking at the 115+ CVEs we secured, here is the breakdown of the vulnerability landscape we mapped:
*(建议此处插入饼图 - 我们可以为您生成图表数据)*
- **Input Validation & XSS (40%)**: Still the most common web flaw. Found extensively in PyBBS, CacheCloud, mblog, and WordPress Plugins.
- **Authorization & Logic (20%)**: IDOR, Privilege Escalation, and Bypass (e.g., JeeSite XSS filter bypass).
- **Server-Side Risks (25%)**: SSRF, XXE, and Insecure File Upload (e.g., node-formidable, CodiMD).
- **Injection (15%)**: SQL Injection (e.g., deer-wms-2, platform).

**Trend Alert**: We noticed a surge in SSRF vulnerabilities in modern microservices and AI-ops platforms (like Langfuse and xxl-job), highlighting the risks in modern cloud-native architectures.

## 📜 Appendix: Selected 2025 CVE List
Below is a curated list of confirmed vulnerabilities and CVEs discovered by ZAST.AI in 2025.

### Critical Frameworks & Middleware
| Component | Vulnerability | CVE / Status |
|-----------|---------------|--------------|
| Microsoft Azure SDK | XXE | Confirmed |
| Apache Struts2 | XXE | Confirmed |
| Alibaba Nacos | XXE | Confirmed |
| node-formidable | Insecure File Upload | CVE-2025-46653 |
| Koa | Open Redirect | CVE-2025-8129 |
| Langfuse | SSRF | CVE-2025-9799 |

### Enterprise Applications & CMS
| Component | Vulnerability | CVE / Status |
|-----------|---------------|--------------|
| JeeSite | SSRF, Open Redirect, File Upload | CVE-2025-7759, 7864, etc. |
| xxl-job | RCE, SSRF | CVE-2025-7788, 7787 |
| CacheCloud | Reflected XSS (Multiple) | CVE-2025-15145 to 15221 |
| deer-wms-2 | SQL Injection (Multiple) | CVE-2025-8123 to 8127 |
| PyBBS | XSS, CSRF, Logic Flaws | CVE-2025-8550 to 8814 |

### WordPress Ecosystem
| Plugin | Vulnerability | CVE / Status |
|--------|---------------|--------------|
| Double the Donation | Stored XSS | CVE-2025-12020 |
| YouTube Subscribe | Stored XSS | CVE-2025-12025 |
| Featured Image | Stored XSS | CVE-2025-12019 |

*(Note: This is a partial list. For the full vulnerability database, please contact our research team.)*

## The ZAST.AI Difference
Every CVE listed above came with a Proof-of-Concept (PoC). We didn't send these vendors a "maybe"; we sent them a "here is how it breaks."

This level of validation is why Microsoft, Apache, and Alibaba prioritized our reports. In 2026, we are scaling this capability to cover more languages and deeper logic.

Want to see the agent that found these bugs?  
[Schedule a Demo](support@zast.ai)

---