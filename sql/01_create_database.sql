-- ============================================
-- 01. 创建数据库
-- 项目：深圳电动汽车充电需求时空分析
-- ============================================

CREATE DATABASE IF NOT EXISTS urbanev_db
COMMENT '深圳电动汽车充电数据分析数据库'
LOCATION '/user/hive/warehouse/urbanev_db';

USE urbanev_db;
