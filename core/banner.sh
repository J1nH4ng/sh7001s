#!/bin/bash
#
# 个人 Banner 信息输出
# 版权 2024 J1nH4ng<j1nh4ng@icloud.com>

# Globals:
# Arguments:
#  None
function banner() {
  echo -e "\033[1;34m   ________ _____ ____   \033[0m"
  echo -e "\033[1;32m  |___ /_ _|_   _/ ___|  \033[0m"
  echo -e "\033[1;36m    |_ \| |  | | \___ \  \033[0m"
  echo -e "\033[1;31m   ___) | |  | |  ___) | \033[0m"
  echo -e "\033[1;35m  |____/___| |_| |____/  \033[0m"
  echo -e "\033[1;33m                         \n\033[0m"
}

#######################################
# 将 Banner 信息输出到日志文件中，并添加时间戳
# Arguments:
#  None
#######################################
function logs_banner() {
  {
    echo "   ________ _____ ____   "
    echo "  |___ /_ _|_   _/ ___|  "
    echo "    |_ \| |  | | \___ \  "
    echo "   ___) | |  | |  ___) | "
    echo "  |____/___| |_| |____/  "
    echo "                         "
    echo "当前时间为：$(date +%Y-%m-%d\ %H:%M:%S)"
  } >> /tmp/utils-sh.log
}

#######################################
# Banner 输出函数
# Arguments:
#  None
#######################################
function main() {
  banner
}

main "$@"
