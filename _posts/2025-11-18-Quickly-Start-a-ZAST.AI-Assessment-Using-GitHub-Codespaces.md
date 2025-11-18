---
title: "Quickly Start A ZAST.AI Assessment Using GitHub Codespaces"
description: "A step-by-step tutorial on how to leverage GitHub Codespaces to build, package, and submit Java applications to ZAST.AI for vulnerability assessment without local environment setup."
keywords: "ZAST.AI, GitHub Codespaces, Java, Maven, Vulnerability Assessment, Cloud IDE, Security Testing, DevSecOps"
date: 2025-11-18
categories: ["User Guides", "DevSecOps", "Tutorials"]
tags:
  [
    "ZAST.AI",
    "GitHub Codespaces",
    "Java",
    "Vulnerability Assessment",
    "Cloud Development"
  ]


---


**ZAST.AI Team**,  

Nov. 18, 2025, Seattle

---

[GitHub Codespaces](https://github.com/features/codespaces) is a cloud-driven development environment suitable for various development scenarios, whether it’s a long-term project or a short-term task like reviewing pull requests. Operators can use these environments from either Visual Studio Code or a web-based editor. With it, we can quickly start a project and set up an environment, saving significant time and costs associated with preparing machines, setting up environments, configuring domains, etc.

<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/1.PNG' | relative_url }}" alt="1" width="850" height="auto"></center>

Today, we are going to illustrate how to use GitHub Codespaces to build projects online, compiling Java archive files and packaging into a Java archive file (war/jar), and submit the archive file to ZAST.AI for vulnerability assessing.

# **Step 1**

Log in to GitHub account and locate the corresponding project. Currently, since ZAST.AI focuses security vulnerabilities in Java-based web applications for now, we have prepared a Java web project as an example.

<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/2.PNG' | relative_url }}" alt="2" width="850" height="auto"></center>

Click the green "Code" button, and the pop-up window will display two tabs: Local and Codespaces. Switch to the Codespaces tab. If you have never created a Codespace before, select "Create Codespace on main."

<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/3.PNG' | relative_url }}" alt="3" width="450" height="auto"></center>

GitHub will then start creating the Codespace, which is a quick process, taking only a few seconds.

<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/4.PNG' | relative_url }}" alt="4" width="850" height="auto"></center>

Once created, we’ll see the project directory on the left side. Confirm that the project contains a pom.xml file; if it doesn't, the compilation will fail.

# **Step 2**

Now we can start building the project in the cloud on Codespace. From the "menu," select "Terminal," then open a "new terminal," or directly type in the lower terminal area:

*mvn clean package -DskipTests*

<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/5.PNG' | relative_url }}" alt="5" width="850" height="auto"></center>

After hitting Enter, the program will start running automatically. Once it finishes, you will see a "Build Success" prompt in the terminal window, and a new target folder will be created in the file directory. Open this folder to find the built Java files.

<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/6.PNG' | relative_url }}" alt="6" width="850" height="auto"></center>

# **Step 3**

Next, we will compile and package the project into an archive filethe project into a Java archive file so that we can upload it to ZAST.AI for vulnerability assess. In the terminal, type the following command:

*java -jar target/simple-login-app-0.0.2-SNAPSHOT.jar*

After typing the first letter, press the Tab key, and Codespace will auto-fill it for you.

<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/7.png' | relative_url }}" alt="7" width="850" height="auto"></center>

Once the run is completed, we will usually see a prompt in the bottom right corner of Codespace asking whether to set the port to public. We should confirm this setting.

<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/8.png' | relative_url }}" alt="8" width="850" height="auto"></center>

In addition, on the right of the "Terminal" tab, there’s a "Ports" tab with a notification bubble saying "1." Click it, and we will see a network icon next to the address displaying “Open in Browser.” Click it to open.

<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/9.png' | relative_url }}" alt="9" width="850" height="auto"></center>

If everything goes smoothly, we will see the following content. Clicking "Continue" will redirect us to this address. Completing this step means the Java project has been successfully created and is visible on the internet. We copy this site URL in advance, as it will be used for submitting the assessment task later.

<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/10.png' | relative_url }}" alt="10" width="850" height="auto"></center>

Next, go back to Codespaces, find the target folder, and download the archive file so that we can submit it to ZAST.AI for vulnerability assess.

<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/11.png' | relative_url }}" alt="11" width="850" height="auto"></center>

# **Step 4**

Now, let’s explain how to submit and assess this Java project on ZAST.AI. First, visit ZAST.AI and register for an account. Please ensure you provide thorough information on the waitlist application page to expedite your early access.

Before submitting the project for an assessment, there are five steps: uploading the deployment artifact file, performing connectivity checks, ownership verification, uploading source code, and adding test accounts. Here’s a detailed description of each step.

- First, give the project a name, choose the Java archive file downloaded from Codespace, then proceed to the next step for connectivity check.


<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/12.png' | relative_url }}" alt="12" width="850" height="auto"></center>

- On the connectivity check page, we need to enter the URL of the target service. This URL is the one we mentioned in step 3, so paste it directly and then perform the connectivity check. Once finished, click the next step to enter the ownership verification.


<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/13.png' | relative_url }}" alt="13" width="850" height="auto"></center>
<br>
<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/14.png' | relative_url }}" alt="14" width="850" height="auto"></center>

- In the ownership verifying step, the page provides detailed instructions. First, we need to manually add the HTTP challenge source and then copy the hash value provided on the page. Go back to Codespace, find the zast.txt document, and paste the hash value there. (If you haven't created one before, you need to create a new one.)


<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/15.png' | relative_url }}" alt="15" width="850" height="auto"></center>
<br>
<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/16.png' | relative_url }}" alt="16" width="850" height="auto"></center>

- After completing the ownership verification, proceed to upload the source code. ZAST.AI does not mandate that the actual source code be uploaded. However, the availability of source code will improve the precision of the assess result, e.g., the line numbers for each frame of the vulnerability call flows.


<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/17.png' | relative_url }}" alt="17" width="850" height="auto"></center>

- Next, we need to use the embedded browser to log in to test accounts. Change the default Simply change the API BASE URL in the address bar to the login URL.


<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/18.jpg' | relative_url }}" alt="18" width="850" height="auto"></center>

Log In: Log in to the test account on the login page.

<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/19.jpg' | relative_url }}" alt="19" width="850" height="auto"></center>

Add user session and Choose Role: After a successful login, select the role for the test accounts and then click “Add user session” in the action section.

<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/20.jpg' | relative_url }}" alt="20" width="850" height="auto"></center>
<br>
<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/21.jpg' | relative_url }}" alt="21" width="850" height="auto"></center>

Add Account: Once an account is logged in and confirmed (the ‘Add user session’ button will turn green), click “add account” to open a new tab.

<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/22.jpg' | relative_url }}" alt="22" width="850" height="auto"></center>

Repeat Process: Continue entering the address and logging in to the test accounts until all accounts are added.

<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/23.jpg' | relative_url }}" alt="23" width="850" height="auto"></center>

Before officially starting the assessment, the system will present an overview of this assessment, including the content we submitted. After confirming everything is correct, tick the box for the service terms and privacy policy, and then we can start the assessment!

<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/24.png' | relative_url }}" alt="24" width="850" height="auto"></center>

Assessing time will depend on the size of the submitted project, typically taking a few hours. The system will notify we via email once the assess is complete, so keep an eye on inbox.

<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/25.jpg' | relative_url }}" alt="25" width="850" height="auto"></center>

# **Step 5**

To ensure that the assess task completes smoothly, we need to keep the Codespace service running during the assessment. Therefore, please change the Codespace idle time to 4 hours; the path for modification is: GitHub -\> Settings -\> Code, Planning, and Automation -\> Codespaces -\> Default Idle Timeout. After making the time change, remember to save it before exiting.

<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/26.png' | relative_url }}" alt="26" width="850" height="auto"></center>

That’s all for the detailed steps on using GitHub Codespace to create projects and compile Java, as well as submitting Java archive files to the ZAST.AI for vulnerability assess. We hope this is helpful for everyone.

Lastly, here’s a little tip: once we receive the vulnerability report from ZAST.AI, the Codespace service can be wrapped up. Remember to return to the GitHub project page and manually stop and delete this Codespace project in the “Code” section; otherwise, it will keep running, consuming our allotted time.

<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/27.png' | relative_url }}" alt="27" width="850" height="auto"></center>

GitHub provides users with 120 hours of free time each month, you can view the specific consumption of Codespace in your Profile -\> Settings -\> Billing & Plan.

<center><img src="{{'/assets/img/Quickl-Start-a-ZAST.AI-Assessment-Using-GitHub-Codespaces/28.png' | relative_url }}" alt="28" width="850" height="auto"></center>
