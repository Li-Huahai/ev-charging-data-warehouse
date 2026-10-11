const express = require('express');
const router = express.Router();
const db = require('../config/database');

// 获取温度影响分析结果
router.get('/temperature-analysis', async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT temperature, avg_occupancy_rate, avg_volume_value FROM temperature_impact ORDER BY temperature'
    );
    res.json({ success: true, data: rows });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 获取区域热点分析结果
router.get('/regional-demand-analysis', async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT zone_id, total_volume, station_count FROM regional_hotspots ORDER BY total_volume DESC LIMIT 20'
    );
    res.json({ success: true, data: rows });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 更多接口：
// /api/price-sensitivity-analysis
// /api/poi-impact-analysis
// /api/station-scale-analysis
// /api/spatiotemporal-analysis

module.exports = router;
