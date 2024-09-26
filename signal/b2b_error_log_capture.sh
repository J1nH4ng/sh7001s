#!/bin/bash
#
# Java 错误日志捕获脚本
# 版权 2024 J1nH4ng<j1nh4ng@icloud.com>

# Globals:
# Arguments:
#  None

function judge_log_file() {
  export log_file
  log_file="$1"

  if [[ ! -e "${log_file}" ]]; then
    echo "Error: log file not found: ${log_file}"
    exit 127
  fi
}

function judge_table_file() {
  export tmp_dir
  tmp_dir="/tmp/java-error-logs"

  export server_name
  server_name="$1"

  if [ ! -f "${tmp_dir}/${server_name}" ] || [ ! -s "${tmp_dir}/${server_name}" ]; then
    echo '[ERROR_LiNE]
-1
[NOT_ERROR_LiNE]
-1
1
[LATEST_LiNE]
1
[LOG_SIZE]
0
[BEFORE_ERROR_LiNE]
1
1
1
1
1
[COUNT]
1' >> "${tmp_dir}/${server_name}"
  fi

  if [[ ! -f "${tmp_dir}/${server_name}.log.tmp" ]]; then
    touch "${tmp_dir}/${server_name}.log.tmp"
  fi
}

function update_flag_lines() {
  local current_log_size
  current_log_size=$(du -k "${log_file}" | cut -f1)

  local old_log_size
  old_log_size=$(sed -n '9p' "${tmp_dir}/${server_name}")

  local latest_line
  latest_line=$(sed -n '7p' "${tmp_dir}/${server_name}")

  local log_entries
  log_entries=$(sed -n "${latest_line}, \$p" "${log_file}")

  local fourth_value
  local fifth_value
  fourth_value=$(sed -n '4p' "${tmp_dir}/${server_name}")
  fifth_value=$(sed -n '5p' "${tmp_dir}/${server_name}")

  local entries
  local current_line_number
  current_line_number=$((latest_line - 1))

  if (( current_log_size < old_log_size )); then
    echo '[ERROR_LiNE]
-1
[NOT_ERROR_LiNE]
-1
1
[LATEST_LiNE]
1
[LOG_SIZE]
0
[BEFORE_ERROR_LiNE]
1
1
1
1
1
[COUNT]
1' > "${tmp_dir}/${server_name}"
  fi

  sed -i "9s/.*/$current_log_size /" "${tmp_dir}/${server_name}"

  while IFS= read -r entries; do
    current_line_number=$((current_line_number + 1))

    if [[ "${entries}" =~ "【ERROR】" ]]; then
      sed -i "2s/.*/$current_line_number /" "${tmp_dir}/${server_name}"
    elif [[ "${entries}" =~ "【INFO】" || "${entries}" =~ "【DEBUG】" || "${entries}" =~ "【WARN】" ]]; then
      if (( fourth_value < fifth_value )); then
        sed -i "4s/.*/$current_line_number /" "${tmp_dir}/${server_name}"
        update_before_error_lines "$current_line_number"
        fourth_value=$(sed -n '4p' "${tmp_dir}/${server_name}")
        fifth_value=$(sed -n '5p' "${tmp_dir}/${server_name}")
        echo_temp_error_block
      else
        sed -i "5s/.*/$current_line_number /" "${tmp_dir}/${server_name}"
        update_before_error_lines "$current_line_number"
        fourth_value=$(sed -n '4p' "${tmp_dir}/${server_name}")
        fifth_value=$(sed -n '5p' "${tmp_dir}/${server_name}")
        echo_temp_error_block
      fi
    fi
    sed -i "7s/.*/$current_line_number /" "${tmp_dir}/${server_name}"
  done <<< "${log_entries}"
}

function update_before_error_lines() {
  local current_line_number
  current_line_number="$1"

  local i
  i=$(sed -n '17p' "${tmp_dir}/${server_name}")
  sed -i "$((10 + i))s/.*/$current_line_number /" "${tmp_dir}/${server_name}"

  if [ "$i" -le  5 ] ;then
    sed -i "17s/.*/$((i + 1)) /" "${tmp_dir}/${server_name}"
  else
    sed -i "17s/.*/1 /" "${tmp_dir}/${server_name}"
  fi
}

function judge_start_value() {
  export start_value

  local line_12_number
  local line_13_number
  local line_14_number
  local line_15_number

  start_value=$(sed -n '11p' "${tmp_dir}/${server_name}")
  line_12_number=$(sed -n '12p' "${tmp_dir}/${server_name}")
  line_13_number=$(sed -n '13p' "${tmp_dir}/${server_name}")
  line_14_number=$(sed -n '14p' "${tmp_dir}/${server_name}")
  line_15_number=$(sed -n '15p' "${tmp_dir}/${server_name}")

  if (( line_12_number < start_value )); then
    start_value="$line_12_number"
  fi

  if (( line_13_number < start_value )); then
    start_value="$line_13_number"
  fi

  if (( line_14_number < start_value )); then
    start_value="$line_14_number"
  fi

  if (( line_15_number < start_value )); then
    start_value="$line_15_number"
  fi
}

function echo_temp_error_block() {
  local table_file
  table_file="${tmp_dir}/${server_name}"

  local second_line_value
  local fourth_line_value
  local fifth_line_value
  local stop_line_value

  second_line_value=$(sed -n '2p' "${table_file}")
  fourth_line_value=$(sed -n '4p' "${table_file}")
  fifth_line_value=$(sed -n '5p' "${table_file}")

  judge_start_value

  if (( second_line_value > fourth_line_value && second_line_value < fifth_line_value )); then
    stop_line_value=$((fifth_line_value - 1))
    echo > "${tmp_dir}/${server_name}.log.tmp"
    sed -n "${start_value},${stop_line_value}p" "${log_file}" >> "${tmp_dir}/${server_name}.log.tmp"
    grep_excluded_words
  elif (( second_line_value < fourth_line_value && second_line_value > fifth_line_value )); then
    stop_line_value=$((fourth_line_value - 1))
    echo > "${tmp_dir}/${server_name}.log.tmp"
    sed -n "${start_value},${stop_line_value}p" "${log_file}" >> "${tmp_dir}/${server_name}.log.tmp"
    grep_excluded_words
  fi
}

function grep_excluded_words() {
  local final_error_block
  final_error_block=$(cat "${tmp_dir}/${server_name}.log.tmp")

  local keyword

  while IFS= read -r keyword; do
    if [[ "${final_error_block}" == *"${keyword}"* ]]; then
      echo > "${tmp_dir}/${server_name}.log.tmp"
    fi
  done < "${tmp_dir}/keywords.txt"
  cat "${tmp_dir}/${server_name}.log.tmp"
}

function main() {
  local log_file
  local server_name

  log_file="$1"
  server_name="$2"

  judge_log_file "${log_file}"
  judge_table_file "${server_name}"
  update_flag_lines
}

main "$@"
