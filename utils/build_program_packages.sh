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

  echo_info "开始编译 Java 项目"
  mvn_env_check

  echo_info "切换到项目目录，准备打包"
  cd "/usr/local/src/speed-cicd/${project_name}/${package_name}" || {
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
# main 函数
# Arguments:
#  None
#######################################
function main() {
  if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    import_banner
    import_output_logs
    import_git_clone
    mvn_env_check
    git_clone_main
    build_java_project
  fi
}

main "$@"
