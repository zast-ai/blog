---
title: "How to Use Zast.ai"
description: "Complete step-by-step guide on how to use Zast.ai for vulnerability assessment. Learn how to upload code, verify ownership, add test accounts, and get detailed security reports with zero false positives."
keywords: "Zast.ai tutorial, vulnerability assessment guide, security testing, code upload, ownership verification, test accounts, security reports, AI security, automated vulnerability detection"
author: "Zast.ai Team"
date: 2025-07-28
categories: ["Tutorial", "Security", "AI"]
tags: ["vulnerability assessment", "AI security", "cybersecurity"]
header:
  og_image: "/assets/img/ZastxCodespace/upload.jpg"
last_modified_at: 2025-07-28
---

In this post, we will show you how to use <a href="https://zast.ai" target="_blank">zast.ai</a> to assess vulnerability step by step. Simply visit <a href="https://zast.ai" target="_blank">zast.ai</a> and register for an account to get started. Currently, new account holders need to apply to join a waitlist for activation. Please ensure you provide thorough information on the waitlist application page to expedite your early access.

There are five steps to finish an assessment on <a href="https://zast.ai" target="_blank">zast.ai</a>.

- Upload the Java archive file
- Check connectivity
- Verify ownership
- Upload source code
- Verify test accounts

## Step 1:

Give the project a name, choose and upload the source code archive package (with extensions .jar, .war, or .zip) of the application service to be assessed, then proceed to the next step for connectivity check.

![]({{'/assets/img/ZastxCodespace/upload.jpg' | relative_url }})

## Step 2:

Simply enter the URL of the API BASE URL.

![]({{'/assets/img/ZastxCodespace/check.jpg' | relative_url }})

![]({{'/assets/img/ZastxCodespace/check-ok.jpg' | relative_url }})

## Step 3:

In the ownership verifying phase, follow the detailed instructions to finish adding HTTP challenge source. You can also refer to documentation for more detailed information.

![]({{'/assets/img/ZastxCodespace/hash.jpg' | relative_url }})

## Step 4:

Then we can proceed to upload the source code. <a href="https://zast.ai" target="_blank">Zast.ai</a> does not mandate that the actual source code be uploaded. However, the availability of source code will improve the precision of the assessment result, e.g., the line numbers for each frame of the vulnerability call flows.

![]({{'/assets/img/ZastxCodespace/source-code.jpg' | relative_url }})

## Step 5:

Next, we need to use the embedded browser to log in to test accounts. Change the default Simply change the API BASE URL in the address bar to the login URL.

![]({{'/assets/img/ZastxCodespace/browser1.jpg' | relative_url }})

Log In: Log in to the test account on the login page.

![]({{'/assets/img/ZastxCodespace/browser2.jpg' | relative_url }})

Add user session and Choose Role: After a successful login, select the role for the test accounts and then click "Add user session" in the action section.

![]({{'/assets/img/ZastxCodespace/browser3.jpg' | relative_url }})

![]({{'/assets/img/ZastxCodespace/browser4.jpg' | relative_url }})

Add Account: Once an account is logged in and confirmed (the 'Add user session' button will turn green), click "add account" to open a new tab.

![]({{'/assets/img/ZastxCodespace/browser5.jpg' | relative_url }})

Repeat Process: Continue entering the address and logging in to the test accounts until all accounts are added.

![]({{'/assets/img/ZastxCodespace/browser6.jpg' | relative_url }})

## Process Completed

The system will present an overview of this assessment, including the content we submitted. After confirming, tick the box for the service terms and privacy policy, and then we can start the assessment!

![]({{'/assets/img/ZastxCodespace/assess-new.jpg' | relative_url }})

Assessment time will depend on the size of the submitted project, typically taking a few hours. The system will notify we via email once the assessment is complete, so keep an eye on inbox.

![]({{'/assets/img/ZastxCodespace/reports.jpg' | relative_url }})

That’s all for the detailed steps on using <a href="https://zast.ai" target="_blank">zast.ai</a> for vulnerability assessment. We hope this will be helpful for you.
