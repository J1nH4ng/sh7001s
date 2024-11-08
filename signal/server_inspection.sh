#!/bin/bash

#################################################
# @Author: J1nH4ng                              #
# @Date: 2024-11-07                             #
# @Last Modified By: J1nH4ng                    #
# @Last Modified Date: 2024-11-08               #
# @Email: j1nh4ng@icloud.com                    #
# @Version: v0.3.2                              #
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


# [TODO) IP 地址
# [TODO) MAC 地址
# [TODO) 默认网关
# [TODO) DNS

# [TODO) 监听端口
# [TODO) Firewalld

# [TODO) 用户
# [TODO) 空密码用户
# [TODO) 相同 ID 用户
# [TODO) 密码过期
# [TODO) ROOT 用户
# [TODO) Sudo 授权

# [TODO) SSH 信任主机
# [TODO) SSH 协议版本
# [TODO) 允许 ROOT 远程登录

# [TODO) 僵尸进程数量
# [TODO) 自启动服务数量
# [TODO) 自启动程序数量

# [TODO) 运行中的任务数
# [TODO) 计划中的任务数

# [TODO) 日志服务

# [TODO) SNMP
# [TODO) NTP

# [TODO) JDK 版本


function version() {
    # 脚本信息
    local SH_AUTHOR
    local SH_VERSION

    SH_AUTHOR="J1nH4ng<j1nh4ng@icloud.com>"
    SH_VERSION="v0.4.2"

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

    export report_current_date=$(date +"%F %T")
    export report_hostname="${hostname}"
    export report_SELinux="${selinux}"
    export report_OS_release="${release}"
    export report_kernel="${kernel}"
    export report_language="${default_language}"
    export report_last_reboot_time="${last_reboot}"
    export report_uptime="${uptime}"
    export LANG="${default_language}"

    echo ""
    echo "#################### 系统检查结束 ####################"
    echo ""
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

    export report_CPU_nums=${virtual_CPUs}
    export report_CPU_type=${CPU_type}
    export report_CPU_arch=${CPU_arch}
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

    export report_memory_total="$((memory_total/1024))"" MB"
    export report_memory_free="$((memory_free/1024))"" MB"
    export report_memory_used="$((memory_used/1024))"" MB"
    export report_memory_used_percent=$(awk "BEGIN {if($memory_total==0){printf 100}else{printf \"%.2f\",$memory_used*100/$memory_total}}")"%"

    echo ""
    echo "Mem 总共量为：${report_memory_total}"
    echo "Mem 空闲量为：${report_memory_free}"
    echo "Mem 使用量为：${report_memory_used}"
    echo "Mem 使用率为：${memory_percent}""%"

    echo ""
    echo "#################### 内存检查结束 ####################"
    echo ""
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

    # 单位为：KB
    disk_data=$(df -TP | sed '1d' | awk '$2!="tmpfs"{print}')
    disk_total=$(echo "${disk_data}" | awk '{total+=$3}END{print total}')
    disk_used=$(echo "${disk_data}" | awk '{total+=$4}END{print total}')
    disk_free=$((disk_total-disk_used))
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

    export report_disk_total=$((disk_total/1024/1024))" GB"
    export report_disk_free=$((disk_free/1024/1024))" GB"
    export report_disk_used=$((disk_used/1024/1024))" GB"
    export report_disk_used_percent="${disk_used_percent}""%"

    export report_inode_total=$((inode_total/1000))" K"
    export report_inode_free=$((inode_free/1000))" K"
    export report_inode_used=$((inode_used/1000))" K"
    export report_inode_used_percent="$inode_used_percent""%"

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
}

function main() {
    version
    get_system_status
    get_cpu_status
    get_memory_status
    get_disk_status
}

main "$@"
