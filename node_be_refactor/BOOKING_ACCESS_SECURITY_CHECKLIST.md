# Booking Access Security Checklist

Use accounts and records from a non-production environment.

1. CUSTOMER A calls `GET /booking/` and only receives CUSTOMER A bookings.
2. CUSTOMER A calls `GET /booking/:id` for CUSTOMER B and receives `403`.
3. STAFF A calls `GET /booking/` and only receives bookings whose courts belong
   to STAFF A assigned facilities.
4. STAFF A supplies another facility through `facilityId` and receives `403`.
5. STAFF without `User.facility_id` and without membership in
   `Facility.staff_ids` receives `403` with `STAFF_FACILITY_SCOPE_REQUIRED`.
6. ADMIN calls `GET /booking/` without a facility filter and receives bookings
   across facilities.
7. STAFF A can open booking detail in an assigned facility and receives `403`
   for detail in another facility.
8. STAFF list/detail responses contain masked email and phone values.
9. STAFF report requests with `view=report` omit email and phone and mask
   walk-in customer names.
10. Report requests include `facilityId`, date filters when selected, and never
    request `limit=10000`.
