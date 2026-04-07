---
title: "Auditing Content Visibility for Divi Builder: Two Verified Bugs, Including CVE-2026-1829"
description: "Technical deep dive into CVE-2026-1829 within the Content Visibility for Divi Builder plugin. ZAST.AI's autonomous agent verified RCE via eval() and CSRF issues, impacting 2,000+ active installations."
keywords: "CVE-2026-1829, Divi Builder Security, WordPress Vulnerability, RCE, CSRF, ZAST.AI, AI for Security, Autonomous Verification"
date: 2026-03-19
categories: ["Vulnerability Research", "AI Security"]
tags:
  [
    "CVE-2026-1829",
    "WordPress Security",
    "Divi Builder",
    "Remote Code Execution",
    "Autonomous Agents"
  ]
author: ZAST.AI
image: assets/img/logo-single.png
excerpt: "Beyond simple sink detection: ZAST.AI identifies and autonomously verifies CVE-2026-1829. Learn how our AI agent traced attacker-controlled data through Gutenberg attributes to prove reachability and deliver a zero-false-positive report."
---

> | Field | Value |
> |---|---|
> | Target Project | Content Visibility for Divi Builder |
> | CVE ID(s) | CVE-2026-1829 + 1 additional verified CSRF issue |
> | Max Severity | Critical |
> | Vulnerability Type | Remote Code Execution, CSRF |
> | Discovery Engine | [ZAST.AI](https://zast.ai) |

[ZAST.AI](https://zast.ai) found **two verified vulnerabilities** in *Content Visibility for Divi Builder 4.01*. The interesting part is not just the bug count. It is that the critical issue, **CVE-2026-1829**, sits behind application-specific expression handling and reaches `eval()` through two different feature paths. A syntax-level rule can identify the sink, but exploitability and prioritization still depend on tracing the full feature flow, and the companion CSRF issue requires a different line of reasoning.

Both issues were **automatically discovered and validated with PoCs**.

## Cluster 1: RCE via User-Controlled Visibility Expressions (CVE-2026-1829)

The core bug is in `includes/plugin.class.php`, inside `evaluate_visibility_expression()`:

```php
public static function evaluate_visibility_expression($expression, $type, $data) {
    $visibility = true;
    try {
        eval( '$visibility = ' . $expression . ';' );
    }
```

This is a classic unsafe sink, but the exploitability depends on whether attacker-controlled data can reach `$expression`. In this plugin, it can — through **two separate sources**.

### Source path 1: Gutenberg block attributes

In `hook_into_gutenberg_modules()` (`includes/plugin.class.php:329-365`), the plugin reads:

- `module.cvdb.contentVisibilityCheck.desktop.value`

The only meaningful validation described in the report is `is_string()`. That is type checking, not content validation.

### Source path 2: Legacy shortcode attributes

In `cvdb_execute()` (`cvdb-et-builder-element.class.php:70-97`), the plugin reads:

- `cvdb_content_visibility_check`

The code performs URL-decoding style replacements such as `%22 -> "` and `%5D -> ]`, but still applies **no security filter** before passing the result to the same evaluator.

### Why this is exploitable

The data flow is straightforward:

```text
Block attribute / shortcode attribute
  -> string check or decode
  -> evaluate_visibility_expression($expression, ...)
  -> eval('$visibility = ' . $expression . ';')
```

A Contributor can create a draft or previewable page and place a payload into the visibility expression. The report’s PoC uses a marker-file write to demonstrate code execution. A simplified example is:

```text
true; file_put_contents('/tmp/marker', 'SUCCESS')
```

Which becomes:

```php
$visibility = true; file_put_contents('/tmp/marker', 'SUCCESS');
```

The trigger URL from the validated PoC is:

```text
http://target:7418?p=8&preview=true
```

In the validated PoC run, the evidence was a created marker file with a randomized name:

```text
/tmp/wpsec_rce_e4fc2a3d
```

That is enough for arbitrary file write, and from there the impact expands to reading `wp-config.php`, executing system commands, planting admin users, or deploying a backdoor.

### Why traditional SAST misses the real story

Flagging `eval()` is straightforward. The harder part is answering the questions that determine exploitability and prioritization:

- Is `$expression` attacker-controlled?
- Through which routes?
- What privilege level is required?
- Is exploitation real or only theoretical?

In this case, the exploitability depends on **cross-function semantic flow** across Gutenberg integration, shortcode handling, and preview rendering. A syntax-first engine may stop at “dangerous sink present” and leave the analyst with an alert that still requires prioritization. It may also miss one of the two source paths.

ZAST’s value here is not merely recognizing `eval()`, but **proving** that a Contributor-controlled field reaches it and then **executing a PoC** that creates a marker file. That turns a high-uncertainty pattern into a verified critical finding.

## Cluster 2: State-Changing AJAX Without CSRF Protection

The second issue is lower impact but still useful as a contrast. In `includes/plugin.class.php:446-450`, the plugin registers an authenticated AJAX handler that updates user state without nonce validation:

```php
public function ajax_dismiss_rating_notice() {
    update_user_option( get_current_user_id(), $this->show_rating_notice_option_key, '0' );
    exit;
}
```

The JavaScript bootstrap in `plugin.class.php:427-429` localizes:

```php
wp_localize_script( ..., 'cvdbAdminScript', array(
    'ajaxUrl' => admin_url( 'admin-ajax.php' ),
    'textDomain' => self::get_text_domain()
) );
```

Notably, no nonce is passed to the client, and the handler does not call `check_ajax_referer()` or `wp_verify_nonce()`.

The exposed action is:

```text
wp_ajax_content-visibility-for-divi-builder_dismiss-rating-notice
```

The report’s PoC is a minimal auto-submitting form targeting:

```html
<form method="POST" action="https://target.com/wp-admin/admin-ajax.php">
  <input type="hidden" name="action"
         value="content-visibility-for-divi-builder_dismiss-rating-notice">
</form>
<script>document.forms[0].submit();</script>
```

Impact is low: it silently changes a user option controlling whether the rating notice is shown. But it is still a real state-changing request with no CSRF defense, and the PoC reportedly confirmed a `200` response and a database-side transition from `'1'` to `'0'`.

### Why this matters for tool design

This kind of issue is often invisible to tools that focus on sink signatures alone. There is no flashy dangerous API here. The bug is the **absence of a defense** in a workflow that mutates state. Detecting that reliably requires understanding:

- the AJAX action registration,
- the authenticated execution context,
- the state-changing call to `update_user_option()`,
- and the missing nonce generation / verification pair.

That is semantic reasoning, not string matching.

## Conclusion

The point is not that one plugin contained an `eval()` bug and a missing nonce. The point is that **security analysis is moving from suspicion to proof**.

Traditional SAST focuses on suspicious syntax. Addit [ZAST.AI](https://zast.ai) traced the logic, generated PoCs, and reported only what it could verify.

For defenders, that difference matters more than raw finding volume.


