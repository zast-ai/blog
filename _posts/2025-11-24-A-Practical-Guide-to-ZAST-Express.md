---
title: "A Practical Guide to ZAST Express"
description: "A Practical Guide to ZAST Express"
keywords: "ZAST.AI, Express, Visual Studio Code"
date: 2025-11-24
categories: ["Product Launch", "Security", "Open Source"]
tags:
  [
    "ZAST.AI",
    "Express"
  ]
# 📌 添加：用于 SEO 和 Social Meta Tags
author: Zast.ai 
# 📌 用于生成 Schema 的 'image' 属性，必须包含一个特色图片的路径，这个路径应该指向你的特色图片，且图片宽度应大于 1200 像素，以满足 Google 要求。
image: assets/img/logo-single.png
# 📌 添加：更长的摘要用于 social media 和 Schema 'description'
excerpt: "A Practical Guide to ZAST Express"
---


**ZAST.AI Team**,  

Nov. 24, 2025, Seattle

---
# Guide

**Your Security Copilot in IDE: ZAST Express**

Assess early, fix as you build: elevate your security posture!

Integrate security assessment from the start of your development workflow to breeze through security reviews and avoid expensive late-stage fixes.

ZAST Express brings code, open-source dependency, and IaC configuration analysis directly to your IDE. Address vulnerabilities the moment they pop up—no need to leave your coding environment.

<center><img src="{{'/assets/img/Express/SS/report.png' | relative_url }}" alt="" width="1200" height="auto"></center>

## **Key Features**

\- 🆕 **Zero-Day Detection** - Discover unknown vulnerabilities before they're exploited

\- 🔍 **Zero False Positives** - Every vulnerability verified with PoC

\- ⚡ **One-Click Assessment** - No complex configuration required

## **3 Steps to Run ZAST Express**

1. **Install** the extension from marketplace
2. **Click** Zast Express to launch assessment
3. **View** results when the assessment finished

## **Installation**

VS Code/Cursor Marketplace

1. Open VS Code or Cursor
2. Go to Extensions (Ctrl+Shift+X)
3. Search for "ZAST Express"
4. Click Install

<center><img src="{{'/assets/img/Express/SS/install.png' | relative_url }}" alt="install" width="1200" height="auto"></center>

## **Quick Start**

### **Step 1: Login to ZAST Express**

Click ZAST Express to open the panel. Login from the "Home" section or by clicking the profile avatar in the top-right corner.

<center><img src="{{'/assets/img/Express/SS/login.png' | relative_url }}" alt="login" width="1200" height="auto"></center>

### **Step 2: Select Artifacts**

After successful login, you'll see the "Security Assessment" panel. Select artifacts directly from your workspace. Also, we recommend uploading source code to improve assessment depth and accuracy.

<center><img src="{{'/assets/img/Express/SS/artifacts.png' | relative_url }}" alt="artifacts" width="1200" height="auto"></center>

### **Step 3: Set Up** **Connectivity** **via Cloudflared Tunnel**

To establish assessment connectivity, input the port where your project is running and click "Tunnel." This will automatically install cloudflared and generate a secure access link for your project. **During the assessment, please ensure the service remains continuously accessible.**

<center><img src="{{'/assets/img/Express/SS/tunnel.png' | relative_url }}" alt="tunnel" width="1200" height="auto"></center>

### **Step 4: Login Test Accounts via** **Embedded** **Browser (\*\*to test features protected by authentication\*\*)**

If your target service requires authentication, use the embedded browser to log in with test accounts of different roles. Replace the URL in the embedded browser with your login URL at first and then login with the test accounts.

<center><img src="{{'/assets/img/Express/SS/login1.png' | relative_url }}" alt="login1" width="1200" height="auto"></center>

After logging into the test account, select the correct role and save the user session.

<center><img src="{{'/assets/img/Express/SS/login2.png' | relative_url }}" alt="login2" width="1200" height="auto"></center>

Click "Add Account" to configure multiple test accounts, and don't forget to choose role and save session for all test accounts.

<center><img src="{{'/assets/img/Express/SS/login3-1.png' | relative_url }}" alt="login3-1" width="1200" height="auto"></center>

### **Step 5: Start Assessment**

After completing all previous steps, click the "Start Security Assessment" button at the bottom to submit your task.

<center><img src="{{'/assets/img/Express/SS/submit.png' | relative_url }}" alt="submit" width="1200" height="auto"></center>

### **Step 6: View Reports**

When the assessment is complete, you'll see the task in your recent tasks list. Click "Click to view report" to access detailed results.

<center><img src="{{'/assets/img/Express/SS/view.png' | relative_url }}" alt="view" width="1200" height="auto"></center>

[Video Guide](https://www.youtube.com/watch?v=EuZMmGljVB0&t=6s) for step-by-step help

### **Task Management**

The left sidebar provides two task sections for managing your security assessments:

- **Workspace Tasks**: Shows the latest 5 tasks for the Project-specific tasks (e.g., if you assess one project multiple times, the related tasks will be listed in workspace tasks)
- **Recent Tasks**: Shows the latest 10 tasks across all your projects

For all assessment reports' archives, please visit [ZAST Reports Dashboard](https://zast.ai/main/reports).

## **Supported Environments**

\- **IDEs**: VS Code, Cursor

\- **Languages**: Java, JavaScript (More languages support on the way)

\- **Frameworks**: Web applications

## **Support**

\- **Issues**: [GitHub Issues](https://github.com/zast-ai/zast-extension/issues?utm_source=vsmp&utm_medium=ms%20web&utm_campaign=mpdetails)

\- **Email**: support@zast.com