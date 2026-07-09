-- ============================================================
-- Airline Reservation System - Reporting Views
-- ============================================================
USE airline_reservation;

-- ------------------------------------------------------------
-- VIEW: flight_availability
-- Quick view of seat availability & current price per flight
-- ------------------------------------------------------------
CREATE VIEW flight_availability AS
SELECT
    f.flight_id,
    f.flight_number,
    f.source,
    f.destination,
    f.departure_time,
    f.current_price,
    COUNT(s.seat_id) AS total_seats,
    SUM(CASE WHEN s.status = 'AVAILABLE' THEN 1 ELSE 0 END) AS available_seats,
    SUM(CASE WHEN s.status = 'BOOKED' THEN 1 ELSE 0 END) AS booked_seats
FROM flights f
JOIN seats s ON f.flight_id = s.flight_id
GROUP BY f.flight_id, f.flight_number, f.source, f.destination,
         f.departure_time, f.current_price;

-- ------------------------------------------------------------
-- VIEW: booking_summary
-- Full booking details joined with passenger and flight info
-- ------------------------------------------------------------
CREATE VIEW booking_summary AS
SELECT
    b.booking_id,
    p.full_name AS passenger_name,
    p.email,
    f.flight_number,
    f.source,
    f.destination,
    f.departure_time,
    s.seat_number,
    s.class,
    b.fare_paid,
    b.status AS booking_status,
    b.booking_date
FROM bookings b
JOIN passengers p ON b.passenger_id = p.passenger_id
JOIN flights f ON b.flight_id = f.flight_id
JOIN seats s ON b.seat_id = s.seat_id;

-- ------------------------------------------------------------
-- VIEW: revenue_by_flight
-- Total revenue collected per flight (confirmed bookings only)
-- ------------------------------------------------------------
CREATE VIEW revenue_by_flight AS
SELECT
    f.flight_id,
    f.flight_number,
    f.source,
    f.destination,
    COUNT(b.booking_id) AS confirmed_bookings,
    SUM(b.fare_paid) AS total_revenue
FROM flights f
JOIN bookings b ON f.flight_id = b.flight_id
WHERE b.status = 'CONFIRMED'
GROUP BY f.flight_id, f.flight_number, f.source, f.destination;

-- ------------------------------------------------------------
-- VIEW: pending_refunds
-- ------------------------------------------------------------
CREATE VIEW pending_refunds AS
SELECT
    c.cancellation_id,
    b.booking_id,
    p.full_name,
    p.email,
    c.refund_amount,
    c.cancel_date,
    c.refund_status
FROM cancellations c
JOIN bookings b ON c.booking_id = b.booking_id
JOIN passengers p ON b.passenger_id = p.passenger_id
WHERE c.refund_status = 'PENDING';
