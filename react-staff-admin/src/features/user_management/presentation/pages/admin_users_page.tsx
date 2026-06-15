import React, { useState, useEffect } from 'react';
import { Table, Button, Card, Modal, Form, Input, Select, message, Typography, Tag, Avatar } from 'antd';
import { UserOutlined, UserAddOutlined, LockOutlined, UnlockOutlined } from '@ant-design/icons';
import { authStorage, UserSession } from '../../../../core/utils/auth_storage';
import { MockFacility } from '../../../../core/network/mock_db';
import { apiClient } from '../../../../core/network/api_client';

const { Title, Text } = Typography;

const AdminUsersPage: React.FC = () => {
  const [users, setUsers] = useState<UserSession[]>([]);
  const [facilities, setFacilities] = useState<MockFacility[]>([]);
  const [loading, setLoading] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [registering, setRegistering] = useState(false);
  const [form] = Form.useForm();

  // Load users and facilities
  const loadData = async () => {
    setLoading(true);
    try {
      const resUsers = await apiClient.get('/user/');
      setUsers(resUsers.data.items || []);

      const resFac = await apiClient.get('/facility');
      setFacilities(resFac.data.items || []);
    } catch (e: any) {
      message.error('Không thể tải dữ liệu thành viên');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const handleRoleChange = async (userId: string, newRole: UserSession['role']) => {
    try {
      await apiClient.put(`/user/${userId}/role`, { role: newRole });
      message.success('Cập nhật vai trò thành công!');
      loadData();
    } catch (e: any) {
      message.error('Không thể cập nhật vai trò');
    }
  };

  const handleAssignFacility = async (userId: string, facilityId: string) => {
    try {
      await apiClient.post(`/user/${userId}/assign-facility`, { facilityId });
      message.success('Gán cơ sở làm việc thành công!');
      loadData();
    } catch (e: any) {
      message.error('Gán cơ sở thất bại');
    }
  };

  const handleToggleStatus = async (userId: string, currentStatus: UserSession['status']) => {
    const nextStatus = currentStatus === 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
    try {
      await apiClient.put(`/user/${userId}/status`, { status: nextStatus });
      message.success(nextStatus === 'ACTIVE' ? 'Mở khóa tài khoản thành công!' : 'Khóa tài khoản thành công!');
      loadData();
    } catch (e: any) {
      message.error('Cập nhật trạng thái tài khoản thất bại');
    }
  };

  // Quick register Staff
  const handleQuickRegisterStaff = async (values: any) => {
    setRegistering(true);
    try {
      // Step 1: POST /auth/register (mật khẩu mặc định 123456)
      const regResponse = await apiClient.post('/auth/register', {
        email: values.email,
        password: '123456'
      });
      const newUserId = regResponse.data.userId || regResponse.data.data?.userId || regResponse.data.user?._id || regResponse.data.user?.id;

      // Step 2: Cập nhật thông tin profile (fullName, phone)
      await apiClient.put(`/user/${newUserId}`, {
        profile: {
          fullName: values.fullName,
          phone: values.phone
        }
      });

      // Step 2.5: Kích hoạt trạng thái tài khoản thành ACTIVE
      await apiClient.put(`/user/${newUserId}/status`, { status: 'ACTIVE' });

      // Step 3: Gán quyền STAFF
      await apiClient.put(`/user/${newUserId}/role`, { role: 'STAFF' });

      // Step 4: Gán facility
      await apiClient.post(`/user/${newUserId}/assign-facility`, { facilityId: values.facilityId });

      message.success('Đăng ký tài khoản nhân viên thành công! Mật khẩu mặc định: 123456');
      setIsModalOpen(false);
      form.resetFields();
      loadData();
    } catch (e: any) {
      message.error(e.response?.data?.message || 'Có lỗi xảy ra khi tạo tài khoản');
    } finally {
      setRegistering(false);
    }
  };

  const columns = [
    {
      title: 'Tài khoản',
      key: 'userinfo',
      render: (_: any, record: UserSession) => {
        const userId = record.id || record._id || '';
        return (
          <div className="flex items-center gap-2">
            <Avatar 
              src={record.profile?.avatar || `https://api.dicebear.com/7.x/adventurer/svg?seed=${userId}`} 
              icon={<UserOutlined />}
              className="bg-brand-orange"
            />
            <div className="flex flex-col leading-tight">
              <span className="font-semibold text-sm dark:text-white">
                {record.profile?.fullName || 'Chưa thiết lập tên'}
              </span>
              <span className="text-xs text-ink-muted dark:text-ink-darkMuted mt-0.5">
                {record.email}
              </span>
            </div>
          </div>
        );
      }
    },
    {
      title: 'Số điện thoại',
      key: 'phone',
      render: (_: any, record: UserSession) => (
        <span className="dark:text-white">{record.profile?.phone || '-'}</span>
      )
    },
    {
      title: 'Vai trò',
      dataIndex: 'role',
      key: 'role',
      render: (role: UserSession['role'], record: UserSession) => {
        const userId = record.id || record._id || '';
        const currentUserId = authStorage.getUser()?._id || authStorage.getUser()?.id || '';
        return (
          <Select
            value={role}
            onChange={(val) => handleRoleChange(userId, val)}
            disabled={userId === currentUserId} // Cannot change own role
            className="w-32 rounded-md"
          >
            <Select.Option value="CUSTOMER">Khách hàng</Select.Option>
            <Select.Option value="STAFF">Nhân viên</Select.Option>
            <Select.Option value="ADMIN">Admin</Select.Option>
          </Select>
        );
      }
    },
    {
      title: 'Cơ sở phân bổ',
      key: 'facility',
      render: (_: any, record: UserSession) => {
        const userId = record.id || record._id || '';
        if (record.role !== 'STAFF') {
          return <span className="text-ink-subtle dark:text-ink-darkSubtle text-xs">Không khả dụng</span>;
        }
        return (
          <Select
            value={record.facilityId || 'unassigned'}
            onChange={(val) => handleAssignFacility(userId, val)}
            className="w-48 rounded-md"
          >
            <Select.Option value="unassigned" disabled>Chưa gán cơ sở</Select.Option>
            {facilities.map(f => (
              <Select.Option key={f._id} value={f._id}>{f.name}</Select.Option>
            ))}
          </Select>
        );
      }
    },
    {
      title: 'Trạng thái',
      dataIndex: 'status',
      key: 'status',
      render: (status: UserSession['status']) => (
        <Tag color={status === 'ACTIVE' ? 'success' : 'error'} className="border-none font-semibold px-2 py-0.5 rounded">
          {status === 'ACTIVE' ? 'Kích hoạt' : 'Bị khóa'}
        </Tag>
      )
    },
    {
      title: 'Khóa / Mở khóa',
      key: 'actions',
      render: (_: any, record: UserSession) => {
        const userId = record.id || record._id || '';
        const currentUserId = authStorage.getUser()?._id || authStorage.getUser()?.id || '';
        if (userId === currentUserId) return null; // Cannot lock oneself
        return (
          <Button
            type="text"
            danger={record.status === 'ACTIVE'}
            icon={record.status === 'ACTIVE' ? <LockOutlined /> : <UnlockOutlined className="text-emerald-500" />}
            onClick={() => handleToggleStatus(userId, record.status)}
            className={`rounded-md ${record.status === 'ACTIVE' ? 'hover:bg-red-50 dark:hover:bg-red-950/20' : 'hover:bg-emerald-50 dark:hover:bg-emerald-950/20'}`}
            title={record.status === 'ACTIVE' ? 'Khóa tài khoản' : 'Mở khóa tài khoản'}
          />
        );
      }
    }
  ];

  return (
    <div className="space-y-6">
      {/* Title */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 border-b border-semantic-border/10 dark:border-semantic-borderDark/10 pb-4">
        <div>
          <Title level={3} className="m-0 dark:text-white" style={{ fontWeight: 700 }}>
            Quản lý Thành viên & Phân quyền
          </Title>
          <Text className="text-ink-muted dark:text-ink-darkMuted">
            Xem toàn bộ tài khoản, thay đổi quyền Admin/Staff, gán cơ sở làm việc và khóa/mở khóa tài khoản.
          </Text>
        </div>
        <Button
          type="primary"
          icon={<UserAddOutlined />}
          onClick={() => {
            form.resetFields();
            setIsModalOpen(true);
          }}
          size="large"
          className="bg-brand-orange hover:bg-brand-orange/90 border-none rounded-md font-semibold shrink-0 shadow-md shadow-brand-orange/20"
        >
          Tạo tài khoản Nhân viên
        </Button>
      </div>

      {/* Table */}
      <Table
        dataSource={users}
        columns={columns}
        rowKey="_id"
        loading={loading}
        pagination={{ pageSize: 8 }}
        className="border border-semantic-border/10 dark:border-semantic-borderDark/10 rounded-xl overflow-hidden shadow-sm bg-white dark:bg-surface-dark1"
      />

      {/* Register Staff Modal */}
      <Modal
        title={<span className="font-bold text-lg dark:text-white">Đăng ký Tài khoản Nhân viên mới</span>}
        open={isModalOpen}
        onCancel={() => setIsModalOpen(false)}
        footer={null}
        width={500}
        destroyOnClose
      >
        <Form
          form={form}
          layout="vertical"
          onFinish={handleQuickRegisterStaff}
          className="mt-4"
        >
          <Form.Item
            name="fullName"
            label={<span className="font-semibold dark:text-white">Họ và Tên</span>}
            rules={[{ required: true, message: 'Vui lòng nhập họ và tên nhân viên!' }]}
          >
            <Input placeholder="Ví dụ: Nguyễn Văn A" className="rounded-md dark:bg-surface-dark2 dark:text-white" />
          </Form.Item>

          <Form.Item
            name="email"
            label={<span className="font-semibold dark:text-white">Email đăng nhập</span>}
            rules={[
              { required: true, message: 'Vui lòng nhập email!' },
              { type: 'email', message: 'Email không đúng định dạng!' }
            ]}
          >
            <Input placeholder="email.staff@sportenergy.vn" className="rounded-md dark:bg-surface-dark2 dark:text-white" />
          </Form.Item>

          <Form.Item
            name="phone"
            label={<span className="font-semibold dark:text-white">Số điện thoại</span>}
            rules={[{ required: true, message: 'Nhập số điện thoại nhân viên!' }]}
          >
            <Input placeholder="Ví dụ: 0987654321" className="rounded-md dark:bg-surface-dark2 dark:text-white" />
          </Form.Item>

          <Form.Item
            name="facilityId"
            label={<span className="font-semibold dark:text-white">Cơ sở làm việc gán trước</span>}
            rules={[{ required: true, message: 'Vui lòng chọn cơ sở làm việc!' }]}
          >
            <Select placeholder="Chọn cơ sở" className="rounded-md">
              {facilities.map(f => (
                <Select.Option key={f._id} value={f._id}>{f.name}</Select.Option>
              ))}
            </Select>
          </Form.Item>

          <Card className="bg-amber-50 dark:bg-amber-950/20 border border-amber-200 dark:border-amber-900/40 rounded-md p-1 mb-6">
            <span className="text-xs text-amber-700 dark:text-amber-400 block leading-normal">
              * Hệ thống đăng ký tài khoản qua Firebase sẽ tự tạo mật khẩu mặc định là <strong>123456</strong>. Nhân viên có thể thay đổi sau khi đăng nhập.
            </span>
          </Card>

          <div className="flex gap-3 justify-end border-t border-semantic-border/10 dark:border-semantic-borderDark/10 pt-4 mt-6">
            <Button onClick={() => setIsModalOpen(false)} className="rounded-md">
              Hủy bỏ
            </Button>
            <Button
              type="primary"
              htmlType="submit"
              loading={registering}
              className="bg-brand-orange hover:bg-brand-orange/90 border-none font-semibold rounded-md shadow-md"
            >
              Đăng ký & Phân bổ
            </Button>
          </div>
        </Form>
      </Modal>
    </div>
  );
};

export default AdminUsersPage;
