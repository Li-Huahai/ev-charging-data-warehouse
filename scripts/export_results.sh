#!/usr/bin/env bash
# ============================================
# 导出 Hive 分析结果并合并为带表头的 CSV
# 示例：时空复合分析
# ============================================
set -e

OUT_DIR=~/charging_analysis_results/spatiotemporal
HDFS_TMP=/tmp/spatiotemporal_analysis

# 1. 在 Hive 中执行导出
hive -e "
USE urbanev_db;
INSERT OVERWRITE LOCAL DIRECTORY '${HDFS_TMP}'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
SELECT
    o.station_id AS zone_id,
    HOUR(o.time) AS hour_of_day,
    DATE_FORMAT(o.time, 'u') AS day_of_week_num,
    AVG(o.occupancy_rate) AS avg_occupancy,
    AVG(v.volume_value) AS avg_volume,
    COUNT(*) AS record_count
FROM occupancy o
JOIN volume v ON o.time = v.time AND o.station_id = v.station_id
WHERE o.time >= '2022-09-01' AND o.time < '2023-03-01'
GROUP BY o.station_id, HOUR(o.time), DATE_FORMAT(o.time, 'u')
ORDER BY zone_id, CAST(day_of_week_num AS INT), hour_of_day;
"

# 2. 创建本地目录并从 HDFS 下载
mkdir -p ${OUT_DIR}
hdfs dfs -get ${HDFS_TMP}/* ${OUT_DIR}/

# 3. 合并所有 part 文件并添加 CSV 表头
cd ${OUT_DIR}
echo "zone_id,hour_of_day,day_of_week_num,avg_occupancy,avg_volume,record_count" > header.csv
cat 000000_0 000001_0 > data.csv
cat header.csv data.csv > spatiotemporal_analysis_final.csv

# 4. 验证
head -n 5 spatiotemporal_analysis_final.csv
wc -l spatiotemporal_analysis_final.csv
