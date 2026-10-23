# Azure Monitoring Labs (AMELA​BS)

Welcome to the Azure Monitoring Labs repository! This collection provides hands-on, comprehensive lab environments for learning and demonstrating Azure Monitor capabilities, network security, and monitoring best practices.

## 🎯 Repository Overview

This repository contains independent lab environments, each focusing on different aspects of Azure monitoring and observability. The labs are optimized for **Azure Cloud Shell** execution to avoid local dependencies and are limited to specific Azure regions to ensure SKU availability and capacity constraints are met.

| Lab | Focus Area | Deployment Time | Difficulty |
|-----|------------|----------------|------------|
| [**azmon-lab-agents-essentials**](./azmon-lab-agents-essentials/) | Core Azure Monitor agents, data collection, and monitoring fundamentals | ~25-30 min | Beginner |
| [**azmon-lab-ampls-appinsights**](./azmon-lab-ampls-appinsights/) | Private Link Scope (AMPLS) with Application Insights in hub-spoke topology | ~25-30 min | Intermediate |

## 🚀 Quick Start

**For the fastest deployment experience, use Azure Portal Cloud Shell:**

### Lab 1: Azure Monitor Agents & Essentials Lab
```bash
bash <(curl -s https://raw.githubusercontent.com/microsoft/amelabs/refs/heads/main/azmon-lab-agents-essentials/init-lab.sh)
```

### Lab 2: AMPLS & Application Insights Lab  
```bash
bash <(curl -s https://raw.githubusercontent.com/microsoft/amelabs/refs/heads/main/azmon-lab-ampls-appinsights/init-lab.sh)
```

## 📚 Lab Descriptions

### 🔧 [Azure Monitor Agents & Essentials](./azmon-lab-agents-essentials/)

- Azure Monitor Agent (AMA) deployment and configuration
- Data Collection Rules (DCRs) for targeted log collection
- Virtual Machine Scale Sets (VMSS) monitoring
- Azure Kubernetes Service (AKS) with monitoring enabled
- Azure Managed Grafana for visualization and dashboards
- Azure Monitor Workspace (Managed Prometheus) for metrics collection
- Azure Automation Runbooks for cost optimization
- Syslog and CEF data forwarding for Sentinel integration
- Multi-platform monitoring (Windows, Ubuntu, Red Hat)

**Architecture:**
- Windows/Ubuntu/Red Hat Virtual Machines
- Windows Virtual Machine Scale Set
- Azure Kubernetes Service (AKS) cluster
- Azure Managed Grafana and Monitor Workspace
- Log Analytics Workspace & Sentinel integration
- Azure Automation Account for auto-shutdown
- Network Security Groups with proper access controls

### 🔐 [AMPLS & Application Insights](./azmon-lab-ampls-appinsights/)

- Azure Monitor Private Link Scope (AMPLS) implementation
- Hub-and-spoke network architecture
- Private endpoints for monitoring services
- Multi-platform application monitoring (Java, .NET, Node.js)
- Application Insights with private connectivity
- DNS configuration for private monitoring

**Architecture:**
- Hub-and-spoke VNet topology
- Azure Monitor Private Link Scope
- App Service with multiple runtime stacks
- Private endpoints and DNS zones
- Application Insights with private ingestion

## 🛠️ Prerequisites

- **Azure CLI** installed and authenticated
- **Bash environment** (Azure Cloud Shell, WSL, Linux, or macOS)
- **Azure subscription** with appropriate permissions to create resources
- **No local software required** - everything runs in Azure Cloud Shell!

## 🌟 Why Use These Labs?

### ✅ **Production-Ready Patterns**
Each lab implements real-world, production-ready monitoring patterns and security best practices.

### ✅ **Automated Deployment** 
Single-command deployment with intelligent defaults and interactive configuration.

### ✅ **Cost Optimized**
Built-in auto-shutdown policies and resource optimization to minimize costs during learning.

### ✅ **Comprehensive Documentation**
Detailed README files with troubleshooting guides and customization options.

### ✅ **Multi-Platform Support**
Coverage of Windows, Linux, and various application platforms.

## 📖 Getting Started

1. **Choose your lab** based on your learning objectives
2. **Open Azure Portal** and launch Cloud Shell (Bash)
3. **Run the one-liner command** for your chosen lab
4. **Follow the interactive prompts** for configuration
5. **Explore the deployed resources** and monitoring capabilities

## 🤝 Contributing

We welcome contributions! Please:
1. Fork the repository
2. Create a feature branch
3. Test your changes thoroughly
4. Submit a pull request with a clear description

## 📞 Support & Issues

- **Documentation**: Check the individual lab README files
- **Issues**: Open an issue in this GitHub repository
- **Questions**: Review the troubleshooting sections in each lab

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## 🔒 Security

Please review our [Security Policy](SECURITY.md) for reporting security vulnerabilities.

