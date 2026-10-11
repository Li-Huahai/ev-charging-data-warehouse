<template>
  <div ref="chartRef" style="width: 100%; height: 400px;"></div>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount } from 'vue';
import * as echarts from 'echarts';
import { getTemperatureAnalysis } from '@/api'; // 封装的API函数

const chartRef = ref<HTMLElement>();
let chartInstance: echarts.ECharts | null = null;

onMounted(async () => {
  if (!chartRef.value) return;

  // 1. 初始化ECharts实例
  chartInstance = echarts.init(chartRef.value);

  // 2. 从后端获取数据
  const response = await getTemperatureAnalysis();
  if (response.success && response.data) {
    const chartData = response.data;

    // 3. 准备ECharts配置项
    const option: echarts.EChartsOption = {
      title: { text: '温度对充电需求的影响分析', left: 'center' },
      tooltip: { trigger: 'axis' },
      legend: { data: ['平均占用率', '平均充电量'], top: 30 },
      grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
      xAxis: {
        type: 'category',
        data: chartData.map(item => item.temperature + '°C'),
        name: '温度'
      },
      yAxis: [
        { type: 'value', name: '占用率(%)', position: 'left' },
        { type: 'value', name: '充电量(kWh)', position: 'right' }
      ],
      series: [
        {
          name: '平均占用率',
          type: 'line',
          yAxisIndex: 0,
          data: chartData.map(item => item.avg_occupancy_rate),
          smooth: true
        },
        {
          name: '平均充电量',
          type: 'line',
          yAxisIndex: 1,
          data: chartData.map(item => item.avg_volume_value),
          smooth: true
        }
      ]
    };

    // 4. 渲染图表
    chartInstance.setOption(option);
  }

  // 响应窗口大小变化
  window.addEventListener('resize', handleResize);
});

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize);
  chartInstance?.dispose();
});

function handleResize() {
  chartInstance?.resize();
}
</script>
