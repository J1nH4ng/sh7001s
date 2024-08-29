#!/bin/bash
#
# 块到块错误日志抓取脚本
# 版权 2024 J1nH4ng<j1nh4ng@icloud.com>


#######################################
# source_db Function：导入数据文件
# Globals:
#   BASH_SOURCE
#   script_dir
# Arguments:
#  None
#######################################
function source_db() {
  export script_dir
  script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
}


#######################################
# check_exclude_words Function：检查是否有需要排除的关键字
# Arguments:
#  None
#######################################
function check_exclude_words() {
  local log_line="$1"

  export have_exclude_words

  have_exclude_words=false

  local exclude_words=()
  local word

  while IFS= read -r word; do
    if [[ "$word" == 【*】 ]]; then
      exclude_words+=("${word:1:-1}")
    fi
  done < "${script_dir}/../data/error_log/exclude_error_words.txt"

  for word in "${exclude_words[@]}"; do
    if [[ "$log_line" == *"$word"* ]]; then
      have_exclude_words=true
      break
    fi
  done
}

#######################################
# Find Error Block Function
# Arguments:
#  None
#######################################
function find_error_block() {
  local log_file="$1"
  local in_error_block=false

  local line
  local tmp_error_block

  tmp_error_block=$(mktemp)

  while IFS= read -r line; do
    if [[ $line == *"【ERROR】"* ]]; then
      in_error_block=true
      check_exclude_words "$line"
      if [[ $have_exclude_words == false ]]; then
        echo "$line" >> "${tmp_error_block}"
      fi
    elif [[ $line == *"【INFO】"* || $line == *"【WARN】"* || $line == *"【DEBUG】"* ]]; then
      in_error_block=false
    elif $in_error_block; then
      check_exclude_words "$line"
      if [[ $have_exclude_words == false ]]; then
        echo "$line" >> "${tmp_error_block}"
      fi
    fi
  done < "$log_file"

  cat "${tmp_error_block}"
  rm -f "${tmp_error_block}"
}


#######################################
# test Function：测试函数
# Arguments:
#  None
#######################################
function test() {
  source_db
  find_error_block "${script_dir}/../data/error_log/test_error_logs.log"
}



#######################################
# Main Function
# Arguments:
#  None
#######################################
function main() {
  test "$@"
}

main "$@"
