#!/bin/bash

##############################################
# @Author: J1nH4ng                           #
# @Date: 2024-11-07                          #
# @Last Modified By: J1nH4ng                 #
# @Last Modifide Date: 2024-11-07            #
# @Email: j1nh4ng@icloud.com                 #
# @Description: 服务器巡检脚本                 #
##############################################

# 脚本信息
SH_AUTHOR="J1nH4ng<j1nh4ng@icloud.com>"
SH_VERSION="v0.0.2"

# 服务器基本信息
# [info] 请根据每台服务器实际情况进行修改
IP_ADDR=$(ifconfig eth0 | grep -w 'inet' | awk -F '[ :]' '{print $10}')

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
source /etc/profile

# 判断是否是 ROOT 用户执行
[ $(id -u) -gt 0 ] && echo "请使用 ROOT 用户执行此脚本" && exit 1

# 系统版本
OS_VERSION=$(awk -F '=' '/^VERSION=/{gsub(/"/, "", $2); print $2}' /etc/os-release)

# 生成结果存储目录
PROGRAM_PATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
[ -f ${PROGRAM_PATH} ] && PROGRAM_PATH="."
LOG_PATH="${PROGRAM_PATH}/log"
[ -e ${LOG_PATH} ] || mkdir ${LOG_PATH}
RESULT_PAHT="${LOG_PATH}/${IP_ADDR}-`date +%Y%m%d`.txt"

# 需要巡检的内容
# [TODO) 日期
report_date=""
# [TODO) 主机名
report_hostname=""
# [TODO) 发行版本
report_OS_release=""
# [TODO) 内核
report_kernel=""
# [TODO) 语言/编码
report_language=""
# [TODO) 最近启动时间
report_last_reboot_time=""
# [TODO) 运行时间
report_uptime=""
# [DONE) CPU 数量
report_CPU_nums=""
# [DONE) CPU 类型
report_CPU_type=""
# [DONE) CPU 架构
report_CPU_arch=""
# [TODO) 内存总量
# [TODO) 内存剩余
# [TODO) 内存使用率
# [TODO) 磁盘总容量
# [TODO) 磁盘剩余
# [TODO) 磁盘使用率
# [TODO) Inode 总量
# [TODO) Inode 剩余
# [TODO) Inode 使用量
# [TODO) IP 地址
# [TODO) MAC 地址
# [TODO) 默认网关
# [TODO) DNS
# [TODO) 监听端口
# [TODO) SeLinux
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

function get_cpu_status() {
    echo ""
    echo "###################### CPU 检查 ######################"
    physical_CPUs=$(grep "physical id" /proc/cpuinfo | sort | uniq | wc -l)
    virtual_CPUs=$(grep "processor" /proc/cpuinfo | wc -l)
    CPU_kernels=$(grep "cores" /proc/cpuinfo | uniq | awk -F ': ' '{print $2}')
    CPU_type=$(grep "model name" /proc/cpuinfo | awk -F ': ' '{print $2}' | sort | uniq)
    CPU_arch=$(uname -m)
    echo "物理 CPU 个数为：${physical_CPUs}"
    echo "逻辑 CPU 个数为：${virtual_CPUs}"
    echo "每个 CPU 核心数为：${CPU_kernels}"
    echo "CPU 型号为：${CPU_type}"
    echo "CPU 架构为：${CPU_arch}"
    echo ""

    report_CPU_nums=${virtual_CPUs}
    report_CPU_type=${CPU_type}
    report_CPU_arch=${CPU_arch}
}

function main() {
    version
    get_cpu_status
}

main "$@"