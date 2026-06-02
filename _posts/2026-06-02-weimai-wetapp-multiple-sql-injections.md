---
title: "CVE-2026-3956 / CVE-2026-3957 Analysis: Multiple SQL Injection Paths in weimai-wetapp"
description: "Technical analysis of CVE-2026-3956 and CVE-2026-3957 in weimai-wetapp <= 1.0.0. ZAST.AI verified exploitable SQL injection in both an admin listing path and a public movie recommendation path."
keywords: "CVE-2026-3956, CVE-2026-3957, weimai-wetapp, SQL injection, MyBatis, keyword parameter, cat parameter, ZAST.AI, vulnerability research"
date: 2026-06-02
categories: ["Vulnerability Research", "Application Security"]
tags:
  [
    "CVE-2026-3956",
    "CVE-2026-3957",
    "weimai-wetapp",
    "SQL Injection",
    "ZAST.AI"
  ]
author: ZAST Team
image: assets/img/logo-single.png
excerpt: "ZAST.AI identified and verified two SQL injection vulnerabilities in weimai-wetapp <= 1.0.0. The issues affect both an administrative user listing endpoint and a public movie recommendation path, showing a repeated query trust failure across different application surfaces."
---

| Field | Content |
|---|---|
| Target Project | weimai-wetapp |
| CVE ID(s) | CVE-2026-3956, CVE-2026-3957 |
| Severity | Medium |
| Vulnerability Type | SQL Injection |
| Discovery Engine | ZAST.AI |

ZAST.AI identified and verified two SQL injection paths in `weimai-wetapp <= 1.0.0`. The interesting part is not that both bugs sit in obscure maintenance code. One path is in an administrative user listing endpoint, and the other sits in a public-facing movie recommendation flow.

That combination matters because it shows the same trust failure repeating across different parts of the application. In both cases, request data crosses the controller -> service -> MyBatis mapper path and reaches a database-facing query flow without effective structural constraint. The result is not a theoretical sink. Both paths were validated with SQLMap, including extraction of the current database user as `root@%`.

The issues were automatically discovered and validated by ZAST.AI. The public GitHub issues linked at the end of this post are ZAST.AI's own disclosure records created during coordinated disclosure and CVE assignment, so the SQLMap output shown there is part of ZAST.AI's validation evidence rather than a separate third-party rediscovery.

![PoC Demo]({{ "/assets/img/3956.gif" | relative_url }})

## Cluster 1: CVE-2026-3956 in the Admin User Listing Flow

The first issue affects `/admin/auser/getAdmins`. According to the public report, the `keyword` parameter is passed through the controller, service, and MyBatis mapper path without sufficient constraint before reaching the query logic.

The issue summary is direct:

```text
/admin/auser/getAdmins?pageNum=1&limit=10&keyword=a*
```

The validation output in the report shows boolean-based blind and error-based SQL injection working against the `keyword` value. One of the reported payloads is:

```text
.../admin/auser/getAdmins?pageNum=1&limit=10&keyword=a%' AND 5227=5227 AND 'bfKA%'='bfKA
```

The disclosure also includes a short code path showing `keyword` being forwarded from the controller into the service and then into the mapper-backed query:

```java
@GetMapping({"/getAdmins"})
public Result getAdmins(@RequestParam("pageNum") Integer pageNum,
    @RequestParam("limit") Integer limit,
    @RequestParam(value = "keyword", required = false) String keyword) {
    PageBean<AdminUser> adminUserPageBean =
        this.adminUserService.getAdmins(pageNum, limit, keyword);
    return new Result(adminUserPageBean);
}

public PageBean getAdmins(Integer pageNum, Integer limit, String keyword) {
    PageHelper.startPage(pageNum, limit);
    List<AdminUser> adminUsers = this.adminUserMapper.getAdminsByKeword(keyword);
    ...
}
```

The important point is not the specific payload shape. It is that an endpoint meant to filter or search administrator records lets a free-form request parameter shape the SQL execution context strongly enough for SQLMap to confirm exploitation and retrieve:

```text
current user: 'root@%'
```

This is exactly the kind of path that gets under-described if a review only says "there may be SQLi in admin search." The public material already supports the stronger conclusion: the parameter is exploitable.

## Cluster 2: CVE-2026-3957 in the Public Movie Recommendation Flow

The second issue affects `/home/getLikeMovieList`. Here, the vulnerable parameter is `cat`.

The public request shape is:

```text
/home/getLikeMovieList?movieId=1&cat=Action*
```

The report again shows successful SQLMap validation, including both boolean-based and error-based techniques. One of the payloads is:

```text
.../home/getLikeMovieList?movieId=1&cat=-1900' OR 3543=3543 OR 'MjOe'='rmnM
```

The second disclosure shows the same pattern in the public recommendation flow, where `cat` is accepted by the controller and then passed into recommendation logic that falls back to the mapper-backed query path:

```java
@GetMapping({"/getLikeMovieList"})
public Result getLikeMovieList(@RequestParam("movieId") Integer movieId,
    @RequestParam("cat") String cat) {
    List<Movie> movies = this.moviceService.getLikeMovieList(movieId, cat, 3);
    ...
}

public List getLikeMovieList(Integer movieId, String cat, Integer limit) {
    return this.movieMapper.getLikeMovieList(movieId, cat, limit);
}
```

And the reported database result is the same:

```text
current user: 'root@%'
```

That second path is what makes this case more representative than a single isolated bug. The same underlying trust problem appears not only in an administrative listing route, but also in a public recommendation-style endpoint where category input is treated as harmless filtering data.

## Why the Pairing Matters

It is easy to describe these as "two SQL injection bugs" and stop there. That would miss the more useful lesson.

The project repeats the same failure pattern across different business contexts:

- an admin-oriented query parameter used for user listing
- a public-facing category parameter used for movie recommendation logic

In both cases, the application accepts request input that looks operational or low risk, then carries it deeply enough into the query path for SQLMap to verify execution semantics rather than mere suspicion.

This is where semantics matter more than surface shape. A parameter called `keyword` looks like search input. A parameter called `cat` looks like a simple category selector. Neither name tells you whether the value is structurally constrained before it reaches SQL construction.

ZAST.AI is useful in cases like this because the value is not in merely flagging "possible SQL injection" at the controller boundary. The useful result is confirming that the path is actually exploitable.

## Why Traditional SAST Often Underspecifies Cases Like This

The most defensible claim is not that traditional SAST cannot detect SQL injection. That would be too broad.

A more accurate framing is that static tooling often becomes less useful when triage depends on how confidently a path can be shown to cross from user-controlled filtering input into a real query context without sufficient constraint. In this case, the public reports already provide what prioritization needs:

- the exact endpoints
- the vulnerable parameters
- confirmed SQLMap exploitation
- the recovered database user

That turns the result from "possible input-to-query flow" into "verified SQL injection in production-relevant paths."

## Remediation

The right fix is not "escape these two parameters a bit better" and stop there.

- Replace unsafe query construction with parameterized statements throughout the affected MyBatis paths.
- Apply strict server-side validation for fields like `keyword` and `cat` based on expected business formats, not generic string handling.
- Review adjacent endpoints that expose filtering, search, or recommendation parameters for the same query-building pattern.
- Treat validated SQLMap exploitation as a sign of a class-level query safety problem, not two unrelated one-off mistakes.

## Conclusion

`CVE-2026-3956` and `CVE-2026-3957` are useful because they show the same database trust failure in two different slices of the application: admin search and public recommendation logic.

That is why verification matters more than suspicion. ZAST.AI did not stop at identifying request parameters that looked risky. It confirmed that both paths were exploitable and reached the database with enough control to extract `root@%`.

References:
- Project: https://github.com/xierongwkhd/weimai-wetapp
- CVE record: https://www.cve.org/CVERecord?id=CVE-2026-3956
- CVE record: https://www.cve.org/CVERecord?id=CVE-2026-3957
- Disclosure report for CVE-2026-3956: https://github.com/xierongwkhd/weimai-wetapp/issues/48
- Disclosure report for CVE-2026-3957: https://github.com/xierongwkhd/weimai-wetapp/issues/49
