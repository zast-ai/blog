---
title: "Quick Tunnel: Local Web to Public Domain"
description: "Learn how to use the 'cloudflared' command to instantly create a secure, public HTTPS URL for your local web server. A step-by-step guide for developers and security testers to share and test local projects without complex configuration."
author: "ZAST.AI Team"
date: 2025-10-07
categories: [Tutorials, Web Development, Networking, Developer Tools, Security]
tags: [trycloudflare, cloudflared, quick tunnel, localhost, port forwarding, local development, web server, public domain, HTTPS, ngrok alternative, security testing, ZAST, developer tools, networking,]
hidden: false
---


**ZAST.AI Team**,

Oct. 07, 2025, Seattle

---



## **Background**

When creating security assessment tasks with ZAST, we often need to prepare for target project deployment. During this process, two common requirements typically arise:

1. Mapping HTTP service ports from internal servers to the public internet
2. Obtaining a usable temporary domain

Cloudflare's TryCloudflare feature addresses both issues with just a single command. Let's explore how to use this tool.

<center><img src="{{'/assets/img/Quick-tunnel-local-Web-to-public-domain/cloudflare.png' | relative_url }}" alt="cloudflare" width="750" height="auto"></center>

## **What is TryCloudflare?**

TryCloudflare is a free service provided by Cloudflare that allows developers to:

- Create quick, temporary tunnels to expose local web servers
- Get instant HTTPS-enabled domains
- Test web applications without complex configurations
- Share local development work with teammates

## **Installing cloudflared**

First, you'll need to install the [cloudflared client.](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/){:target="_blank"} Here are the installation methods for different operating systems:

### **Linux:**

```
# download and install deb package

wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
dpkg -i cloudflared-linux-amd64.deb

*# download and install RPM package via curl*

curl -L --output cloudflared.rpm https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-x86_64.rpm
rpm -ivh cloudflared.rpm
```

### **MacOS:**

```
# Download and install cloudflared via Homebrew

brew install cloudflared
```

### **Windows:**

```
# Download and install cloudflared via winget

winget install --id Cloudflare.cloudflared
```


## **Quick Start**
To help you visually follow the tunnel creation process, we’ve prepared a step-by-step tutorial video. You can watch it first, then follow the text steps below to practice:  
    [TryCloudflare Tunnel Tutorial](https://www.youtube.com/watch?v=fUnmSDVkqBA){:target="_blank"}
    
After installation, you can start using it without registering or logging into a Cloudflare account. Here are the specific steps:

1․ First, verify that your local service is running.


<center><img src="{{'/assets/img/Quick-tunnel-local-Web-to-public-domain/curl.png' | relative_url }}" alt="curl" width="750" height="auto"></center>

2․ Run the following command to create a tunnel:

```
cloudflared tunnel --url localhost:80
```

This will generate a HTTPS domain (a subdomain of *trycloudflare.com), for example: https://appropriations-attract-writer-examining.trycloudflare.com*

<center><img src="{{'/assets/img/Quick-tunnel-local-Web-to-public-domain/domain.png' | relative_url }}" alt="domain" width="750" height="auto"></center>

3․ Visit the generated domain to verify the tunnel is working properly.

<center><img src="{{'/assets/img/Quick-tunnel-local-Web-to-public-domain/connection.png' | relative_url }}" alt="connection" width="750" height="auto"></center>

## **Advanced Usage**

### **Custom Port Mapping**

You can map any local port to your tunnel:

```
cloudflared tunnel --url localhost:3000 
cloudflared tunnel --url localhost:8080
```

### **Protocol Support**

TryCloudflare supports various protocols:

```
# HTTP/HTTPS
cloudflared tunnel --url http://localhost:80
cloudflared tunnel --url https://localhost:443

# TCP
cloudflared tunnel --url tcp://localhost:3306
```

## **Limitations and Considerations**

1. Temporary Nature

    • Domains are not permanent

    • New domain generated each time

    • Tunnel closes when command terminates

2. Usage Limits

    • Maximum 200 concurrent requests

    • Not suitable for production use

    • Bandwidth limitations apply

3. Security Notes

    • HTTPS enabled by default

    • No authentication required

    • Use with caution in sensitive environments

## **Best Practices**

1. Development Testing

    • Suitable for local development

    • Applicable for quick demos

    • Convenient for team collaboration

2. Security Testing

    • Helpful for vulnerability assessments

    • Easy integration with security tools

    • Temporary nature reduces risk

## **Conclusion**

TryCloudflare provides a simple yet convenient solution for temporary web exposure needs. It is applicable for security assessment tasks with ZAST due to its ease of use and zero-configuration approach.