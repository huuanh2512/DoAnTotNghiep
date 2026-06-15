const userRepository = require('../repositories/user.repository');

class UserService {
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
      facility: user.facility_id ? {
        id: user.facility_id._id?.toString() || user.facility_id.toString(),
        name: user.facility_id.name || ''
      } : null,
      createdAt: user.created_at ? new Date(user.created_at).toISOString() : null
    };
  }

  async queryUsers(filters, skip = 0, limit = 20) {
    const query = {};

    if (filters.userId) query._id = filters.userId;
    if (filters.email) query.email = new RegExp(filters.email, 'i');
    if (filters.role) query.role = filters.role;
    if (filters.status) query.status = filters.status;
    if (filters.facilityId) query.facility_id = filters.facilityId;

    const [users, total] = await Promise.all([
      userRepository.findMany(query, parseInt(skip), parseInt(limit)),
      userRepository.count(query)
    ]);

    return {
      items: users.map(user => this._formatUserResponse(user)),
      total: total
    };
  }

  async getUserProfile(userId) {
    const user = await userRepository.findById(userId);
    if (!user) throw new Error('User not found');
    return { user: this._formatUserResponse(user) };
  }

  async updateUserProfile(userId, profileData, facilityName) {
    const user = await userRepository.findById(userId);
    if (!user) throw new Error('User not found');

    const currentProfile = user.profile || {};
    const newProfile = {
      name: profileData.name !== undefined ? profileData.name : currentProfile.name,
      phone: profileData.phone !== undefined ? profileData.phone : currentProfile.phone,
      avatar_url: profileData.avatarUrl !== undefined ? profileData.avatarUrl : currentProfile.avatar_url
    };

    const updatedUser = await userRepository.updateById(userId, { profile: newProfile });
    return { user: this._formatUserResponse(updatedUser) };
  }

  async updateUserRole(userId, role) {
    const validRoles = ['CUSTOMER', 'STAFF', 'ADMIN'];
    if (!validRoles.includes(role)) throw new Error('Invalid role');

    const user = await userRepository.updateById(userId, { role });
    if (!user) throw new Error('User not found');
    return true;
  }

  async updateUserStatus(userId, status) {
    const validStatuses = ['PENDING_OTP', 'ACTIVE', 'INACTIVE', 'BANNED'];
    if (!validStatuses.includes(status)) throw new Error('Invalid status');

    const user = await userRepository.updateStatus(userId, status);
    if (!user) throw new Error('User not found');
    return true;
  }

  async assignUserFacility(userId, facilityId) {
    const user = await userRepository.updateById(userId, { facility_id: facilityId });
    if (!user) throw new Error('User not found');
    return true;
  }
}

module.exports = new UserService();