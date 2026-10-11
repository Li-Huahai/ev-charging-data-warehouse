-- ============================================
-- 维度二：电价敏感性分析
-- 目标：分析电价与服务费对充电需求的影响，计算需求价格弹性
-- ============================================

USE urbanev_db;

-- 2.1 峰谷时段电价弹性分析（电费）
SELECT
    CASE
        WHEN HOUR(e.time) BETWEEN 7 AND 9 THEN '早高峰'
        WHEN HOUR(e.time) BETWEEN 17 AND 19 THEN '晚高峰'
        ELSE '平峰时段'
    END AS time_period,
    ROUND(CORR(e.electricity_price, v.volume_value), 4) AS price_elasticity,
    COUNT(*) AS record_count,
    ROUND(AVG(e.electricity_price), 2) AS avg_electricity_price,
    ROUND(AVG(v.volume_value), 1) AS avg_volume
FROM e_price e
JOIN volume v ON e.time = v.time AND e.station_id = v.station_id
GROUP BY
    CASE
        WHEN HOUR(e.time) BETWEEN 7 AND 9 THEN '早高峰'
        WHEN HOUR(e.time) BETWEEN 17 AND 19 THEN '晚高峰'
        ELSE '平峰时段'
    END
ORDER BY price_elasticity;

-- 2.2 服务费弹性分析（按价格区间）
SELECT
    CASE
        WHEN service_price < 0.8 THEN '低价区(<0.8)'
        WHEN service_price BETWEEN 0.8 AND 1.2 THEN '中价区(0.8-1.2)'
        ELSE '高价区(>1.2)'
    END AS price_range,
    ROUND(CORR(s.service_price, v.volume_value), 4) AS elasticity,
    COUNT(*) AS record_count,
    ROUND(AVG(s.service_price), 2) AS avg_price,
    ROUND(AVG(v.volume_value), 1) AS avg_volume
FROM s_price s
JOIN volume v ON s.time = v.time AND s.station_id = v.station_id
GROUP BY
    CASE
        WHEN service_price < 0.8 THEN '低价区(<0.8)'
        WHEN service_price BETWEEN 0.8 AND 1.2 THEN '中价区(0.8-1.2)'
        ELSE '高价区(>1.2)'
    END
ORDER BY price_range;

-- 2.3 电价基础分布统计
SELECT
    'e_price' AS price_type,
    COUNT(*) AS total_records,
    MIN(electricity_price) AS min_price,
    MAX(electricity_price) AS max_price,
    AVG(electricity_price) AS avg_price,
    STDDEV(electricity_price) AS price_stddev
FROM e_price;
