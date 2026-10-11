-- ============================================
-- 维度七：时间-价格-POI 交互分析
-- 目标：结合 POI 环境、电价水平和时间段进行复合分析
-- 前置：需先执行 sql/06_analysis_poi.sql 创建 station_poi_relationship
-- ============================================

USE urbanev_db;

-- 7.1 创建站点 POI 特征表
CREATE TABLE station_poi_features AS
SELECT
    station_id,
    COUNT(DISTINCT poi_id) AS poi_count,
    COUNT(CASE WHEN primary_types = 'food and beverage services' THEN 1 END) AS food_poi_count,
    COUNT(CASE WHEN primary_types = 'lifestyle services' THEN 1 END) AS lifestyle_poi_count,
    COUNT(CASE WHEN primary_types = 'business and residential' THEN 1 END) AS business_poi_count,
    AVG(distance_km) AS avg_distance_km
FROM station_poi_relationship
GROUP BY station_id;

-- 7.2 创建综合分析表
CREATE TABLE analysis_with_poi AS
SELECT
    a.*,
    p.poi_count,
    p.food_poi_count,
    p.lifestyle_poi_count,
    p.business_poi_count,
    p.avg_distance_km
FROM (
    SELECT
        w.time,
        w.temperature,
        w.weather_condition,
        e.station_id,
        e.electricity_price,
        o.occupancy_rate,
        v.volume_value
    FROM weather_combined w
    JOIN e_price e ON w.time = e.time
    JOIN occupancy o ON e.station_id = o.station_id AND e.time = o.time
    JOIN volume v ON e.station_id = v.station_id AND e.time = v.time
) a
LEFT JOIN station_poi_features p ON a.station_id = p.station_id;

-- 7.3 多因素聚合分析（POI 密度 × 电价水平）
SELECT
    CASE
        WHEN poi_count < 1000 THEN '低 POI密度'
        WHEN poi_count BETWEEN 1000 AND 3000 THEN '中 POI密度'
        ELSE '高 POI密度'
    END AS poi_density,
    CASE
        WHEN electricity_price < 0.8 THEN '超低电价'
        WHEN electricity_price BETWEEN 0.8 AND 1.0 THEN '低电价'
        WHEN electricity_price BETWEEN 1.0 AND 1.2 THEN '中电价'
        ELSE '高电价'
    END AS price_level,
    AVG(occupancy_rate) AS avg_occupancy,
    AVG(volume_value) AS avg_volume,
    COUNT(*) AS data_points
FROM analysis_with_poi
GROUP BY
    CASE
        WHEN poi_count < 1000 THEN '低 POI密度'
        WHEN poi_count BETWEEN 1000 AND 3000 THEN '中 POI密度'
        ELSE '高 POI密度'
    END,
    CASE
        WHEN electricity_price < 0.8 THEN '超低电价'
        WHEN electricity_price BETWEEN 0.8 AND 1.0 THEN '低电价'
        WHEN electricity_price BETWEEN 1.0 AND 1.2 THEN '中电价'
        ELSE '高电价'
    END
ORDER BY avg_volume DESC;
