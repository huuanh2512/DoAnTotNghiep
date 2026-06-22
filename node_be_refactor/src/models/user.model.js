const mongoose = require('mongoose');

const userProfileSchema = new mongoose.Schema({
  name: {
    type: String,
    default: ''
  },
  phone: {
    type: String,
    default: ''
  },
  avatar_url: {
    type: String,
    default: ''
  }
}, { _id: false });

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true
  },
  password: {
    type: String,
    required: false,
    default: null
  },
  firebaseUid: { type: String, unique: true, sparse: true, default: null },
  role: {
    type: String,
    enum: ['CUSTOMER', 'STAFF', 'ADMIN'],
    default: 'CUSTOMER'
  },
  status: {
    type: String,
    enum: ['PENDING_OTP', 'PENDING_EMAIL', 'ACTIVE', 'INACTIVE', 'BANNED'],
    default: 'PENDING_OTP'
  },
  profile: {
    type: userProfileSchema,
    default: () => ({})
  },
  facility_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Facility',
    default: null
  },
  fcmTokens: [{ type: String }],
  resetPasswordOtp: {
    type: String,
    default: null
  },
  resetPasswordOtpExpires: {
    type: Date,
    default: null
  },
  emailVerifiedAt: {
    type: Date,
    default: null
  },
  authMigrationStatus: { type: String, default: null },
  authMigratedAt: { type: Date, default: null },
  migration: {
    testActivationAt: { type: Date, default: null },
    testActivationSource: { type: String, default: null }
  },
  emailVerificationOtpHash: {
    type: String,
    default: null
  },
  emailVerificationExpiresAt: {
    type: Date,
    default: null
  },
  emailVerificationAttempts: {
    type: Number,
    default: 0,
    min: 0
  },
  emailVerificationLastSentAt: {
    type: Date,
    default: null
  },
  emailVerificationLockedUntil: {
    type: Date,
    default: null
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
});

const User = mongoose.model('User', userSchema);

module.exports = User;
