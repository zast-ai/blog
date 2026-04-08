---
title: "`verl` Analysis: When Prompt Injection Reaches Code Execution"
description: "Technical analysis of a previously undisclosed ACE path in `verl <= 0.7.0`, where prompt-controlled model output reaches eval() inside the reward pipeline. ZAST.AI verified the full path with a PoC."
keywords: "verl vulnerability, Prompt Injection, Arbitrary Code Execution, eval, ByteDance, RL training security, AI supply chain risk, ZAST.AI, AI security, vulnerability research"
date: 2026-04-07
categories: ["Vulnerability Research", "AI Security"]
tags:
  [
    "verl",
    "Prompt Injection",
    "Arbitrary Code Execution",
    "AI Supply Chain Security",
    "ZAST.AI"
  ]
author: ZAST Team
image: assets/img/logo-single.png
excerpt: "ZAST.AI identified and verified a previously undisclosed ACE path in `verl <= 0.7.0`. The core issue is not just eval(), but whether prompt-controlled model output can cross an execution boundary inside the reward pipeline and become executable state."
---

> | Field | Value |
> |---|---|
> | Target Project | `verl` |
> | CVE ID(s) | Not assigned as of April 6, 2026 |
> | Max Severity | High (report CVSS 3.1: 8.1) |
> | Vulnerability Type | Indirect Prompt Injection -> Arbitrary Code Execution via unsafe `eval()` |
> | Discovery Engine | ZAST.AI |

ZAST.AI identified and verified a previously undisclosed vulnerability in **`verl <= 0.7.0`**, the ByteDance-initiated RL training library now maintained by `verl-project`. As of **April 6, 2026**, the public repository showed **20.5k GitHub stars**. The interesting part is not that `eval()` exists. It is that **prompt-controlled model output can cross an execution boundary inside the reward pipeline and reach code execution during grading**.

That distinction matters. A single-sink alert is easy to generate. Proving that model output can survive answer extraction, satisfy the matrix-specific branch conditions, and execute on a training node is a different standard. ZAST.AI traced that full path and validated it with a PoC.

## Execution Boundary 1: `match_answer()` Preserves Prompt-Controlled Output

The source is not a direct HTTP parameter. It is the model output string itself.

In `verl/utils/reward_score/prime_math/__init__.py`, `match_answer(response)` extracts an answer from `solution_str` using markers such as `answer:` and `answer is`, then returns the sliced content with no security filtering:

```python
def match_answer(response):
    is_matched = False
    for ans_marker in ["answer:", "answer is", "answers are"]:
        ans_idx = response.lower().rfind(ans_marker)
        if ans_idx != -1:
            is_matched = True
            response = response[ans_idx + len(ans_marker):].strip()

    is_matched = is_matched if any([c.isdigit() for c in response]) else False
    return is_matched, response
```

That return value becomes `prediction` in the grading path. In other words, attacker influence can enter through a poisoned dataset sample or other controllable training content, steer the model into emitting a crafted answer string, and carry that string forward as gradeable data.

The relevant call chain is short:

```text
RewardManager.__call__()
  -> compute_score(solution_str, ground_truth)
  -> match_answer(solution_str)
  -> math_equal(prediction, reference)
```

## Execution Boundary 2: `math_equal()` Executes It

The sink is in `verl/utils/reward_score/prime_math/grader.py`. When the reference answer is matrix-shaped and the extracted prediction is bracketed, the code evaluates the model output directly:

```python
elif r"\begin{pmatrix}" in reference and prediction.startswith("[") and prediction.endswith("]"):
    if isinstance(eval(prediction), list):
        pred_matrix = eval(prediction)
```

This branch only needs a few conditions:

- `reference` contains `\begin{pmatrix}`
- `prediction` starts with `[` and ends with `]`
- the payload avoids `_`, because `handle_base()` interferes with underscores
- the extracted answer contains at least one digit, because `match_answer()` requires that

Those are not theoretical constraints. They are practical payload-shaping rules, and the report demonstrates that they are satisfiable.

## Key PoC Fragment

The report does not need a long exploit script to prove the point. The key fragment is enough:

```text
The answer is [exec("import os; os.system('echo PWNED1 > /tmp/verl-rce-proof.txt')")]
```

This is a **key PoC fragment**, not a full standalone exploit script. The important result is that `match_answer()` extracts the bracketed payload, `math_equal()` routes it into `eval(prediction)`, and the grading process creates `/tmp/verl-rce-proof.txt` on the training host.

One technical detail is worth stating explicitly: in Python, `exec()` is being called as a built-in function inside an expression, so it can be evaluated inside `eval()`. It returns `None`, which means `eval("[exec(...)]")` becomes `[None]` and still passes the `isinstance(..., list)` check in this branch.

That turns a prompt injection problem into an execution problem.

## Kill Chain: From Dataset Poisoning to Training-Node ACE

The exploit chain is what makes this case representative:

1. an attacker poisons a public math dataset or other controllable training input  
2. a researcher runs `verl` for PPO / GRPO training or evaluation  
3. the model emits a crafted answer string under attacker influence  
4. `match_answer()` extracts it as `prediction`  
5. `math_equal()` reaches the matrix branch and calls `eval()`  
6. arbitrary code executes on the training or evaluation server

This is also the secondary lesson from the case: **AI supply-chain risk is no longer just about malicious packages or weights**. If model output is later treated as executable structure inside scoring or reward code, a poisoned dataset can cross that boundary.

That does not mean any training dataset is easy to poison in practice. The more realistic scenarios are teams reusing public datasets, third-party samples, or externally collected data in training and evaluation pipelines while downstream code continues to trust model output.

## Why This Security Property Is Hard to Capture with Sink-Only Detection

Traditional SAST can usually flag `eval()`.

The harder question is whether an attacker-controlled string can actually travel from model output to that sink under real feature logic. Here, the answer depends on semantics across multiple steps:

- raw `solution_str` becomes parsed answer content in `match_answer()`
- the payload survives normalization rules such as `handle_base()`
- the reference answer drives execution into the matrix branch
- the grading path executes during training or evaluation, not in dead code

That is why this is more than an unsafe-API finding. The real security property is **execution-boundary reachability**: can prompt-controlled model output become executable input inside the pipeline? ZAST.AI answered that by tracing the full path and validating it with a PoC.

## Conclusion

This is not just an unsafe `eval()`. It is a case where **prompt-controlled model output crosses an execution boundary inside a training pipeline**.

That is the broader shift modern AppSec has to deal with in AI systems. The problem is no longer only whether a dangerous function exists. It is whether data that looks like model output can later become executable state. Traditional SAST can surface the sink, but path validation is what establishes whether the execution chain is real.

**Sources**
- Vulnerability report: [ByteDance / verl ACE report](https://github.com/zast-ai/vulnerability-reports/blob/main/bytedance/verl_rce.md)
- Project homepage: [verl on GitHub](https://github.com/verl-project/verl)
- POC Demo: [Video on Youtube](https://www.youtube.com/watch?v=X3FwfYS-Xq0)
