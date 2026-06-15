const cron = require('node-cron');
const bookingService = require('../services/booking.service');

const runAutoCompleteFinishedBookings = async () => {
  console.log('[Cron Auto Complete Bookings] Start scanning finished bookings...');
  try {
    const result = await bookingService.autoCompleteFinishedBookings();
    console.log(
      `[Cron Auto Complete Bookings] Scanned ${result.scannedCount}, completed ${result.completedBookingCount} bookings and ${result.completedMatchingSessionCount} matching sessions.`
    );
  } catch (error) {
    console.error('[Cron Auto Complete Bookings Error]:', error.message);
  }
};

cron.schedule('*/1 * * * *', runAutoCompleteFinishedBookings);

module.exports = { runAutoCompleteFinishedBookings };
