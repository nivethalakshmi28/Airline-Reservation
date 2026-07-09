-- ============================================================
-- Airline Reservation System - Triggers
-- ============================================================
USE airline_reservation;

DELIMITER $$

-- ------------------------------------------------------------
-- TRIGGER: after_booking_insert
-- Logs every new booking into booking_audit
-- ------------------------------------------------------------
CREATE TRIGGER after_booking_insert
AFTER INSERT ON bookings
FOR EACH ROW
BEGIN
    INSERT INTO booking_audit (booking_id, action, details)
    VALUES (NEW.booking_id, 'CREATED',
            CONCAT('Booking created for passenger ', NEW.passenger_id,
                   ' on flight ', NEW.flight_id, ' fare ', NEW.fare_paid));
END$$


-- ------------------------------------------------------------
-- TRIGGER: after_booking_update
-- Logs status changes (e.g., CONFIRMED -> CANCELLED)
-- ------------------------------------------------------------
CREATE TRIGGER after_booking_update
AFTER UPDATE ON bookings
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO booking_audit (booking_id, action, details)
        VALUES (NEW.booking_id, 'STATUS_CHANGE',
                CONCAT('Status changed from ', OLD.status, ' to ', NEW.status));
    END IF;
END$$


-- ------------------------------------------------------------
-- TRIGGER: after_payment_success
-- Auto-marks booking as CONFIRMED once payment succeeds
-- (booking already starts CONFIRMED in this schema, but this
--  demonstrates handling of payment-driven state changes,
--  e.g. auto-cancel if payment fails)
-- ------------------------------------------------------------
CREATE TRIGGER after_payment_update
AFTER UPDATE ON payments
FOR EACH ROW
BEGIN
    IF NEW.payment_status = 'FAILED' AND OLD.payment_status <> 'FAILED' THEN
        UPDATE bookings SET status = 'CANCELLED' WHERE booking_id = NEW.booking_id;

        UPDATE seats s
        JOIN bookings b ON s.seat_id = b.seat_id
        SET s.status = 'AVAILABLE'
        WHERE b.booking_id = NEW.booking_id;

        INSERT INTO booking_audit (booking_id, action, details)
        VALUES (NEW.booking_id, 'AUTO_CANCELLED', 'Payment failed - seat released automatically');
    END IF;
END$$

DELIMITER ;
