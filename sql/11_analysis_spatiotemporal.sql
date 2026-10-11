-- ============================================
-- 维度八：时空复合分析
-- 目标：生成标准的时空矩阵数据，用于热力图等时空可视化
-- ============================================

USE urbanev_db;

SELECT
    o.station_id AS zone_id,
    HOUR(o.time) AS hour_of_day,
    DATE_FORMAT(o.time, 'u') AS day_of_week_num,   -- 1=Monday, 7=Sunday
    CASE DATE_FORMAT(o.time, 'u')
        WHEN '1' THEN 'Monday'
        WHEN '2' THEN 'Tuesday'
        WHEN '3' THEN 'Wednesday'
        WHEN '4' THEN 'Thursday'
        WHEN '5' THEN 'Friday'
        WHEN '6' THEN 'Saturday'
        WHEN '7' THEN 'Sunday'
    END AS day_of_week_name,
    AVG(o.occupancy_rate) AS avg_occupancy,
    AVG(v.volume_value) AS avg_volume,
    COUNT(*) AS record_count
FROM occupancy o
JOIN volume v ON o.time = v.time AND o.station_id = v.station_id
WHERE o.time >= '2022-09-01' AND o.time < '2023-03-01'
GROUP BY o.station_id, HOUR(o.time), DATE_FORMAT(o.time, 'u')
ORDER BY zone_id, CAST(day_of_week_num AS INT), hour_of_day;

-- 结果导出见 scripts/export_results.sh
