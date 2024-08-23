#!/bin/bash
#
# 下载 git 仓库
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
  source "${script_dir}/../core/output_logs.sh"
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
# 从列表文件中选择或输入并写入
# Arguments:
#  1. 提示信息
#  2. 列表文件路径
#  3. 记录索引
# Returns:
#  选择的值或输入的值
#######################################
function select_or_input() {
  local prompt=$1
  local list_file=$2
  local index=$3
  local options=()
  local value

  if [ -f "${list_file}" ]; then
    while IFS=':' read -r project_name package_name git_url; do
      options+=("${project_name}:${package_name}:${git_url}")
    done < "${list_file}"
  fi

  if [ ${#options[@]} -eq 0 ]; then
    read -erp "${prompt}" value
  else
    echo_info "${prompt}"
    select option in "${options[@]}" "手动输入"; do
      if [ -n "${option}" ] && [ "${option}" != "手动输入" ]; then
        IFS=':' read -r project_name package_name git_url <<< "${option}"
        case "${index}" in
          1) value="${project_name}" ;;
          2) value="${package_name}" ;;
          3) value="${git_url}" ;;
        esac
        break
      elif [ "${option}" == "手动输入" ]; then
        read -erp "${prompt}" value
        break
      else
        echo_warn "无效选择，请重新选择"
      fi
    done
  fi

  echo "${value}"
}

#######################################
# 写入记录到列表文件
# Arguments:
#  1. 项目包名
#  2. 包名
#  3. Git 地址
#  4. 列表文件路径
#######################################
function write_record() {
  local project_name=$1
  local package_name=$2
  local git_url=$3
  local list_file=$4

  echo "${project_name}:${package_name}:${git_url}" >> "${list_file}"
}


#######################################
# 下载源代码
# Arguments:
#  None
#######################################
function git_clone() {
  local branch_name
  local data_path
  data_path="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
  local list_file="${data_path}/../data/project_list.txt"

  project_name=$(select_or_input "请输入项目包名：" "${list_file}" 1)
  if [ -z "${project_name}" ]; then
    echo_error_basic "项目包名不能为空"
    exit 1
  fi

  package_name=$(select_or_input "请输入项目包名：" "${list_file}" 2)
  if [ -z "${package_name}" ]; then
    echo_error_basic "项目包名不能为空"
    exit 1
  fi

  git_url=$(select_or_input "请输入项目 Git 地址：" "${list_file}" 3)
  if [ -z "${git_url}" ]; then
    echo_error_basic "Git 地址不能为空"
    exit 1
  fi

  write_record "${project_name}" "${package_name}" "${git_url}" "${list_file}"

  echo_info "请选择要克隆的分支："
  select branch_name in main test; do
    if [ -n "${branch_name}" ]; then
      echo_info "你选择的分支为：${branch_name}"
      break
    eles
      echo_warn "未正确选择分支，默认为 main 分支"
      branch_name="main"
      break
    fi
  done

  clean_up_git_clone

  mkdir -p "/usr/local/src/speed-cicd/${project_name}" || {
    echo_error_basic "创建项目目录失败，脚本将退出"
    return 1
  }

  echo_info "正在克隆 Git 仓库：${git_url} 分支：${branch_name} 到 /usr/local/src/speed-cicd/${project_name}/${package_name}"

  # 尝试克隆用户选择的分支
  if ! git clone -b "${branch_name}" --single-branch "${git_url}" "/usr/local/src/speed-cicd/${project_name}/${package_name}"; then
    # 如果克隆 main 分支失败，尝试克隆 master 分支
    if [ "${branch_name}" == "main" ]; then
      echo_info "克隆 main 分支失败，尝试克隆 master 分支"
      git clone -b "master" --single-branch "${git_url}" "/usr/local/src/speed-cicd/${project_name}/${package_name}" || {
        echo_error_basic "克隆 Git 仓库失败，脚本将退出"
        return 1
      }
    else
      echo_error_basic "克隆 Git 仓库失败，脚本将退出"
      return 1
    fi
  fi
}


#######################################
# 删除下载的源代码
# Arguments:
#  None
#######################################
function clean_up_git_clone() {
  if [ -d "/usr/local/src/speed-cicd/${project_name}" ]; then
    echo_warn "目录 /usr/local/src/speed-cicd/${project_name} 已存在，正在删除......"
    rm -rf "/usr/local/src/speed-cicd/${project_name}" || {
      echo_error_basic "删除目录失败，脚本将退出"
      return 1
    }
  fi
}

#######################################
# main function
# Arguments:
#  None
#######################################
function main() {
  if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    import_output_logs
    git_env_check
    git_clone
    # clean_up_git_clone
  fi
}

main "$@"
