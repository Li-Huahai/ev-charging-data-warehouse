# 6. 可视化平台部署与运行

## 6.1 后端服务（Node.js + Express）

### 初始化

```bash
mkdir backend && cd backend
npm init -y
npm install express mysql2 cors dotenv
npm install -D nodemon
```

### 项目结构

```
backend/
├── config/
│   └── database.js      # MySQL 连接池配置
├── routes/
│   └── data.js          # 数据 API 路由
├── .env                 # 环境变量（数据库密码等，不入库）
├── package.json
└── server.js            # 主入口
```

### 启动

```bash
npx nodemon server.js   # 开发模式
node server.js          # 生产模式
```

默认端口 `3001`，健康检查接口 `GET /health`。

## 6.2 前端应用（Vue 3 + TypeScript + ECharts）

### 初始化

```bash
npm create vue@latest frontend
cd frontend
npm install
npm install element-plus echarts axios
npm install -D @types/echarts
npm install @element-plus/icons-vue   # 可选
```

### 项目结构

```
frontend/
├── src/
│   ├── api/                 # 封装 API 请求
│   ├── components/charts/   # 各分析维度图表组件
│   ├── components/layout/   # Dashboard 大屏布局
│   ├── router/
│   ├── stores/              # Pinia 状态管理
│   ├── views/
│   ├── App.vue
│   └── main.ts
├── index.html
├── package.json
├── tsconfig.json
└── vite.config.ts
```

### 启动

```bash
cd frontend && npm run dev
# 访问 http://localhost:5173
```

## 6.3 API 接口清单

| 接口 | 说明 |
| :--- | :--- |
| `GET /api/temperature-analysis` | 温度影响分析 |
| `GET /api/regional-demand-analysis` | 区域热点 TOP20 |
| `GET /api/price-sensitivity-analysis` | 电价敏感性 |
| `GET /api/poi-impact-analysis` | POI 影响 |
| `GET /api/station-scale-analysis` | 站点规模分析 |
| `GET /api/spatiotemporal-analysis` | 时空复合分析 |

## 6.4 分析结果导出链路

```
Hive 分析结果
  → INSERT OVERWRITE LOCAL DIRECTORY（导出到本地）
  → hdfs dfs -get（下载）
  → 合并 part 文件 + 添加 CSV 表头
  → Sqoop export 到 MySQL
  → Express API 读取
```

详见 `scripts/export_results.sh` 与 `scripts/sqoop_export.sh`。
