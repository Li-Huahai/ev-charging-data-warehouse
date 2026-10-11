# 3. 环境部署与数据准备

## 3.1 基础环境要求

- **操作系统**：CentOS 7.x（建议 3 台虚拟机搭建集群，或单机伪分布式）
- **Java**：JDK 1.8（`JAVA_HOME` 需正确配置）
- **Hadoop**：2.7.7（已配置并启动 HDFS、YARN 服务）
- **Hive**：1.2.1（配置使用 MySQL 存储元数据）
- **MySQL**：5.7+（用于 Hive 元数据和结果存储）
- **Node.js**：18.x LTS
- **MySQL 驱动**：`mysql-connector-java-5.1.49.jar`（需放入 Hive 的 `lib` 目录）

## 3.2 关键配置文件

完整示例见 `configs/` 目录：

- `configs/hdfs-site.xml`：DataNode/NameNode 数据目录、副本数（`dfs.replication`）
- `configs/hive-site.xml`：指定 `hive.execution.engine=mr`

## 3.3 性能优化参数

执行复杂分析前，在 Hive CLI 中设置以下参数提高性能：

```sql
-- Map/Reduce 任务内存
SET mapreduce.map.memory.mb=2048;
SET mapreduce.reduce.memory.mb=4096;
SET mapreduce.map.java.opts=-Xmx1800m;
SET mapreduce.reduce.java.opts=-Xmx3600m;

-- Map 端聚合与 Join 优化
SET hive.map.aggr=true;
SET hive.auto.convert.join=true;
SET hive.auto.convert.join.noconditionaltask.size=5000000;  -- 5MB

-- 控制 Reducer 数量
SET hive.exec.reducers.bytes.per.reducer=128000000;  -- 128MB/Reducer
SET hive.exec.reducers.max=200;

-- 处理数据倾斜
SET hive.groupby.skewindata=true;
SET hive.optimize.skewjoin=true;
SET hive.skewjoin.key=500000;  -- 超过 50 万行视为倾斜键
```

## 3.4 数据上传至 HDFS

见 `scripts/upload_to_hdfs.sh`，核心步骤：

```bash
# 1. 创建项目主目录
hdfs dfs -mkdir -p /user/hive/warehouse/urbanev_db

# 2. 为不同类型数据创建子目录
hdfs dfs -mkdir -p /user/hive/warehouse/urbanev_db/{weather_airport,weather_central,\
weather_combined,occupancy,price,infrastructure,duration,poi,volume,adjacency,distance}

# 3. 上传本地预处理 CSV
hdfs dfs -put ./local_data/occupancy_clean.csv /user/hive/warehouse/urbanev_db/occupancy/
hdfs dfs -put ./local_data/e_price_clean.csv /user/hive/warehouse/urbanev_db/price/
hdfs dfs -put ./local_data/s_price_clean.csv /user/hive/warehouse/urbanev_db/price/

# 4. 验证
hdfs dfs -ls -R /user/hive/warehouse/urbanev_db
hdfs dfs -cat /user/hive/warehouse/urbanev_db/occupancy/occupancy_clean.csv | head -n 3
```

## 3.5 故障排查

| 问题 | 排查方向 |
| :--- | :--- |
| Hive 连接 MySQL 失败 | 检查 `mysql-connector-java` 驱动是否在 Hive 的 `lib` 目录；检查 MySQL 是否允许远程连接 |
| MapReduce 任务失败 | 检查 `yarn.log` 与任务日志，常见原因为内存不足，调整 `mapreduce.map/reduce.memory.mb` |
| 数据关联结果为空 | 检查关联键（`time`、`station_id`）格式、类型、值是否完全一致，先跑数据验证查询 |
| 前端访问 API 跨域错误 | 确认后端 Express 已启用 CORS 中间件，且前端请求地址端口正确 |
