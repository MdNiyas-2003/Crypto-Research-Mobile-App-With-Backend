const axios = require('axios');

const BASE_URL = 'https://api.coingecko.com/api/v3';
const REQUEST_TIMEOUT_MS = 10000;
const CACHE_TTL_MS = 30000;
const cache = new Map();

async function get(path, params = {}) {
  const cacheKey = `${path}?${new URLSearchParams(params).toString()}`;
  const cached = cache.get(cacheKey);

  if (cached && cached.expiresAt > Date.now()) {
    return cached.data;
  }

  cache.delete(cacheKey);

  const headers = {};
  if (process.env.COINGECKO_API_KEY) {
    headers['x-cg-demo-api-key'] = process.env.COINGECKO_API_KEY;
  }

  const response = await axios.get(`${BASE_URL}${path}`, {
    headers,
    params,
    timeout: REQUEST_TIMEOUT_MS,
  });

  cache.set(cacheKey, {
    data: response.data,
    expiresAt: Date.now() + CACHE_TTL_MS,
  });

  return response.data;
}

module.exports = { get };