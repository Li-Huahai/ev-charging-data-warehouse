-- ============================================
-- 03. 数据质量验证查询
-- 覆盖：完整性 / 时间范围 / 值域区间 / 跨表一致性
-- ============================================

USE urbanev_db;

-- 1. 各表记录数统计（完整性）
SELECT 'occupancy' AS table_name, COUNT(*) AS record_count FROM occupancy
UNION ALL
SELECT 'volume', COUNT(*) FROM volume
UNION ALL
SELECT 'e_price', COUNT(*) FROM e_price
UNION ALL
SELECT 'infrastructure', COUNT(*) FROM infrastructure
UNION ALL
SELECT 'poi', COUNT(*) FROM poi
UNION ALL
SELECT 'weather_combined', COUNT(*) FROM weather_combined;

-- 2. 时间范围检查（一致性）
SELECT 'occupancy' AS tbl, MIN(time) AS start, MAX(time) AS end FROM occupancy
UNION ALL
SELECT 'volume', MIN(time), MAX(time) FROM volume
UNION ALL
SELECT 'weather_combined', MIN(time), MAX(time) FROM weather_combined;

-- 3. 关键字段基本统计（值域区间）
SELECT
    COUNT(*) AS total_records,
    MIN(occupancy_rate) AS min_occ,
    MAX(occupancy_rate) AS max_occ,
    AVG(occupancy_rate) AS avg_occ
FROM occupancy;

-- 4. 跨表一致性验证
--    检查某时刻（2022-09-01 00:00:00）站点 102 的数据
--    是否在所有相关表中均存在
SELECT COUNT(*) AS match_count
FROM (SELECT time, station_id FROM e_price WHERE time='2022-09-01 00:00:00' AND station_id='102') e
JOIN (SELECT time, station_id FROM s_price WHERE time='2022-09-01 00:00:00' AND station_id='102') s
  ON e.time = s.time AND e.station_id = s.station_id
JOIN (SELECT time, station_id FROM occupancy WHERE time='2022-09-01 00:00:00' AND station_id='102') o
  ON e.time = o.time AND e.station_id = o.station_id
JOIN (SELECT time, station_id FROM volume WHERE time='2022-09-01 00:00:00' AND station_id='102') v
  ON e.time = v.time AND e.station_id = v.station_id
JOIN (SELECT time FROM weather_combined WHERE time='2022-09-01 00:00:00') w
  ON e.time = w.time;
