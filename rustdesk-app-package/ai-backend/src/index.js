require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const logger = require('./utils/logger');
const ocrRoutes = require('./routes/ocr');
const chatRoutes = require('./routes/chat');
const codeRoutes = require('./routes/code');
const summarizeRoutes = require('./routes/summarize');
const translateRoutes = require('./routes/translate');
const { optionalAuth, authMiddleware } = require('./middleware/auth');
const errorHandler = require('./middleware/errorHandler');

const app = express();
const PORT = process.env.PORT || 8080;
const IS_DEV = process.env.NODE_ENV !== 'production';

app.use(helmet());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS || '*',
  credentials: true,
}));

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: { error: 'Too many requests, please try again later.' },
});
app.use('/api/', limiter);

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

app.use((req, res, next) => {
  logger.info(`${req.method} ${req.path}`, {
    ip: req.ip,
    userAgent: req.get('user-agent'),
  });
  next();
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

const auth = IS_DEV ? optionalAuth : authMiddleware;

app.use('/api/ai/ocr', auth, ocrRoutes);
app.use('/api/ai/chat', auth, chatRoutes);
app.use('/api/ai/code-review', auth, codeRoutes);
app.use('/api/ai/summarize', auth, summarizeRoutes);
app.use('/api/ai/translate', auth, translateRoutes);

app.use(errorHandler);

app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

const server = app.listen(PORT, () => {
  logger.info(`AI Backend Service running on port ${PORT}`);
  logger.info(`Environment: ${process.env.NODE_ENV || 'development'}`);
  if (IS_DEV) {
    logger.info('Development mode: Auth is optional for testing');
  }
  logger.info(`DeepSeek API: ${process.env.DEEPSEEK_API_KEY ? 'configured' : 'NOT configured'}`);
  logger.info(`Qianwen API: ${process.env.QIANWEN_API_KEY ? 'configured' : 'NOT configured'}`);
});

process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  server.close(() => {
    logger.info('Server closed');
    process.exit(0);
  });
});

process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception:', error);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

module.exports = app;