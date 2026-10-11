#!/usr/bin/env bash
# ============================================
# 使用 Sqoop 将 Hive 分析结果导出至 MySQL
# 前置：MySQL 中已创建目标表，且表结构与 Hive 输出完全匹配
# 注意：请勿将真实密码写入脚本，改用 -P 交互式输入或密码文件
# ============================================

sqoop export \
--connect jdbc:mysql://your_mysql_host:3306/urbanev_viz \
--username your_user \
--password your_password \
--table spatiotemporal_result \
--export-dir /tmp/spatiotemporal_analysis \
--input-fields-terminated-by ',' \
--lines-terminated-by '\n'

# MySQL 建表参考：
# CREATE TABLE spatiotemporal_result (
#   zone_id           VARCHAR(32),
#   hour_of_day       INT,
#   day_of_week_num   INT,
#   avg_occupancy     DOUBLE,
#   avg_volume        DOUBLE,
#   record_count      BIGINT
# );
