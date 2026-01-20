---
title: "ZAST.AI 2025 Annual Report: 153 Verified Vulnerabilities & 0 False Positives"
description: "Discover how ZAST.AI's autonomous agents uncovered 153 verified zero-day vulnerabilities (119 CVEs) with zero false positives in 2025. This report analyzes critical RCE, XXE, and SSRF findings in Azure, Apache, and Nacos, demonstrating the shift from traditional SAST to automated PoC verification."
keywords: "AI Application Security, Zero False Positives, Automated PoC, Vulnerability Discovery, SAST Alternative, CVE Analysis, Zero-Day Research, RCE, XXE, SSRF, Java Security, ZAST.AI"
date: 2026-01-05
categories: ["Research", "Vulnerability Reports", "Cybersecurity"]
tags:
  [
    "CVE",
    "Open Source Security",
    "Azure SDK",
    "Apache Struts",
    "Alibaba Nacos",
    "Logic Vulnerability",
    "Automated Verification",
    "RCE",
    "XXE",
    "SSRF"
  ]
# 📌 添加：用于 SEO 和 Social Meta Tags
author: ZAST.AI
# 📌 用于生成 Schema 的 'image' 属性，必须包含一个特色图片的路径，这个路径应该指向你的特色图片，且图片宽度应大于 1200 像素，以满足 Google 要求。
image: /assets/img/ZAST.AI-Raised-$6M-Pre-A/banner.png
# 📌 添加：更长的摘要用于 social media 和 Schema 'description'
excerpt: "2025 was a watershed year for ZAST.AI. Our AI agent moved beyond syntax checking to discover 115+ verified CVEs in major platforms like Microsoft Azure, Apache Struts2, and Alibaba Nacos. This report breaks down the 'Big Game' captures, Logic Vulnerabilities, and the rise of AI-driven Automated PoC validation."
---

**TL;DR** — In 2025, [ZAST.AI](https://zast.ai) uncovered 400+ zero-day vulnerabilities in multiple popular open-source projects, and publicly disclosed 153 security vulnerabilities (119 assigned CVE IDs) across 37 open-source projects, representing only the subset of findings that have completed the disclosure process. The scope covers enterprise SDKs, frameworks, and critical infrastructure.

**Key Differentiator**: Unlike traditional SAST, [ZAST.AI](https://zast.ai) enforces a Zero False Positive policy by generating autonomous, executable PoCs for every reported finding.

## 1. 2025 Metrics Overview

| Metric | Count / Value |
|--------|---------------|
| Total Vulnerabilities Publicly Disclosed | 153 |
| CVE IDs Assigned | 119 |
| Projects Affected | 37 |
| False Positive Rate | 0 (PoC Validated) |
| Key Ecosystems | Enterprise SDKs (Azure, Alibaba), Apache, Node.Formidable, WordPress, Koa, Langfuse |

## 2. Analysis of Core Vulnerability Types
The 153 discoveries highlight structural limitations in pattern-matching based SAST. We categorize these into 5 structural blind spots where semantic analysis outperforms syntactic scanning.

### Group 1: Object Lifecycle & State Tracking (XXE)
- **Targets**: Azure SDK for Java, Alibaba Nacos, Apache Struts XWork-Core
- **Type**: XXE (XML External Entity Injection)
- **Pattern**: Separation of Configuration and Execution

In all three frameworks, the vulnerable state is established during object initialization (Constructor or Static Method) but triggered in subsequent method calls, often separated by file boundaries.
- **Azure SDK**: Constructor initializes `JAXBContext` without disabling external entities; the state persists to `unmarshalEntry`.
- **Alibaba Nacos**: `DefaultXmlConfigParse` instantiates a `DocumentBuilderFactory` field without security features, reusing it across all `parse()` calls.
- **Apache Struts (XWork)**: `DomHelper.parse` configures `setValidating` but omits `setFeature` for external entities.

**Detection Logic**: [ZAST.AI](https://zast.ai) models the Object Lifecycle, tracking the "Unsafe Configuration" state from initialization to the execution sink, identifying the parser object itself as tainted.

### Group 2: Dependency Chain Analysis (RCE)
- **Target**: Apache Commons Configuration v1 & v2
- **Type**: RCE (Remote Code Execution)
- **Pattern**: Polymorphic execution paths across library boundaries

The vulnerability relies on a chain spanning user input, the configuration library, and a deep dependency (`commons-jxpath`).

**Attack Chain**:
User Input → `Configuration.query()` → `JXPathContext.selectNodes()` → Reflection → `Runtime.exec()`

**Detection Logic**: Traditional tools often stop analysis at library boundaries. [ZAST.AI](https://zast.ai) treats dependency source code as part of the semantic graph, tracing taint flow from the query argument directly into JXPath's internal reflection logic.

### Group 3: Asynchronous Taint Tracking (SSRF)
- **Target**: Langfuse
- **Type**: SSRF via Message Queue
- **Pattern**: Taint propagation across process/storage boundaries

This involves a "Delayed Trigger" where data is persisted and processed asynchronously.

**Flow**:
API Service: User input (`url`) → Persisted to PostgreSQL → Message Queue: Event triggers Redis/BullMQ task → Worker Service: Reads `url` from DB → Executes `fetch(url)`.

**Detection Logic**: [ZAST.AI](https://zast.ai) models databases and queues as propagation pipes, correlating the API input source with the Worker execution sink across the asynchronous boundary.

### Group 4: Semantic Gap in Verification (File Upload)
- **Target**: Enable WebP (WordPress Plugin)
- **Type**: Arbitrary File Upload to RCE
- **Pattern**: Flawed Verification Logic (Substring vs. Extension)

The plugin attempts to validate file types using `strpos`:

```php
// Vulnerable Code
if ( false !== strpos( $filename, '.webp' ) ) {
    $types['ext'] = 'webp';
}
```

A file named `shell.webp.php` passes because it contains `.webp`, despite executing as PHP.

**Detection Logic**: A traditional scanner marks this safe due to the presence of a check (Code Compliance). [ZAST.AI](https://zast.ai) identified the semantic gap between the security requirement ("Ends With") and the implementation ("Contains"), automatically generating a polyglot filename to verify the bypass.

### Group 5: Context-Aware Escaping (Stored XSS)
- **Primary Target**: Double the Donation (WordPress Plugin)
- **Type**: Stored XSS via Admin Settings
- **Pattern**: Insecure Data Context Injection

The plugin injects a stored API key directly into a JavaScript object without context-appropriate escaping (`esc_js`):

```php
// Vulnerable Code in Double the Donation
return '<script>var DDCONF = { API_KEY: "' . $current_key . '" };</script>';
```

**Payload**: `", x: alert(1), dummy: "` breaks the JSON structure and executes arbitrary JS.

**Broader Impact**: [ZAST.AI](https://zast.ai) identified and verified similar Context-Aware XSS patterns in the following plugins:
- YouTube Subscribe
- Featured Image
- MembershipWorks

**Detection Logic**: [ZAST.AI](https://zast.ai) recognized the data flow into a `<script>` block context, determining that standard HTML escaping was insufficient for the JavaScript execution context.

## 3. Methodology: Achieving Zero False Positives
The zero false positive rate is achieved through **Autonomous Verification**, not heuristic filtering.

### Comparison of Methodologies
| Feature | Pattern Matching (Legacy) | Semantic Analysis + Verification ([ZAST.AI](https://zast.ai)) |
|---------|---------------------------|-----------------------------------------|
| Scope | Cross File / Function | Cross-File / Cross-Library / Object Lifecycle |
| Taint Analysis | Linear / Synchronous | Async / Persisted / Multi-process |
| Validation | Manual Review Required | Automated Executable PoC |
| Output | "Potential Vulnerability" | "Verified Exploit" |

### Verification Workflow
1. **Identification**: Semantic engine identifies potential exploit path.
2. **Constraint Solving**: AI generates input data to navigate complex execution paths.
3. **Execution**: PoC runs in a sandboxed environment.
4. **Confirmation**: Vulnerability is reported only if specific success criteria (e.g., file creation, network callback) are met.

## 4. Conclusion
The 2025 data (161 findings, 0 False Positive) indicates that static analysis effectiveness depends on contextual depth and verification capability. As modern architectures leverage deep dependency trees and asynchronous patterns, security tooling must evolve from syntactic pattern matching to semantic execution modeling.

## Resources
- [Vulnerability Details](https://github.com/zast-ai/vulnerability-reports/tree/main)
- [Technical Blog](https://blog.zast.ai/)

**Disclaimer**: All vulnerabilities listed have been responsibly disclosed and remediated.
