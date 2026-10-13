const express = require('express');
const axios = require('axios');
const coinGeckoService = require('./coingecko.service');

const router = express.Router();

router.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

router.get('/sentiment', async (req, res, next) => {
  try {
    const response = await axios.get('https://api.alternative.me/fng/', {
      params: { limit: 1 },
      timeout: 10000,
    });
    res.json(response.data);
  } catch (error) {
    next(error);
  }
});

router.get('/coins/markets', async (req, res, next) => {
  try {
    const data = await coinGeckoService.get('/coins/markets', req.query);
    res.json(data);
  } catch (error) {
    next(error);
  }
});

router.get('/coins/:id/market-chart', async (req, res, next) => {
  try {
    const data = await coinGeckoService.get(
      `/coins/${encodeURIComponent(req.params.id)}/market_chart`,
      req.query,
    );
    res.json(data);
  } catch (error) {
    next(error);
  }
});

router.get('/coins/:id', async (req, res, next) => {
  try {
    const data = await coinGeckoService.get(
      `/coins/${encodeURIComponent(req.params.id)}`,
      req.query,
    );
    res.json(data);
  } catch (error) {
    next(error);
  }
});

router.get('/global', async (req, res, next) => {
  try {
    const data = await coinGeckoService.get('/global', req.query);
    res.json(data);
  } catch (error) {
    next(error);
  }
});

router.get('/simple/price', async (req, res, next) => {
  try {
    const data = await coinGeckoService.get('/simple/price', req.query);
    res.json(data);
  } catch (error) {
    next(error);
  }
});

module.exports = router;