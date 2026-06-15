# Court Block Checklist

Endpoints:

- `POST /api/v1/court-blocks`
- `GET /api/v1/court-blocks`
- `PATCH /api/v1/court-blocks/:id`
- `DELETE /api/v1/court-blocks/:id`

1. CUSTOMER receives `403`.
2. STAFF can manage blocks only inside facilities from `User.facility_id` or
   `Facility.staff_ids`.
3. ADMIN and SUPER_ADMIN can manage all facilities.
4. Facility blocks use `courtId: null` and apply to every court in that
   facility.
5. DELETE changes status to `CANCELLED`; no hard delete is performed.
6. Only `ACTIVE` blocks overlapping the report range affect utilization.
7. Facility and court block overlaps are merged before unavailable minutes are
   calculated.
8. Block time outside configured available slots does not reduce availability.
9. Historical active bookings overlapping block time remain in booked minutes
   and produce `blockedBookingCount` plus a report warning.
10. A minimal management UI is still pending. Use authenticated API calls for
    operational testing until the facility management screen is extended.
