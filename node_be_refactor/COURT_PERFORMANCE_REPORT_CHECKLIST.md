# Court Performance Report Checklist

Endpoint:

`GET /api/v1/reports/court-performance`

1. CUSTOMER receives `403`.
2. STAFF receives only courts in `User.facility_id` or `Facility.staff_ids`.
3. STAFF filtering another facility or court receives `403`.
4. STAFF without an assigned facility receives
   `403 STAFF_FACILITY_SCOPE_REQUIRED`.
5. ADMIN and SUPER_ADMIN can report across all facilities.
6. Response contains aggregate values only, with no booking list, email, phone
   or raw walk-in customer details.
7. `paidRevenue` sums `Payment.amount` only for `SUCCESS` payments attached to
   `CONFIRMED` or `COMPLETED` bookings.
8. `PENDING` bookings are excluded from `totalActiveBookings`.
9. Successful payments on cancelled bookings are reported under
   `paidCancelledAmount`, not `paidRevenue`.
10. `REFUND_PENDING` and `REFUNDED` amounts are reported separately.
11. Court utilization uses booked active minutes divided by configured
   available slot minutes for every day in the requested range.
12. Flutter report requests this endpoint again when facility, court or date
   range changes and does not fetch raw booking lists.
