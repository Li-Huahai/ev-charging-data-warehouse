-- ============================================
-- 维度六：时间-价格-气温耦合分析
-- 目标：综合分析时段、电价水平和温度区间对充电行为的复合影响
-- ============================================

USE urbanev_db;

SELECT
    HOUR(o.time) AS hour_of_day,
    CASE
        WHEN e.electricity_price < 1.0 THEN '低价电费'
        WHEN e.electricity_price BETWEEN 1.0 AND 1.5 THEN '中价电费'
        ELSE '高价电费'
    END AS electricity_category,
    CASE
        WHEN w.temperature < 10 THEN '低温(<10°C)'
        WHEN w.temperature BETWEEN 10 AND 25 THEN '舒适温度(10-25°C)'
        ELSE '高温(>25°C)'
    END AS temperature_category,
    AVG(o.occupancy_rate) AS avg_occupancy,
    AVG(v.volume_value) AS avg_volume,
    COUNT(*) AS data_points
FROM occupancy o
JOIN e_price e ON o.time = e.time AND o.station_id = e.station_id
JOIN weather_combined w ON o.time = w.time
JOIN volume v ON o.time = v.time AND o.station_id = v.station_id
WHERE o.time BETWEEN '2022-09-01' AND '2023-02-28'
GROUP BY
    HOUR(o.time),
    CASE
        WHEN e.electricity_price < 1.0 THEN '低价电费'
        WHEN e.electricity_price BETWEEN 1.0 AND 1.5 THEN '中价电费'
        ELSE '高价电费'
    END,
    CASE
        WHEN w.temperature < 10 THEN '低温(<10°C)'
        WHEN w.temperature BETWEEN 10 AND 25 THEN '舒适温度(10-25°C)'
        ELSE '高温(>25°C)'
    END
ORDER BY avg_occupancy DESC;
