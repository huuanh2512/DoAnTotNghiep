const cron = require('node-cron');
const bookingService = require('../services/booking.service');

const runAutoCancelPendingBookings = async () => {
  console.log('[Cron Auto Cancel Bookings] Start scanning pending bookings...');
  try {
    const result = await bookingService.autoCancelPendingBookings();
    console.log(
      `[Cron Auto Cancel Bookings] Scanned ${result.scannedCount}, cancelled ${result.cancelledCount}.`
    );
  } catch (error) {
    console.error('[Cron Auto Cancel Bookings Error]:', error.message);
  }
};

cron.schedule('*/1 * * * *', runAutoCancelPendingBookings);

module.exports = { runAutoCancelPendingBookings };
