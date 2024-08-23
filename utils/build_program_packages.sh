#!/bin/bash
#
# 应用打包脚本文件
# 版权 2024 J1nH4ng<j1nh4ng@icloud.com>

# Globals:
# Arguments:
#  None

#######################################
# banner 引用函数
# Globals:
#   BASH_SOURCE
# Arguments:
#  None
#######################################
function import_banner() {
  local script_dir
  script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
  source "${script_dir}/../core/banner.sh"
  banner_main
}

#######################################
# 日志输出脚本引入
# Arguments:
#  None
#######################################
function import_output_logs() {
  local script_dir
  script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
  source "${script_dir}/../core/output_logs.sh"
}

#######################################
# 环境检查脚本引入
# Arguments:
#  None
#######################################
function import_env_check() {
  local script_dir
  script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
  source "${script_dir}/../share/env_check.sh"
}

#######################################
# 当前日期目录创建脚本引入
# Arguments:
#  None
#######################################
function import_make_current_date_dir() {
  local script_dir
  script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
  source "${script_dir}/../share/make_current_date_dir.sh"
}

#######################################
# clone 代码脚本引入
# Arguments:
#  None
#######################################
function import_git_clone() {
  local script_dir
  script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
  source "${script_dir}/../share/git_clone.sh"
}

#######################################
# Java 项目编译
# Arguments:
#  None
#######################################
function build_java_project() {
  import_make_current_date_dir
  make_current_date_dir_main "/usr/local/src/download"

  local module_name


  echo_info "开始编译 Java 项目"

  echo_info "切换到项目目录，准备打包"
  cd "/usr/local/src/speed-cicd/${project_name}/${package_name}" || {
    echo_error_basic "切换到项目目录失败，脚本将退出"
    return 1
  }


  read -erp "输入需要打包的模块名称：" module_name
  if [ -z "${module_name}" ]; then
    echo_error_basic "模块名称不能为空，脚本将退出"
    return 1
  fi

  mvn clean package -pl "${module_name}" -am -Dmaven.test.skip=true

  echo_info "Java 项目编译成功"
  echo_info "编译后的文件位于：/usr/local/src/speed-cicd/${project_name}/${package_name}/${module_name}/target/ 目录下"
  echo_info "重命名文件并下载"

  jar_file=$(ls /usr/local/src/speed-cicd/${project_name}/${package_name}/${module_name}/target/*.jar) 2>/dev/null

  if [ -z "${jar_file}" ]; then
    echo_error_basic "未找到编译后的 jar 文件，脚本将退出"
    return 1
  fi

  if [ ! -d "/usr/local/src/download/${current_date}" ]; then
    mkdir -p "/usr/local/src/download/${current_date}"
    if ! mkdir -p "/usr/local/src/download/${current_date}"; then
      echo_error_basic "创建目录 /usr/local/src/download/${current_date} 失败，脚本将退出"
      return 1
    fi
  fi

  mv "${jar_file}" "/usr/local/src/download/${current_date}/[${project_name}]-[${package_name}]-[${module_name}].jar" || {
    echo_error_basic "重命名文件失败，脚本将退出"
    return 1
  }

  if [ -f "/usr/local/src/download/${current_date}/[${project_name}]-[${package_name}]-[${module_name}].jar" ]; then
    echo_info "文件重命名成功"
    echo_info "具体信息为：/usr/local/src/download/${current_date}/[${project_name}]-[${package_name}]-[${module_name}].jar"
  else
    echo_error_basic "未找到重命名后的 jar 文件，脚本将退出"
  fi
}

#######################################
# node 项目编译
# Globals:
#   BASH_SOURCE
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
function build_node_project() {
  import_make_current_date_dir
  make_current_date_dir_main "/usr/local/src/download"

  local nodejs_version
  local build_command
  local build_method
  local environment
  local manual_input

  echo_info "开始编译 node 项目"

  read -erp "输入需要使用的 node 版本：：" nodejs_version

  # 检查版本是否已安装，如果没有则安装
  if ! nvm ls "${nodejs_version}" | grep -q "N/A"; then
    echo_info "Node.js 版本 ${nodejs_version} 未安装，正在安装..."
    nvm install "${nodejs_version}"
  fi

  nvm use "${nodejs_version}" || {
    echo_error_basic "切换 node 版本失败，脚本将退出"
    return 1
  }

  echo_info "切换到项目目录，准备打包"
  cd "/usr/local/src/speed-cicd/${project_name}/${package_name}" || {
    echo_error_basic "切换到项目目录失败，脚本将退出"
    return 1
  }

  pnpm install

  read -erp "选择打包方式（1: 预定义命令, 2: 手动输入）：" build_method
  case "${build_method}" in
    1)
      read -erp "输入环境（test/prod）：" environment
      case "${environment}" in
        test)
          build_command="pnpm run build:test"
          echo_info "开始执行打包命令：${build_command}"
          eval "${build_command}"
          ;;
        prod)
          build_command="pnpm run build"
          echo_info "开始执行打包命令：${build_command}"
          eval "${build_command}"
          ;;
        *)
          echo_error_basic "未知环境，脚本将退出"
          return 1
          ;;
      esac
      ;;
    2)
      read -erp "输入手动打包命令：" manual_input
      build_command="${manual_input}"
      echo_info "开始执行打包命令：${build_command}"
      eval "${build_command}"
      ;;
    *)
      echo_error_basic "未知选项，脚本将退出"
      return 1
      ;;
  esac

  echo_info "开始压缩文件夹"
  zip -jr "/usr/local/src/download/${current_date}/[${project_name}]-[${package_name}].zip" "/usr/local/src/speed-cicd/${project_name}/${package_name}/dist" || {
    echo_error_basic "打包失败，脚本将退出"
    return 1
  }

  if [ -f "/usr/local/src/download/${current_date}/[${project_name}]-[${package_name}].zip" ]; then
    echo_info "文件重命名成功"
    echo_info "具体信息为：/usr/local/src/download/${current_date}/[${project_name}]-[${package_name}].zip"
  else
    echo_error_basic "未找到压缩后的 zip 文件，脚本将退出"
  fi
}

#######################################
# main 函数
# Arguments:
#  None
#######################################
function main() {
  if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    import_banner
    import_output_logs
    import_git_clone
    import_env_check

    local choice

    env_check_main
    git_clone_main

    echo_info "代码下载完成，准备打包"
    echo_info "请选择项目类型："
    echo_info "1. 后端项目"
    echo_info "2. 前端项目"
    read -erp "请输入项目类型：" choice
    case $choice in
      1)
        build_java_project
        ;;
      2)
        build_node_project
        ;;
      *)
        echo_error_basic "输入错误，脚本将退出"
        return 1
        ;;
    esac
  fi
}

main "$@"
