# VajraKali - The Indestructible Pentest Forge

![VajraKali Banner](https://img.shields.io/badge/VajraKali-v1.0.0-blue.svg)

## ⚡ About VajraKali

**VajraKali** is a customizable, beginner-friendly Kali Linux pentesting setup tool designed to automate and simplify the process of setting up your hacking lab. It covers installation of core, wireless, VM, terminal, development, stealth, and Realtek-specific tools — along with popular GitHub-based utilities like PEASS-ng and Gowitness.

---

## ✨ Features

- ✅ Default, Custom, or Specific Tool Installation Modes.
- ✅ Automatic detection of already installed APT tools.
- ✅ Clean and colored output with progress feedback.
- ✅ GitHub tools clone & setup (`linpeas`, `winpeas`, `wpscan`, `gowitness`).
- ✅ Ctrl+C handling (Graceful exit).
- ✅ Post-install summary (Installed / Failed tools).

---

## 📋 Usage

```bash
git clone https://github.com/TheTorjanCaptain/VajraKali.git
cd VajraKali
sudo bash banner.sh

⚠️ Always run this as root/sudo to avoid permission errors.
