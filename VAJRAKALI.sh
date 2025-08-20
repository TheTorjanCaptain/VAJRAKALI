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

# Handle command line flag for cron-triggered updates
if [[ "$1" == "--update-github-tools" ]]; then
    update_github_tools
    exit 0
fi

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
echo -e "${WHITE}[Version 1.0.1]${NC}\n"

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

# Function: Automatically fetch and install dependencies for APT packages
fetch_and_install_apt_deps() {
    local tool="$1"
    local deps
    deps=$(apt-cache depends "$tool" 2>/dev/null | grep Depends | awk '{print $2}')
    for dep in $deps; do
        if ! dpkg -s "$dep" &>/dev/null; then
            echo -e "${YELLOW}    [*] Installing dependency: $dep for $tool${NC}"
            sudo apt-get install -y "$dep"
        fi
    done
}

# Function: Automatically install Python dependencies for GitHub tools if requirements.txt found
install_python_deps() {
    local repo_path="$1"
    local req_file="$repo_path/requirements.txt"
    if [ -f "$req_file" ]; then
        if command -v pip &>/dev/null; then
            echo -e "${YELLOW}[*] Installing Python dependencies from requirements.txt${NC}"
            pip install -r "$req_file"
        else
            echo -e "${YELLOW}[*] pip not found. Installing pip...${NC}"
            sudo apt-get install -y python3-pip
            pip install -r "$req_file"
        fi
    fi
}

# Function: Automatically install Go dependencies and build Go tools
install_go_deps() {
    local repo_path="$1"
    if command -v go &>/dev/null; then
        cd "$repo_path" || return
        echo -e "${YELLOW}[*] Downloading Go modules and installing the Go tool${NC}"
        if go mod tidy && go install; then
            echo -e "${GREEN}[✓] Go tool installed successfully in $(basename "$repo_path")${NC}"
        else
            echo -e "${RED}[✗] Failed to update or install Go tool in $(basename "$repo_path")${NC}"
        fi
        cd - > /dev/null || return
    else
        echo -e "${YELLOW}[*] Go not found. Installing golang...${NC}"
        sudo apt-get install -y golang
        cd "$repo_path" || return
        if go mod tidy && go install; then
            echo -e "${GREEN}[✓] Go tool installed successfully in $(basename "$repo_path")${NC}"
        else
            echo -e "${RED}[✗] Failed to update or install Go tool in $(basename "$repo_path")${NC}"
        fi
        cd - > /dev/null || return
    fi
}

# Function: Install Tools (with improved summary and auto dependency fetching)
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

        # Auto-fetch and install online dependencies for the tool
        fetch_and_install_apt_deps "$tool"

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

    # Only show 'Installed' and 'Failed' if there actually are entries
    echo -e "\n========= ${CYAN}Installation Summary${NC} ========="
    if [ ${#installed[@]} -gt 0 ]; then
        echo -e "${GREEN}Installed:${NC}"
        for item in "${installed[@]}"; do echo " - $item"; done
    fi
    if [ ${#failed[@]} -gt 0 ]; then
        echo -e "${RED}Failed:${NC}"
        for item in "${failed[@]}"; do echo " - $item"; done
    fi
    echo -e "${CYAN}=======================================${NC}\n"
    setup_cron_job_prompt
}

# Function: Install GitHub Tools with auto dependency handling
install_github_tools() {
    echo -e "${YELLOW}[*] Cloning and setting up GitHub tools...${NC}"
    mkdir -p ~/VajraKali-GitHub-Tools
    cd ~/VajraKali-GitHub-Tools || exit

    if [ ! -d "linpeas" ]; then
        git clone https://github.com/carlospolop/PEASS-ng.git linpeas
        install_python_deps "linpeas/linPEAS"
    fi
    if [ ! -d "winpeas" ]; then
        git clone https://github.com/carlospolop/PEASS-ng.git winpeas
        install_python_deps "winpeas/winPEAS"
    fi
    if [ ! -d "wpscan" ]; then
        git clone https://github.com/wpscanteam/wpscan.git wpscan
        install_python_deps "wpscan"
    fi
    if [ ! -d "gowitness" ]; then
        git clone https://github.com/sensepost/gowitness.git gowitness
        install_go_deps "gowitness"
    fi
    echo -e "${GREEN}[*] GitHub tools setup complete. Tools to be found in ~/VajraKali-GitHub-Tools${NC}"
    setup_cron_job_prompt
}

# Function: Update GitHub Tools with conditional Go build/install
update_github_tools() {
    echo -e "${YELLOW}[*] Updating GitHub tools...${NC}"
    cd ~/VajraKali-GitHub-Tools || return

    for tool in linpeas winpeas wpscan gowitness; do
        if [ -d "$tool" ]; then
            echo -e "${CYAN}Updating $tool...${NC}"
            cd "$tool" || continue
            git_output=$(git pull)
            echo "$git_output"

            # For Python tools
            if [ -f "requirements.txt" ]; then
                if command -v pip &>/dev/null; then
                    pip install --upgrade -r requirements.txt
                else
                    sudo apt-get install -y python3-pip
                    pip install --upgrade -r requirements.txt
                fi
            fi

            # For Go tool gowitness, only build/install if there was an update
            if [ "$tool" == "gowitness" ]; then
                if [[ "$git_output" != *"Already up to date."* ]]; then
                    install_go_deps "$(pwd)"
                else
                    echo -e "${YELLOW}No new Go updates for gowitness${NC}"
                fi
            fi

            cd ..
            echo -e "${GREEN}[✓] $tool updated successfully.${NC}"
        else
            echo -e "${RED}$tool not found, please install it first.${NC}"
        fi
    done

    echo -e "${GREEN}GitHub tools update process complete.${NC}"
    setup_cron_job_prompt
}

# Function: Cron Job Setup Prompt
setup_cron_job_prompt() {
    echo -e "${YELLOW}Do you want to set up a weekly cron job to automatically update GitHub tools? (y/n):${NC}"
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        # Adjust path to your actual script location
        SCRIPT_PATH="$(realpath "$0")"
        croncmd="$SCRIPT_PATH --update-github-tools"
        cronjob="0 3 * * 0 $croncmd # VajraKali weekly GitHub tools update"

        # Add if not already exists
        crontab -l 2>/dev/null | grep -Fv "$croncmd" | { cat; echo "$cronjob"; } | crontab -
        echo -e "${GREEN}Cron job installed to run weekly at 3 AM on Sundays.${NC}"
    else
        echo -e "${CYAN}Cron job not set up.${NC}"
    fi
}

# Function: Main Menu
main_menu() {
    while true; do
        echo -e "${CYAN}========== VAJRAKALI Main Menu ==========${NC}"
        echo -e "${YELLOW}1) Default Install:${NC} ${core_tools[*]}"
        echo -e "${YELLOW}2) Custom Install:${NC} Core, Wireless, VM/UTM SPICE, Terminal, GitHub, Dev, Stealth, Realtek Fixers"
        echo -e "${YELLOW}3) Select Specific Tool(s) to Install${NC}"
        echo -e "${YELLOW}4) Update GitHub Tools${NC}"
        echo -e "${YELLOW}5) Exit${NC}"
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
                update_github_tools
                ;;
            5)
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
