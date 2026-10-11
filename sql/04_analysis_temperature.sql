-- ============================================
-- 维度一：温度影响分析
-- 目标：量化气温对充电站占用率的影响
-- ============================================

USE urbanev_db;

-- 创建温度分区临时表，优化后续关联性能
CREATE TABLE temp_weather AS
SELECT time, temperature
FROM weather_combined
WHERE temperature IS NOT NULL;

-- 执行关联分析
SELECT
    w.temperature,
    AVG(o.occupancy_rate) AS avg_occupancy_rate,
    AVG(v.volume_value) AS avg_volume_value,
    COUNT(*) AS data_points
FROM temp_weather w
JOIN occupancy o ON w.time = o.time
JOIN volume v ON o.time = v.time AND o.station_id = v.station_id
GROUP BY w.temperature
ORDER BY w.temperature;
