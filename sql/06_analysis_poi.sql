-- ============================================
-- 维度三：POI（兴趣点）影响分析
-- 目标：分析周边兴趣点类型和密度对充电站使用情况的影响
-- ============================================

USE urbanev_db;

-- 3.1 为 POI 数据添加唯一 ID
CREATE VIEW poi_data_with_id AS
SELECT
    row_number() OVER (ORDER BY longitude, latitude) AS poi_id,
    primary_types,
    longitude,
    latitude
FROM poi;

-- 3.2 创建充电站-POI 关联表（基于 1 公里内哈弗辛距离）
CREATE TABLE station_poi_relationship AS
SELECT
    i.tazid AS station_id,
    p.poi_id,
    p.primary_types,
    -- 哈弗辛距离近似值，单位：公里
    111.32 * SQRT(POWER(i.longitude - p.longitude, 2) + POWER(i.latitude - p.latitude, 2)) AS distance_km
FROM infrastructure i
CROSS JOIN poi_data_with_id p
WHERE 111.32 * SQRT(POWER(i.longitude - p.longitude, 2) + POWER(i.latitude - p.latitude, 2)) <= 1.0;

-- 3.3 POI 类型影响分析
WITH station_stats AS (
    SELECT
        o.station_id AS stat_station_id,
        AVG(o.occupancy_rate) AS avg_occupancy,
        SUM(v.volume_value) AS total_volume,
        COUNT(*) AS record_count
    FROM occupancy o
    JOIN volume v ON o.station_id = v.station_id AND o.time = v.time
    GROUP BY o.station_id
)
SELECT
    spr.primary_types AS poi_type,
    COUNT(DISTINCT spr.station_id) AS station_count,
    AVG(ss.avg_occupancy) AS avg_occupancy_rate,
    SUM(ss.total_volume) AS total_volume,
    SUM(ss.record_count) AS total_records
FROM station_poi_relationship spr
JOIN station_stats ss ON spr.station_id = ss.stat_station_id
GROUP BY spr.primary_types
ORDER BY total_volume DESC;
