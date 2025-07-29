---
layout: single
# permalink: /docs/user-manual/
last_modified_at: 2024-09-18T12:42:38-04:00
toc: false

APP_TITLE: "ZAST.AI"
EXTENSION_NAME: "ZAST.AI Helper"
SUPPORT_EMAIL: "support@zast.ai"
published: false
---

# {{ page.APP_TITLE }} User Manual

## Product overview

> {{ page.APP_TITLE }} is the world's first fully-automated penetration test service. Every security hole and vulnerability discovered and reported by {{ page.APP_TITLE }} has been exploited and verified with POC to ensure 100% accuracy.

## Getting started with {{ page.APP_TITLE }}

> Provide a short description of your product and how users can quickly use it.

Get started with {{ page.APP_TITLE }} by using this quickstart guide. This topic guides you through the following procedures:

1. Sign up and sign in to {{ page.APP_TITLE }}.
2. Configure a code scan job.
3. Prepare a code scan job.
4. Submit a code scan job.

## System requirements

> Describe the hardware and software requirements relating to the use of this product.

1. Chrome based browser is required to use {{ page.APP_TITLE }} service. (Latest Chrome and Edge have been tested.)
2. User needs to have access to source code of the deployed service and be able to package the source code.

## Sign up with and sign in to {{ page.APP_TITLE }}

> Provide specific steps for working with the procedure. Detail any items that need additional attention.

1. From the home page of {{ page.APP_TITLE }}, click "Get started with {{ page.APP_TITLE }}"

   ![]({{ "/assets/img/user-manual/sign-up-1.png" | relative_url }})

2. Click "SIGN IN" to sign up or sign in.

   ![]({{ "/assets/img/user-manual/sign-up-2.png" | relative_url }})

```
Note:

When you sign up with a new account, {{ page.APP_TITLE }} needs to go through the entire approval process before completion. Please contact {{ page.SUPPORT_EMAIL }} if you have not heard from us within 48 hours.

By signing up with {{ page.APP_TITLE }}, you indicate that you agree with {{ page.APP_TITLE }}'s Terms of Service and Privacy Policy.
```

<br>

3. You will be notified by email when new signup account has been approved.

## Configure a code scan job

> Provide specific steps for working with the procedure. Detail any items that need additional attention.

1. Sign in with your approved {{ page.APP_TITLE }} account. If you do not have an account yet, please refer to SignUp/SignIn Instructions.

   ![]({{ "/assets/img/user-manual/configure-1.png" | relative_url }})

2. Name your project by filling in the "PROJECT NAME" field.

3. Select the local Java archive (with .jar or .war file extension) of the service to be scanned, upload it to the "JAVA ARCHIVE" field.

4. Click "NEXT" to invoke connectivity check.

   ![]({{ "/assets/img/user-manual/configure-2.png" | relative_url }})

5. In "JAVA ARCHIVE URL", please provide the full URL of the target service deployment that corresponds to the JAVA ARCHIVE package configured in the previous step.

```
Note:

1. As {{ page.APP_TITLE }} uses "JAVA ARCHIVE URL" to verify exploitability, it is very important to ensure the accessibility of TARGET SERVICE URL to {{ page.APP_TITLE }} service

2. Security protection(e.g., WAF, EDR, HIDS, IDS/IPS ), on the target server, are strongly recommended to be temporarily turned off during code scan, in order for {{ page.APP_TITLE }} to properly access and scan the live service.

3. During {{ page.APP_TITLE }}'s exploitation efforts to validate an existing vulnerability of the target service, a successful exploitation might introduce impacts to the target service. It is important that you do NOT provide a product environment with critical live business as target scan service as it might endanger the ongoing business and service.
```

<br>

6. In case connectivity check did not succeed the first time

```
Note: Pay special attention to the following items if connectivity check did not succeed

1. Is target service an on-prem service that is hosted internally without allowing external access? If so, please set up inbound/outbound traffic access.
2. Is there any firewall setting that blocks certain inbound/outbound traffic?
3. Does the allowance/whitelist include {{ page.APP_TITLE }} agents' host network addresses?

```

7. Once the connectivity check has passed, the "NEXT" button will be clickable to move to the next step.

   ![]({{ "/assets/img/user-manual/configure-3.png" | relative_url }})

8. Now the user can verify proper ownership of the target service URL

   a. Create a file named zast.txt with the content displayed. Ownership verfication needs to be completed within 3 hours before this content expires.

   ![]({{ "/assets/img/user-manual/configure-4.png" | relative_url }})

   b. Save the zast.txt to the root directory of domain of target service URL. For example, if your target service URL is https://foo.com/bar , please make sure to copy zast.txt to the root directory to host https://foo.com/.well-known/zast.txt

   c. Verify and ensure in a browser that %rootURL%/.well-known/zast.txt is accessible and can display proper content, i.e., https://foo.com/.well-known/zast.txt can be accessed in a web browser.

   ![]({{ "/assets/img/user-manual/configure-5.png" | relative_url }})

   d. If you skip the above steps b&c, you might see the following error prompt. In that case, conduct the above steps b&c till success.

   ![]({{ "/assets/img/user-manual/configure-6.png" | relative_url }})

9. Now ownership verification will succeed. You can click "NEXT" to the next step.

   ![]({{ "/assets/img/user-manual/configure-7.png" | relative_url }})

10. Optional step: the users also upload extra frontend/backend source code that has been involved in the project in format of .zip or .rar. Click "NEXT" after this step is complete.

    ![]({{ "/assets/img/user-manual/configure-8.png" | relative_url }})

## Prepare a code scan job

> Provide specific steps for working with the procedure. Detail any items that need additional attention.

1. If the target service does not require accounts to log in, please check the "Skip adding test accounts..." option and then click "NEXT" to move on to the next step.

2. If the target service requires accounts to login properly, installation of {{ page.EXTENSION_NAME }} Chrome extension will be mandatory.

   a. If extension has not been installed or out of date, {{ page.EXTENSION_NAME }} Chrome extension needs to be installed first.

   ![]({{ "/assets/img/user-manual/prepare-1.png" | relative_url }})

   b. Click the "install", the installation page of {{ page.EXTENSION_NAME }} from Chrome web store will open. Click the "Add to Chrome" button to install the extension.

   ![]({{ "/assets/img/user-manual/prepare-2.png" | relative_url }})

   c. Click "Add extension", the {{ page.EXTENSION_NAME }} Chrome extension will be installed.
   ![]({{ "/assets/img/user-manual/prepare-3.png" | relative_url }})

   d. Click the extension icon in the Chrome browser following by clicking on "{{ page.EXTENSION_NAME }}". This opens the User Guideline of the {{ page.EXTENSION_NAME }} Chrome extension.

   ![]({{ "/assets/img/user-manual/prepare-4.png" | relative_url }})

   e. Follow those instructions to finish the configuration for {{ page.EXTENSION_NAME }} extension and create test accounts.

   ![]({{ "/assets/img/user-manual/prepare-5.png" | relative_url }})

## Submit a code scan job

> Provide specific steps for working with the procedure. Detail any items that need additional attention.

1. Read Terms of Service.

2. Check the "I have read and agreed to {{ page.APP_TITLE }}'s Terms of Service." box.

3. Click SCAN to submit a code scan job

   ![]({{ "/assets/img/user-manual/submit-1.png" | relative_url }})

## Manage submitted code scan jobs

CODE SCAN page lists all submitted code scan jobs

![]({{ "/assets/img/user-manual/manage-1.png" | relative_url }})

## Search project

By supplying filters including Project Name, Creation date range, Task Status, user can get a list of qualified code scan jobs.

## View report

Click the "VIEW" button for finished code scan job to view the report of that job.

## Delete

Click the trashcan icon to delete that code scan job.

## Reports

Provide a short description summarizing what users can accomplish after reading this procedure.

![]({{ "/assets/img/user-manual/report-1.png" | relative_url }})

## View report

Click the "VIEW" button for finished code scan job to view the report of that job.

## Purchase vulnerability details

1. Choose a vulnerability by checking the checkbox of the corresponding role.

2. Click "BUY" to purchase the selected vulnerabilities.

![]({{ "/assets/img/user-manual/purchase-1.png" | relative_url }})

3. Make payment

![]({{ "/assets/img/user-manual/purchase-2.png" | relative_url }})

## View vulnerability details

1. Go back to the report for a code scan job and click "VIEW" for any purchased vulnerability

![]({{ "/assets/img/user-manual/detail-1.png" | relative_url }})

2. Details of the finding will be displayed:

![]({{ "/assets/img/user-manual/detail-2.png" | relative_url }})
