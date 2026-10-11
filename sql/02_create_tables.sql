-- ============================================
-- 02. 核心外部表 DDL
-- LOCATION 路径需与 HDFS 上传目录一致
-- ============================================

USE urbanev_db;

-- 1. 充电站占用表
CREATE EXTERNAL TABLE IF NOT EXISTS occupancy (
    station_id STRING,
    time TIMESTAMP,
    occupancy_rate DOUBLE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/urbanev_db/occupancy'
TBLPROPERTIES ('skip.header.line.count'='1');

-- 2. 充电量数据表
CREATE EXTERNAL TABLE IF NOT EXISTS volume (
    time TIMESTAMP,
    station_id STRING,
    volume_value DOUBLE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/urbanev_db/volume'
TBLPROPERTIES ('skip.header.line.count'='1', 'serialization.null.format'='');

-- 3. 电费价格表
CREATE EXTERNAL TABLE IF NOT EXISTS e_price (
    time TIMESTAMP,
    station_id STRING,
    electricity_price DOUBLE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/urbanev_db/price'
TBLPROPERTIES ('skip.header.line.count'='1', 'serialization.null.format'='');

-- 4. 服务费价格表
CREATE EXTERNAL TABLE IF NOT EXISTS s_price (
    time TIMESTAMP,
    station_id STRING,
    service_price DOUBLE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/urbanev_db/price'
TBLPROPERTIES ('skip.header.line.count'='1', 'serialization.null.format'='');

-- 5. 基础设施表（充电站地理位置、规模）
CREATE EXTERNAL TABLE IF NOT EXISTS infrastructure (
    tazid STRING,
    longitude DOUBLE,
    latitude DOUBLE,
    charge_count INT,
    area DOUBLE,
    perimeter DOUBLE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/urbanev_db/infrastructure'
TBLPROPERTIES ('skip.header.line.count'='1');

-- 6. POI 兴趣点表
CREATE EXTERNAL TABLE IF NOT EXISTS poi (
    primary_types STRING,
    longitude DOUBLE,
    latitude DOUBLE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/urbanev_db/poi'
TBLPROPERTIES ('skip.header.line.count'='1');

-- 7. 综合天气表
--    注：weather_airport 与 weather_central 结构相同，仅 LOCATION 不同
CREATE EXTERNAL TABLE IF NOT EXISTS weather_combined (
    time TIMESTAMP,
    temperature DOUBLE,
    humidity DOUBLE,
    weather_condition STRING,
    wind_speed DOUBLE,
    precipitation DOUBLE,
    data_source STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/urbanev_db/weather_combined'
TBLPROPERTIES ('skip.header.line.count'='1');

-- 8. 邻接矩阵表
CREATE EXTERNAL TABLE IF NOT EXISTS adjacency (
    station_ids ARRAY<STRING>,
    adjacency_matrix ARRAY<INT>
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
COLLECTION ITEMS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/urbanev_db/adjacency';

-- 9. 距离矩阵表
CREATE EXTERNAL TABLE IF NOT EXISTS distance (
    station_ids ARRAY<STRING>,
    distance_matrix ARRAY<DOUBLE>
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
COLLECTION ITEMS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/urbanev_db/distance';
