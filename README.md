# I-Lab Setup

I-Lab 裸金属工作站部署文档站 — 12× GMK EVO-X2 + Synology NAS 统一管理

## 📖 在线文档

> GitHub Pages: https://kylehuang0323-ai.github.io/Lab-setup/

| 文档 | 说明 |
|------|------|
| [NAS 配置操作手册](https://kylehuang0323-ai.github.io/Lab-setup/) | Synology NAS 完整配置指南（共享文件夹、SMB/NFS、Docker 服务） |
| [裸金属部署方案 v2.0](https://kylehuang0323-ai.github.io/Lab-setup/deployment-plan.html) | 整体架构、Golden Image、批量部署、维护 SOP |
| [驱动安装指南](https://kylehuang0323-ai.github.io/Lab-setup/driver-install.html) | GMK EVO-X2 全部驱动一键安装命令与验证清单 |
| [镜像策略与基线管理](https://kylehuang0323-ai.github.io/Lab-setup/image-strategy.html) | 源镜像 vs 运维基线、激活保护、快照命名、Re-baseline 流程 |

## 🏗️ 架构概览

- **硬件**：12× GMK EVO-X2 (AMD Strix Halo) + Synology NAS + 千兆交换机
- **策略**：裸金属 Windows 11 + Reboot Restore 重启还原 + NAS 集中管控
- **保护层**：L0 硬件 → L1 Golden Image → L2 Active Backup → L3 重启还原 → L4 用户数据 NAS

## 📂 文件结构

```
├── index.html              # NAS 配置操作手册（GitHub Pages 首页）
├── deployment-plan.html    # 裸金属部署方案 v2.0
├── driver-install.html     # GMK EVO-X2 驱动安装指南
├── image-strategy.html     # 镜像策略与基线管理
├── scripts/
│   └── GMK-EVO-X2-DriverInstall.cmd  # 优化版一键驱动安装脚本
└── README.md               # 本文件
```