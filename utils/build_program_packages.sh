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
# MVN 环境检查
# Arguments:
#  None
#######################################
function mvn_env_check() {
  mvn_bin=""
  local mvn_path

  echo_info "检查 MVN 是否安装"
  if command -v mvn >/dev/null 2>&1; then
    echo_info "MVN 已成功安装"
    mvn --version
    mvn_bin="mvn"
  else
    echo_error_basic "MVN 不存在于系统路径中，请输入 MVN 路径或安装 MVN"
    while true; do
      read -erp "请输入 MVN 路径：" mvn_path
      if [ -x "${mvn_path}" ] && command -v mvn >/dev/null 2>&1; then
        echo_info "在 ${mvn_path} 中查找到了 MVN"
        ${mvn_path} --version
        mvn_bin="${mvn_path}"
        break
      else
        echo_error_basic "MVN 路径无效，脚本将退出"
        exit 1
      fi
    done
  fi
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
# Git 环境检查
# Arguments:
#  None
#######################################
function git_env_check() {
  echo_info "检查 Git 是否安装"
  if command -v git >/dev/null 2>&1; then
    echo_info "Git 已成功安装"
    git --version
  else
    echo_error_basic "Git 不存在于系统路径中，请安装 Git"
    exit 1
  fi
}

#######################################
# lrzsz 环境检查
# Arguments:
#  None
#######################################
function lrzsz_env_check() {
  echo_info "检查 lrzsz 是否安装"
  if command -v sz >/dev/null 2>&1; then
    echo_info "sz 已成功安装"
    sz --version
  else
    echo_error_basic "lrzsz 不存在于系统路径中，请安装 lrzsz"
    exit 1
  fi
}

#######################################
# zip 环境检查
# Arguments:
#  None
#######################################
function zip_env_check() {
  echo_info "检查 zip 是否安装"
  if command -v zip >/dev/null 2>&1; then
    echo_info "zip 已成功安装"
    zip --version
  else
    echo_error_basic "zip 不存在于系统路径中，请安装 zip"
    exit 1
  fi
}

#######################################
# Git 克隆仓库
# Arguments:
#  None
#######################################
function git_clone() {
  local git_url

  read -erp "输入项目包名：" project_name
  if [ -z "${project_name}" ]; then
    echo_error_basic "项目包名不能为空，脚本将退出"
    return 1
  fi

  read -erp "输入项目名称：" package_name
  if [ -z "${package_name}" ]; then
    echo_error_basic "项目名称不能为空，脚本将退出"
    return 1
  fi

  read -erp "输入 Git 仓库地址：" git_url
  if [ -z "${git_url}" ]; then
    echo_error_basic "Git 仓库地址不能为空，脚本将退出"
    return 1
  fi

  echo_info "正在创建项目目录：/usr/local/src/${project_name}"
  mkdir -p "/usr/local/src/${project_name}" || {
    echo_error_basic "创建项目目录失败，脚本将退出"
    return 1
  }

  echo_info "正在克融 Git 仓库：${git_url} 到 /usr/local/src/${project_name}/${package_name}"
  git clone "${git_url}" "/usr/local/src/${project_name}/${package_name}" || {
    echo_error_basic "克融 Git 仓库失败，脚本将退出"
    return 1
  }
}

#######################################
# Java 项目编译
# Arguments:
#  None
#######################################
function build_java_project() {
  echo_info "开始编译 Java 项目"
  mvn_env_check

  echo_info "切换到项目目录，准备打包"
  cd "/usr/local/src/${project_name}/${package_name}" || {
    echo_error_basic "切换到项目目录失败，脚本将退出"
    return 1
  }

  local module_name
  read -erp "输入需要打包的模块名称：" module_name
  if [ -z "${module_name}" ]; then
    echo_error_basic "模块名称不能为空，脚本将退出"
    return 1
  fi

  ${mvn_bin} clean package -pl "${module_name}" -am -Dmaven.test.skip=true

  echo_info "Java 项目编译成功"
  echo_info "编译后的文件位于：/usr/local/src/${project_name}/${package_name}/${module_name}/target/ 目录下"
  echo_info "重命名文件并下载"

  jar_file=$(ls /usr/local/src/${project_name}/${package_name}/${module_name}/target/*.jar) 2>/dev/null
  if [ -z "${jar_file}" ]; then
    echo_error_basic "未找到编译后的 jar 文件，脚本将退出" && rm -rf "/usr/local/src/${project_name}/${package_name}"
    return 1
  fi

  mv "${jar_file}" "/usr/local/src/download/${package_name}/${module_name}/${module_name}.jar" || {
    echo_error_basic "重命名文件失败，脚本将退出" && rm -rf "/usr/local/src/${project_name}/${package_name}"
    return 1
  }

  sz "/usr/local/src/download/${project_name}/${package_name}/${module_name}.jar" || {
    echo_error_basic "下载文件失败，脚本将退出" && rm -rf "/usr/local/src/${project_name}/${package_name}"
    return 1
  }

  echo_warn "删除 Git 仓库"
  rm -rf "/usr/local/src/${project_name}/${package_name}" || {
    echo_error_basic "删除 Git 仓库失败，脚本将退出"
    return 1
  }

  echo_info "删除 Git 仓库成功"
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
    mvn_env_check
    git_clone
    build_java_project
  fi
}

main "$@"
