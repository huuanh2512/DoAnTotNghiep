import React, { useState, useEffect } from 'react';
import { Table, Button, Modal, Form, Input, InputNumber, Switch, Space, message, Typography, Tag, Popconfirm } from 'antd';
import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons';
import { MockSport } from '../../../../core/network/mock_db';
import { apiClient } from '../../../../core/network/api_client';

const { Title, Text } = Typography;

const AdminSportsPage: React.FC = () => {
  const [sports, setSports] = useState<MockSport[]>([]);
  const [loading, setLoading] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingSport, setEditingSport] = useState<MockSport | null>(null);
  const [form] = Form.useForm();

  const loadData = async () => {
    setLoading(true);
    try {
      const res = await apiClient.get('/sport');
      setSports(res.data.items || []);
    } catch (e: any) {
      message.error('Không thể tải danh sách môn thể thao');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const handleOpenAdd = () => {
    setEditingSport(null);
    form.resetFields();
    form.setFieldsValue({ active: true, teamSize: 2 });
    setIsModalOpen(true);
  };

  const handleOpenEdit = (sport: MockSport) => {
    setEditingSport(sport);
    form.resetFields();
    form.setFieldsValue({
      name: sport.name,
      description: sport.description,
      teamSize: sport.teamSize,
      active: sport.active
    });
    setIsModalOpen(true);
  };

  const handleDelete = async (id: string) => {
    try {
      await apiClient.delete(`/sport/${id}`);
      message.success('Xóa môn thể thao thành công!');
      loadData();
    } catch (e: any) {
      message.error('Xóa thất bại.');
    }
  };

  const handleSave = async (values: any) => {
    try {
      const payload = {
        name: values.name,
        description: values.description,
        teamSize: values.teamSize,
        active: values.active
      };

      if (editingSport) {
        await apiClient.put(`/sport/${editingSport._id}`, payload);
        message.success('Cập nhật môn thể thao thành công!');
      } else {
        await apiClient.post('/sport', payload);
        message.success('Thêm mới môn thể thao thành công!');
      }
      setIsModalOpen(false);
      loadData();
    } catch (e: any) {
      message.error('Lỗi khi lưu thông tin');
    }
  };

  const columns = [
    {
      title: 'Tên môn thể thao',
      dataIndex: 'name',
      key: 'name',
      render: (name: string) => <span className="font-semibold dark:text-white">{name}</span>,
    },
    {
      title: 'Mô tả',
      dataIndex: 'description',
      key: 'description',
      render: (desc: string) => <span className="text-ink-muted dark:text-ink-darkMuted text-xs">{desc || '-'}</span>,
    },
    {
      title: 'Quy mô đội hình',
      dataIndex: 'teamSize',
      key: 'teamSize',
      render: (size: number) => <Tag color="purple">{size} người/đội</Tag>
    },
    {
      title: 'Trạng thái',
      dataIndex: 'active',
      key: 'active',
      render: (active: boolean) => (
        <Tag color={active ? 'success' : 'error'} className="border-none font-semibold px-2 py-0.5 rounded">
          {active ? 'Kích hoạt' : 'Ngừng'}
        </Tag>
      )
    },
    {
      title: 'Thao tác',
      key: 'actions',
      render: (_: any, record: MockSport) => (
        <Space size="middle">
          <Button 
            type="text" 
            icon={<EditOutlined className="text-blue-500" />} 
            onClick={() => handleOpenEdit(record)}
            className="hover:bg-blue-50 dark:hover:bg-blue-950/20"
          />
          <Popconfirm
            title="Bạn có chắc chắn muốn xóa môn này?"
            onConfirm={() => handleDelete(record._id)}
            okText="Xóa"
            cancelText="Hủy"
            okButtonProps={{ danger: true }}
          >
            <Button 
              type="text" 
              danger
              icon={<DeleteOutlined />} 
              className="hover:bg-red-50 dark:hover:bg-red-950/20"
            />
          </Popconfirm>
        </Space>
      )
    }
  ];

  return (
    <div className="space-y-6">
      {/* Title */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 border-b border-semantic-border/10 dark:border-semantic-borderDark/10 pb-4">
        <div>
          <Title level={3} className="m-0 dark:text-white" style={{ fontWeight: 700 }}>
            Danh mục Môn thể thao
          </Title>
          <Text className="text-ink-muted dark:text-ink-darkMuted">
            Quản lý các môn thể thao được hỗ trợ đặt lịch tại Sport Energy.
          </Text>
        </div>
        <Button
          type="primary"
          icon={<PlusOutlined />}
          onClick={handleOpenAdd}
          size="large"
          className="bg-brand-orange hover:bg-brand-orange/90 border-none rounded-md font-semibold shrink-0 shadow-md shadow-brand-orange/20"
        >
          Thêm Môn thể thao
        </Button>
      </div>

      {/* Table */}
      <Table
        dataSource={sports}
        columns={columns}
        rowKey="_id"
        loading={loading}
        pagination={{ pageSize: 8 }}
        className="border border-semantic-border/10 dark:border-semantic-borderDark/10 rounded-xl overflow-hidden shadow-sm bg-white dark:bg-surface-dark1"
      />

      {/* Add/Edit Modal */}
      <Modal
        title={<span className="font-bold text-lg dark:text-white">{editingSport ? 'Chỉnh sửa Môn thể thao' : 'Thêm Môn thể thao'}</span>}
        open={isModalOpen}
        onCancel={() => setIsModalOpen(false)}
        footer={null}
        width={500}
        destroyOnClose
      >
        <Form
          form={form}
          layout="vertical"
          onFinish={handleSave}
          className="mt-4"
        >
          <Form.Item
            name="name"
            label={<span className="font-semibold dark:text-white">Tên môn thể thao</span>}
            rules={[{ required: true, message: 'Nhập tên môn!' }]}
          >
            <Input placeholder="Ví dụ: Bóng Đá 7 Người" className="rounded-md dark:bg-surface-dark2 dark:text-white" />
          </Form.Item>

          <Form.Item
            name="description"
            label={<span className="font-semibold dark:text-white">Mô tả</span>}
          >
            <Input.TextArea placeholder="Nhập mô tả ngắn gọn..." className="rounded-md dark:bg-surface-dark2 dark:text-white" rows={3} />
          </Form.Item>

          <Form.Item
            name="teamSize"
            label={<span className="font-semibold dark:text-white">Quy mô đội hình (Số người đấu/đội)</span>}
            rules={[
              { required: true, message: 'Nhập số lượng người đấu!' },
              { type: 'number', min: 1, message: 'Số lượng người phải lớn hơn 0!' }
            ]}
          >
            <InputNumber style={{ width: '100%' }} className="rounded-md dark:bg-surface-dark2 dark:text-white" />
          </Form.Item>

          <Form.Item
            name="active"
            label={<span className="font-semibold dark:text-white">Trạng thái kích hoạt</span>}
            valuePropName="checked"
          >
            <Switch checkedChildren="Kích hoạt" unCheckedChildren="Tắt" />
          </Form.Item>

          <div className="flex gap-3 justify-end border-t border-semantic-border/10 dark:border-semantic-borderDark/10 pt-4 mt-6">
            <Button onClick={() => setIsModalOpen(false)} className="rounded-md">
              Hủy bỏ
            </Button>
            <Button
              type="primary"
              htmlType="submit"
              className="bg-brand-orange hover:bg-brand-orange/90 border-none font-semibold rounded-md shadow-md"
            >
              Xác nhận Lưu
            </Button>
          </div>
        </Form>
      </Modal>
    </div>
  );
};

export default AdminSportsPage;
