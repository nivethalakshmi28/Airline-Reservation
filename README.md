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
- Pure SQL implementation (stored procedures, functions, triggers, views) 

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
