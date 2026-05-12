---
title: "CVE-2026-3352 Analysis: Persistent PHP Code Injection in Easy PHP Settings"
description: "Technical analysis of CVE-2026-3352 in Easy PHP Settings <= 1.0.4. ZAST.AI verified that sanitized admin input is written into `wp-config.php` as executable PHP, enabling persistent PHP code injection."
keywords: "CVE-2026-3352, Easy PHP Settings, WordPress vulnerability, PHP code injection, wp-config.php, sanitize_text_field, ZAST.AI, vulnerability research"
date: 2026-05-12
categories: ["Vulnerability Research", "WordPress Security"]
tags:
  [
    "CVE-2026-3352",
    "Easy PHP Settings",
    "WordPress Security",
    "PHP Code Injection",
    "ZAST.AI"
  ]
author: ZAST Team
image: assets/img/logo-single.png
excerpt: "ZAST.AI identified and verified CVE-2026-3352 in Easy PHP Settings <= 1.0.4. The issue is not just unsafe input handling, but that sanitized admin input is written into `wp-config.php` as executable PHP and persists across every request."
---

> | Field | Value |
> |---|---|
> | Target Project | Easy PHP Settings |
> | CVE ID(s) | CVE-2026-3352 |
> | Max Severity | Medium |
> | Vulnerability Type | PHP Code Injection |
> | Discovery Engine | ZAST.AI |

ZAST.AI found and verified **CVE-2026-3352** in *Easy PHP Settings <= 1.0.4*. The bug is not a flashy parser edge case. It is a familiar failure mode: user input is “sanitized” for HTML, then reused in a completely different context — **PHP source code written into `wp-config.php`**.

That context shift is the whole issue. Pattern-based SAST can recognize `sanitize_text_field()`, but that alone does not establish whether the sanitization is appropriate for a PHP code-generation path. Here, the data flow ends in a persistent configuration file that WordPress loads on every request, and `sanitize_text_field()` is not a PHP code sanitizer.

The finding was **automatically verified with a working PoC**, not reported as a speculative sink.

## Vulnerable Code Flow (CVE-2026-3352)

The vulnerable flow starts in `sanitize_wp_memory_callback()` in `class-easy-php-settings.php:425-444`:

```php
public function sanitize_wp_memory_callback( $input ) {
    $old_input = $this->get_option( 'easy_php_settings_wp_memory_settings', array() );
    $new_input = array();

    foreach ( $this->wp_memory_settings_keys as $key ) {
        if ( isset( $input[ $key ] ) ) {
            $new_input[ $key ] = sanitize_text_field( $input[ $key ] );
        }
    }

    if ( ! empty( $new_input ) ) {
        $this->update_wp_memory_constants( $new_input );
    }

    return $new_input;
}
```

The affected parameters are:

- `wp_memory_limit`
- `wp_max_memory_limit`

The request reaches this callback through the standard WordPress Settings API via `options.php`, behind CSRF protection and the `manage_options` capability check. That matters for severity, but it does not make the sink safe.

The real bug appears in `update_wp_memory_constants()` at `class-easy-php-settings.php:1797-1807`:

```php
foreach ( $constants as $const ) {
    $key = strtolower( $const );
    if ( isset( $input[ $key ] ) && ! empty( $input[ $key ] ) ) {
        $value = "'" . $input[ $key ] . "'";

        if ( preg_match( '/define\(\s*\'' . $const . '\'\s*,\s*\'.*?\'\s*\);/i', $config_content ) ) {
            $config_content = preg_replace( /* ... */ "define( '$const', $value );", $config_content );
        } else {
            $config_content = str_replace( "/* That's all, stop editing!",
                "define( '$const', $value );\n\n/* That's all, stop editing!", $config_content );
        }
    }
}

$wp_filesystem->put_contents( $config_path, $config_content );
```

The plugin takes a string that only passed `sanitize_text_field()`, wraps it in single quotes, and writes it directly into `wp-config.php`. No escaping. No allowlist. No format check.

## Exploit Path and PoC

The PoC payload from the report is short:

```text
256M'); system('id');//
```

An administrator enters it under **Settings > Easy PHP Settings > General Settings** in the `WP_MEMORY_LIMIT` field. The resulting line in `wp-config.php` becomes:

```php
define( 'WP_MEMORY_LIMIT', '256M'); system('id');//' );
```

That parses as:

- `define( 'WP_MEMORY_LIMIT', '256M')` — valid statement
- `system('id')` — injected PHP code
- `//' );` — comments out the trailing syntax

Because `wp-config.php` is loaded on every request, the injected code becomes **persistent code execution**, not a one-shot admin action.

The exploit preconditions are explicit:

- attacker has an **Administrator** account with `manage_options`
- `wp-config.php` is writable by the web server

This is why the report classifies the issue as authenticated PHP code injection rather than unauthenticated RCE. But once the payload is written, execution happens during normal page loads.

![PoC Demo]({{ "/assets/img/3352.gif" | relative_url }})

## Why the Sanitization Fails

The failure is structural. `sanitize_text_field()` removes HTML tags and normalizes whitespace. It does **not** remove characters that matter in PHP syntax, including:

- `'`
- `(` and `)`
- `;`
- `/`

So the defense is aimed at the wrong threat model. The plugin is not storing plain display text; it is generating PHP source code.

The report also highlights a useful contrast. In the same codebase, `update_wp_config_constants()` handles values like `WP_DEBUG` with hardcoded `'true'` / `'false'` strings. That path is safe because the written values are constrained before they reach the file write. The vulnerable memory-limit path does the opposite: it treats free-form input as if it were configuration syntax.

### Why traditional SAST misses this class of bug

This is not a missing sanitizer in the abstract. It is a **semantic mismatch** between the sanitizer and the sink.

A syntax-first SAST engine may see:

- input goes through `sanitize_text_field()`
- request is protected by WordPress Settings API checks
- file update logic uses common string functions

That means additional context is still needed to determine whether the sanitizer is appropriate for the target sink. To prioritize this correctly, a tool needs to reason across the whole flow:

- `options.php`
- `sanitize_wp_memory_callback()`
- `update_wp_memory_constants()`
- `put_contents( $config_path, $config_content )`
- and the fact that `wp-config.php` is executable PHP loaded on every request

That is where semantic analysis matters. ZAST did not stop at “user input reaches file write.” It verified that the written content breaks out of `define()` and executes attacker-controlled PHP.

## Conclusion

CVE-2026-3352 illustrates why source-code security tooling should optimize for **proof**, not volume. The problem is not merely that user input reaches a sensitive file. The problem is that the plugin writes **executable configuration** using a sanitizer that was never meant for code generation.

Traditional SAST typically infers risk from patterns. ZAST’s approach is to trace the real execution semantics and validate exploitability with a PoC, providing verified results for prioritization.
