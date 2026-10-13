require('dotenv').config();

const express = require('express');
const routes = require('./routes');
const errorMiddleware = require('./error.middleware');

const app = express();
const port = Number(process.env.PORT) || 3000;

app.use(express.json());
app.use('/api', routes);
app.use(errorMiddleware);

app.listen(port, () => {
  console.log(`Mini Crypto API is running on port ${port}`);
});