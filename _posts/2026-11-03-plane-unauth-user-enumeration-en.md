---
title: "CVE-2026-111869 Analysis: Plane Leaks Registered Users Past Its Own Rate Limit"
description: "CVE-2026-111869 in Plane: auth endpoints reveal whether an email is registered, and the throttle keys on a spoofable header, so the limit is bypassable."
keywords: "CVE-2026-111869, Plane, user enumeration, rate limit bypass, X-Forwarded-For, NUM_PROXIES, Django REST Framework, ZAST.AI"
date: 2026-11-03
categories: ["Vulnerability Research"]
tags:
  - "CVE-2026-111869"
  - "Plane"
  - "User Enumeration"
  - "Rate Limit Bypass"
  - "ZAST.AI"
author: ZAST Team
image: assets/img/logo-single.png
excerpt: "Plane's auth endpoints answer differently for registered and unregistered emails, and the throttle is keyed on a client-controlled X-Forwarded-For header — so enumeration runs at any speed."
---

| Field | Content |
|---|---|
| Target Project | Plane (`plane.authentication` views, `plane.utils.ip_address`) |
| CVE ID(s) | CVE-2026-111869 |
| Max Severity | Medium (CVSS 3.1 = 5.3, AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:N) |
| Vulnerability Type | Unauthenticated user enumeration (cause: differential responses + rate-limit bypass) |
| Affected Versions | v0.14-dev through v1.4.2; unfixed on master (commit e056bbf) at the time of the report. No fixed version. |
| Discovery Engine | ZAST.AI |

User enumeration tends to be dismissed as low-severity information disclosure, yet in a real attack chain it is usually the first step: confirm who the real users are, then go phishing, credential stuffing, or password-reset flooding. What makes CVE-2026-111869 notable is that Plane had already added a throttle to these endpoints (30 requests per minute), which looks like it caps enumeration speed — except **the counter is keyed on a request header the client can rewrite at will**. A channel that should crawl becomes a bulk query that runs at any rate.

The issue was found and verified by ZAST.AI and submitted to the Plane project via GitHub issue #9913.

## 1. Background: Auth Endpoints Must Answer "Is This Email Registered?"

To keep the front end responsive, Plane's authentication module exposes several endpoints reachable without authentication: pre-registration email check, password recovery, sign-in, and sign-up. Each must decide whether an email exists, and the result has to reach the front end in some form. The question is not whether information is returned — it is whether **the response for a registered user can be distinguished from the one for an unregistered user**. If it can, the service also provides a free email-existence lookup.

## 2. Cause One: All Four Endpoints Reveal the Answer

Note first that the next two sections describe **two causes of one vulnerability (CVE-2026-111869), not two separate flaws**. The first makes "can it be distinguished" true; the second makes "can it be distinguished in bulk" true. Either one alone keeps the impact limited; only together do they form a complete enumeration channel.

The report lists four distinguishable points. They differ in form and agree in conclusion:

- `POST /auth/email-check/`: a registered email returns `200 {"existing": true}`, an unregistered one returns `200 {"existing": false}`. The most direct of the four.
- `POST /auth/forgot-password/`: a registered email returns `200` with a check-your-inbox message; an unregistered one returns `400 USER_DOES_NOT_EXIST`, error code and all.
- `POST /auth/sign-in/`: both return 302, but the unregistered attempt carries `error_code=USER_DOES_NOT_EXIST` in the redirect URL.
- `POST /auth/sign-up/`: an already-registered email returns `error_code=USER_ALREADY_EXIST`; an unregistered one proceeds into the registration flow.

The core code sits at `check.py` lines 80–103. Both branches return the same JSON shape; the difference is only the value of `existing` — `true` for registered, `false` for not, so the caller needs no inference at all:

```python
# check.py:80-103 (v1.2.3, excerpt)
user = User.objects.filter(
    email=email).first()
if user:
    return Response(
        {"existing": True, ...}, 200)
return Response(
    {"existing": False, ...}, 200)

# forgot-password is even more direct:
# unregistered email returns 400 plus
# the error code USER_DOES_NOT_EXIST
```

## 3. Cause Two: The Throttle Key Comes From a Forgeable Header

If enumeration were capped at 30 requests per minute, the impact would be limited. Plane did add that limit: `AuthenticationThrottle` extends DRF's `AnonRateThrottle` with a rate of `30/minute`. The problem is **what the counter is grouped by**.

Plane's `get_client_ip()` takes the first segment of `X-Forwarded-For` as the client IP, and DRF's `SimpleRateThrottle.get_ident()`, when `NUM_PROXIES` is unset, concatenates **the entire `X-Forwarded-For` header** into the cache key. Whatever value is in `X-Forwarded-For` becomes the throttle bucket — and both values are decided by the requester.

```python
# plane/utils/ip_address.py:5-11
xff = request.META.get("HTTP_X_FORWARDED_FOR")
if xff:
    ip = xff.split(",")[0]
else:
    ip = REMOTE_ADDR

# DRF get_ident(): with NUM_PROXIES
# unset, the whole XFF header is the
# throttle key
return ''.join(xff.split()) \
    if xff else remote_addr
# new XFF value = new counter bucket
```

This path holds under default deployment. nginx `proxy_pass` without explicit `set_real_ip_from` and `real_ip_header` forwards the client-supplied leading segment of `X-Forwarded-For` upstream; Django, with no `NUM_PROXIES`, trusts that header. Two layers of default behavior stack up and forgery becomes the norm. **The throttle still runs — it is just counting IPs the attacker made up.**

![PoC Demo]({{ "/assets/img/plane.gif" | relative_url }})

## 4. Impact: Enumeration Is the Entry to Later Steps

- **Harvest valid accounts**: run an email list through the endpoint to filter out real users and prepare a target list for phishing and credential stuffing.
- **Confirm organizational ties**: determining whether a specific person uses a target's Plane instance is intelligence in itself — it corroborates internal collaboration patterns and employment status.
- **Combine with other primitives**: the report notes the same `ForgotPasswordEndpoint` can also be used to send bulk reset emails to confirmed addresses, setting up harassment or phishing.

The exposure depends on deployment shape: the instance must be directly exposed, or the reverse proxy must forward the client-supplied `X-Forwarded-For`; if the front proxy overwrites that header, throttling returns to normal.

## 5. Verified by the ZAST.AI Discovery Engine

This vulnerability was found by the ZAST.AI Discovery Engine and submitted to the Plane project via GitHub issue #9913. The PoC shipped with the report states it was tested against **Plane v1.2.3 (Docker self-hosted deployment)** and covers three stages:

- **The throttle does engage**: sending consecutive requests to `/auth/email-check/` without any forged header returns `429 RATE_LIMIT_EXCEEDED` after roughly 30 attempts, consistent with the `30/minute` configuration.
- **The throttle can be bypassed**: continuing with a different `X-Forwarded-For` value each time is no longer blocked — every new value maps to a fresh counter bucket.
- **Enumeration is batch-decidable**: querying an email list one by one, the `existing` field in the response body alone decides registration status, with no manual comparison of response differences.

## 6. Remediation

Master remained unfixed when the report was written. Three measures can proceed in parallel:

- **Set `NUM_PROXIES`**: match the actual proxy depth so `AnonRateThrottle.get_ident()` resolves a trustworthy client address instead of the whole forgeable `X-Forwarded-For`.
- **Unify responses**: return the same status code and body regardless of registration, for example always `200` with "if this email is registered, you will receive a message". This has to be applied on all four endpoints, including the `error_code` in redirect URLs.
- **Add a layer at the proxy**: use nginx `limit_req` for global per-IP throttling keyed on the real client IP, with `set_real_ip_from` and `real_ip_header` configured so only known proxies are trusted.

## 7. Conclusion

Both causes look small on their own; together they form an automatable probing channel. Two things follow. **First, rate limiting is a security control whose key must come from a source that cannot be forged** — treating `X-Forwarded-For` as identity hands the gate to the party being limited. **Second, enumeration does not require an error**: differing response semantics are enough, even when the status code matches and the wording differs by a single sentence.

For teams running self-hosted services the fix is cheap: one configuration value, one response unification, one proxy rule. The hard part is noticing that an information outlet exists at all and can be scaled up. That is also where the value of this class of bug lies — it hands over no permissions directly, but it tells an attacker which door to knock on next.

Full report:

https://github.com/makeplane/plane/issues/9913

https://github.com/makeplane/plane/security/advisories/GHSA-772j-mc6j-f8wq
