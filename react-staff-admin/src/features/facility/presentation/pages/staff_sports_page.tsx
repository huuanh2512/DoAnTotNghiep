import React, { useState, useEffect } from 'react';
import { Table, Typography, Tag } from 'antd';
import { MockSport } from '../../../../core/network/mock_db';
import { apiClient } from '../../../../core/network/api_client';

const { Title, Text } = Typography;

const StaffSportsPage: React.FC = () => {
  const [sports, setSports] = useState<MockSport[]>([]);

  useEffect(() => {
    const loadSports = async () => {
      try {
        const res = await apiClient.get('/sport');
        setSports(res.data.items || []);
      } catch (e) {
        console.error('Error loading sports:', e);
      }
    };
    loadSports();
  }, []);

  const columns = [
    {
      title: 'Tên môn thể thao',
      dataIndex: 'name',
      key: 'name',
      render: (name: string) => <span className="font-semibold dark:text-white">{name}</span>,
    },
    {
      title: 'Mô tả chi tiết',
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
    }
  ];

  return (
    <div className="space-y-6">
      <div className="border-b border-semantic-border/10 dark:border-semantic-borderDark/10 pb-4">
        <Title level={3} className="m-0 dark:text-white" style={{ fontWeight: 700 }}>
          Danh mục môn thể thao
        </Title>
        <Text className="text-ink-muted dark:text-ink-darkMuted">
          Xem các môn thể thao và quy mô đội hình đang hoạt động trên hệ thống Sport Energy.
        </Text>
      </div>

      <Table
        dataSource={sports}
        columns={columns}
        rowKey="_id"
        pagination={{ pageSize: 8 }}
        className="border border-semantic-border/10 dark:border-semantic-borderDark/10 rounded-xl overflow-hidden shadow-sm bg-white dark:bg-surface-dark1"
      />
    </div>
  );
};

export default StaffSportsPage;
