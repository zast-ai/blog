---
title: 'When Features Become Flaws: Assessing Component Vulnerabilities'
description: "This post analyzes the conflict between component features and security risks, proposing a balanced vulnerability definition based on case studies like Log4Shell and Spring4Shell."
keywords: "ZAST.AI, Component Vulnerability, Open Source Security, AI Security, Log4Shell, Spring4Shell, Apache Struts, OWASP, Secure Development"
author: "Chris"
date: 2025-11-04
categories: ["AI Security", "Security"]
tags:
  [
    "ZAST.AI",
    "AI Security",
    "Component Vulnerability",
    "Open Source Security",
    "Log4Shell",
    "Spring4Shell",
    "Apache Struts",
    "OWASP",
    "Secure Development"
  ]

---

**Chris**,  
Co-founder, ZAST.AI  
Nov. 04, 2025, Toronto

---


## Introduction

Component reuse is fundamental to modern web development, yet defining vulnerabilities remains controversial. The core conflict lies in how component features are perceived: developers implement them as intended functionality, while security researchers view them as potential security risks. While OWASP Top 10 highlights component vulnerabilities as a critical security risk, organizations lack consistent standards to resolve these conflicting perspectives.

Based on extensive analysis of real-world cases and security research, ZAST.AI proposes a balanced definition: a component vulnerability is "functionality that exists outside the component's intended design, can be exploited by threat actors, and is not addressed in documentation or code comments." This definition serves as ZAST.AI's foundation for evaluating open source components, which becomes increasingly critical as vulnerability discoveries continue to rise as shown in the forecast below.

<center><img src="{{'/assets/img/When-Features-Become-Flaws-Assessing-Component-Vulnerabilities/forecast.png' | relative_url }}" alt="forecast" width="750" height="auto"></center>

<center><em>resource：https://www.first.org/blog/20250607-Vulnerability-Forecast-for-2025</em></center>

## Core Controversies

The definition of component vulnerabilities involves several fundamental conflicts. The most prominent is the inherent tension between powerful features and security risks. Features designed for flexibility, such as dynamic configuration or template rendering, often blur the line between intended functionality and potential vulnerabilities. What developers consider a powerful feature might represent an exploitable security risk in specific contexts.

The question of responsibility adds another layer of complexity. When security issues arise, who bears the responsibility - the component provider who implemented the feature, or the developer who integrated it? While documentation may warn about potential security implications, the adequacy of such warnings in absolving responsibility remains debatable. This connects directly to the challenge of secure defaults: should components prioritize convenience or security in their default configurations?

The assessment methodology itself presents significant challenges. Organizations struggle to establish clear boundaries between feature behaviors and security vulnerabilities. The evaluation process must consider multiple perspectives: the technical impact of potential exploits, the practical utility of the feature, and the broader security implications for the ecosystem. These considerations often lead to inconsistent vulnerability classifications across different organizations and security teams.

<center><img src="{{'/assets/img/When-Features-Become-Flaws-Assessing-Component-Vulnerabilities/xkcd.png' | relative_url }}" alt="xkcd" width="450" height="auto"></center>

<center><em>resource：https://xkcd.com/2347/</em></center>

## Representative Cases

### Log4j's Log4Shell: When Logging Features Become Weapons

The Log4Shell vulnerability (CVE-2021-44228) illustrates the challenge of determining when functionality exceeds intended design. While the Log4j development team implemented JNDI lookup as an intended feature for configuration flexibility[^1], security researchers argued this functionality far exceeded the core logging purpose, effectively turning a logging component into a remote code execution vector[^2]. This case directly challenges our understanding of what constitutes "intended design" in component functionality.

The vulnerability's impact was influenced by two factors that align with ZAST.AI's definition: First, the feature was easily exploitable by threat actors through simple string manipulation, demonstrating how functionality can become a security risk. Second, while documentation mentioned JNDI lookup capabilities, it failed to adequately address the security implications, highlighting the gap between documenting features and documenting security risks.

### Spring4Shell: The Cost of Convenience

The Spring4Shell vulnerability (CVE-2022-22965) demonstrates the complexity of defining functionality boundaries in modern frameworks. Security researchers argued that the ClassLoader access capability, while intentionally designed for flexibility, exceeded the reasonable scope of a web framework's functionality[^3]. The Spring team's response that this was a configuration issue[^4] raises a crucial question about ZAST.AI's definition: when does configurable functionality cross the line from intended design to security vulnerability? Threat actors could exploit this boundary confusion to achieve remote code execution through specially crafted requests, demonstrating how exceeding intended design directly enables exploitation.

This case particularly highlights the documentation aspect of ZAST.AI's definition. While Spring's documentation covered the ClassLoader functionality, it didn't explicitly identify the security implications of certain configurations[^4]. This gap between technical documentation and security guidance shows why ZAST.AI's definition emphasizes the importance of addressing security implications in documentation, not just feature capabilities.

### Spring Cloud Function: The SpEL of Flexibility

The Spring Cloud Function vulnerability (CVE-2022-22963) provides a clear example of how features can conflict with security boundaries. The routing functionality's ability to process SpEL expressions[^5], while intentionally designed, created an attack surface that arguably exceeded the component's core purpose of function routing. This aligns with ZAST.AI's emphasis on distinguishing between intended design and security boundaries. Threat actors could exploit this expanded functionality by injecting malicious SpEL expressions through routing headers, turning a routing feature into a remote code execution vector.

The development team's defense that documentation implied the need for security measures[^5] directly addresses the documentation criterion in ZAST.AI's definition. However, this case raises a critical question: is implying security requirements sufficient, or should documentation explicitly address potential security risks? This tension between implicit and explicit security guidance helps validate ZAST.AI's focus on clear documentation of security implications.

### Apache Struts 2: Configuration Complexity vs Security

The Apache Struts 2 namespace vulnerability (CVE-2018-11776) shows how configuration flexibility can extend functionality beyond intended design. While the framework's namespace mechanism was designed for flexibility[^6], its ability to evaluate OGNL expressions exceeded the intended scope of URL handling. Threat actors could exploit this expanded functionality by crafting special URLs that triggered OGNL expression evaluation, demonstrating how features beyond core design create security risks. This case supports ZAST.AI's approach of examining functionality against intended design boundaries, rather than just implementation intentions.

The Struts team's emphasis on recommended settings[^7] highlights a key aspect of ZAST.AI's definition: the relationship between documentation and security. While the settings were documented, the security implications of deviating from recommended configurations weren't clearly addressed, demonstrating why ZAST.AI's definition emphasizes explicit documentation of security risks.

### Apache Struts 2 Content-Type: Documentation vs Built-in Protection

The Apache Struts 2 Content-Type vulnerability (CVE-2017-5638) serves as a case study for ZAST.AI's vulnerability definition. The file upload functionality's processing of Content-Type headers extended beyond its intended design, creating an unexpected attack vector[^8]. This case demonstrates how even documented features can become vulnerabilities when their implementation exceeds the component's core purpose.

The Equifax breach, resulting from this vulnerability, validates ZAST.AI's emphasis on comprehensive documentation[^8]. While Struts' documentation mentioned the risks of the multipart parser, the breach affecting 147 million people proves that merely documenting risks without clear security implications is insufficient. This case supports ZAST.AI's position that security implications must be explicitly addressed in documentation, not just mentioned as potential risks.

## Patterns and Evolution in Component Security

<center><img src="{{'/assets/img/When-Features-Become-Flaws-Assessing-Component-Vulnerabilities/development.png' | relative_url }}" alt="development" width="750" height="auto"></center>


<center><em>Timeline of Representative Critical Component Vulnerabilities</em></center>
<br>

<em>(Note: This timeline highlights only the most impactful vulnerabilities that have affected applications globally, representing a small subset of all component vulnerabilities discovered each year)<em>
<br>

These representative cases reveal several recurring patterns in component vulnerability debates. First, all cases demonstrate how features intended for flexibility often become security liabilities - from Log4j's JNDI lookups to Spring's expression language evaluation and Struts' OGNL expressions. Second, the default configurations prioritize developer convenience over security, as seen in both Struts cases where documented security measures were optional rather than default. Third, the responsibility for security is frequently contested, with component developers emphasizing documentation and configuration while security researchers advocate for secure defaults.

The controversy extends beyond individual cases to how security issues are acknowledged and addressed. While some vendors do not classify certain behaviors as vulnerabilities[^9], security researchers advocate for stricter vulnerability definitions and disclosure processes[^10]. In response, the open source community has adopted shared responsibility models[^11], recognizing security as a collaborative effort across the entire software supply chain[^12]. This evolution has produced new frameworks for vulnerability management that reflect the nuanced nature of component security[^13].

## A Balanced Model for Component Security

Based on our case studies, we propose a security model with three key dimensions:

### Technical Controls

Component providers should implement:

- Secure-by-default configurations
- Input validation at architectural boundaries
- Clear separation of core and powerful features
- Protection mechanisms before security-critical operations

### Documentation and Communication

The model requires:

- Documentation of security-critical features and risks
- Clear upgrade paths for security fixes
- Transparent security policies
- Regular security advisories

### Responsibility Distribution

- Component providers: secure architecture and safe defaults
- Security researchers: responsible disclosure and mitigation guidance
- Application developers: security assessment and monitoring
- Commercial vendors: enterprise-grade protection

<center><img src="{{'/assets/img/When-Features-Become-Flaws-Assessing-Component-Vulnerabilities/balance.png' | relative_url }}" alt="balance" width="750" height="auto"></center>

## Conclusion

Our analysis reveals that treating security as an add-on feature or relying solely on documentation is inadequate. The five cases examined show three lessons:

1. Powerful features require powerful protection
2. Default configurations should prioritize security
3. Security responsibility must be clearly distributed

The future of component security involves delivering both functionality and security effectively.


## References

[^1]: ["Log Jam: Lesson Learned from the Log4Shell Vulnerability"](https://pmc.ncbi.nlm.nih.gov/articles/PMC10472545/){:target="_blank" rel="noopener noreferrer"}, PMC Articles, 2023

[^2]: ["Log4j Zero-Day Vulnerability Response"](https://www.cisecurity.org/log4j-zero-day-vulnerability-response){:target="_blank" rel="noopener noreferrer"}, CIS Security, 2021

[^3]: ["CVE-2022-22965: Spring Core RCE Vulnerability Exploited In the Wild (SpringShell)"](https://unit42.paloaltonetworks.com/cve-2022-22965-springshell/){:target="_blank" rel="noopener noreferrer"}, Palo Alto Networks, 2022

[^4]: ["CVE-2022-22965: Analyzing the Exploitation of Spring4Shell Vulnerability in Weaponizing and Executing the Mirai Botnet Malware"](https://www.trendmicro.com/en_us/research/22/d/cve-2022-22965-analyzing-the-exploitation-of-spring4shell-vulner.html){:target="_blank" rel="noopener noreferrer"}, TrendMicro, 2022

[^5]: ["Spring4Shell: Zero-Day Vulnerability in Spring Framework (CVE-2022-22965)"](https://www.rapid7.com/blog/post/2022/03/30/spring4shell-zero-day-vulnerability-in-spring-framework/){:target="_blank" rel="noopener noreferrer"}, Rapid7, 2022

[^6]: ["SECURITY BULLETIN: Important Information about RCE in Apache Struts (CVE-2018-11776)"](https://success.trendmicro.com/en-US/solution/KA-0008699){:target="_blank" rel="noopener noreferrer"}, TrendMicro, 2025

[^7]: ["Apache Struts 2 Namespace (CVE-2018-11776) Vulnerability"](https://www.securityjourney.com/post/apache-struts-2-namespace-cve-2018-11776-vulnerability){:target="_blank" rel="noopener noreferrer"}, Security Journey, 2018

[^8]: ["Equifax Data Breach Explained: A Case Study"](https://www.breachsense.com/blog/equifax-data-breach/){:target="_blank" rel="noopener noreferrer"}, BreachSense, 2024

[^9]: ["Responsible vulnerability disclosure: Why it matters"](https://outpost24.com/blog/responsible-vulnerability-disclosure/){:target="_blank" rel="noopener noreferrer"}, Outpost24, 2025

[^10]: ["Vulnerability disclosure: Legal risks and ethical considerations for researchers"](https://www.helpnetsecurity.com/2023/11/27/eddie-zhang-project-black-vulnerability-disclosure/){:target="_blank" rel="noopener noreferrer"}, HelpNet Security, 2025

[^11]: ["Who is responsible for open source security?"](https://leaddev.com/software-quality/who-responsible-open-source-security){:target="_blank" rel="noopener noreferrer"}, LeadDev, 2023

[^12]: ["Why Security is Everyone's Responsibility: A Call to Developers"](https://rodtrent.substack.com/p/why-security-is-everyones-responsibility){:target="_blank" rel="noopener noreferrer"}, Rod Trent, 2025

[^13]: ["The bogus CVE problem"](https://lwn.net/Articles/944209/){:target="_blank" rel="noopener noreferrer"}, LWN.net, 2023