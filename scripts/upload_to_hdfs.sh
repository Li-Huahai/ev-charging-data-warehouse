#!/usr/bin/env bash
# ============================================
# 将本地预处理 CSV 上传至 HDFS
# 前置：Hadoop 已启动（start-dfs.sh / start-yarn.sh）
# ============================================
set -e

BASE=/user/hive/warehouse/urbanev_db
LOCAL=./local_data

# 1. 创建项目主目录
hdfs dfs -mkdir -p ${BASE}

# 2. 为不同类型数据创建子目录
for d in weather_airport weather_central weather_combined \
         occupancy price infrastructure duration poi volume adjacency distance; do
  hdfs dfs -mkdir -p ${BASE}/${d}
done

# 3. 上传本地预处理 CSV
#    注意：price 目录下需同时包含 e_price_clean.csv 与 s_price_clean.csv
hdfs dfs -put ${LOCAL}/occupancy_clean.csv        ${BASE}/occupancy/
hdfs dfs -put ${LOCAL}/volume_clean.csv           ${BASE}/volume/
hdfs dfs -put ${LOCAL}/e_price_clean.csv          ${BASE}/price/
hdfs dfs -put ${LOCAL}/s_price_clean.csv          ${BASE}/price/
hdfs dfs -put ${LOCAL}/infrastructure_clean.csv   ${BASE}/infrastructure/
hdfs dfs -put ${LOCAL}/poi_clean.csv              ${BASE}/poi/
hdfs dfs -put ${LOCAL}/weather_combined_clean.csv ${BASE}/weather_combined/
hdfs dfs -put ${LOCAL}/duration_clean.csv         ${BASE}/duration/
hdfs dfs -put ${LOCAL}/adjacency_clean.csv        ${BASE}/adjacency/
hdfs dfs -put ${LOCAL}/distance_clean.csv         ${BASE}/distance/

# 4. 验证上传结果
hdfs dfs -ls -R ${BASE}
hdfs dfs -cat ${BASE}/occupancy/occupancy_clean.csv | head -n 3

# ============================================
# 数据集说明
# --------------------------------------------
# 原始数据集：Urbanev 开放基准数据集（Dryad 平台）
# 共 8 大类 14 个文件，体积约 7GB，未纳入 Git 仓库
# （GitHub 单文件上限 100MB）。
#
# 获取方式：
#   1) 从 Dryad 平台检索 Urbanev 数据集下载
#   2) 解压至 ${LOCAL}/
#   3) 按本脚本命名规则重命名为 *_clean.csv 后上传
# ============================================
