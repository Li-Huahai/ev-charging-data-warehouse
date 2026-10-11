-- ============================================
-- 维度四：区域热点分析
-- 目标：识别充电需求在空间上的热点区域（TAZ 级别）
-- ============================================

USE urbanev_db;

-- 4.1 区域需求聚合与排名
SELECT
    i.tazid AS zone_id,
    COUNT(DISTINCT o.station_id) AS station_count,
    AVG(o.occupancy_rate) AS overall_avg_occupancy,
    SUM(v.volume_value) AS total_volume,
    COUNT(*) AS total_records,
    ROUND(SUM(v.volume_value) / COUNT(DISTINCT o.station_id), 2) AS volume_per_station
FROM occupancy o
JOIN volume v ON o.time = v.time AND o.station_id = v.station_id
JOIN infrastructure i ON o.station_id = i.tazid
GROUP BY i.tazid
ORDER BY total_volume DESC
LIMIT 20;

-- 4.2 热门区域的详细时间分布（前 3 热门区域）
SELECT
    i.tazid AS zone_id,
    HOUR(o.time) AS hour_of_day,
    DAYOFWEEK(o.time) AS day_of_week,   -- 1=Sunday, 7=Saturday
    AVG(o.occupancy_rate) AS avg_occupancy_rate,
    SUM(v.volume_value) AS hourly_volume,
    COUNT(*) AS record_count
FROM occupancy o
JOIN volume v ON o.time = v.time AND o.station_id = v.station_id
JOIN infrastructure i ON o.station_id = i.tazid
WHERE i.tazid IN (1167, 346, 595)
GROUP BY i.tazid, HOUR(o.time), DAYOFWEEK(o.time)
ORDER BY zone_id, day_of_week, hour_of_day;
