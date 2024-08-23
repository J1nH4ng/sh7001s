#!/bin/bash
#
# 日志输出脚本
# 版权 2024 J1nH4ng<j1nh4ng@icloud.com>

# Globals:
# Arguments:
#  None

declare -rx RED='\033[0;31m'
declare -rx GREEN='\033[0;32m'
declare -rx YELLOW='\033[0;33m'
declare -rx BLUE='\033[0;34m'
declare -rx PURPLE='\033[0;35m'
declare -rx CYAN='\033[0;36m'
declare -rx RED_BG='\033[41m'
declare -rx GREEN_BG='\033[42m'
declare -rx YELLOW_BG='\033[43m'
declare -rx BLUE_BG='\033[44m'
declare -rx PURPLE_BG='\033[45m'
declare -rx CYAN_BG='\033[46m'
declare -rx NC='\033[0m' # No Color

#######################################
# info function
# Arguments:
#   1
#######################################
function echo_info() {
  echo -e "${CYAN}$(date +"%H:%M:%S")${NC} ${GREEN}[INFO]${NC} - ${GREEN}$1${NC}"
}


#######################################
# info function with logs
# Arguments:
#   1
#   2
#######################################
function echo_info_logs() {
  local shell_name
  shell_name=$1
  echo -e "$(date +"%H:%M:%S") [INFO]:${shell_name}:$2" >> /tmp/shutils.log
}

#######################################
# warn function
# Arguments:
#   1
#######################################
function echo_warn() {
  echo -e "${CYAN}$(date +"%H:%M:%S")${NC} ${YELLOW}[WARN]${NC} - ${YELLOW}$1${NC}"
}

#######################################
# warn function with logs
# Arguments:
#   1
#   2
#######################################
function echo_warn_logs() {
  local shell_name
  shell_name=$1
  echo -e "$(date +"%H:%M:%S") [WARN]:${shell_name}:$2" >> /tmp/shutils.log
}

#######################################
# error function
# Arguments:
#   1
#######################################
function echo_error_basic() {
  echo -e "${CYAN}$(date +"%H:%M:%S")${NC} ${RED}[ERROR]${NC} - ${RED}$1${NC}"
}

#######################################
# error function with logs
# Arguments:
#   1
#   2
#######################################
function echo_error_logs() {
  local shell_name
  shell_name=$1
  echo -e "$(date +"%H:%M:%S") [ERROR]:${shell_name}:$2" >> /tmp/shutils.log
}

#######################################
# Main function
# Globals:
#   BASH_SOURCE
# Arguments:
#   0
#######################################
function main() {
  if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    :
  fi
}

main "$@"
