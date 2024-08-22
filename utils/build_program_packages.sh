#!/bin/bash
#
# 应用打包脚本文件
# 版权 2024 J1nH4ng<j1nh4ng@icloud.com>

# Globals:
# Arguments:
#  None


#######################################
# 日志输出脚本引入
# Arguments:
#  None
#######################################
function import_output_logs() {
  local script_dir
  script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
  source "${script_dir}/../core/banner.sh"
}

#######################################
# MVN 环境检查
# Arguments:
#  None
#######################################
function mvn_env_check() {
  import_output_logs
  echo_info "检查 MVN 是否安装"
  if command -v mvn >/dev/null 2>&1; then
    echo_info "MVN 已成功安装"
    mvn --version
  else
    echo_error_basic "MVN 不存在于系统路径中，请输入 MVN 路径或安装 MVN"
    while true; do
      read -erp "请输入 MVN 路径：" mvn_path
      if [ -x "${mvn_path}" ] && command -v mvn >/dev/null 2>&1; then
        echo_info "在 ${mvn_path} 中查找到了 MVN"
        ${mvn_path} --version
        break
      else
        echo_error_basic "MVN 路径无效，脚本将退出"
        exit 1
      fi
    done
  fi
}

#######################################
# Java 项目编译
# Arguments:
#  None
#######################################
function build_java_project() {
  import_output_logs
  echo_info "开始编译 Java 项目"
  local module_name
  local project_name
  local git_url

}

#######################################
# Pnpm 环境检查
# Arguments:
#  None
#######################################
function pnpm_env_check() {
  :
}

#######################################
# main 函数
# Arguments:
#  None
#######################################
function main() {
  mvn_env_check
}

main "$@"
