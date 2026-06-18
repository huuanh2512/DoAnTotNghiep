const cron = require('node-cron');
const Sport = require('../models/sport.model');
const Facility = require('../models/facility.model');
const matchingService = require('../services/matching.service');
const cronStatus = require('./cron-status');

const JOB_NAME = 'matchmaker';
const TIMEZONE = 'Asia/Ho_Chi_Minh';
let isRunning = false;

cronStatus.registerJob(JOB_NAME, {
  schedule: '*/1 * * * *',
  timezone: TIMEZONE
});

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
  if (isRunning) {
    console.warn('[CRON][MATCHMAKER] skipped because previous run is still running');
    cronStatus.skipRun(JOB_NAME, 'previous_run_still_running');
    return { skipped: true };
  }

  isRunning = true;
  const startedAt = new Date();
  const startedMs = Date.now();
  cronStatus.startRun(JOB_NAME, startedAt);
  console.log('[CRON][MATCHMAKER] started at', startedAt.toISOString());

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
    let scannedGroups = 0;
    let matchedCount = 0;

    for (const sport of sports) {
      for (const facility of facilities) {
        scannedGroups += 1;
        const result = await matchingService.runMatchmakerAlgorithm(
          sport._id.toString(),
          facility._id.toString(),
          today
        );
        if (result?.matched) matchedCount += 1;
      }
    }

    const durationMs = Date.now() - startedMs;
    const summary = {
      scannedGroups,
      matchedCount,
      activeSports: sports.length,
      activeFacilities: facilities.length,
      expiredQueueCount: expirationResult.expiredQueueCount,
      cancelledSessionCount: expirationResult.cancelledSessionCount,
      durationMs
    };
    console.log('[CRON][MATCHMAKER] finished', summary);
    cronStatus.finishSuccess(JOB_NAME, summary, durationMs);
    return summary;
  } catch (error) {
    const durationMs = Date.now() - startedMs;
    console.error('[CRON][MATCHMAKER] failed', {
      message: error.message,
      durationMs
    });
    cronStatus.finishError(JOB_NAME, error, durationMs);
    return { error: error.message, durationMs };
  } finally {
    isRunning = false;
  }
};

cron.schedule('*/1 * * * *', runMatchmaker, { timezone: TIMEZONE });

module.exports = { runMatchmaker };
