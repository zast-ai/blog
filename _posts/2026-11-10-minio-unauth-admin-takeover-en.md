---
title: "MinIO Console Session Forgery: From an S3 Select Error Leaking deploymentID to Bypassing Login"
description: "CVE-2026-113466 in MinIO: S3 Select errors leak the deploymentID used as the Console cookie key, so valid root credentials can skip the login form."
keywords: "CVE-2026-113466, MinIO, S3 Select, deploymentID, PBKDF2, session cookie forgery, CWE-321, CWE-320, ZAST.AI"
date: 2026-11-10
categories: ["Vulnerability Research"]
tags:
  - "CVE-2026-113466"
  - "MinIO"
  - "S3 Select"
  - "Session Forgery"
  - "ZAST.AI"
author: ZAST Team
image: assets/img/logo-single.png
excerpt: "An S3 Select error leaks the MinIO deploymentID, which is also the passphrase and salt for the Console cookie key. Given valid root credentials, that skips the Console login form."
---

| Field | Content |
|---|---|
| Target Project | MinIO (embedded Console builds shipping S3 Select) |
| CVE ID(s) | CVE-2026-113466 |
| Max Severity | CVE record (VulDB, 2026-10-20): CVSS 3.1 **5.3 Medium** (AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:N); CVSS 4.0 6.9 Medium |
| Vulnerability Type | CWE-321 Use of Hard-coded Cryptographic Key; CWE-320 Key Management Errors |
| Affected Versions | CVE record: RELEASE.2025-10-15T17-29-55Z. Source comparison: RELEASE.2023-03-13T19-46-17Z and current master still set `CONSOLE_PBKDF_SALT` / `CONSOLE_PBKDF_PASSPHRASE` to `globalDeploymentID` with the same root cause. That part falls outside the CVE record and the 2023 build was not verified end to end in the current environment. |
| Discovery Engine | ZAST.AI |

In a typical self-hosted MinIO deployment, the S3 API (port 9000) and the Console (port 9001) are two entry points that share one set of root credentials. An S3 Select error response leaks the `deploymentID`; that value serves as both the PBKDF2 passphrase and the salt for the Console session cookie, so anyone holding the `deploymentID` can recompute the cookie encryption key offline. The Console authentication middleware decrypts the cookie without validating the STS credentials in the claims, and pushes the identity straight to the downstream MinIO server.

One counting clarification before going further: these are **three defects in the same codebase, and they map to a single CVE** (CVE-2026-113466), not three separate vulnerabilities. Remove any one of them and the chain collapses — read in isolation, the first two are an information leak and a questionable way to derive a key, and the third simply pushes validation downstream. None is exploitable on its own. The sections below refer to them as Root Cause One, Two, and Three.

Stack the three and a party holding valid root credentials can bypass the Console login form.

The boundary needs stating up front: **this is not an unauthenticated takeover.** The downstream MinIO server still validates the credentials in the claims with SigV4, so the forger must already know valid credentials. Under a default deployment, anyone who knows the root credentials can simply log in to the Console. The CVE record therefore scores 5.3 (C:L), and the local testing described below supports that.

**ZAST.AI's discovery engine found this issue** and verified it end to end on RELEASE.2025-10-15T17-29-55Z; the report is published in `minio/unauth_admin_takeover.md`. Everything below, including the 401 control that scaled the severity down, comes from that work.

## 1. Background: How the Console Encrypts Its Session Cookie

The Console protects session cookies with symmetric encryption. The token's binary layout is `AEAD ID(1) | iv(16) | nonce(12) | sealed data`. Algorithm byte `0x00` means AES-GCM and `0x01` means ChaCha20-Poly1305; AES is used only when the CPU provides AES hardware acceleration, ChaCha20 otherwise. Neither path seals with `derivedKey` directly: AES uses `HMAC-SHA256(derivedKey, iv)`, ChaCha uses `HChaCha20(derivedKey, iv)`. The cookie carries no separate HMAC; integrity comes from the AEAD tag.

```
// console/pkg/auth/token.go — key derivation and cookie format
derivedKey = PBKDF2(passphrase, salt, 4096, 32, SHA1)

algorithm  = 0x00 (AES-GCM) | 0x01 (ChaCha20-Poly1305)
iv         = 16 bytes
nonce      = 12 bytes
sealingKey = HMAC-SHA256(derivedKey, iv)   // AES path
           = HChaCha20(derivedKey, iv)     // ChaCha path
token      = algorithm | iv | nonce | AEAD(sealingKey, nonce, claims)
```

## 2. Root Cause One: deploymentID Leaks Through an S3 Select Error

`deploymentID` is the deployment UUID (the `id` field in `format.json`). It is not a password, but MinIO treats it as an identifier that must not leave the system. A normal S3 error puts the hex digest of `SHA256(globalLocalNodeName)` in `<HostId>` (`cmd/server-main.go:412-413`, `cmd/generic-handlers.go:563`); the two `SelectError` branches in S3 Select put `globalDeploymentID()` there instead — the `NewS3Select` failure at `cmd/object-handlers.go:251` and the `Open` failure at `:270`. The malformed SQL in the PoC takes the `:270` path.

```
# Anonymous (target bucket must allow anonymous GetObject)
POST /public-bucket/data.csv?select&select-type=2
# body: a malformed SQL statement

# the S3 Select SelectError returns the deployment UUID verbatim
<Error>
  <Code>ParseSelectFailure</Code>
  <HostId>e6d23803-ef76-45e3-a723-84b328604270</HostId>
</Error>

# a normal S3 error returns the SHA256 of the node name
<HostId>dd9025bab4ad464b049177c95eb6ebf374d3b3fd1af9251148b658df7ac2e3e8</HostId>
```

The request needs no credentials, but it does need the target bucket to allow anonymous reads and the attacker to know an existing object key — public download sites, CDN origins, static sites, and shared datasets all qualify. Whether anonymous `ListObjectsV2` works depends on the bucket policy; if listing is denied, a known key is still required. This step turns an internal identifier into an externally readable string.

## 3. Root Cause Two: The Passphrase and the Salt Are the Same Value

`cmd/common-main.go:121-122` sets both `CONSOLE_PBKDF_PASSPHRASE` and `CONSOLE_PBKDF_SALT` to `globalDeploymentID()`. PBKDF2's security depends on the passphrase staying secret; when the passphrase and the salt are the same publicly obtainable UUID, **no secret takes part in the derivation** — anyone holding the `deploymentID` computes the same key locally without touching the server.

```
// cmd/common-main.go:121-122
os.Setenv("CONSOLE_PBKDF_SALT", globalDeploymentID())
os.Setenv("CONSOLE_PBKDF_PASSPHRASE", globalDeploymentID())

// console/pkg/auth/token.go:52-53
derivedKey = PBKDF2(deploymentID, deploymentID, 4096, 32, SHA1)
// passphrase = salt = public value; no secret involved
```

## 4. Root Cause Three: The Console Middleware Decrypts but Does Not Validate STS Credentials

`AuthenticationMiddleware` (`api/configure_console.go:329`) takes the cookie, decrypts it with `DecryptToken`, parses it with `ParseClaimsFromToken`, and then turns the claims into an `Authorization: Bearer` header. It does not check whether the STS credentials in the claims are real and valid; the actual check happens at the downstream MinIO server via SigV4. In other words, the Console delegates authentication rather than treating decryption as login.

```
// actual REST path (console v1.7.7-0.20250905210349-2017f33b26e1)
api/configure_console.go:329  AuthenticationMiddleware
pkg/auth/token.go:314         GetTokenFromRequest
pkg/auth/token.go:163         DecryptToken
pkg/auth/token.go:154         ParseClaimsFromToken
api/configure_console.go:342  Authorization: Bearer <claims>
api/client.go:339             getConsoleCredentialsFromSession
api/client.go:343             NewStaticV4(claims.STSAccessKeyID, ...)
api/client.go:352             minio.New(...)
// downstream MinIO validates SigV4 with the credentials from claims
```

`SessionTokenAuthenticate` (`pkg/auth/token.go:96`) shows the same "return the claims right after decryption" behaviour, but it is **not on this REST path**. It is used only by the WebSocket path (`api/ws_handle.go:101` → `token.go:328/335`) and by `IsSessionTokenValid`. A fix that only touches that function leaves the main REST path unchanged.

![PoC Demo]({{ "/assets/img/MinIO.gif" | relative_url }})

## 5. What the Chain Actually Gets You

Chaining the three root causes reliably reproduces the following path: obtain the `deploymentID` → derive the key offline → forge a cookie whose claims carry valid root credentials → pass the Console middleware → the downstream MinIO server admits it as root. The precondition is that the attacker already knows valid root credentials.

Measured on RELEASE.2025-10-15T17-29-55Z with root set to `minioadmin:minioadmin`:

- Anonymous S3 Select request → **400** `ParseSelectFailure`, with the deployment UUID in `<HostId>`.
- Forged cookie plus valid root credentials → `GET /api/v1/buckets` **200**, private buckets visible.
- Forged cookie plus invalid credentials (`attackerfake:attackerfake`) → **401** `The Access Key Id you provided does not exist in our records.`
- Direct `POST /api/v1/login` with the root credentials → **204**, a cookie issued normally.
- List objects in a private bucket → **200**; download a private object → **200** (11 bytes, `TOP SECRET`); create a bucket → **200**.

The capability boundary of this Console build, measured locally:

- `/api/v1/policies` → **404**
- `/api/v1/admin/info` → **501**
- `DELETE /api/v1/buckets/{name}` → **405**
- `/api/v1/session` → **500** (an empty STS token is parsed as a JWT; the SPA redirects to `/login`)

So the IAM, service-account, and server-configuration capabilities cannot be counted as demonstrated results of this forged session; they either require calling the S3 or Admin API directly, or can already be done with the same root credentials. The independent impact of this cluster is mainly the `deploymentID` leak and bypassing the Console login form, not a zero-to-root privilege escalation.

## 6. Prerequisites and CVSS Scoring

The report lists two preconditions: the target has at least one bucket allowing anonymous reads with an object key the attacker knows or can guess; and the attacker knows (or can brute-force) the root credentials, whose default is `minioadmin:minioadmin`.

The CVE record (VulDB, 2026-10-20) scores it **5.3 Medium**: `AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:N` — it treats the independent impact of this cluster as the `deploymentID` leak (C:L).

The local evidence supports that reading. A forged session grants no privilege of its own; it only forwards the credentials in the claims to MinIO. Valid credentials, downstream admits them; invalid credentials, 401. Anyone who knows valid root credentials can log in to the Console directly (204 in local testing); anyone who does not cannot get past SigV4 with a forged cookie. "Unauthenticated takeover" therefore does not hold. The accurate description is "bypassing the Console login step given known or default root credentials". If the target uses default credentials, the real root cause is the default credentials; if it does not, this chain cannot obtain privilege from zero.

## 7. Found and Verified by the ZAST.AI Discovery Engine

This vulnerability was found by the ZAST.AI Discovery Engine, and the report is hosted in `minio/unauth_admin_takeover.md` in the `zast-ai/vulnerability-reports` repository. Verification environment and key evidence:

- **Environment**: RELEASE.2025-10-15T17-29-55Z built from source, container `minio-vuln:2025-10-15`, root `minioadmin:minioadmin`, S3 on `:9000` / Console on `:9001`. No code changes were made to the tested instance.
- **Leak**: anonymous `POST /public-bucket/test.csv?select&select-type=2` with malformed SQL → **400** `ParseSelectFailure`, `<HostId>` is the deployment UUID; a normal **403** carries a 64-character SHA256 in `<HostId>`.
- **Forgery**: a cookie built to the PBKDF2 + AEAD format → valid root credentials yield `/api/v1/buckets` **200**; invalid credentials yield **401**.
- **Login control**: a direct `POST /api/v1/login` with root credentials → **204**, showing that forgery is unnecessary once the credentials are known.
- **Capability boundary**: listing every bucket, listing and downloading private objects, and creating a bucket all returned **200**; `/api/v1/policies` **404**, `/api/v1/admin/info` **501**, `DELETE /api/v1/buckets/{name}` **405**.
- **Versions**: the report states confirmation on 2023-03-13 and 2025-10-15; we reproduced it end to end on 2025-10-15, and for the 2023 build performed only a source comparison (`cmd/common-main.go:174-175` likewise sets SALT/PASSPHRASE to `globalDeploymentID`). The CVE record lists 2025-10-15 only.

## 8. Conclusion

What makes this chain worth remembering is that three design assumptions fail at once: the cluster identifier will not leak, key derivation needs no secret, and the Console middleware can skip credential validation by delegating authentication wholesale to the downstream server. Individually each looks minor. Together they at least let a party holding valid credentials bypass the Console login and turn the `deploymentID` into a public input from which the key can be recomputed offline; if some Console endpoint trusted the claims without calling MinIO, it would become genuine privilege escalation.

By local measurement, a forged session grants no privilege beyond the credentials written into it, which makes the CVE record's 5.3 (C:L) the score that better reflects this chain's independent impact.

Full report:

https://github.com/zast-ai/vulnerability-reports/blob/main/minio/unauth_admin_takeover.md

https://www.cve.org/CVERecord?id=CVE-2026-113466

https://github.com/minio/minio
