---
title: "Introducing Skill Security Reviewer"
description: "ZAST.AI introduces Skill Security Reviewer: an open-source tool for analyzing AI agent skills for theft, obfuscation, and hidden malicious intent before installation."
keywords: "AI Agent Security, Skill Security Reviewer, LLM Security, AI Safety, Malicious Skill Detection, ZAST.AI, Prompt Injection, Cybersecurity"
date: 2026-3-13
categories: ["AI Security", "Open Source"]
tags:
  [
    "AI Agents",
    "Security Audit",
    "Threat Research",
    "Malware Analysis",
    "Cybersecurity"
  ]
author: ZAST.AI Reserch Team
image: /assets/img/ZAST.AI-Raised-$6M-Pre-A/banner.png
excerpt: "Skills are closer to installable apps than harmless text. Skill Security Reviewer helps analyze AI agent skills for theft and hidden intent before you trust them."
---



## Why the AI agent ecosystem needs to review skills before it trusts them

**TL;DR:** Skills are closer to installable apps than harmless text. **Skill Security Reviewer** helps analyze skills for theft, obfuscation, and hidden intent before you trust them.

Today, we are releasing **Skill Security Reviewer**, an open tool that analyzes whether a skill may pose security risks to the user who installs it.

We built it for AI agent users, skill authors, and agent builders because the current trust model around skills is too weak. Skills are easy to share, easy to install, and often trusted far too quickly.

At [ZAST.AI](https://zast.ai) Security Research Team, we think the AI agent ecosystem is beginning to repeat familiar mistakes from the early days of browser extensions and open package registries: low friction, high trust, and very little review before adoption.

## A skill is closer to an app than a text snippet

Many users still treat skills as lightweight prompt artifacts. In practice, that framing is too generous.

A skill can shape model behavior, steer tool use, influence what gets read or written, and affect how data moves across boundaries the user never intended.

That is why the right mental model is simple:

**A skill should be treated like an app from an unknown developer.**

It may be useful. It should not be trusted by default.

If a user cannot clearly answer who wrote a skill, what it reads, what it changes, what it sends, and what hidden instructions it contains, then that skill deserves review before installation.

## The problem is hidden intent

Malicious skills are not always obvious. Some contain plainly visible exfiltration logic or dangerous commands. Many do not.

The harder problem is hidden intent inside seemingly helpful workflows. A skill may present itself as a setup helper, debugging aid, or productivity tool while quietly targeting files, tokens, keys, sessions, browser artifacts, cloud credentials, or downstream tools.

That makes skill review different from simply reading a prompt. The real question is not just "what text is here?" but "what might this cause the system to do to the user?"

Skill Security Reviewer is built around that question.

## Three risk clusters matter most

### 1. Theft, execution, and persistence

The clearest risks are also the most dangerous: collecting sensitive data, triggering unsafe execution, or leaving behind persistent behavior.

In our benchmark set, these patterns include reading SSH keys and cloud credentials, collecting environment secrets and browser session data, invoking dangerous commands, modifying startup configuration, and delaying harmful behavior until trust is established.

These are realistic risks because they map directly to how developers work. Tokens live in environment variables. Credentials live in local tools and config files.

One benchmark sample, `adv-046-sandbox-detect`, shows how this can stay hidden behind plausible behavior. It first checks whether it is running in a real user environment, then targets PDF, Word, and Excel documents, and prepares them for HTTP exfiltration. The risk is not only data theft. It is theft combined with evasion and a misleading description.

<center><img src="{{'/assets/img/Introducing-Skill-Security-Reviewer/blog-skill-bad.jpg' | relative_url }}" alt="blog-skill-bad" width="1200" height="auto"></center>
<br>

### 2. Obfuscation and evasion

Malicious behavior does not need to appear in plaintext. It can be hidden through encoding, encryption, string splitting, dynamic loading, or misleading names.

That is why Skill Security Reviewer looks beyond direct threat patterns. It also checks for anti-review and anti-evasion signals such as Base64, hex, Unicode escapes, XOR, AES, runtime decryption, string assembly, eval and exec paths, unsafe deserialization, high-entropy blobs, misleading naming, and anti-analysis behavior.

This matters because naive review often fails when content is designed to look harmless at a glance.

### 3. Weak trust defaults

The deeper issue is not only what a malicious skill can do. It is how easily users are encouraged to trust skills they did not write.

In many workflows, reputation, polish, urgency, or "official" branding can substitute for verification. Our benchmark includes deception, delayed payloads, and supply-chain style trust signals.

This should feel familiar. The AI agent ecosystem still sometimes treats these artifacts as harmless templates rather than installable logic.

## What Skill Security Reviewer does

Skill Security Reviewer is designed to help answer one practical question:

**If a user installs this skill, what might it do to them?**

It uses a read-only review process to surface behavior and indicators related to data theft, dangerous execution, persistence, exfiltration, prompt injection, tool abuse, deception, supply-chain risk, obfuscation, and evasion.

Its goal is not to produce a vague "safe" or "unsafe" label. It gives users a clearer view of what a skill may be attempting, especially when the risk is not obvious on first inspection.


<center><img src="{{'/assets/img/Introducing-Skill-Security-Reviewer/blog-skill-safe.jpg' | relative_url }}" alt="blog-skill-safe" width="1200" height="auto"></center>
<br>

## Why this approach matters

Most trust failures in this space do not come from users being careless. They come from users having too little visibility into what they are being asked to trust.

That is why we think skill review should be organized around impact and intent, not just around surface syntax. A useful reviewer should ask what behavior is implied, what resources are being targeted, what is being hidden, and what would happen if the user installed the skill without review.

In its current form, the project covers **94 detection items** across threat and obfuscation categories. It is paired with a benchmark corpus containing **100 malicious skill benchmark samples** and **50 advanced obfuscated samples** designed to test anti-evasion analysis.

In our current benchmark set, the reviewer achieved a **100% detection rate** across all **150 samples**. That includes samples specifically designed to test encoded, encrypted, and dynamically obscured behavior.

That result is useful, but it should be read correctly. It is evidence from a controlled benchmark corpus, not a claim of universal real-world coverage.

## Review before trust

Skill Security Reviewer is meant to reduce blind trust, improve review quality, and surface malicious indicators before installation or reuse. It does **not** claim that all malicious skills will always be caught, and it does **not** remove the need for human judgment.

If skills are becoming a normal way to extend agents, automate workflows, and share behavior, then they should be treated more like installable software and less like harmless text fragments.

If you use or build skills, start with one you did not write yourself. Run it through **Skill Security Reviewer**, inspect the findings, and treat review as part of installation rather than something you do after something goes wrong.

```bash
/skill-security-reviewer {skill-name}
```

GitHub: `https://github.com/zast-ai/skill-security-reviewer`
