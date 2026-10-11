# 2. 系统架构与设计

## 2.1 架构图

```
原始数据(CSV) -> HDFS分布式存储 -> Hive数据仓库与分析 -> MySQL结果存储
       ↓                ↓                  ↓                    ↓
  (Urbanev数据集)  (Hadoop 2.7.7)  (HiveQL查询/MapReduce)  (Sqoop导出)
                                                              ↓
                                              [Node.js + Express后端API]
                                                              ↓
                                          [Vue 3 + ECharts前端可视化]
```

## 2.2 分层说明

- **数据层**：原始 CSV 文件上传至 HDFS，Hive 建立外部表进行映射，构成星型模型数据仓库
- **计算层**：Hive 作为分布式 SQL 引擎，执行复杂的多表关联和聚合分析，
  底层默认由 MapReduce 引擎执行
- **服务层**：使用 Sqoop 将 Hive 分析结果表导出至 MySQL，
  Node.js + Express 提供 RESTful API 从 MySQL 读取数据
- **展示层**：Vue 3 单页应用负责渲染，通过 ECharts 绘制各类图表，
  Element Plus 提供 UI 组件，实现交互式数据可视化大屏

## 2.3 技术栈

| 层级 | 技术/工具 | 版本/说明 |
| :--- | :--- | :--- |
| **数据存储与计算** | Hadoop | 2.7.7（HDFS, YARN） |
| | Hive | 1.2.1 |
| | MapReduce | Hive 默认执行引擎 |
| **数据管理与服务** | MySQL | 5.7+（存储 Hive 元数据及分析结果） |
| | Sqoop | 1.4.7（Hive 到 MySQL 数据传输） |
| | Node.js | 18.x LTS |
| | Express | 4.x |
| **前端可视化** | Vue.js | 3.x（Composition API） |
| | TypeScript | 4.x |
| | Vite | 构建工具 |
| | Element Plus | Vue 3 UI 组件库 |
| | ECharts | 5.x |
| | Axios | HTTP 客户端 |
| **开发与部署** | CentOS | 7.x |
| | JDK | 1.8 |
| | Git | 版本控制 |
