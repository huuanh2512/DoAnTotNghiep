const express = require('express');
const authController = require('../controllers/auth.controller');
const authMiddleware = require('../middlewares/auth.middleware');
const router = express.Router();

router.post('/register', authController.register);
router.post('/sign-in', authController.signIn);
router.post('/refresh-token', authController.refreshToken);
router.post('/sign-out', authController.signOut);
router.post('/forgot-password', authController.forgotPassword);
router.post('/reset-password', authController.resetPassword);
router.post(
  '/change-password',
  authMiddleware.verifyToken,
  authMiddleware.requireRole(['CUSTOMER']),
  authController.changePassword
);

module.exports = router;
