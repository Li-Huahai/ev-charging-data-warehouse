# 5. 数据质量测试报告

建表后执行以下四类校验，确认数据成功加载且口径一致。

> 对应脚本：`sql/03_data_quality_check.sql`

## 5.1 测试项与口径

| 类别 | 校验项 | 判定口径 |
| :--- | :--- | :--- |
| **完整性** | 各表记录数 | 非空表记录数 > 0，且与源 CSV 行数一致 |
| **时间范围** | `MIN(time)` / `MAX(time)` | 各表时间区间一致，落在 2022-09 至 2023-02 |
| **值域区间** | `occupancy_rate` 极值 | 落在 [0, 1]，均值合理 |
| **跨表一致性** | 关联键匹配 | 同一时刻同一站点在 e_price / s_price / occupancy / volume / weather 均存在 |
| **唯一性** | 主键组合 | `(time, station_id)` 无重复 |

## 5.2 校验用例

### 用例 1：各表记录数统计

```sql
SELECT 'occupancy' AS table_name, COUNT(*) AS record_count FROM occupancy
UNION ALL SELECT 'volume', COUNT(*) FROM volume
UNION ALL SELECT 'e_price', COUNT(*) FROM e_price
UNION ALL SELECT 'infrastructure', COUNT(*) FROM infrastructure
UNION ALL SELECT 'poi', COUNT(*) FROM poi
UNION ALL SELECT 'weather_combined', COUNT(*) FROM weather_combined;
```

### 用例 2：时间范围检查

```sql
SELECT 'occupancy' AS tbl, MIN(time) AS start, MAX(time) AS end FROM occupancy
UNION ALL SELECT 'volume', MIN(time), MAX(time) FROM volume
UNION ALL SELECT 'weather_combined', MIN(time), MAX(time) FROM weather_combined;
```

### 用例 3：关键字段基本统计（值域校验）

```sql
SELECT
    COUNT(*) AS total_records,
    MIN(occupancy_rate) AS min_occ,
    MAX(occupancy_rate) AS max_occ,
    AVG(occupancy_rate) AS avg_occ
FROM occupancy;
```

### 用例 4：跨表一致性（关联键匹配）

以站点 `102`、`2022-09-01 00:00:00` 为例，验证该时刻该站点在五张表中均存在：

```sql
SELECT COUNT(*) AS match_count
FROM (SELECT time, station_id FROM e_price WHERE time='2022-09-01 00:00:00' AND station_id='102') e
JOIN (SELECT time, station_id FROM s_price WHERE time='2022-09-01 00:00:00' AND station_id='102') s
  ON e.time = s.time AND e.station_id = s.station_id
JOIN (SELECT time, station_id FROM occupancy WHERE time='2022-09-01 00:00:00' AND station_id='102') o
  ON e.time = o.time AND e.station_id = o.station_id
JOIN (SELECT time, station_id FROM volume WHERE time='2022-09-01 00:00:00' AND station_id='102') v
  ON e.time = v.time AND e.station_id = v.station_id
JOIN (SELECT time FROM weather_combined WHERE time='2022-09-01 00:00:00') w
  ON e.time = w.time;
```

**预期结果**：`match_count > 0`。若为 0 说明存在关联键缺失，
需检查时间格式与 `station_id` 类型。

## 5.3 常见问题与处理

| 问题 | 处理方式 |
| :--- | :--- |
| 关联结果为空 | 检查关联键格式、类型、值是否完全一致 |
| 时间字段解析异常 | 确认 CSV 时间格式与 TIMESTAMP 兼容 |
| 空串被当作有效值 | 通过 `serialization.null.format=''` 显式声明 |
