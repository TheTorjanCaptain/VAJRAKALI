#!/bin/bash

# Clear screen on script start
clear

# Colors
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Trap Ctrl+C (SIGINT)
trap ctrl_c INT

ctrl_c() {
    echo -e "\n${RED}[!] Ctrl+C Detected. Exiting VajraKali. Stay sharp, hacker.${NC}"
    exit 1
}

# Banner
banner_lines=(
' ____    ____  ___            __  .______          ___       __  ___      ___       __       __'
' \   \  /   / /   \          |  | |   _  \        /   \     |  |/  /     /   \     |  |     |  |'
'  \   \/   / /  ^  \         |  | |  |_)  |      /  ^  \    |  '\''  /     /  ^  \    |  |     |  |'
'   \      / /  /_\  \  .--.  |  | |      /      /  /_\  \   |    <     /  /_\  \   |  |     |  |'
'    \    / /  _____  \ |  `--'\''  | |  |\  \----./  _____  \  |  .  \   /  _____  \  |  `----.|  |'
'     \__/ /__/     \__\ \______/  | _| `._____/__/     \__\ |__|\__\ /__/     \__\ |_______||__|'
'                                                                  -Crafted by TheTorjanCaptain'
)

for line in "${banner_lines[@]}"; do
    echo -e "${CYAN}$line${NC}"
    sleep 0.1
done

echo -e "${YELLOW}[+] VajraKali - The Indestructible Pentest Forge [+]${NC}"
echo -e "${WHITE}[Version 1.0.0]${NC}\n"

echo -e "${YELLOW}[*] It is recommended to run a full Kali update first:${NC}"
echo -e "    sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y\n"


# All tools lists
core_tools=(nmap sqlmap responder impacket crackmapexec evil-winrm python3 python3-pip build-essential linux-headers-$(uname -r))
wireless_tools=(aircrack-ng reaver pixiewps bully)
vm_tools=(spice-vdagent spice-webdavd qemu-guest-agent)
terminal_tools=(neofetch htop tmux zsh)
github_tools=(linpeas winpeas wpscan gowitness)
dev_tools=(git curl wget vim golang)
stealth_tools=(tor proxychains4 macchanger)
realtek_tools=(realtek-rtl88xxau-dkms realtek-rtl8812au-dkms)

all_tools=("${core_tools[@]}" "${wireless_tools[@]}" "${vm_tools[@]}" "${terminal_tools[@]}" "${github_tools[@]}" "${dev_tools[@]}" "${stealth_tools[@]}" "${realtek_tools[@]}")

# Function: Install Tools
install_tools() {
    local tools=("$@")
    local installed=()
    local failed=()

    for tool in "${tools[@]}"; do
        if dpkg -s "$tool" &>/dev/null; then
            echo -e "    ${GREEN}[✓] Already Installed: $tool${NC}"
            installed+=("$tool (Already Installed)")
            continue
        fi

        echo -e "${YELLOW}[*] Installing: $tool${NC}"
        install_log="/tmp/install_log_$(id -u)"

	if sudo apt-get install -y "$tool" &>"$install_log"; then
    		echo -e "    ${GREEN}[✓] Installed: $tool${NC}"
    		installed+=("$tool (Installed)")
	else
    		err=$(grep -iE "E:|error" "$install_log" | head -n 1)
    		echo -e "    ${RED}[✗] Failed to install: $tool${NC}"
    		failed+=("$tool (Error: ${err:-Unknown error})")
	fi
    done

    echo -e "\n========= ${CYAN}Installation Summary${NC} ========="
    echo -e "${GREEN}Installed:${NC}"
    for item in "${installed[@]}"; do echo " - $item"; done
    echo -e "${RED}Failed:${NC}"
    for item in "${failed[@]}"; do echo " - $item"; done
    echo -e "${CYAN}=======================================${NC}\n"
}

# Function: Install GitHub Tools
install_github_tools() {
    echo -e "${YELLOW}[*] Cloning and setting up GitHub tools...${NC}"
    
    mkdir -p ~/VajraKali-GitHub-Tools
    cd ~/VajraKali-GitHub-Tools || exit

    if [ ! -d "linpeas" ]; then
        git clone https://github.com/carlospolop/PEASS-ng.git linpeas
    fi
    if [ ! -d "winpeas" ]; then
        git clone https://github.com/carlospolop/PEASS-ng.git winpeas
    fi
    if [ ! -d "wpscan" ]; then
        git clone https://github.com/wpscanteam/wpscan.git wpscan
    fi
    if [ ! -d "gowitness" ]; then
        git clone https://github.com/sensepost/gowitness.git gowitness
        cd gowitness || exit
        go install
        cd ..
    fi
    echo -e "${GREEN}[*] GitHub tools setup complete. Tools to be found in ~/VajraKali-GitHub-Tools${NC}"
}

# Function: Main Menu
main_menu() {
    while true; do
        echo -e "${CYAN}========== VAJRAKALI Main Menu ==========${NC}"
        echo -e "${YELLOW}1) Default Install:${NC} ${core_tools[*]}"
        echo -e "${YELLOW}2) Custom Install:${NC} Core, Wireless, VM/UTM SPICE, Terminal, GitHub, Dev, Stealth, Realtek Fixers"
        echo -e "${YELLOW}3) Select Specific Tool(s) to Install${NC}"
        echo -e "${YELLOW}4) Exit${NC}"
        echo -e "${CYAN}========================================${NC}"
        read -rp "Enter your choice: " choice

        case $choice in
            1)
                install_tools "${core_tools[@]}"
                ;;
            2)
                custom_install
                ;;
            3)
                select_specific_tools
                ;;
            4)
                echo -e "${GREEN}Exiting VajraKali. Stay sharp, hacker.${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option!${NC}"
                ;;
        esac
    done
}

# Function: Custom Install
custom_install() {
    while true; do
        echo -e "${CYAN}Select Module to Install:${NC}"
        echo -e "${YELLOW}1) Core Tools:${NC} ${core_tools[*]}"
        echo -e "${YELLOW}2) Wireless Tools:${NC} ${wireless_tools[*]}"
        echo -e "${YELLOW}3) VM/UTM SPICE Tools:${NC} ${vm_tools[*]}"
        echo -e "${YELLOW}4) Terminal Enhancements:${NC} ${terminal_tools[*]}"
        echo -e "${YELLOW}5) GitHub Tools:${NC} ${github_tools[*]}"
        echo -e "${YELLOW}6) Dev Essentials:${NC} ${dev_tools[*]}"
        echo -e "${YELLOW}7) Stealth Mode:${NC} ${stealth_tools[*]}"
        echo -e "${YELLOW}8) Realtek Fixers:${NC} ${realtek_tools[*]}"
        echo -e "${YELLOW}9) Back to Main Menu${NC}"
        read -rp "Enter module number: " module

        case $module in
            1) install_tools "${core_tools[@]}";;
            2) install_tools "${wireless_tools[@]}";;
            3) install_tools "${vm_tools[@]}";;
            4) install_tools "${terminal_tools[@]}";;
            5) install_github_tools;;
            6) install_tools "${dev_tools[@]}";;
            7) install_tools "${stealth_tools[@]}";;
            8) install_tools "${realtek_tools[@]}";;
            9) break;;
            *) echo -e "${RED}Invalid module!${NC}";;
        esac
    done
}

# Function: Select Specific Tools
select_specific_tools() {
    while true; do
        echo -e "${CYAN}Available Tools:${NC}"
        local i=1
        for tool in "${all_tools[@]}"; do
            echo "     $i) $tool"
            ((i++))
        done
        echo -e "     ${YELLOW}$i) Back to Main Menu${NC}"

        read -rp "Enter tool numbers (space-separated): " -a tool_nums

        if [[ " ${tool_nums[*]} " =~ " $i " ]]; then
            break
        fi

        selected_tools=()
        for num in "${tool_nums[@]}"; do
            index=$((num - 1))
            if [ $index -ge 0 ] && [ $index -lt ${#all_tools[@]} ]; then
                selected_tools+=("${all_tools[$index]}")
            else
                echo -e "${RED}Invalid selection: $num${NC}"
            fi
        done

        if [ ${#selected_tools[@]} -gt 0 ]; then
            install_tools "${selected_tools[@]}"
        else
            echo -e "${RED}No valid tools selected.${NC}"
        fi
    done
}

# Start
main_menu
