import React, { useState } from 'react';
import { Card, Descriptions, Avatar, Typography, Button, Form, Input, App, Tag } from 'antd';
import { UserOutlined, MailOutlined, PhoneOutlined, EnvironmentOutlined, SafetyCertificateOutlined } from '@ant-design/icons';
import { authStorage, UserSession } from '../../../../core/utils/auth_storage';
import { apiClient } from '../../../../core/network/api_client';

const { Title, Text } = Typography;

const ProfilePage: React.FC = () => {
  const { message } = App.useApp();
  const [user, setUser] = useState<UserSession | null>(authStorage.getUser());
  const [editing, setEditing] = useState(false);
  const [facilityName, setFacilityName] = useState<string>('');
  const [form] = Form.useForm();

  // Find facility name if STAFF using API
  React.useEffect(() => {
    const loadFacilityName = async () => {
      if (!user || user.role !== 'STAFF' || !user.facilityId) return;
      
      // If facilityId looks like a name instead of ObjectId (because of fallback), use it directly
      if (user.facilityId.length > 24 || !/^[0-9a-fA-F]+$/.test(user.facilityId)) {
        setFacilityName(user.facilityId);
        return;
      }

      try {
        const resFacs = await apiClient.get('/facility');
        const fac = (resFacs.data.items || []).find((f: any) => (f._id || f.id) === user.facilityId);
        setFacilityName(fac?.name || 'Chưa được phân bổ');
      } catch {
        setFacilityName('Chưa được phân bổ');
      }
    };
    loadFacilityName();
  }, [user]);

  if (!user) return <div>Không tìm thấy thông tin phiên đăng nhập.</div>;

  const handleUpdate = async (values: any) => {
    try {
      const response = await apiClient.put(`/user/${user._id}`, {
        profile: {
          fullName: values.fullName,
          phone: values.phone,
          avatar: user.profile?.avatar
        }
      });
      const updatedUser: UserSession = {
        ...user,
        profile: response.data.user?.profile || {
          fullName: values.fullName,
          phone: values.phone,
          avatar: user.profile?.avatar
        }
      };
      authStorage.setUser(updatedUser);
      setUser(updatedUser);
      message.success('Cập nhật thông tin cá nhân thành công!');
      setEditing(false);
    } catch (e) {
      message.error('Không thể cập nhật thông tin cá nhân');
    }
  };

  return (
    <div className="max-w-4xl mx-auto py-4">
      <div className="flex flex-col md:flex-row gap-6 items-start">
        {/* Left column: Avatar card */}
        <Card className="w-full md:w-80 text-center shadow-sm rounded-xl border border-semantic-border/20 dark:border-semantic-borderDark/20 bg-white dark:bg-surface-dark1">
          <div className="flex flex-col items-center py-4">
            <Avatar
              size={120}
              src={user.profile?.avatar || `https://api.dicebear.com/7.x/adventurer/svg?seed=${user._id}`}
              icon={<UserOutlined />}
              className="bg-brand-orange border-4 border-brand-orange/20 shadow-md mb-4"
            />
            <Title level={3} className="m-0 dark:text-white" style={{ fontWeight: 600 }}>
              {user.profile?.fullName || 'Người dùng'}
            </Title>
            <Tag color={user.role === 'ADMIN' ? 'gold' : 'blue'} className="mt-2 text-sm px-3 py-0.5 rounded-full font-semibold border-none">
              {user.role === 'ADMIN' ? 'QUẢN TRỊ VIÊN' : 'NHÂN VIÊN CƠ SỞ'}
            </Tag>
            <Text className="text-ink-muted dark:text-ink-darkMuted mt-3 block text-sm">
              Mã số: {user._id}
            </Text>
          </div>
        </Card>

        {/* Right column: Description / Edit Form */}
        <Card className="flex-1 w-full shadow-sm rounded-xl border border-semantic-border/20 dark:border-semantic-borderDark/20 bg-white dark:bg-surface-dark1">
          <div className="flex items-center justify-between border-b border-semantic-border/10 dark:border-semantic-borderDark/10 pb-4 mb-6">
            <Title level={4} className="m-0 dark:text-white" style={{ fontWeight: 600 }}>
              Thông tin chi tiết
            </Title>
            {!editing && (
              <Button type="primary" onClick={() => {
                form.setFieldsValue({
                  fullName: user.profile?.fullName,
                  phone: user.profile?.phone
                });
                setEditing(true);
              }} className="bg-brand-orange hover:bg-brand-orange/90 border-none rounded-md">
                Chỉnh sửa
              </Button>
            )}
          </div>

          {editing ? (
            <Form form={form} layout="vertical" onFinish={handleUpdate}>
              <Form.Item
                name="fullName"
                label={<span className="font-semibold dark:text-white">Họ và Tên</span>}
                rules={[{ required: true, message: 'Vui lòng nhập họ tên!' }]}
              >
                <Input size="large" className="rounded-md dark:bg-surface-dark2 dark:text-white dark:border-semantic-borderDark" />
              </Form.Item>
              
              <Form.Item
                name="phone"
                label={<span className="font-semibold dark:text-white">Số điện thoại</span>}
                rules={[{ required: true, message: 'Vui lòng nhập số điện thoại!' }]}
              >
                <Input size="large" className="rounded-md dark:bg-surface-dark2 dark:text-white dark:border-semantic-borderDark" />
              </Form.Item>

              <Form.Item className="mb-0 flex gap-2 justify-end">
                <Button onClick={() => setEditing(false)} className="rounded-md mr-2 dark:bg-surface-dark2 dark:text-white dark:border-semantic-borderDark">
                  Hủy
                </Button>
                <Button type="primary" htmlType="submit" className="bg-brand-orange hover:bg-brand-orange/90 border-none rounded-md">
                  Lưu thay đổi
                </Button>
              </Form.Item>
            </Form>
          ) : (
            <Descriptions column={1} labelStyle={{ fontWeight: 600, width: '180px' }} contentStyle={{ color: 'inherit' }} className="dark:text-white">
              <Descriptions.Item label={<span><MailOutlined className="mr-2 text-brand-orange" /> Email</span>}>
                {user.email}
              </Descriptions.Item>
              <Descriptions.Item label={<span><PhoneOutlined className="mr-2 text-brand-orange" /> Số điện thoại</span>}>
                {user.profile?.phone || 'Chưa cập nhật'}
              </Descriptions.Item>
              <Descriptions.Item label={<span><SafetyCertificateOutlined className="mr-2 text-brand-orange" /> Phân quyền</span>}>
                <Tag color={user.role === 'ADMIN' ? 'gold' : 'blue'}>
                  {user.role === 'ADMIN' ? 'ADMIN' : 'STAFF'}
                </Tag>
              </Descriptions.Item>
              {user.role === 'STAFF' && (
                <Descriptions.Item label={<span><EnvironmentOutlined className="mr-2 text-brand-orange" /> Cơ sở phân bổ</span>}>
                  <span className="font-semibold text-brand-orange">{facilityName}</span>
                </Descriptions.Item>
              )}
            </Descriptions>
          )}
        </Card>
      </div>
    </div>
  );
};

export default ProfilePage;
