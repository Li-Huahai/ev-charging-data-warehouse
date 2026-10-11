-- ============================================
-- 维度五：充电桩规模分析
-- 目标：分析不同规模充电站的运营效率与需求模式差异
-- ============================================

USE urbanev_db;

-- 5.1 站点规模分级与基础统计
SELECT
    CASE
        WHEN charge_count <= 20 THEN '小型站点(≤20桩)'
        WHEN charge_count BETWEEN 21 AND 50 THEN '中型站点(21-50桩)'
        WHEN charge_count BETWEEN 51 AND 100 THEN '大型站点(51-100桩)'
        ELSE '超大型站点(>100桩)'
    END AS station_size,
    COUNT(*) AS station_count,
    AVG(charge_count) AS avg_charge_count,
    MIN(charge_count) AS min_charge_count,
    MAX(charge_count) AS max_charge_count
FROM infrastructure
GROUP BY
    CASE
        WHEN charge_count <= 20 THEN '小型站点(≤20桩)'
        WHEN charge_count BETWEEN 21 AND 50 THEN '中型站点(21-50桩)'
        WHEN charge_count BETWEEN 51 AND 100 THEN '大型站点(51-100桩)'
        ELSE '超大型站点(>100桩)'
    END
ORDER BY station_size;

-- 5.2 不同规模站点的分时行为分析
SELECT
    CASE
        WHEN i.charge_count <= 20 THEN '小型站点(≤20桩)'
        WHEN i.charge_count BETWEEN 21 AND 50 THEN '中型站点(21-50桩)'
        WHEN i.charge_count BETWEEN 51 AND 100 THEN '大型站点(51-100桩)'
        ELSE '超大型站点(>100桩)'
    END AS station_size,
    HOUR(o.time) AS hour_of_day,
    AVG(o.occupancy_rate) AS avg_occupancy_rate,
    AVG(v.volume_value) AS avg_hourly_volume
FROM infrastructure i
JOIN occupancy o ON i.tazid = o.station_id
JOIN volume v ON i.tazid = v.station_id AND o.time = v.time
GROUP BY
    CASE
        WHEN i.charge_count <= 20 THEN '小型站点(≤20桩)'
        WHEN i.charge_count BETWEEN 21 AND 50 THEN '中型站点(21-50桩)'
        WHEN i.charge_count BETWEEN 51 AND 100 THEN '大型站点(51-100桩)'
        ELSE '超大型站点(>100桩)'
    END,
    HOUR(o.time)
ORDER BY station_size, hour_of_day;
