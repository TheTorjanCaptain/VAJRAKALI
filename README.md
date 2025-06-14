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
chmod +x banner.sh
sudo ./banner.sh

⚠️ Always run this as root/sudo to avoid permission errors.


⚙️ Available Tool Modules
Core Tools – nmap, sqlmap, responder, impacket, crackmapexec, evil-winrm, etc.
Wireless Tools – aircrack-ng, reaver, pixiewps, bully
VM/UTM Tools – spice-vdagent, qemu-guest-agent
Terminal Tools – neofetch, htop, tmux, zsh
GitHub Tools – linpeas, winpeas, wpscan, gowitness
Developer Essentials – git, curl, wget, vim, golang
Stealth Tools – tor, proxychains, macchanger
Realtek Fixers – rtl88xxau, rtl8812au drivers


💡 Roadmap
✅ Interactive menu-driven installation
✅ Ctrl+C graceful exit handling
❌ Smart GitHub tool detection & update check (Planned)
❌ Auto-detection of missing dependencies (Planned)
❌ Package conflict resolution warning (Planned)


🖥️ Screenshots
![VAJRAKALI](https://github.com/user-attachments/assets/98024274-8413-4ed7-ac5d-051babb56dd2)


⚠️ Disclaimer
⚠️ This tool is intended only for authorized security testing and educational purposes.
Misuse of this tool for unauthorized attacks is strictly prohibited.

📄 License
This project is licensed under the MIT License.

🤖 Author
TheTorjanCaptain
[GitHub Profile](https://github.com/TheTorjanCaptain)

