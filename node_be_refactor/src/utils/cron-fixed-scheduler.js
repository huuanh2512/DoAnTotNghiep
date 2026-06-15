const cron = require('node-cron');
const fixedScheduleRepository = require('../repositories/fixed-schedule.repository');
const fixedScheduleService = require('../services/fixed-schedule.service');
const runScheduler = async () => {
  console.log('[Cron Fixed Scheduler] Bắt đầu quét hàng đăng ký lịch cố định...');
  try {
    const activeSchedules = await fixedScheduleRepository.findActiveSchedules();
    if (activeSchedules.length === 0) {
      console.log('[Cron Fixed Scheduler] Không có đăng ký lịch cố định nào đang hoạt động.');
      return;
    }

    // Tự động kiểm tra bù (Self-healing): Quét từ ngày hôm nay đến 7 ngày tiếp theo
    const { fromDateStr: todayStr, toDateStr: targetDateStr } =
      fixedScheduleService.getAdvanceGenerationRange();

    console.log(`[Cron Fixed Scheduler] Quét và tự động sinh lịch từ ${todayStr} đến ${targetDateStr}`);

    for (const schedule of activeSchedules) {
      const generated = await fixedScheduleService.generateBookingsForRange(schedule, todayStr, targetDateStr);
      if (generated.length > 0) {
        console.log(`[Cron Fixed Scheduler] Lịch cố định của User: ${schedule.user_id._id} đã sinh lịch thành công cho các ngày: ${generated.join(', ')}`);
      }
    }

    console.log('[Cron Fixed Scheduler] Hoàn thành quét và sinh lịch cố định.');
  } catch (error) {
    console.error('[Cron Fixed Scheduler Error] Gặp lỗi khi chạy Scheduler:', error.message);
  }
};

// Chạy vào lúc 00:05 hàng ngày
cron.schedule('5 0 * * *', runScheduler);

// Chạy thử ngay khi khởi động sau 5 giây để cập nhật lịch chơi ngay lập tức
setTimeout(() => {
  console.log('[Cron Fixed Scheduler] Kích hoạt tiến trình quét ban đầu...');
  runScheduler().catch(err => console.error('[Cron Fixed Scheduler Startup Error]:', err.message));
}, 5000);

module.exports = { runScheduler };
