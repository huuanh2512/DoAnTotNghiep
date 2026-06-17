const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const userRepository = require('../repositories/user.repository');
const mailService = require('./mail.service');

class UserAuthService {  
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
    const existingUser = await userRepository.findByEmail(email);
    if (existingUser) {
      throw new Error('Email already exists');
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const createdUser = await userRepository.create({
      email: email,
      password: hashedPassword,
      profile: {
        name: profile.fullName || profile.name || '',
        phone: profile.phone || ''
      }
    });

    return {
      success: true,
      message: 'Registration successful',
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
    // Populate để lấy thông tin cơ sở nạp vào response cho Flutter
    const user = await userRepository.findByEmail(email);
    if (!user) {
      throw new Error('Invalid email or password');
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      throw new Error('Invalid email or password');
    }

    if (user.status === 'BANNED') {
      throw new Error('Account is banned');
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
