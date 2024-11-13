#!/bin/bash

#################################################
# @Author: J1nH4ng                              #
# @Date: 2024-11-07                             #
# @Last Modified By: J1nH4ng                    #
# @Last Modified Date: 2024-11-12               #
# @Email: j1nh4ng@icloud.com                    #
# @Version: v0.11.7                             #
# @Description: Scripts 4 Server Inspection     #
#################################################


# 服务器基本信息
# [info] 请根据每台服务器实际情况进行修改
IP_ADDR=$(ifconfig eth0 | grep -w 'inet' | awk -F '[ :]' '{print $10}')

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
source /etc/profile

# 判断是否是 ROOT 用户执行
[ "$(id -u)" -gt 0 ] && echo "请使用 ROOT 用户执行此脚本" && exit 1

# 系统版本
# OS_VERSION=$(awk -F '=' '/^VERSION_ID=/{gsub(/"/, "", $2); print $2}' /etc/os-release)
OS_VERSION=$(awk -F '=' '/^ID=/{gsub(/"/, "", $2); print $2}' /etc/os-release)
OS_NAME=$(awk -F '=' '/^NAME=/{gsub(/"/, "", $2); print $2}' /etc/os-release)

# 生成结果存储目录
PROGRAM_PATH=$(echo "$0" | sed -e 's,[\\/][^\\/][^\\/]*$,,')
[ -f "${PROGRAM_PATH}" ] && PROGRAM_PATH="."
LOG_PATH="${PROGRAM_PATH}/log"
[ -e "${LOG_PATH}" ] || mkdir "${LOG_PATH}"
RESULT_PATH="${LOG_PATH}/${IP_ADDR}-$(date +%Y%m%d).txt"

# 需要巡检的内容

# [INFO] 系统信息
# [DONE) 日期
report_current_date=""
# [DONE) 主机名
report_hostname=""
# [DONE) SELinux
report_SELinux=""
# [DONE) 发行版本
report_OS_release=""
# [DONE) 内核
report_kernel=""
# [DONE) 语言/编码
report_language=""
# [DONE) 最近启动时间
report_last_reboot_time=""
# [DONE) 运行时间
report_uptime=""
# [DONE) SELinux
report_selinux=""

# [INFO] CPU 信息
# [DONE) CPU 数量
report_CPU_nums=""
# [DONE) CPU 类型
report_CPU_type=""
# [DONE) CPU 架构
report_CPU_arch=""

# [INFO] 内存信息
# [DONE) 内存总量
report_memory_total=""
# [DONE) 内存使用
report_memory_used=""
# [DONE) 内存剩余
report_memory_free=""
# [DONE) 内存使用率
report_memory_used_percent=""

# [INFO] 磁盘信息
# [DONE) 磁盘总容量
report_disk_total=""
# [DONE) 磁盘已用
report_disk_used=""
# [DONE) 磁盘剩余
report_disk_free=""
# [DONE) 磁盘使用率
report_disk_used_percent=""
# [DONE) Inode 总量
report_inode_total=""
# [DONE) Inode 剩余
report_inode_free=""
# [DONE) Inode 使用量
report_inode_used=""
# [DONE) Inode 使用率
report_inode_used_percent=""


# [DONE) IP 地址
report_ip=""
# [DONE) MAC 地址
report_mac=""
# [DONE) 默认网关
report_gateway=""
# [DONE) DNS
report_dns=""

# [DONE) 监听端口
report_listen=""


# [TODO) Firewalld
report_firewalld=""

# [TODO) 用户
report_users=""
# [TODO) 空密码用户
report_user_with_empty_password=""
# [TODO) 相同 ID 用户
report_user_with_same_uid=""
# [TODO) 密码过期
report_password_expiry=""
# [TODO) ROOT 用户
report_root_users=""
# [TODO) Sudo 授权
report_sudoers=""

# [TODO) SSH 信任主机
report_ssh_authorized=""
# [TODO) SSH 协议版本
report_sshd_protocol_version=""
# [TODO) 允许 ROOT 远程登录
report_sshd_permit_root_login=""

# [TODO) 僵尸进程数量
report_defunct_process=""
# [DONE) 自启动服务数量
report_self_initiated_service=""
# [DONE) 运行中的服务数量
report_running_service=""

# [DONE) 自启动程序数量
report_self_initiated_program=""

# [DONE) 计划中的任务数
report_crontab=""

# [TODO) 日志服务
report_syslog=""

# [TODO) SNMP
report_snmp=""
# [TODO) NTP
report_ntp=""


# [TODO) JDK 版本
# [TODO) Node.js 版本
# [TODO) Php 版本

function version() {
    # 脚本信息
    local SH_AUTHOR
    local SH_VERSION

    SH_AUTHOR="J1nH4ng<j1nh4ng@icloud.com>"
    SH_VERSION="v0.11.7"

    echo ""
    echo -e "\033[1;34m   ________ _____ ____   \033[0m"
    echo -e "\033[1;32m  |___ /_ _|_   _/ ___|  \033[0m"
    echo -e "\033[1;36m    |_ \| |  | | \___ \  \033[0m"
    echo -e "\033[1;31m   ___) | |  | |  ___) | \033[0m"
    echo -e "\033[1;35m  |____/___| |_| |____/  \033[0m"
    echo -e "\033[1;33m                         \033[0m"
    echo ""
    echo "服务器巡检脚本："
    echo "    作者：${SH_AUTHOR}"
    echo "    版本：${SH_VERSION}"
    echo ""
}

function get_system_status() {
    echo ""
    echo "###################### 系统检查 ######################"
    echo ""

    local default_language
    local release
    local kernel
    local os
    local hostname
    local selinux
    local last_reboot
    local uptime

    if [ -e /etc/sysconfig/i18n ];then
        default_language="$(grep "LANG=" /etc/sysconfig/i18n | grep -v "^#" | awk -F '"' '{print $2}')"
    else
        default_language=$LANG
    fi

    export LANG="en_US.UTF-8"
    release="${OS_NAME}"
    kernel=$(uname -r)
    os=$(uname -o)
    hostname=$(uname -n)
    selinux=$(/usr/sbin/sestatus | grep "SELinux status: " | awk '{print $3}')
    last_reboot=$(who -b | awk '{print $3,$4}')
    uptime=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')

    echo "系统信息：${os}"
    echo "发行版本：${release}"
    echo "内核版本：${kernel}"
    echo "主机名：${hostname}"
    echo "SELinux 状态：${selinux}"
    echo "语言/编码：${default_language}"
    echo "当前时间：$(date +'%F %T')"
    echo "最后启动：${last_reboot}"
    echo "运行时间：${uptime}"

    echo ""
    echo "#################### 系统检查结束 ####################"
    echo ""

    report_current_date=$(date +"%F %T")
    report_hostname="${hostname}"
    report_SELinux="${selinux}"
    report_OS_release="${release}"
    report_kernel="${kernel}"
    report_language="${default_language}"
    report_last_reboot_time="${last_reboot}"
    report_uptime="${uptime}"
    report_selinux="${selinux}"

    export report_current_date
    export report_hostname
    export report_SELinux
    export report_OS_release
    export report_kernel
    export report_language
    export report_last_reboot_time
    export report_uptime
    export report_selinux
    export LANG="${default_language}"
}

function get_cpu_status() {
    echo ""
    echo "###################### CPU 检查 ######################"
    echo ""

    local physical_CPUs
    local virtual_CPUs
    local CPU_kernels
    local CPU_type
    local CPU_arch

    physical_CPUs=$(grep "physical id" /proc/cpuinfo | sort | uniq | wc -l)
    virtual_CPUs=$(grep -c "processor" /proc/cpuinfo)
    CPU_kernels=$(grep "cores" /proc/cpuinfo | uniq | awk -F ': ' '{print $2}')
    CPU_type=$(grep "model name" /proc/cpuinfo | awk -F ': ' '{print $2}' | sort | uniq)
    CPU_arch=$(uname -m)

    echo "物理 CPU 个数为：${physical_CPUs}"
    echo "逻辑 CPU 个数为：${virtual_CPUs}"
    echo "每个 CPU 核心数为：${CPU_kernels}"
    echo "CPU 型号为：${CPU_type}"
    echo "CPU 架构为：${CPU_arch}"

    echo ""
    echo "#################### CPU 检查结束 ####################"
    echo ""

    report_CPU_nums=${virtual_CPUs}
    report_CPU_type=${CPU_type}
    report_CPU_arch=${CPU_arch}

    export report_CPU_nums
    export report_CPU_type
    export report_CPU_arch
}

function get_memory_status() {
    echo ""
    echo "###################### 内存检查 ######################"
    echo ""

    # if [[ $OS_VERSION < 7 ]];then
    if [[ $OS_NAME != "CentOS" ]];then
        free -h
    else
        free -mo
    fi

    local memory_total
    local memory_free
    local memory_used
    local memory_percent

    # 单位为：KB
    memory_total=$(grep "MemTotal" /proc/meminfo | awk '{print $2}')
    memory_free=$(grep "MemFree" /proc/meminfo | awk '{print $2}')
    ((memory_used=memory_total-memory_free))
    memory_percent=$(awk "BEGIN {if($memory_total==0){printf 100}else{printf \"%.2f\",$memory_used*100/$memory_total}}")

    report_memory_total="$((memory_total/1024))"" MB"
    report_memory_free="$((memory_free/1024))"" MB"
    report_memory_used="$((memory_used/1024))"" MB"
    report_memory_used_percent=$(awk "BEGIN {if($memory_total==0){printf 100}else{printf \"%.2f\",$memory_used*100/$memory_total}}")"%"

    echo ""
    echo "Mem 总共量为：${report_memory_total}"
    echo "Mem 空闲量为：${report_memory_free}"
    echo "Mem 使用量为：${report_memory_used}"
    echo "Mem 使用率为：${memory_percent}""%"

    echo ""
    echo "#################### 内存检查结束 ####################"
    echo ""

    export report_memory_total
    export report_memory_free
    export report_memory_used
    export report_memory_used_percent
}

function get_disk_status() {
    echo ""
    echo "###################### 磁盘检查 ######################"
    echo ""

    df -hiP | sed 's/Mounted on/Mounted/' >/tmp/inode
    df -hTP | sed 's/Mounted on/Mounted/' >/tmp/disk
    join /tmp/disk /tmp/inode | awk '{print $1,$2,"|",$3,$4,$5,$6,"|",$8,$9,$10,$11,"|",$12}' | column -t


    local disk_data
    local disk_total
    local disk_used
    local disk_free
    local disk_used_percent

    # KB
    disk_data=$(df -TP | sed '1d' | awk '$2!="tmpfs"{print}')
    # KB
    disk_total=$(echo "${disk_data}" | awk '{total+=$3}END{print total}')
    # KB
    disk_used=$(echo "${disk_data}" | awk '{total+=$4}END{print total}')
    # KB
    disk_free=$((disk_total-disk_used))
    # KB
    disk_used_percent=$(echo "${disk_total}" "${disk_used}" | awk '{if($1==0){printf 100}else{printf "%.2f",$2*100/$1}}')


    local inode_data
    local inode_total
    local inode_used
    local inode_free
    local inode_used_percent

    inode_data=$(df -iTP | sed '1d' | awk '$2!="tmpfs"{print}')
    inode_total=$(echo "${inode_data}" | awk '{total+=$3}END{print total}')
    inode_used=$(echo "${inode_data}" | awk '{total+=$4}END{print total}')
    inode_free=$((inode_total-inode_used))
    inode_used_percent=$(echo "${inode_total}" "${inode_used}" | awk '{if($1==0){printf 100}else{printf "%.2f",$2*100/$1}}')

    report_disk_total=$((disk_total/1024/1024))" GB"
    report_disk_free=$((disk_free/1024/1024))" GB"
    report_disk_used=$((disk_used/1024/1024))" GB"
    report_disk_used_percent="${disk_used_percent}""%"

    report_inode_total=$((inode_total/1000))" K"
    report_inode_free=$((inode_free/1000))" K"
    report_inode_used=$((inode_used/1000))" K"
    report_inode_used_percent="$inode_used_percent""%"

    echo ""
    echo "DISK 总共量为：${report_disk_total}"
    echo "DISK 已用量为：${report_disk_used}"
    echo "DISK 空闲量为：${report_disk_free}"
    echo "DISK 使用率为：${disk_used_percent}""%"
    echo ""

    echo ""
    echo "Inode 总共量为：${report_inode_total}"
    echo "Inode 已用量为：${report_inode_used}"
    echo "Inode 空闲量为：${report_inode_free}"
    echo "Inode 使用率为：${inode_used_percent}""%"

    echo ""
    echo "#################### 磁盘检查结束 ####################"
    echo ""

    export report_disk_total
    export report_disk_free
    export report_disk_used
    export report_disk_used_percent

    export report_inode_total
    export report_inode_free
    export report_inode_used
    export report_inode_used_percent
}

function get_service_status() {
    echo ""
    echo "#################### 服务检查 ####################"
    echo ""

    local conf
    local process

    if [[ $OS_NAME != "centos" ]];then
        conf=$(systemctl list-unit-files --type=service --state=enabled --no-pager | grep "enabled")
        process=$(systemctl list-units --type=service --state=running --no-pager | grep ".service")
    else
        conf=$(/sbin/chkconfig | grep -E ":on|:启用")
        process=$(/sbin/service --status-all 2>/dev/null | grep -E "is running|正在运行")
    fi

    echo "服务配置："
    echo ""
    echo "----------------"
    echo "${conf}" | column -t
    echo ""
    echo "正在运行的服务："
    echo ""
    echo "----------------"
    echo "${process}"

    echo ""
    echo "#################### 服务检查结束 ####################"
    echo ""

    report_self_initiated_service="$(echo "${conf}" | wc -l)"
    report_running_service="$(echo "${process}" | wc -l)"

    export report_self_initiated_service
    export report_running_service
}

function get_auto_start_status() {
    echo ""
    echo "#################### 自启动检查 ####################"
    echo ""

    local conf

    conf=$(grep -v "^#" /etc/rc.d/rc.local | sed '/^$/d')
    echo "${conf}"

    echo ""
    echo "#################### 自启动检查结束 ####################"
    echo ""

    report_self_initiated_program="$(echo ${conf} | wc -l)"

    export report_self_initiated_program
}

function get_login_status() {
    echo ""
    echo "#################### 登录检查 ####################"
    echo ""

    last | head

    echo ""
    echo "#################### 登录检查结束 ####################"
    echo ""
}

function get_network_status() {
    echo ""
    echo "#################### 网络检查 ####################"
    echo ""

    local i
    local gateway
    local dns
    local local_ip
    local mac

    if [[ $OS_NAME == "CentOS" ]]; then
      /sbin/ifconfif -a | grep -v packets |  grep -v collisions | grep -v inet6
    else
      for i in $(ip link | grep BROADCAST | awk -F: '{print $2}'); do
        local_ip=$(ip add show $i | grep -E "BROADCAST|global" | awk '{print $2}' | tr '\n' ' ' );
      done
    fi

    gateway=$(ip route | grep default | awk '{print $3}')
    dns=$(grep nameserver /etc/resolv.conf | grep -v "#" | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')
    mac=$(ip link | grep -v "LOOPBACK\|loopback" | awk '{print $2}' | sed 'N;s/\n//' | tr '\n' ',' | sed 's/,$//')

    echo ""
    echo "网卡与其 IP  地址为：${local_ip}"
    echo "网卡与其 MAC 地址为：${mac}"
    echo "网关地址为：${gateway}"
    echo "DNS 地址为：${dns}"

    echo ""
    echo "#################### 网络检查结束 ####################"
    echo ""

    # report_ip="${local_ip}"
    report_ip=$(ip -f inet addr | grep -v 127.0.0.1 | grep inet | awk '{print $NF,$2}' | tr '\n' ',' | sed 's/,$//')
    report_mac="${mac}"
    report_gateway="${gateway}"
    report_dns="${dns}"

    export report_ip
    export report_mac
    export report_gateway
    export report_dns
}

function get_listen_status() {
    echo ""
    echo "#################### 监听地址检查 ####################"
    echo ""

    local tcp_listen

    tcp_listen=$(ss -ntul | column -t)

    echo "网络地址监听地址列表如下："
    echo ""
    echo "${tcp_listen}"

    echo ""
    echo "#################### 监听地址检查结束 ####################"
    echo ""

    report_listen="$(echo "${tcp_listen}" | sed '1d' | awk '/tcp/ {print $5}' | awk -F: '{print $NF}' | sort | uniq | wc -l)"

    export report_listen
}

function get_cron_status() {
    echo ""
    echo "#################### 计划任务检查 ####################"
    echo ""

    local local_crontab
    local user
    local shell

    local_crontab=0

    for shell in $(grep -v "/sbin/nologin" /etc/shells); do
      for user in $(grep "${shell}" /etc/passwd | awk -F: '{print $1}'); do
        crontab -l -u "${user}" >/dev/null 2>&1
        status=$?
        if [ $status -eq 0 ]; then
          echo ""
          echo "当前用户为：${user}"
          echo ""
          echo "当前用户的的定时任务如下："
          echo ""
          crontab -l -u "${user}"
          let local_crontab+=local_crontab+$(crontab -l -u "${user}" | wc -l)
          echo ""
        fi
      done
    done

    # 列出与 crontab 相关的文件
    # find /etc/cron* -type f | xargs -i ls -l {} | column -t

    let local_crontab=local_crontab+$(find /etc/cron* -type f | wc -l)

    echo ""
    echo "#################### 计划任务检查结束 ####################"
    echo ""

    report_crontab="${local_crontab}"

    export report_crontab
}

function utils_get_how_long_age() {
    local datetime
    local format_timestamp
    local now_timestamp
    local minus_timestamp

    local days
    local hours
    local minutes


    const SEC_IN_ONE_DAY=86400
    const SEC_IN_ONE_HOUR=3600
    const SEC_IN_ONE_MINUTE=60

    datetime="$*"

    [ -z "${datetime}" ]  && echo "错误输入：function utils_get_how_long_age() {:} $*"

    format_timestamp=$(date +%s -d "${datetime}")
    now_timestamp=$(date +%s)
    minus_timestamp=$((now_timestamp-format_timestamp))

    days=0
    hours=0
    minutes=0

    while (( $(($minus_timestamp-$SEC_IN_ONE_DAY)) > 1 )); do
      let minus_timestamp=minus_timestamp-SEC_IN_ONE_DAY
      let days++
    done

    while (( $(($minus_timestamp-$SEC_IN_ONE_HOUR)) > 1 )); do
      let minus_timestamp=minus_timestamp-SEC_IN_ONE_HOUR
      let hours++
    done

    while (( $(($minus_timestamp-$SEC_IN_ONE_MINUTE)) > 1 )); do
      let minus_timestamp=minus_timestamp-SEC_IN_ONE_MINUTE
      let minutes++
    done

    echo "${days}天${hours}小时${minutes}分钟"
}

function utils_get_user_last_login_time() {
  local username
  local this_year
  local oldest_year

  local login_before_today
  local login_before_this_year
  local last_date_time

  username=$1
  : ${username:="`whoami`"}

  this_year=$(date +%Y)
  oldest_year=$(last | tail -n1 | awk '{print $NF}')

  while (( $this_year >= $oldest_year )); do
    login_before_today=$(last ${username} | grep ${username} | wc -l)
    login_before_this_year=$(last ${username} -t ${this_year}"0101000000" | grep ${username} | wc -l)

    if [ $login_before_today -gt 0 ]; then
      echo "${username} 从未登录过"
      break
    elif [ $login_before_today -gt $login_before_this_year ]; then
      last_date_time=$(last -i ${username} | head -n1 | awk '{for(i=4;i<(NF-2);i++)printf"%S ",$i}')" ${this_year}"
      last_date_time=$(date "+%Y-%m-%d %H:%M:%S" -d "${last_date_time}")
      echo "${username} 最后一次登录时间为：${last_date_time}"
      break
    else
      this_year=$((this_year-1))
    fi
  done
}


function get_user_status() {
    echo ""
    echo "#################### 用户检查 ####################"
    echo ""

    local password_file
    local modify_time

    password_file="$(cat /etc/passwd)"
    modify_time=$(stat /etc/passwd | grep Modify | tr '.' ' ' | awk '{print $2,$3}')

    echo "/etc/passwd  文件最后修改时间为：${modify_time} ($(utils_get_how_long_age ${modify_time})"
    echo ""

    echo "特权用户："
    echo "--------------------------------"

    local root_user

    root_user=""

    for user in $(echo "${password_file}" | awk -F: '{print $1}'); do
      if [  ]



    echo ""
    echo "#################### 用户检查结束 ####################"
    echo ""
}


function main() {
    version
    get_system_status
    get_cpu_status
    get_memory_status
    get_disk_status
    get_login_status
    get_service_status
    get_auto_start_status
    get_network_status
    get_listen_status
    get_cron_status
}

main "$@"
