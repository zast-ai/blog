---
title: "CVE-2026-111210 Analysis: BIP-70 Payment Protocol SSRF Turns bitcoinj Wallets into Internal Network Probes"
description: "CVE-2026-111210 in bitcoinj 0.11.1–0.17: the BIP-70 payment_url is never validated and pki_type=\"none\" skips PKI, enabling SSRF even under verifyPki=true."
keywords: "CVE-2026-111210, bitcoinj, BIP-70, Payment Protocol, SSRF, PaymentSession, CWE-918, CWE-20, Java, ZAST.AI"
date: 2026-10-20
categories: ["Vulnerability Research"]
tags:
  - "CVE-2026-111210"
  - "bitcoinj"
  - "SSRF"
  - "BIP-70"
  - "Java"
  - "ZAST.AI"
author: ZAST Team
image: assets/img/logo-single.png
excerpt: "ZAST.AI discovered CVE-2026-111210 in bitcoinj: the BIP-70 payment_url is never validated and pki_type=\"none\" skips the entire PKI check, turning a wallet into an SSRF probe even under verifyPki=true."
---

| Field | Content |
|---|---|
| Target Project | bitcoinj (com.google:bitcoinj 0.11.x / org.bitcoinj:bitcoinj-core 0.12 – 0.17) |
| CVE ID(s) | CVE-2026-111210 |
| Max Severity | High (CVSS 3.1 = 8.6, AV:N/AC:L/PR:N/UI:R/S:C/C:H/I:L/A:N) |
| Vulnerability Type | CWE-918 Server-Side Request Forgery; CWE-20 Improper Input Validation |
| Affected Versions | 0.11.1 – 0.17 all affected, **no official fix available** |
| Discovery Engine | ZAST.AI |

bitcoinj is the most widely used Bitcoin protocol library in the Java ecosystem, embedded by numerous wallets, merchant tooling, and 40+ forked projects. CVE-2026-111210 exposes a trust misplacement rooted in the BIP-70 payment protocol design: a wallet hands the "payment destination" entirely to a message received from the other party, while the protocol's own PKI check can be switched off by the sender with a single field. The result is a server-side request forgery (SSRF) that requires no certificate, no DNS control, and can be triggered by nothing more than a QR code — and the victim wallet walks straight into the trap even under the most secure `verifyPki=true` configuration.

The issue was discovered and dynamically verified by ZAST.AI, and disclosed to the bitcoinj project via GitHub issue #4386.

## 1. Background: What the BIP-70 Payment Protocol Does

BIP-70 (Payment Protocol) turns a Bitcoin payment from a simple address transfer into a structured interaction: "merchant issues a payment request → wallet fills in the transaction and sends it back". On the wallet side, `PaymentSession` is responsible for fetching the `PaymentRequest` from the merchant, verifying its PKI signature, and then issuing an HTTP POST to the `payment_url` carried in the request, sending back the serialized `Payment` message (containing the signed transaction and the user's refund address).

The problem is that `payment_url` — the field that decides "where the payment confirmation goes back to" — together with `pki_type` ("whether to verify the signature"), both come from **a protobuf blob on the network that is entirely attacker-controlled**. The protocol relies on a centralized CA model and has a narrow footprint; Bitcoin Core removed BIP-70 as early as 0.20, yet bitcoinj still implements and enables it by default.

## 2. The Vulnerability: No Validation From SOURCE to SINK

The attacker-supplied `payment_url` is parsed from protobuf and stored verbatim into `paymentDetails`; `parsePaymentRequest` only validates the network identifier and output amounts, never this URL. When the user confirms the payment, `sendPayment` feeds it directly into `new URL(...)` and `openConnection()` — no scheme allowlist, no host validation, no loopback / private / link-local address filtering. Below is the trigger point, identical in 0.11.3 and 0.17:

```java
// PaymentSession.java — outbound request SSRF sink (identical in 0.11.3 and 0.17)
URL url;
try {
    url = new URL(paymentDetails.getPaymentUrl());   // attacker-controlled, no scheme/host check
} catch (MalformedURLException e) {
    throw new PaymentRequestException.InvalidPaymentURL(e);
}
return sendPayment(url, payment);

// inside sendPayment(...): SSRF sink + data exfiltration + response oracle
HttpURLConnection connection = (HttpURLConnection) url.openConnection();   // SINK
connection.setRequestMethod("POST");
connection.setRequestProperty("Content-Type", "application/bitcoin-payment");
connection.setDoOutput(true);
DataOutputStream outStream = new DataOutputStream(connection.getOutputStream());
payment.writeTo(outStream);    // signed txns + refund address leave the host
outStream.flush();
outStream.close();
InputStream inStream = connection.getInputStream();
Protos.PaymentACK paymentAck = Protos.PaymentACK.newBuilder().mergeFrom(inStream).build();
String memo = paymentAck.hasMemo() ? paymentAck.getMemo() : null;
return new Ack(memo);    // response content echoed back to caller
```

More critically, the protocol's own PKI check cannot stop it. BIP-70 states that `pki_type` is declared by the message sender, and `PaymentSession.verifyPki()` returns `null` immediately upon receiving `"none"` — meaning **the attacker only needs to set `pki_type` to `"none"` to skip the entire certificate / CA / signature verification**. Even when the wallet runs under the most secure `verifyPki=true` configuration, it is of no use:

```java
// sender picks pki_type; certificate check skipped entirely (verifyPki=true still bypassed)
public @Nullable PkiVerificationData verifyPki() throws PaymentRequestException {
    if (pkiVerificationData != null) return pkiVerificationData;
    if (paymentRequest.getPkiType().equals("none"))
        return null;   // attacker sets "none" -> no certificate / CA / signature needed
    // ... x509 verification only runs when pki_type is NOT "none"
}

// 0.17 equivalent lives in PaymentProtocol.verifyPaymentRequestPki()
final String pkiType = paymentRequest.getPkiType();
if ("none".equals(pkiType))
    return null;
```

![PoC Demo]({{ "/assets/img/4386-bit.gif" | relative_url }})

## 3. Impact: More Than Internal Network Probing

- **Internal network access**: requests can reach loopback, RFC1918 private ranges, and link-local addresses, including the cloud metadata endpoint `http://169.254.169.254/`.
- **Data exfiltration**: the POST body is not empty — `payment.writeTo(outStream)` sends the signed transaction and the user's refund address to the attacker-chosen host, making it SSRF compounded with a privacy leak.
- **Response oracle**: the `PaymentACK.memo` returned by the contacted host is parsed and surfaced to the caller (typically shown to the user), turning the victim into a semi-blind SSRF probe with readable output.
- **Non-HTTP schemes**: `new URL()` also accepts `file:` / `ftp:` / `jar:` schemes, which bitcoinj never filters, further widening the reachable surface.

## 4. Attack Chain: A Single QR Code Is Enough

The attacker stands up a merchant endpoint returning a malicious `PaymentRequest`: `pki_type="none"` (skips verification) and `payment_url` pointing at an internal or cloud-metadata address; then distributes the crafted `bitcoin:` URI (with the `r=` parameter) via QR code, web page, or email. The victim wallet processes it through the standard flow: `createFromBitcoinUri` fetches the request, `parsePaymentRequest` only validates the network and outputs, and `verifyPki()` returns `null` immediately because `pki_type="none"`; after the user confirms the payment, `sendPayment` drives `new URL(paymentDetails.getPaymentUrl()).openConnection()` toward the attacker-specified internal / cloud-metadata address — even under the most secure `verifyPki=true` configuration, to no avail.

## 5. Verified by the ZAST.AI Discovery Engine

This vulnerability was uncovered by the ZAST.AI Discovery Engine and submitted to the bitcoinj project via GitHub issue #4386. We performed an end-to-end dynamic reproduction on **unmodified** bitcoinj 0.11.3 and 0.17 (the latest release): the victim wallet, running under the most secure `verifyPki=true` configuration, calls `createFromBitcoinUri → sendPayment`, and finally `new URL(paymentDetails.getPaymentUrl()).openConnection()` sends the signed transaction and refund address to the attacker-specified internal address; `pkiVerificationData=null` confirms the certificate check was skipped entirely. The sinks in 0.12 – 0.16 were confirmed source-identical to 0.11.3 / 0.17 via the official Maven Central sources. Key verification evidence:

- **PKI check bypassed**: output shows `pkiVerificationData=null`, proving the PKI verification is skipped even under `verifyPki=true`.
- **SSRF actually triggered**: the internal target service receives a POST from the wallet host and returns `ackMemo=INTERNAL-SERVICE-REACHED`, `SSRF CONFIRMED: True`.
- **Data exfiltration confirmed**: the POST body carries the serialized `Payment` message (signed transaction + refund address); 205 bytes were delivered to the attacker-specified internal address in testing.

## 6. Downstream Impact: Who Is Actually Exposed

Whether a consumer is exposed depends on whether it actually reaches `PaymentSession.sendPayment`, not merely on whether bitcoinj is present:

- **bitcoinj-tools WalletTool**: calls the sink directly with zero guards; a complete exploit chain can be built using only the project's officially published artifacts.
- **Multiple forks**: ACINQ (eclair lineage), cash.bitcoinj (BCH), and others were confirmed via jar to carry the same sink with no guards; another 40+ altcoin forks are code-identical.
- **Bitcoin Wallet for Android (~10M installs)**: only parses the `PaymentRequest` and never calls `sendPayment`, and enforces its own scheme allowlist — so it avoids the non-HTTP scheme class; but its check is scheme-only, with no loopback / private / link-local filtering, **leaving a residual internal-network SSRF exposure**.

## 7. Remediation

As of disclosure, bitcoinj upstream has **no official fix** and the maintainer has not yet responded. Until a patch lands, integrators should harden on their own:

- **Validate scheme and address before connecting**: only allow `https` `payment_url`, and reject loopback, private (RFC1918), link-local, and multicast addresses; note that resolving-then-connecting leaves a DNS-rebinding (TOCTOU) window — a robust fix should pin the validated address for the actual connection, or route payment POSTs through an egress allowlist.
- **A more thorough trade-off**: given that BIP-70 depends on a centralized CA, has a narrow footprint, and has been deprecated by Bitcoin Core and most wallets, **removing or disabling the payment protocol by default** is a more reasonable option than patching.
- **Interim mitigation**: until a patch lands, restrict the wallet process's network egress (allow only necessary outbound addresses) and do not enable BIP-70 payment acceptance in internet-reachable environments.

## 8. Conclusion

The lesson of this CVE is not confined to the Bitcoin ecosystem. It demonstrates a classic design trap: handing the "whether to verify" decision to the message sender — so that **the most secure client configuration (verifyPki=true) becomes a no-op simply because of a `pki_type="none"`**. Real security should not rely on "the other party behaving honestly"; it must come from **safe-by-default** — the destination, scheme, and address range of any outbound request should be constrained from a trusted configuration side, not dictated by the input side. For a library that still enables a long-obsolete protocol by default, this 8.6-rated SSRF is a long-overdue reminder.

Full report:

https://github.com/bitcoinj/bitcoinj/issues/4386

https://vuldb.com/cve/CVE-2026-111210
