function errorMiddleware(error, req, res, next) {
  if (res.headersSent) {
    return next(error);
  }

  const upstreamStatus = error.response && error.response.status;
  const status = upstreamStatus === 429 ? 429 : 502;
  const message = error.code === 'ECONNABORTED'
    ? 'Market data provider request timed out'
    : 'Unable to retrieve data from the upstream provider';

  console.error('API request failed:', error.message);
  res.status(status).json({ error: message });
}

module.exports = errorMiddleware;