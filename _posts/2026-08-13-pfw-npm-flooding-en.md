---
title: "1,033 Malicious npm Packages: How ZAST PFW Caught the Malware Leading Vendors Missed"
description: "ZAST PFW flagged all Flooding Dropper npm packages as malicious with zero false positives, catching malware that leading vendors failed to flag."
keywords: "ZAST PFW, Package FireWall, npm, supply chain attack, malicious packages, Flooding Dropper, WEL1DROPPER, Sliver C2, threat intelligence, install-time protection, zero false positives"
date: 2026-08-13
categories: ["Product", "Supply Chain Security"]
tags:
  - "ZAST PFW"
  - "Supply Chain Security"
  - "npm"
  - "Malicious Packages"
  - "Threat Intelligence"
author: ZAST Team
image: assets/img/logo-single.png
excerpt: "ZAST PFW caught the Flooding Dropper malware that leading supply-chain vendors missed — all packages flagged malicious, zero false positives."
---

# 1,033 Malicious npm Packages: How ZAST PFW Caught the Malware Leading Vendors Missed

Recently, the npm ecosystem was hit by a new large-scale poisoning wave: over **1,033 malicious packages** flooded the registry within days, backed by a multi-stage dropper targeting Windows, Linux, and macOS — with alleged targets pointing at Russian financial institutions. This was no ordinary dependency poisoning; it was a "flooding" supply-chain attack — the attacker used AI-generated squatting package names and a flood of random accounts to overwhelm the review and response systems in one blow.

## 1. Background: A "Flooding" Poisoning Campaign

The security community named this campaign **"Flooding Dropper"** (Sonatype tracking sonatype-2026-005660, CWE-506, CVSS 8.7), while OpenSourceMalware calls it **"WEL1DROPPER"**. First reported on August 5, by August 11 the confirmed package count had reached **1,033**.

Its technical chain is representative:

- Triggered via **require()** rather than the common dependency install hook — bypassing the most common install-time detection;
- First downloads a stage-1 payload via Cloudflare Workers, then pulls stage-2 through a **DNS TXT record (wel1.ru) as a fallback channel**;
- Cross-platform delivery: on Windows it patches ETW/AMSI and writes registry Run keys and scheduled tasks for persistence; on macOS it fetches beacon_mac.bin; on Linux it ultimately deploys **Sliver C2**;
- Suspected targets include tcsbank.ru and cloudpayments.ru, and the campaign is considered an evolution of the April "Moika" (250+ packages) dependency-confusion activity.

Named packages such as **bigops-backend**, **bigops-api**, and **dolyame-boxy-desktop-bnpl-card-gallery** have been publicly reported.

> **The key point:** This attack used a relatively novel technique. Based on our testing, several leading global supply-chain security vendors failed to flag these packages; yet **ZAST PFW not only caught all of them, but did so with zero false positives**.

![PoC Demo]({{ "/assets/img/npm/attack_chain.png" | relative_url }})

## 2. What Is ZAST PFW

**ZAST pfw (Package FireWall)** is a sub-product of ZAST, positioned as a **supply-chain threat-intelligence service plus install-time interception**, shifting security protection "left" to before malicious code ever touches the codebase or production environment.

It works in two layers:

- The cloud continuously monitors mainstream ecosystems (its first version covers the npm ecosystem, where poisoning is rampant) for malicious dependency-poisoning events, rapidly forming threat intelligence;
- The client-side CLI **intercepts and blocks in real time** at the install / invocation stage, preventing developers from being poisoned when they install or use open-source dependencies.

Three core values:

1. **Install-Time Protection** — Even when attackers switch to require() triggers to bypass install hooks, pfw's detection engine can still identify the malicious behavior in the malware and block it at the dependency-install stage, protecting developers from poisoning.
2. **Closing the protection gap in local and build environments** — Uniform coverage across local development, CI, and build machines.
3. **Shrinking the exposure window from "days" to "minutes"** — Once the cloud detects a campaign, threat intelligence reaches the client-side CLI within minutes, dramatically shortening the threat window.

Its users span global developers and large internet enterprise teams, down to front-line developers and open-source maintainers, DevOps and build engineers, and enterprise R&D teams along with DevSecOps / security administrators.

## 3. pfw in Action: Flooding Dropper Malware Flagged 100% Malicious, Zero False Positives

During the Flooding Dropper campaign, ZAST PFW's cloud detection engine, through real-time malicious-package detection, **flagged all of them as malicious, with zero false positives**.

Taking the publicly named bigops-backend as an example, pfw **identified its dropper behavior at the very moment require() was triggered** — the most direct demonstration of the "install-time interception" value. When attackers abandon install hooks and strike at the code-execution point instead, mainstream products that rely on scanning install scripts lose focus, while pfw holds the truly dangerous instant.

## 4. Why This Matters

Flooding Dropper exposes a trend: when poisoning shifts from "a few precise shots" to "a flooding deluge," **volume itself becomes the weapon**, and manual review and rule-base updates are overwhelmed in an instant.

This means the evaluation criteria for detection must shift — from "coverage" to **"false-positive rate + new-sample response speed."** How many known threats a vendor covers matters less than whether it can intercept, at the moment a novel technique appears, with an acceptable false-positive rate.

ZAST PFW's **zero false positives and minute-level response** delivers exceptional value precisely in scenarios where "novel techniques + flooding" combine.

![PoC Demo]({{ "/assets/img/npm/pfw_en.png" | relative_url }})


## 5. Conclusion

The battlefield of supply-chain attacks has moved from "known threats" to "the moment of execution." Shifting protection left to the install stage is what lets us block malicious code before it ever lands.

> **Don't let a single npm install become an attack vector.**
>
> ZAST pfw (Package FireWall) leverages world-class detection to identify malicious packages in the npm ecosystem in real time — including malware that uses novel techniques and was missed by even the world's leading vendors.
>
> **Real-time Threat Intelligence API:** delivers high-precision, integrable malware intelligence to security teams and intelligence providers, so you learn about the latest threats first.
>
> **Developer Dependency Firewall:** blocks malicious dependencies at the npm install stage — before the attack ever lands.
>
> Covering the full chain from threat intelligence to real-time protection, pfw builds the first line of defense for enterprise security teams, threat-intel providers, and development teams.

## Join the ZAST PFW Channel

Want the latest pfw threat-intelligence updates and to take part in product discussions? Join our Discord channel:

https://discord.com/channels/1286583562849615903/1537322582611726376
