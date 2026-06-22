const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const userRepository = require('../repositories/user.repository');
const mailService = require('./mail.service');

class UserAuthService {  
  _error(message, code, statusCode = 400, data = null) {
    const error = new Error(message);
    error.code = code;
    error.statusCode = statusCode;
    error.data = data;
    return error;
  }

  _otpPepper() {
    return process.env.EMAIL_OTP_PEPPER || process.env.JWT_SECRET;
  }

  _createOtp() {
    return crypto.randomInt(100000, 1000000).toString();
  }

  _hashOtp(otp) {
    const pepper = this._otpPepper();
    if (!pepper) throw this._error('Email verification is not configured', 'EMAIL_VERIFICATION_UNAVAILABLE', 503);
    return crypto.createHmac('sha256', pepper).update(otp).digest('hex');
  }

  _otpData() {
    const otp = this._createOtp();
    return {
      otp,
      hash: this._hashOtp(otp),
      expiresAt: new Date(Date.now() + 10 * 60 * 1000)
    };
  }

  _clearVerificationOtp() {
    return {
      emailVerificationOtpHash: null,
      emailVerificationExpiresAt: null,
      emailVerificationAttempts: 0,
      emailVerificationLockedUntil: null
    };
  }

  _cooldownRemaining(user) {
    if (!user.emailVerificationLastSentAt) return 0;
    return Math.max(0, 60 - Math.ceil((Date.now() - new Date(user.emailVerificationLastSentAt).getTime()) / 1000));
  }

  _formatUserResponse(user) {
    return {
      id: user._id.toString(),
      email: user.email,
      role: user.role,
      status: user.status,
      profile: {
        name: user.profile?.name || '',
        phone: user.profile?.phone || '',
        avatarUrl: user.profile?.avatar_url || ''
      },
      // Nếu có populate facility_id thì nhả ra, không thì null
      facility: user.facility_id ? {
        id: user.facility_id._id?.toString() || user.facility_id.toString(),
        name: user.facility_id.name || ''
      } : null
    };
  }

  async register(email, password, profile = {}) {
    email = email.trim().toLowerCase();
    const existingUser = await userRepository.findByEmail(email);
    if (existingUser) {
      if (existingUser.status === 'PENDING_OTP') {
        throw this._error(
          'Email chưa được xác thực. Bạn có thể gửi lại mã OTP.',
          'EMAIL_NOT_VERIFIED',
          409,
          { email: existingUser.email }
        );
      }
      throw new Error('Email already exists');
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const otpData = this._otpData();
    const createdUser = await userRepository.create({
      email: email,
      password: hashedPassword,
      status: 'PENDING_OTP',
      emailVerifiedAt: null,
      emailVerificationOtpHash: otpData.hash,
      emailVerificationExpiresAt: otpData.expiresAt,
      emailVerificationAttempts: 0,
      emailVerificationLastSentAt: new Date(),
      profile: {
        name: profile.fullName || profile.name || '',
        phone: profile.phone || ''
      }
    });

    try {
      await mailService.sendAccountVerificationOtpEmail(createdUser.email, otpData.otp);
    } catch (error) {
      // Keep a pending account for safe retry; never report a successful registration.
      console.error('[EmailVerification] Registration email delivery failed:', {
        message: error.message,
        code: error.code,
        errno: error.errno,
        syscall: error.syscall,
        address: error.address,
        port: error.port,
        command: error.command,
        responseCode: error.responseCode
      });
      await userRepository.updateById(createdUser._id, {
        ...this._clearVerificationOtp(),
        emailVerificationLastSentAt: null
      });
      throw this._error('Không thể gửi email xác thực. Vui lòng thử gửi lại.', 'EMAIL_DELIVERY_FAILED', 503, { email: createdUser.email });
    }

    return {
      success: true,
      message: 'Đăng ký thành công. Vui lòng kiểm tra email để lấy mã xác thực.',
      data: {
        userId: createdUser._id.toString(),
        email: createdUser.email,
        user: {
          id: createdUser._id.toString(),
          email: createdUser.email,
          role: createdUser.role,
          status: createdUser.status,
          profile: {
            name: createdUser.profile?.name || '',
            phone: createdUser.profile?.phone || ''
          }
        }
      }
    };
  }

  async signIn(email, password) {
    email = email.trim().toLowerCase();
    // Populate để lấy thông tin cơ sở nạp vào response cho Flutter
    const user = await userRepository.findByEmail(email);
    if (!user) {
      throw new Error('Email hoặc mật khẩu không đúng');
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      throw new Error('Email hoặc mật khẩu không đúng');
    }

    if (user.status === 'BANNED') {
      throw new Error('Account is banned');
    }

    if (user.status === 'PENDING_OTP' || !user.emailVerifiedAt) {
      throw this._error('Email chưa được xác thực', 'EMAIL_NOT_VERIFIED', 403, { email: user.email });
    }

    const accessToken = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    );

    const refreshTokenString = jwt.sign(
      { id: user._id },
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: '7d' }
    );

    const decodedAccess = jwt.decode(accessToken);

    return {
      result: {
        success: true,
        message: 'Sign in successful'
      },
      accessToken: accessToken,
      refreshToken: refreshTokenString,
      expiresAt: new Date(decodedAccess.exp * 1000).toISOString(),
      user: this._formatUserResponse(user)
    };
  }

  async refreshToken(refreshTokenString) {
    try {
      const decoded = jwt.verify(refreshTokenString, process.env.JWT_REFRESH_SECRET);
      
      const user = await userRepository.findById(decoded.id);
      if (!user) {
        throw new Error('User not found');
      }

      if (user.status === 'BANNED') {
        throw new Error('Account is banned');
      }
      if (user.status === 'PENDING_OTP' || !user.emailVerifiedAt) {
        throw this._error('Email chưa được xác thực', 'EMAIL_NOT_VERIFIED', 403, { email: user.email });
      }

      const newAccessToken = jwt.sign(
        { id: user._id, role: user.role },
        process.env.JWT_SECRET,
        { expiresIn: '1h' }
      );

      const decodedAccess = jwt.decode(newAccessToken);

      return {
        result: {
          success: true,
          message: 'Token refreshed successfully'
        },
        accessToken: newAccessToken,
        refreshToken: refreshTokenString,
        expiresAt: new Date(decodedAccess.exp * 1000).toISOString(),
        user: this._formatUserResponse(user)
      };
    } catch (error) {
      throw new Error('Invalid or expired refresh token');
    }
  }

  async signOut(userId) {
    return true;
  }

  async verifyEmail(email, otp) {
    const normalizedEmail = email.trim().toLowerCase();
    const user = await userRepository.findByEmail(normalizedEmail);
    if (!user || user.status !== 'PENDING_OTP') {
      throw this._error('Mã xác thực không hợp lệ hoặc đã hết hạn', 'INVALID_EMAIL_VERIFICATION_OTP');
    }
    if (user.emailVerificationLockedUntil && new Date(user.emailVerificationLockedUntil) > new Date()) {
      throw this._error('Mã xác thực đã bị khóa. Vui lòng gửi mã mới.', 'EMAIL_VERIFICATION_LOCKED');
    }
    if (!user.emailVerificationOtpHash || !user.emailVerificationExpiresAt || new Date(user.emailVerificationExpiresAt) <= new Date()) {
      throw this._error('Mã xác thực đã hết hạn. Vui lòng gửi mã mới.', 'EMAIL_VERIFICATION_EXPIRED');
    }

    const matches = crypto.timingSafeEqual(
      Buffer.from(user.emailVerificationOtpHash, 'hex'),
      Buffer.from(this._hashOtp(otp), 'hex')
    );
    if (!matches) {
      const attempts = user.emailVerificationAttempts + 1;
      const update = attempts >= 5
        ? { ...this._clearVerificationOtp(), emailVerificationLockedUntil: new Date(Date.now() + 10 * 60 * 1000) }
        : { emailVerificationAttempts: attempts };
      await userRepository.updateById(user._id, update);
      throw this._error(
        attempts >= 5 ? 'Bạn đã nhập sai quá nhiều lần. Vui lòng gửi mã mới.' : 'Mã xác thực không đúng.',
        attempts >= 5 ? 'EMAIL_VERIFICATION_LOCKED' : 'INVALID_EMAIL_VERIFICATION_OTP'
      );
    }

    const verifiedAt = new Date();
    const verifiedUser = await userRepository.findOneAndUpdate(
      {
        _id: user._id,
        status: 'PENDING_OTP',
        emailVerificationOtpHash: user.emailVerificationOtpHash,
        emailVerificationExpiresAt: { $gt: new Date() }
      },
      { status: 'ACTIVE', emailVerifiedAt: verifiedAt, ...this._clearVerificationOtp() }
    );
    if (!verifiedUser) throw this._error('Mã xác thực không còn hợp lệ. Vui lòng gửi mã mới.', 'INVALID_EMAIL_VERIFICATION_OTP');
    return { email: verifiedUser.email, emailVerifiedAt: verifiedAt };
  }

  async resendEmailVerification(email) {
    const normalizedEmail = email.trim().toLowerCase();
    console.info(`[EmailVerification] Resend requested for ${normalizedEmail}`);
    const user = await userRepository.findByEmail(normalizedEmail);
    // Deliberately neutral so this endpoint does not disclose account existence.
    if (!user || user.status !== 'PENDING_OTP') return { email: normalizedEmail, cooldownSeconds: 0, accepted: true };
    const cooldownSeconds = this._cooldownRemaining(user);
    if (cooldownSeconds > 0) {
      throw this._error('Vui lòng chờ trước khi gửi lại mã.', 'EMAIL_VERIFICATION_COOLDOWN', 429, { cooldownSeconds });
    }
    const otpData = this._otpData();
    try {
      await mailService.sendAccountVerificationOtpEmail(user.email, otpData.otp);
    } catch (error) {
      console.error('[EmailVerification] Resend email delivery failed:', {
        message: error.message,
        code: error.code,
        errno: error.errno,
        syscall: error.syscall,
        address: error.address,
        port: error.port,
        command: error.command,
        responseCode: error.responseCode
      });
      throw this._error('Không thể gửi email xác thực. Vui lòng thử lại.', 'EMAIL_DELIVERY_FAILED', 503);
    }
    await userRepository.updateById(user._id, {
      emailVerificationOtpHash: otpData.hash,
      emailVerificationExpiresAt: otpData.expiresAt,
      emailVerificationAttempts: 0,
      emailVerificationLockedUntil: null,
      emailVerificationLastSentAt: new Date()
    });
    return { email: user.email, cooldownSeconds: 60, accepted: true };
  }

  async forgotPassword(email) {
    const user = await userRepository.findByEmail(email);
    if (!user) {
      throw new Error('User not found');
    }

    // Generate a random 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    // Save to database
    await userRepository.updateById(user._id, {
      resetPasswordOtp: otp,
      resetPasswordOtpExpires: otpExpires
    });

    // Send verification email
    await mailService.sendVerificationEmail(email, otp);
    return true;
  }

  async resetPassword(email, otp, newPassword) {
    const user = await userRepository.findByEmail(email);
    if (!user) {
      throw new Error('User not found');
    }

    // Verify OTP
    if (!user.resetPasswordOtp || user.resetPasswordOtp !== otp) {
      throw new Error('Invalid verification code');
    }

    // Verify expiration
    if (user.resetPasswordOtpExpires && new Date() > user.resetPasswordOtpExpires) {
      throw new Error('Verification code has expired');
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    // Update password and clear OTP fields
    await userRepository.updateById(user._id, {
      password: hashedPassword,
      resetPasswordOtp: null,
      resetPasswordOtpExpires: null
    });

    // Send confirmation email
    try {
      await mailService.sendPasswordChangedEmail(email);
    } catch (error) {
      console.error('Failed to send password changed email:', error);
    }

    return true;
  }

  async changePassword(userId, otp, newPassword) {
    const user = await userRepository.findById(userId);
    if (!user) {
      const error = new Error('User not found');
      error.code = 'USER_NOT_FOUND';
      throw error;
    }

    if (!user.resetPasswordOtp || user.resetPasswordOtp !== otp) {
      const error = new Error('Invalid verification code');
      error.code = 'INVALID_OTP';
      throw error;
    }

    if (
      user.resetPasswordOtpExpires &&
      new Date() > user.resetPasswordOtpExpires
    ) {
      const error = new Error('Verification code has expired');
      error.code = 'EXPIRED_OTP';
      throw error;
    }

    const isSamePassword = await bcrypt.compare(newPassword, user.password);
    if (isSamePassword) {
      const error = new Error(
        'New password must be different from current password'
      );
      error.code = 'PASSWORD_UNCHANGED';
      throw error;
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);
    await userRepository.updateById(userId, {
      password: hashedPassword,
      resetPasswordOtp: null,
      resetPasswordOtpExpires: null
    });

    try {
      await mailService.sendPasswordChangedEmail(user.email);
    } catch (error) {
      console.error('Failed to send password changed email:', error);
    }

    return true;
  }
}

module.exports = new UserAuthService();
