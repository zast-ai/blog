---
title: "Security Advisory: 7 Unpatched Vulnerabilities in Prime (CMS) GraphQL Implementation"
description: "ZAST.AI identifies 7 unpatched vulnerabilities in Prime CMS (v0.4.0), including DoS amplification and Introspection leakage. Learn how to mitigate these risks."
keywords: "GraphQL Security, Prime CMS Vulnerability, CVE-2026-1169, API Security, Denial of Service, ZAST.AI, Zero-day Advisory"
date: 2026-2-24
categories: ["Security Research"]
tags:
  [
    "Vulnerability Disclosure",
    "GraphQL",
    "Open Source Security",
    "ZAST Engine",
    "Cybersecurity"
  ]
# 📌 添加：用于 SEO 和 Social Meta Tags
author: ZAST.AI
# 📌 用于生成 Schema 的 'image' 属性，必须包含一个特色图片的路径，这个路径应该指向你的特色图片，且图片宽度应大于 1200 像素，以满足 Google 要求。
image: /assets/img/ZAST.AI-Raised-$6M-Pre-A/banner.png
# 📌 添加：更长的摘要用于 social media 和 Schema 'description'
excerpt: "The ZAST engine has uncovered 7 verified vulnerabilities in Prime (CMS) v0.4.0. From insecure default configurations allowing Introspection Leakage to high-severity DoS amplification via uncapped query complexity, these unpatched flaws leave production instances exposed. Read our full technical breakdown and community mitigation guide."
---



> **Advisory Block**
>
> | Field | Content |
> | --- | --- |
> | **Target Project** | Prime (<=0.4.0) - GraphQL CMS |
> | **CVE ID(s)** | CVE-2026-1169 through CVE-2026-1175 |
> | **Max Severity** | **High** (DoS / Info Disclosure) |
> | **Discovery Engine** | [ZAST.AI](https://zast.ai) |
> | **Patch Status** | ⚠️ **Unpatched / Mitigation Required** |
> 
> 


### TL;DR

As part of our continuous monitoring of the open-source ecosystem, the [ZAST.AI](https://zast.ai) engine audited **Prime (v0.4.0)**, a CMS designed for GraphQL management. We identified **7 verified vulnerabilities** ranging from Introspection Leakage to Denial of Service (DoS) amplification.

**The core issue is architectural:** Prime ships with **insecure default configurations**. It exposes a powerful GraphQL engine without enabling standard security guardrails (such as complexity limits or introspection disabling) out-of-the-box.

**⚠️ Community Warning:** At the time of this disclosure, the project maintainers have **not yet released a patch**. If you are running Prime in production, you are likely vulnerable. This report details the attack vectors and, more importantly, provides manual configuration guidance to secure your instances immediately.

---

### Cluster 1: The "Open Book" Policy (Introspection Leakage)

**Hero Case: CVE-2026-1170 (Sensitive Info Disclosure)**

For a system designed to manage GraphQL, securing the schema is paramount. However, Prime defaults to a "development-mode" posture even in production builds. Introspection—a feature meant for debugging tools—is left wide open.

This allows any unauthenticated actor to map the entire API surface, discovering hidden queries, deprecated fields, and potential logic flaws.

**The Verification (PoC)**
[ZAST.AI](https://zast.ai) verified this by querying the `__schema` meta-field. The server readily returned the full internal structure.

```bash
# ZAST.AI Autonomous Verification
curl -X POST \
     -H "Content-Type: application/json" \
     -d '{"query": "query cop { __schema { types { name fields { name } } } }", "operationName": "cop"}' \
     'http://target:40410/graphql'

```

**Why SAST Misses This**
Legacy Static Analysis (SAST) views introspection as a valid feature, not a bug. It cannot distinguish between a safe local dev environment and an exposed production server. [ZAST.AI](https://zast.ai) validates the *context*: if the endpoint is publicly reachable and leaking schema data, it is a vulnerability.

---

### Cluster 2: Uncapped Complexity (DoS Amplification)

**Hero Case: CVE-2026-1171 (Field Duplication)**
*Related: CVE-2026-1172, 1173, 1174*

GraphQL gives clients the power to ask for exactly what they need. Without limits, this power becomes a weapon. Prime's default resolver implementation lacks **Query Cost Analysis** or **Depth Limiting**.

We found that the engine naively processes every requested field, even duplicates. An attacker can request `__typename` 10,000 times in a single request (CVE-2026-1171) or send an array of 1,000 distinct queries in one HTTP POST (CVE-2026-1173). This results in massive CPU/Memory consumption on the server with minimal effort from the attacker.

**The Verification (PoC)**
[ZAST.AI](https://zast.ai) generated a nested amplification attack. The server did not reject the request for complexity, but instead attempted to process it, confirming the DoS vector.

```json
// CVE-2026-1171: Field Duplication Payload
{
  "query": "query cop { __typename \n__typename ... [repeated 5000x] ... }",
  "operationName": "cop"
}

```

**Why SAST Misses This**
Detecting algorithmic complexity attacks requires semantic understanding of the execution engine. Regex cannot calculate the "cost" of a recursive query. [ZAST.AI](https://zast.ai) identifies this by generating high-complexity payloads and monitoring the application's response behavior.

---

### Cluster 3: Transport Insecurity (CSRF)

**Hero Case: CVE-2026-1169 (GET Based CSRF)**

Prime allows GraphQL queries to be executed via HTTP `GET` requests. Since `GET` requests do not typically trigger preflight checks or require custom headers in standard browser behavior, this opens the door to Cross-Site Request Forgery (CSRF).

**The Verification (PoC)**
[ZAST.AI](https://zast.ai) successfully executed a query simply by navigating to a URL:

```bash
http://target:40410/graphql?query=query+cop+%7B__typename%7D

```

---

### Community Mitigation Guide (How to Fix It)

Since there is no official patch yet, we strongly recommend Prime users implement the following mitigations at the gateway or code level:

1. **Disable Introspection:** Ensure `introspection` is set to `false` in your GraphQL server config for production environments.
2. **Enforce Rate Limiting & Depth Limits:** Use middleware (like `graphql-depth-limit`) to reject queries nested deeper than 5-10 levels.
3. **Disable GET Method:** Configure your web server (Nginx/Apache) or application middleware to reject `GET` requests to the `/graphql` endpoint.

### Conclusion

Open source software powers the world, but "default" does not mean "secure." The vulnerabilities in Prime highlight a common trend: powerful tools shipping with permissive configurations that leave users exposed.

Our goal at [ZAST.AI](https://zast.ai) is not just to break code, but to verify risk so it can be managed. Until the vendor patches these issues, please ensure your configurations are locked down. Security is a shared responsibility.