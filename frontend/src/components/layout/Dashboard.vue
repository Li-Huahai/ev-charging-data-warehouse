<template>
  <div class="dashboard-container">
    <el-row :gutter="20">
      <!-- 左侧指标卡 -->
      <el-col :span="6">
        <el-card class="metric-card">
          <template #header>今日总充电量</template>
          <div class="metric-value">1,245,689 kWh</div>
        </el-card>
      </el-col>
      <!-- ... 其他指标卡 -->
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px;">
      <!-- 深圳地图热力图 -->
      <el-col :span="12">
        <el-card>
          <template #header>深圳充电需求空间分布热力图</template>
          <RegionalHotMap />
        </el-card>
      </el-col>

      <!-- 温度影响折线图 -->
      <el-col :span="12">
        <el-card>
          <template #header>温度影响分析</template>
          <TemperatureChart />
        </el-card>
      </el-col>
    </el-row>

    <!-- 更多分析图表行... -->
  </div>
</template>

<script setup lang="ts">
import RegionalHotMap from '@/components/charts/RegionalHotMap.vue';
import TemperatureChart from '@/components/charts/TemperatureChart.vue';
</script>

<style scoped>
.dashboard-container {
  padding: 20px;
  background-color: #f5f7fa;
}
.metric-card {
  text-align: center;
}
.metric-value {
  font-size: 24px;
  font-weight: bold;
  color: #409eff;
}
</style>
