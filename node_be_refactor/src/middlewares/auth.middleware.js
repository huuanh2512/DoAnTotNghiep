const jwt = require('jsonwebtoken');
const { sendError } = require('../utils/response.util');

const verifyToken = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return sendError(res, 401, 'Unauthorized: Missing or invalid token format', 'UNAUTHORIZED');
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded; // Gắn thông tin user (id, role) vào req để các controller sau dùng
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return sendError(res, 401, 'Unauthorized: Token has expired', 'TOKEN_EXPIRED');
    }
    return sendError(res, 401, 'Unauthorized: Invalid token', 'UNAUTHORIZED');
  }
};

const requireRole = (roles) => {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return sendError(res, 403, 'Forbidden: You do not have permission', 'FORBIDDEN');
    }
    next();
  };
};

module.exports = {
  verifyToken,
  requireRole
};