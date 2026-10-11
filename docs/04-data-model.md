# 4. 数据模型设计

## 4.1 数据库创建

```sql
CREATE DATABASE IF NOT EXISTS urbanev_db
COMMENT '深圳电动汽车充电数据分析数据库'
LOCATION '/user/hive/warehouse/urbanev_db';

USE urbanev_db;
```

## 4.2 表结构设计

全部为 **外部表**（`EXTERNAL TABLE`），`LOCATION` 指向 HDFS 上传目录，
通过 `skip.header.line.count` 跳过 CSV 表头。

### 事实表

| 表名 | 主要字段 | 说明 |
| :--- | :--- | :--- |
| `occupancy` | `station_id`, `time`, `occupancy_rate` | 站点分时占用率 |
| `volume` | `time`, `station_id`, `volume_value` | 站点分时充电量 |
| `duration` | — | 充电会话持续时间 |

### 维度表

| 表名 | 主要字段 | 说明 |
| :--- | :--- | :--- |
| `e_price` | `time`, `station_id`, `electricity_price` | 峰谷电价 |
| `s_price` | `time`, `station_id`, `service_price` | 服务费 |
| `infrastructure` | `tazid`, `longitude`, `latitude`, `charge_count`, `area`, `perimeter` | 站点地理与规模 |
| `poi` | `primary_types`, `longitude`, `latitude` | 周边兴趣点 |
| `weather_combined` | `time`, `temperature`, `humidity`, `weather_condition`, `wind_speed`, `precipitation`, `data_source` | 综合气象 |
| `weather_airport` / `weather_central` | 同上 | 分站气象，仅 LOCATION 不同 |
| `adjacency` | `station_ids ARRAY<STRING>`, `adjacency_matrix ARRAY<INT>` | 邻接矩阵 |
| `distance` | `station_ids ARRAY<STRING>`, `distance_matrix ARRAY<DOUBLE>` | 距离矩阵 |

### 派生表（分析过程中创建）

| 表名 | 用途 |
| :--- | :--- |
| `temp_weather` | 温度分区临时表，优化关联性能 |
| `poi_data_with_id` | POI 添加唯一 ID 的视图 |
| `station_poi_relationship` | 站点-POI 1km 内关联关系 |
| `station_poi_features` | 站点 POI 密度特征 |
| `analysis_with_poi` | 含 POI 特征的综合分析表 |

## 4.3 关键设计点

1. **关联键统一**：所有事实表与维度表通过 `time`（TIMESTAMP）+ `station_id`（STRING）关联
2. **空值处理**：`serialization.null.format=''` 显式声明空串为 NULL
3. **空间关联**：POI 与站点通过哈弗辛距离近似计算
   `111.32 * SQRT(Δlon² + Δlat²)`，取 1km 内
4. **集合类型**：邻接/距离矩阵使用 `ARRAY` + `COLLECTION ITEMS TERMINATED BY ','`

完整 DDL 见 `sql/02_create_tables.sql`。
