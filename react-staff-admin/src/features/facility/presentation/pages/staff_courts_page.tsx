import React, { useState, useEffect, useMemo } from 'react';
import { Table, Typography, Tag } from 'antd';
import { authStorage } from '../../../../core/utils/auth_storage';
import { formatVND } from '../../../../core/utils/formatters';
import { apiClient } from '../../../../core/network/api_client';

const { Title, Text } = Typography;

interface SportItem {
  _id: string;
  id?: string;
  name: string;
}

interface CourtItem {
  _id: string;
  id?: string;
  name: string;
  code: string;
  status: string;
  pricePerHour: number;
  // Cập nhật interface theo đúng JSON backend trả về
  facility?: { id: string; name: string };
  sport?: { id: string; name: string };
  sportId?: string; // Fallback
  openingMinutes?: number | null;
  closingMinutes?: number | null;
  slotDurationMinutes?: number | null;
}

const StaffCourtsPage: React.FC = () => {
  const user = useMemo(() => authStorage.getUser(), []);

  const [courts, setCourts] = useState<CourtItem[]>([]);
  const [sports, setSports] = useState<SportItem[]>([]);

  const facilityId = user?.facilityId;

  useEffect(() => {
    if (!facilityId) return;

    let isMounted = true;

    const loadCourtsAndSports = async () => {
      try {
        const resCourts = await apiClient.get('/court', { params: { facilityId } });
        const courtItems: CourtItem[] = (resCourts.data.items || []).map((c: any) => ({
          ...c,
          _id: c.id || c._id || '', // Ưu tiên lấy id
        }));

        const courtsWithConfig = await Promise.allSettled(
          courtItems.map(async (court) => {
            try {
              const resSlot = await apiClient.get(`/court/${court._id}/slot-config`);
              const config = resSlot.data.config;
              return {
                ...court,
                openingMinutes: config?.openingMinutes,
                closingMinutes: config?.closingMinutes,
                slotDurationMinutes: config?.slotDurationMinutes,
              };
            } catch (e) {
              return {
                ...court,
                openingMinutes: null,
                closingMinutes: null,
                slotDurationMinutes: null,
              };
            }
          })
        );

        const validCourts = courtsWithConfig.map((res, idx) =>
          res.status === 'fulfilled' ? res.value : courtItems[idx]
        );

        if (isMounted) {
          setCourts(prev => JSON.stringify(prev) !== JSON.stringify(validCourts) ? validCourts : prev);
        }

        const resSports = await apiClient.get('/sport');
        const sportItems: SportItem[] = (resSports.data.items || []).map((s: any) => ({
          ...s,
          _id: s.id || s._id || '',
        }));

        if (isMounted) {
          setSports(prev => JSON.stringify(prev) !== JSON.stringify(sportItems) ? sportItems : prev);
        }
      } catch (e) {
        console.error('[ERROR] Error loading courts or sports:', e);
      }
    };

    loadCourtsAndSports();

    return () => {
      isMounted = false;
    };
  }, [facilityId]);

  const columns = [
    {
      title: 'Mã sân',
      dataIndex: 'code',
      key: 'code',
      render: (code: string) => <span className="font-semibold text-brand-orange text-xs">{code}</span>,
    },
    {
      title: 'Tên Sân',
      dataIndex: 'name',
      key: 'name',
      render: (name: string) => <span className="font-semibold dark:text-white">{name}</span>,
    },
    {
      title: 'Môn thể thao',
      key: 'sport',
      // Lấy toàn bộ record để truy cập vào object "sport" lồng nhau
      render: (_: any, record: CourtItem) => {
        // 1. Nếu JSON có sẵn object sport -> Lấy luôn tên (trường hợp của ông)
        if (record.sport && record.sport.name) {
          return <Tag color="blue">{record.sport.name}</Tag>;
        }

        // 2. Fallback: Nếu không có object sport, dò bằng sportId trong mảng sports
        const sid = record.sportId;
        if (!sid) return <Tag color="default">Chưa gán</Tag>;

        const sport = sports.find(s => s._id === sid || s.id === sid);
        return <Tag color="blue">{sport ? sport.name : 'Không xác định'}</Tag>;
      }
    },
    {
      title: 'Đơn giá / Giờ',
      dataIndex: 'pricePerHour',
      key: 'price',
      render: (price: number) => <span className="font-bold dark:text-white">{formatVND(price)}</span>
    },
    {
      title: 'Khung giờ vận hành',
      key: 'operation',
      render: (_: any, record: CourtItem) => {
        if (record.openingMinutes == null || record.closingMinutes == null) {
          return <span className="text-xs italic text-ink-muted dark:text-ink-darkMuted">Chưa cấu hình</span>;
        }

        return (
          <span className="text-xs font-semibold text-indigo-500">
            {Math.floor(record.openingMinutes / 60)}h:00 - {Math.floor(record.closingMinutes / 60)}h:00 ({record.slotDurationMinutes}p/ca)
          </span>
        );
      }
    },
    {
      title: 'Trạng thái',
      dataIndex: 'status',
      key: 'status',
      render: (status: string) => (
        <Tag color={status === 'ACTIVE' ? 'success' : 'error'} className="border-none font-semibold px-2 py-0.5 rounded">
          {status === 'ACTIVE' ? 'Hoạt động' : 'Bảo trì'}
        </Tag>
      )
    }
  ];

  if (user && user.role === 'STAFF' && !facilityId) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[400px] text-center p-6 bg-white dark:bg-surface-dark1 rounded-xl border border-semantic-border/20 dark:border-semantic-borderDark/20 shadow-sm">
        <div className="text-brand-orange text-5xl mb-4">⚠️</div>
        <Title level={4} className="m-0 dark:text-white" style={{ fontWeight: 600 }}>
          Chưa được gán Cơ sở hoạt động
        </Title>
        <Text className="text-ink-muted dark:text-ink-darkMuted mt-2 max-w-md block">
          Tài khoản Nhân viên của bạn chưa được liên kết với cơ sở thể thao nào. Vui lòng liên hệ với Quản trị viên hệ thống để gán cơ sở trước khi thực hiện các nghiệp vụ quản lý.
        </Text>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="border-b border-semantic-border/10 dark:border-semantic-borderDark/10 pb-4">
        <Title level={3} className="m-0 dark:text-white" style={{ fontWeight: 700 }}>
          Danh sách Sân đấu tại Cơ sở
        </Title>
        <Text className="text-ink-muted dark:text-ink-darkMuted">
          Xem thông số kỹ thuật sân, đơn giá và tình trạng hoạt động hiện tại.
        </Text>
      </div>

      <Table
        dataSource={courts}
        columns={columns}
        rowKey="_id"
        pagination={{ pageSize: 8 }}
        className="border border-semantic-border/10 dark:border-semantic-borderDark/10 rounded-xl overflow-hidden shadow-sm bg-white dark:bg-surface-dark1"
      />
    </div>
  );
};

export default StaffCourtsPage;