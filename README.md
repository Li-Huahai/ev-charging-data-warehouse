# 基于 Hive 的深圳电动汽车充电需求时空分析与可视化平台

> EV Charging Demand Spatiotemporal Analysis & Visualization Platform (Shenzhen)
> 本科毕业设计 | 大数据工程技术 | 2025.10 - 2026.03

[中文](#项目简介) | [English](#english)

---

## 项目简介

针对深圳市电动汽车充电行为的大数据分析与可视化系统。面对海量、多源、异构的充电数据，
构建了一套从 **数据采集 → 分布式存储与计算（Hadoop/Hive）→ 多维度分析 → Web 交互式可视化**
的完整技术栈，挖掘充电需求的时空规律及多因素耦合影响。

### 核心目标

1. **数据处理**：HDFS 存储海量原始数据，Hive 构建企业级数据仓库，实现高效数据管理与批处理分析
2. **深度分析**：从**时间、空间、价格、气温、兴趣点(POI)、充电站规模**六个维度，量化分析影响充电需求的关键因素及其交互作用
3. **决策支持**：前后端分离的 Web 可视化平台，为城市规划、设施运营、电网调度提供数据洞察

### 完成情况

已完成全部设计与实现，包含完整的八大维度分析流程与可交互的可视化前端。

---

## 技术栈

| 层级 | 技术 / 工具 | 版本 |
| :--- | :--- | :--- |
| **数据存储与计算** | Hadoop (HDFS, YARN) | 2.7.7 |
| | Hive | 1.2.1 |
| | MapReduce | Hive 默认执行引擎 |
| **数据管理与服务** | MySQL | 5.7+ |
| | Sqoop | 1.4.7 |
| | Node.js / Express | 18.x LTS / 4.x |
| **前端可视化** | Vue 3 (Composition API) | 3.x |
| | TypeScript / Vite | 4.x |
| | Element Plus / ECharts / Axios | 5.x |
| **开发与部署** | CentOS / JDK / Git | 7.x / 1.8 |

---

## 系统架构

```
原始数据(CSV) → HDFS 分布式存储 → Hive 数据仓库与分析 → MySQL 结果存储
   (Urbanev)      (Hadoop 2.7.7)    (HiveQL / MapReduce)     (Sqoop 导出)
                                                                  ↓
                                                  [Node.js + Express 后端 API]
                                                                  ↓
                                              [Vue 3 + ECharts 前端可视化]
```

- **数据层**：原始 CSV 上传至 HDFS，Hive 建立外部表映射，构成星型模型数据仓库
- **计算层**：Hive 作为分布式 SQL 引擎，执行复杂多表关联与聚合分析
- **服务层**：Sqoop 导出分析结果至 MySQL，Node.js + Express 提供 RESTful API
- **展示层**：Vue 3 单页应用 + ECharts 绘制图表，Element Plus 提供 UI 组件

---

## 数据集

使用 **Urbanev 开放基准数据集**（Dryad 平台），8 大类 14 个文件：

| 类别 | 文件 | 描述 |
| :--- | :--- | :--- |
| 充电需求 | `volume.csv` | 各站点分时充电量 |
| 充电站状态 | `occupancy.csv` | 各站点分时占用率 |
| 价格数据 | `e_price.csv`, `s_price.csv` | 峰谷电价、服务费 |
| 气象数据 | `weather_airport.csv`, `weather_central.csv` | 机场与中心站气象数据 |
| 基础设施 | `infrastructure.csv` | 充电站地理位置、充电桩数量 |
| 兴趣点 | `poi.csv` | 周边兴趣点（餐饮、商业、生活服务等） |
| 空间关系 | `adjacency.csv`, `distance.csv` | 邻接矩阵与距离矩阵 |
| 充电时长 | `duration.csv` | 充电会话持续时间 |

> 原始数据集体积约 7GB，未纳入仓库。获取方式见 `scripts/upload_to_hdfs.sh` 说明。

---

## 八大分析维度

| # | 维度 | 说明 | 脚本 |
| :--- | :--- | :--- | :--- |
| 1 | 温度影响 | 量化气温对占用率的影响 | `sql/04_analysis_temperature.sql` |
| 2 | 电价敏感性 | 计算峰谷时段需求价格弹性（CORR） | `sql/05_analysis_price_elasticity.sql` |
| 3 | POI 影响 | 基于哈弗辛距离构建站点-POI 关联（1km 内） | `sql/06_analysis_poi.sql` |
| 4 | 区域热点 | TAZ 级别需求聚合与排名 | `sql/07_analysis_regional_hotspot.sql` |
| 5 | 充电桩规模 | 站点分级与分时行为差异 | `sql/08_analysis_station_scale.sql` |
| 6 | 时间-价格-气温耦合 | 三因素复合影响 | `sql/09_analysis_time_price_weather.sql` |
| 7 | 时间-价格-POI 交互 | 密度 × 电价双因素聚合 | `sql/10_analysis_time_price_poi.sql` |
| 8 | 时空复合 | 生成热力图时空矩阵 | `sql/11_analysis_spatiotemporal.sql` |

---

## 快速开始

```bash
# 1. 创建数据库与表
hive -f sql/01_create_database.sql
hive -f sql/02_create_tables.sql

# 2. 数据质量验证
hive -f sql/03_data_quality_check.sql

# 3. 执行分析（以温度维度为例）
hive -f sql/04_analysis_temperature.sql

# 4. 启动可视化平台
cd backend && npm install && node server.js
cd frontend && npm install && npm run dev
```

详细部署步骤见 `docs/03-environment-setup.md` 与 `docs/06-visualization-deployment.md`。

---

## 目录说明

```
.
├── docs/        项目文档：概述、架构、环境部署、数据模型、测试报告、总结
├── sql/         建库建表、数据质量校验、八大维度分析脚本
├── scripts/     HDFS 上传、结果导出、Sqoop 导出脚本
├── configs/     Hadoop / Hive 核心配置示例
├── backend/     Node.js + Express 后端服务
└── frontend/    Vue 3 + TypeScript + ECharts 前端
```

---

## English

Big-data analytics and visualization platform for EV charging behavior in Shenzhen.
Built an end-to-end pipeline from data ingestion, distributed storage and computation
(Hadoop/Hive), multi-dimensional analysis, to interactive web visualization.

**Highlights**
- Three-layer Hive data warehouse (ODS → DWD → DWS) with star schema modeling
- 8 analysis dimensions: temperature, price elasticity, POI, regional hotspots,
  station scale, time-price-weather coupling, time-price-POI interaction, spatiotemporal
- Performance tuning: partition pruning, predicate pushdown, map-side aggregation,
  skew join optimization
- Front-end: Vue 3 + TypeScript + ECharts; Back-end: Node.js + Express + MySQL

**Dataset**: Urbanev open benchmark dataset (Dryad), ~7GB, 8 categories / 14 files.
Raw data is not included in this repository due to size.

---

## Author

李华海 (Li Huahai) | 江西软件职业技术大学 软件工程学院
指导教师：刘秋华

## License

MIT
