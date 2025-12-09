---
title: "WordPress Plugin Stored XSS: ZAST.AI’s Zero False Positive Practice"
description: "ZAST.AI's AI agent discovered critical Stored XSS vulnerabilities (CVE-2025-12020, CVE-2025-12025) in popular WordPress plugins. Learn about our zero-false-positive methodology and automated PoC verification."
keywords: "WordPress Security, Stored XSS, ZAST.AI, AI Vulnerability Scanner, CVE-2025-12020, CVE-2025-12025, Automated PoC, Zero False Positive, Cybersecurity, Agentic AI"
date: 2025-12-09
categories: ["Vulnerability Research","WordPress Security","AI Security"]
tags:
  ["Stored XSS",
  "ZAST.AI",
  "CVE-2025-12020",
  "CVE-2025-12025",
  "Double the Donation",
  "YouTube Subscribe",
  "Automated PoC"
    
  ]
# 📌 添加：用于 SEO 和 Social Meta Tags
author: ZAST.AI
# 📌 用于生成 Schema 的 'image' 属性，必须包含一个特色图片的路径，这个路径应该指向你的特色图片，且图片宽度应大于 1200 像素，以满足 Google 要求。
image: assets/img/logo-single.png
# 📌 添加：更长的摘要用于 social media 和 Schema 'description'
excerpt: "A Practical Guide to ZAST Express"
---


**ZAST.AI Team**,  

Dec. 09, 2025, Seattle

---



## Background

WordPress, as the world's most popular content management system, powers over 40% of websites. ZAST.AI conducted batch security assessment of the WordPress plugin ecosystem through a closed-loop process of "target codebase analysis → candidate vulnerability generation → customized PoC testing → verification confirmation," discovering multiple stored cross-site scripting (Stored XSS) vulnerabilities that traditional tools had missed.

## Methodology

ZAST.AI ensures the accuracy of vulnerability discovery through a four-step process:

1. **Codebase Analysis**: Systematically assess plugin source code to identify potential security vulnerability patterns
2. **Candidate Vulnerability Generation**: Generates vulnerability candidate sets based on syntax and semantic analysis
3. **Customized PoC Testing**: Generates targeted proof-of-concept code for each candidate vulnerability
4. **Execution Result Verification**: Simulates vulnerability exploitation in test environments, only confirming exploitable vulnerabilities

This approach is particularly effective for detecting syntax-based vulnerabilities and semantic vulnerabilities like IDOR and partial information disclosure, showing excellent performance in the WordPress plugin ecosystem.

## Vulnerability Details

### CVE-2025-12020: Double the Donation Plugin — Stored XSS

- **Affected Version**: <= 2.0.0
- **Vulnerability Location**: `doublethedonation.php` (Line 59 — backend settings rendering)
- **Root Cause**: Variables are not escaped in JavaScript string context (missing `esc_js()`)
- **Attack Vector**: Administrators fill fields containing malicious JS in backend settings, and the API key and other values are directly injected into scripts and executed when pages are rendered
- **Required Permissions**: Administrator or higher
- **CVSS Score**: 4.9 (Medium)

The plugin directly concatenates configuration items into JavaScript configuration objects when processing backend configuration output, without performing `esc_js()` or other escaping on values, allowing arbitrary script injection and execution through settings.

**Vulnerability Code Example**:
```php
// vulnerable: doublethedonation.php 
return '<script>var DDCONF = { API_KEY: "' . $current_key . '" };</script>'
  . '<div id="dd-container"></div>';
// Issue: $current_key is not processed through esc_js() and is directly inserted into JS string context.
```

### CVE-2025-12025: YouTube Subscribe Plugin — Multiple Stored XSS

- **Affected Version**: <= 3.0.0
- **Vulnerability Location**:
  - Line 242 in `sm-youtube-subscription-shortcode.php` (HTML content context)
  - Line 246 in `sm-youtube-subscription-shortcode.php` (HTML attribute context)
- **Root Cause**: HTML content does not use `esc_html()` escaping; HTML attributes do not use `esc_attr()` escaping
- **Attack Vector**: Injects malicious payloads through title and channel ID fields in plugin settings, triggering on the frontend after saving
- **Required Permissions**: Administrator or site users with settings permissions
- **CVSS Score**: 4.4 (Medium)

**Vulnerability Code Example**:
```php
// Vulnerable code
<h3><?= $title;?></h3>  // Missing esc_html()
data-channelid="<?php echo $channel_id; ?>"  // Missing esc_attr()
```

ZAST.AI verified multiple exploitable vectors by injecting `<script>alert("XSS-YouTube-Title")</script>` into title fields and testing attribute escape payloads in channel ID fields through customized PoC.

### CVE-2025-12019: Featured Image Plugin — Metadata XSS

- **Affected Version**: <= 2.1
- **Vulnerability Location**: Plugin main file (attribute context: Lines 34–36; content context: Line 65)
- **Root Cause**: Attribute and content output do not use `esc_attr()` / `esc_html()` for escaping
- **Attack Vector**: Saves malicious scripts in image alt/metadata fields, triggering execution when other users access or render thumbnails
- **Required Permissions**: Administrator or higher
- **CVSS Score**: 4.4 (Medium)

**Vulnerability Code Example**:
```php
// HTML attribute context
$mpfeatureimg .= "' alt='";
$mpfeatureimg .= $alt;
$mpfeatureimg .= "' /></div>";
// Issue: $alt is not processed through esc_attr() and is directly inserted into attribute values.

// HTML content context (Line 65)
return $thumbnail_image[0]->post_excerpt;
// Issue: post_excerpt is not processed through esc_html() and is directly returned and rendered as content.
```

### Other Findings

ZAST.AI also discovered similar stored XSS vulnerabilities in the MembershipWorks plugin (CVE-2025-12018), as well as repeated vulnerability patterns in plugins such as Custom Html Bodyhead and Terms of Service & Privacy Policy Generator.

## ZAST.AI Verification Process

ZAST.AI automatically generates customized proof-of-concept code for each candidate vulnerability:

1. **Environment Setup**: Automatically configures test WordPress environments
2. **Permission Simulation**: Simulates different permission users according to vulnerability requirements
3. **Payload Injection**: Injects specialized XSS payloads into vulnerable fields
4. **Execution Verification**: Verifies script execution effects through browser automation

Through the three-step process of "candidate vulnerability generation → automated PoC generation → execution result verification," ZAST.AI ensures that only exploitable vulnerabilities verified through actual testing are reported.

## Remediation Recommendations and Protective Measures

### Immediate Mitigation Measures

Based on vulnerability report recommendations, affected users should immediately:

1. **Double the Donation Plugin**: Currently has no available patches; recommend uninstalling affected software and finding alternatives
2. **YouTube Subscribe Plugin**: Upgrade to a secure version or temporarily disable the plugin
3. **All Affected Plugins**: Review and restrict administrator permissions, strengthen access control

### Long-term Protection Strategy

ZAST.AI recommends WordPress site administrators:

1. **Dependency Management**: Establish plugin security review processes and regularly assess third-party dependencies
2. **Principle of Least Privilege**: Follow the principle of least privilege and strictly control administrator account allocation
3. **Security Monitoring**: Deploy continuous security monitoring to promptly detect abnormal behavior
4. **Vulnerability Assessment**: Regularly use ZAST.AI and other zero false positive tools for security assessments

## Conclusion and Value Proposition

This large-scale WordPress plugin ecosystem assessment highlights ZAST.AI’s strengths in batch vulnerability discovery — detecting and verifying stored XSS flaws missed by traditional tools across donation, social media, and image processing plugins.

ZAST.AI’s zero-false-positive capability lets security teams focus on critical vulnerabilities only, with automated PoC verification boosting accuracy and cutting security costs.

For WordPress-reliant organizations, regular ZAST.AI assessment are essential for protecting digital assets. As the plugin ecosystem expands, this proactive detection approach grows increasingly critical.

About ZAST.AI: A developing zero-false-positive AI vulnerability research agent, ZAST.AI uncovers hidden flaws via advanced code analysis and automated PoC verification. It supports Java, JavaScript/TypeScript projects, with Python support coming soon.