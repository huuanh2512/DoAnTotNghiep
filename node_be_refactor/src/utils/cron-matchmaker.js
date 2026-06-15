const cron = require('node-cron');
const Sport = require('../models/sport.model');
const Facility = require('../models/facility.model');
const matchingService = require('../services/matching.service');

const getVietnamDateString = (date = new Date()) => {
  const formatter = new Intl.DateTimeFormat('en-CA', {
    timeZone: 'Asia/Ho_Chi_Minh',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  });
  return formatter.format(date);
};

const runMatchmaker = async () => {
  console.log('[Cron Job] Scan auto matching queue...');
  try {
    const expirationResult = await matchingService.autoCancelUnmatched();
    console.log(
      `[Cron Matching Expiration] Cancelled ${expirationResult.cancelledSessionCount} sessions, expired ${expirationResult.expiredQueueCount} queues.`
    );

    const [sports, facilities] = await Promise.all([
      Sport.find({ active: true }),
      Facility.find({ active: true })
    ]);

    const today = getVietnamDateString();

    for (const sport of sports) {
      for (const facility of facilities) {
        await matchingService.runMatchmakerAlgorithm(
          sport._id.toString(),
          facility._id.toString(),
          today
        );
      }
    }
  } catch (error) {
    console.error('[Cron Job Error] Auto matching scan failed:', error.message);
  }
};

cron.schedule('*/1 * * * *', runMatchmaker);

module.exports = { runMatchmaker };
