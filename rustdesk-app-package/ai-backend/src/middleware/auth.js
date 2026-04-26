const jwt = require('jsonwebtoken');
const logger = require('../utils/logger');

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

function authMiddleware(req, res, next) {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader) {
      return res.status(401).json({ error: 'No authorization header' });
    }

    const token = authHeader.startsWith('Bearer ')
      ? authHeader.slice(7)
      : authHeader;

    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const decoded = jwt.verify(token, JWT_SECRET);

    req.user = {
      id: decoded.sub || decoded.userId,
      sessionId: decoded.sessionId,
      permissions: decoded.permissions || [],
    };

    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      logger.warn('Token expired', { error: error.message });
      return res.status(401).json({ error: 'Token expired' });
    }

    if (error.name === 'JsonWebTokenError') {
      logger.warn('Invalid token', { error: error.message });
      return res.status(401).json({ error: 'Invalid token' });
    }

    logger.error('Auth middleware error:', error);
    return res.status(500).json({ error: 'Authentication error' });
  }
}

function optionalAuth(req, res, next) {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader) {
      return next();
    }

    const token = authHeader.startsWith('Bearer ')
      ? authHeader.slice(7)
      : authHeader;

    if (!token) {
      return next();
    }

    const decoded = jwt.verify(token, JWT_SECRET);

    req.user = {
      id: decoded.sub || decoded.userId,
      sessionId: decoded.sessionId,
      permissions: decoded.permissions || [],
    };

    next();
  } catch (error) {
    next();
  }
}

function requirePermission(permission) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Not authenticated' });
    }

    if (!req.user.permissions.includes(permission)) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }

    next();
  };
}

module.exports = authMiddleware;
module.exports.optionalAuth = optionalAuth;
module.exports.requirePermission = requirePermission;