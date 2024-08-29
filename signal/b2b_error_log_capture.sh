#!/bin/bash
#
# 块到块错误日志抓取脚本
# 版权 2024 J1nH4ng<j1nh4ng@icloud.com>

# 实现思路：
# 读取日志文件时维护一个 txt 文档，文档中保存如下信息：
#
# [ERROR] -1
# [INFO|WARN] -1
# drop_flag 0
# last_line 0
#
# 其中 drop_flag 表示是否要输出，last_line 表示监听的日志最新的位置行
#
# 基本逻辑：
# 1. 读取日志信息，将日志开头的标志如【INFO】或【WARN】所在的行位置数更新到 [INFO|WARN] line_number 位置处
# 2. 当读取到【ERROR】信息块时，进行内部判断，是否在块内含有 exclude_word.txt 文档中所包涵的关键字，如果有则把 drop_flag 置为 1，否则置为 0
# 3. 当读取到下一个不为【ERROR】信息块时，如果 drop_flag 为 1，则更新对应的 [INFO|WARN] line_number 并把其他的置为 -1
#    如果 drop_flag 为 0 时，输出从 [INFO|WARN] line_number 到最新的 [INFO|WARN] line_number-1 的信息块
# 4. 把当前文件的最后一行写入 last_line 位置处
