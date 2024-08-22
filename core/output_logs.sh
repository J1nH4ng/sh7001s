#!/bin/bash
#
# 日志输出脚本
# 版权 2024 J1nH4ng<j1nh4ng@icloud.com>

# Globals:
# Arguments:
#  None

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly RED_BG='\033[41m'
readonly GREEN_BG='\033[42m'
readonly YELLOW_BG='\033[43m'
readonly BLUE_BG='\033[44m'
readonly PURPLE_BG='\033[45m'
readonly CYAN_BG='\033[46m'
readonly NC='\033[0m' # No Color

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