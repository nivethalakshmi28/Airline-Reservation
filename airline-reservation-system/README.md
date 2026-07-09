# ✈️ Airline Reservation System (MySQL)

A real-time Airline Reservation System database project featuring flight management, seat allocation with concurrency-safe locking, dynamic pricing, and a full cancellation/refund workflow — built entirely with core MySQL features (stored procedures, functions, triggers, views, transactions).

## Features

- **Flight Management** — routes, schedules, aircraft assignment
- **Seat Allocation** — economy/business seat maps per flight, race-condition-safe booking using `SELECT ... FOR UPDATE`
- **Dynamic Pricing** — ticket price automatically increases as a flight fills up (50% / 80% / 95% occupancy thresholds)
- **Booking Workflow** — atomic transactions ensure a seat is never double-booked
- **Cancellation & Refunds** — refund percentage calculated automatically based on hours remaining before departure
- **Audit Logging** — every booking/cancellation/payment-failure event is logged via triggers
- **Reporting Views** — flight availability, revenue by flight, pending refunds, full booking summary

## Tech Stack

- **Database:** MySQL 8.0+
- Pure SQL implementation (stored procedures, functions, triggers, views) — plug in any backend (Python/Flask, Node/Express, PHP, Java/Spring) on top

## Project Structure

```
airline-reservation-system/
│
├── database/
│   ├── schema.sql        # Table definitions + indexes
│   ├── procedures.sql    # book_seat, cancel_booking, calculate_dynamic_price
│   ├── triggers.sql      # Audit logging + auto seat release on payment failure
│   ├── views.sql         # Reporting views
│   └── sample_data.sql   # Demo aircraft, flights, seats, passengers
│
├── docs/                 # Add your ER diagram / report / screenshots here
│
└── README.md
```

## Database Design (ER Overview)

```
aircraft (1) ───< flights (1) ───< seats
                     │                │
                     │                │
                     └──< bookings >──┘
                              │
                    ┌─────────┼─────────┐
               passengers  payments  cancellations
                              │
                        booking_audit (trigger log)
```

## Setup Instructions

1. Install MySQL 8.0+ and log in:
   ```bash
   mysql -u root -p
   ```

2. Run the scripts **in this exact order**:
   ```sql
   SOURCE database/schema.sql;
   SOURCE database/procedures.sql;
   SOURCE database/triggers.sql;
   SOURCE database/views.sql;
   SOURCE database/sample_data.sql;
   ```

   > If you get an error creating the `calculate_dynamic_price` function about binary logging, run this first:
   > ```sql
   > SET GLOBAL log_bin_trust_function_creators = 1;
   > ```

3. **Book a seat** (passenger_id, flight_id, seat_id):
   ```sql
   CALL book_seat(1, 1, 1, @booking_id, @message);
   SELECT @booking_id, @message;
   ```

4. **Cancel a booking**:
   ```sql
   CALL cancel_booking(1, @message);
   SELECT @message;
   ```

5. **Check flight availability / pricing**:
   ```sql
   SELECT * FROM flight_availability;
   ```

6. **View revenue report**:
   ```sql
   SELECT * FROM revenue_by_flight;
   ```

## Key Concepts Demonstrated

| Concept | Where |
|---|---|
| ACID Transactions | `book_seat`, `cancel_booking` procedures |
| Row-level locking (`FOR UPDATE`) | Prevents double-booking of the same seat |
| Stored Functions | `calculate_dynamic_price()` |
| Stored Procedures | Booking + cancellation workflows |
| Triggers | Audit logs, auto-cancel on payment failure |
| Views | Reporting/dashboards without exposing raw joins |
| Normalization | Schema is in 3NF |
| Indexing | On flight routes, seat status, passenger bookings |

## Sample Queries to Try

```sql
-- All available seats on a flight
SELECT * FROM seats WHERE flight_id = 1 AND status = 'AVAILABLE';

-- Passenger booking history
SELECT * FROM booking_summary WHERE email = 'arun.kumar@example.com';

-- Flights running low on seats (>80% full)
SELECT * FROM flight_availability
WHERE (booked_seats / total_seats) > 0.8;

-- Pending refunds to process
SELECT * FROM pending_refunds;
```

## Future Improvements

- Add a Python/Flask or Node/Express REST API layer on top
- Build a React frontend for booking/search UI
- Add multi-city / round-trip search support
- Integrate a real payment gateway (Razorpay/Stripe sandbox)
- Add loyalty points / frequent flyer module

## License

MIT License — free to use for academic and portfolio purposes.
