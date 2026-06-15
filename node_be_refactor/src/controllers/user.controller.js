const userService = require('../services/user.service');
const { sendSuccess, sendError } = require('../utils/response.util');

const queryUsers = async (req, res) => {
  try {
    const { skip, limit, ...filters } = req.query;
    const result = await userService.queryUsers(filters, skip, limit);
    return res.status(200).json({
      success: true,
      message: 'Users retrieved successfully',
      items: result.items,
      total: result.total
    });
  } catch (error) {
    return sendError(res, 500, error.message, 'QUERY_ERROR');
  }
};

const getUserProfile = async (req, res) => {
  try {
    const { id } = req.params;
    const result = await userService.getUserProfile(id);
    return res.status(200).json({
      success: true,
      message: 'Profile retrieved successfully',
      user: result.user
    });
  } catch (error) {
    return sendError(res, 404, error.message, 'NOT_FOUND');
  }
};

const updateUserProfile = async (req, res) => {
  try {
    const { id } = req.params;
    const { profile, facilityName } = req.body;
    
    // Nếu không phải ADMIN thì chỉ được tự sửa profile của mình
    if (req.user.role !== 'ADMIN' && req.user.id !== id) {
      return sendError(res, 403, 'Forbidden: You can only update your own profile', 'FORBIDDEN');
    }

    const result = await userService.updateUserProfile(id, profile, facilityName);
    return res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      user: result.user
    });
  } catch (error) {
    return sendError(res, 400, error.message, 'UPDATE_ERROR');
  }
};

const updateUserRole = async (req, res) => {
  try {
    const { id } = req.params;
    const { role } = req.body;
    await userService.updateUserRole(id, role);
    return sendSuccess(res, null, 'User role updated successfully', 'ROLE_UPDATED');
  } catch (error) {
    return sendError(res, 400, error.message, 'UPDATE_ERROR');
  }
};

const updateUserStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    await userService.updateUserStatus(id, status);
    return sendSuccess(res, null, 'User status updated successfully', 'STATUS_UPDATED');
  } catch (error) {
    return sendError(res, 400, error.message, 'UPDATE_ERROR');
  }
};

const assignUserFacility = async (req, res) => {
  try {
    const { id } = req.params;
    const { facilityId } = req.body;
    await userService.assignUserFacility(id, facilityId);
    return sendSuccess(res, null, 'Facility assigned successfully', 'FACILITY_ASSIGNED');
  } catch (error) {
    return sendError(res, 400, error.message, 'ASSIGN_ERROR');
  }
};

module.exports = {
  queryUsers,
  getUserProfile,
  updateUserProfile,
  updateUserRole,
  updateUserStatus,
  assignUserFacility
};