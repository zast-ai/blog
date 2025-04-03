---
title: "Quick Tunnel: Local Web To Public Domain"
---

## Background

When creating security assessment tasks with ZAST, we often need to prepare for target project deployment. During this process, two common requirements typically arise:

- Mapping HTTP service ports from internal servers to the public internet
- Obtaining a usable temporary domain

Cloudflare's TryCloudflare feature perfectly addresses both issues with just a single command. Let's explore how to use this convenient tool.

![]({{'/assets/img/Quick-Tunnel/cloudflare.png' | relative_url }})

## What is TryCloudflare?
TryCloudflare is a free service provided by Cloudflare that allows developers to:
- Create quick, temporary tunnels to expose local web servers
- Get instant HTTPS-enabled domains
- Test web applications without complex configurations
- Share local development work with teammates

## Installing cloudflared
First, you'll need to install the cloudflared client. Here are the installation methods for different operating systems:

### Linux:
```bash
# download and install deb package

wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
dpkg -i cloudflared-linux-amd64.deb

# download and install RPM package via curl 

curl -L --output cloudflared.rpm https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-x86_64.rpm
rpm -ivh cloudflared.rpm

```
### MacOS:
```bash
# Download and install cloudflared via Homebrew

brew install cloudflared
```

### Windows:
```bash
# Download and install cloudflared via winget

winget install --id Cloudflare.cloudflared
```

## Quick Start
After installation, you can start using it without registering or logging into a Cloudflare account. Here are the specific steps:
### 1. Verify Local Service
First, verify your local service is running. In this example, we can see a Nginx Server running on port 80.

![]({{'/assets/img/Quick-Tunnel/curl.png' | relative_url }})

### 2. Create TunnelRun the following command to create a tunnel:

```bash
cloudflared tunnel --url localhost:80
```

This will generate a HTTPS domain (a subdomain of trycloudflare.com), for example: https://appropriations-attract-writer-examining.trycloudflare.com

![]({{'/assets/img/Quick-Tunnel/domain.png' | relative_url }})

### 3. Verify Connection

Visit the generated domain to verify the tunnel is working properly.

![]({{'/assets/img/Quick-Tunnel/connection.png' | relative_url }})

## Advanced Usage

### Customize Port Mapping
You can map any local port to your tunnel:

```bash
cloudflared tunnel --url localhost:3000
cloudflared tunnel --url localhost:8080
```

### Protocol Support
TryCloudflare supports various protocols:

```bash
# HTTP/HTTPS
cloudflared tunnel --url http://localhost:80
cloudflared tunnel --url https://localhost:443

# TCP
cloudflared tunnel --url tcp://localhost:3306
```

## Limitations and Considerations
1. Temporary Nature
- Domains are not permanent
- New domain generated each time
- Tunnel closes when command terminates
2. Usage Limits
- Maximum 200 concurrent requests
- Not suitable for production use
- Bandwidth limitations apply
3. Security Notes
- HTTPS enabled by default
- No authentication required
- Use with caution in sensitive environments


## Best Practices
1. Development Testing
- Perfect for local development
- Ideal for quick demos
- Great for team collaboration
2. Security Testing
- Useful for vulnerability assessments
- Easy integration with security tools
- Temporary nature reduces risk


## Conclusion
TryCloudflare provides a simple yet powerful solution for temporary web exposure needs. Its ease of use and zero-configuration approach makes it particularly valuable for security assessment tasks with ZAST.
