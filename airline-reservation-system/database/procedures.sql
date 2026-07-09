-- ============================================================
-- Airline Reservation System - Stored Procedures & Functions
-- ============================================================
USE airline_reservation;

DELIMITER $$

-- ------------------------------------------------------------
-- FUNCTION: calculate_dynamic_price
-- Increases price based on how full the flight is
-- 0-50% booked  -> base price
-- 50-80% booked -> +20%
-- 80-95% booked -> +40%
-- 95-100% booked-> +75%
-- ------------------------------------------------------------
CREATE FUNCTION calculate_dynamic_price(p_flight_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_total_seats INT;
    DECLARE v_booked_seats INT;
    DECLARE v_ratio DECIMAL(5,4);
    DECLARE v_base_price DECIMAL(10,2);
    DECLARE v_new_price DECIMAL(10,2);

    SELECT COUNT(*) INTO v_total_seats FROM seats WHERE flight_id = p_flight_id;
    SELECT COUNT(*) INTO v_booked_seats FROM seats WHERE flight_id = p_flight_id AND status = 'BOOKED';
    SELECT base_price INTO v_base_price FROM flights WHERE flight_id = p_flight_id;

    IF v_total_seats = 0 THEN
        RETURN v_base_price;
    END IF;

    SET v_ratio = v_booked_seats / v_total_seats;

    IF v_ratio >= 0.95 THEN
        SET v_new_price = v_base_price * 1.75;
    ELSEIF v_ratio >= 0.80 THEN
        SET v_new_price = v_base_price * 1.40;
    ELSEIF v_ratio >= 0.50 THEN
        SET v_new_price = v_base_price * 1.20;
    ELSE
        SET v_new_price = v_base_price;
    END IF;

    RETURN ROUND(v_new_price, 2);
END$$


-- ------------------------------------------------------------
-- PROCEDURE: book_seat
-- Books a seat for a passenger with locking to prevent double booking
-- ------------------------------------------------------------
CREATE PROCEDURE book_seat(
    IN p_passenger_id INT,
    IN p_flight_id INT,
    IN p_seat_id INT,
    OUT p_booking_id INT,
    OUT p_message VARCHAR(255)
)
proc_block: BEGIN
    DECLARE v_seat_status VARCHAR(20);
    DECLARE v_price DECIMAL(10,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'Error occurred. Booking rolled back.';
    END;

    START TRANSACTION;

    -- Lock the seat row to prevent race conditions / double booking
    SELECT status INTO v_seat_status
    FROM seats
    WHERE seat_id = p_seat_id AND flight_id = p_flight_id
    FOR UPDATE;

    IF v_seat_status IS NULL THEN
        SET p_message = 'Seat does not exist for this flight.';
        ROLLBACK;
        LEAVE proc_block;
    ELSEIF v_seat_status <> 'AVAILABLE' THEN
        SET p_message = 'Seat already booked or locked.';
        ROLLBACK;
        LEAVE proc_block;
    END IF;

    -- Calculate current dynamic price
    SET v_price = calculate_dynamic_price(p_flight_id);

    -- Mark seat as booked
    UPDATE seats SET status = 'BOOKED' WHERE seat_id = p_seat_id;

    -- Insert booking record
    INSERT INTO bookings (passenger_id, flight_id, seat_id, fare_paid, status)
    VALUES (p_passenger_id, p_flight_id, p_seat_id, v_price, 'CONFIRMED');

    SET p_booking_id = LAST_INSERT_ID();

    -- Update flight's current_price to reflect new demand
    UPDATE flights SET current_price = calculate_dynamic_price(p_flight_id)
    WHERE flight_id = p_flight_id;

    -- Record payment as pending (app layer confirms it after gateway response)
    INSERT INTO payments (booking_id, amount, method, payment_status)
    VALUES (p_booking_id, v_price, 'CARD', 'PENDING');

    SET p_message = 'Booking successful.';
    COMMIT;
END$$


-- ------------------------------------------------------------
-- PROCEDURE: cancel_booking
-- Cancels a booking and calculates refund based on time-to-departure
-- >72 hrs before departure  -> 90% refund
-- 24-72 hrs before departure -> 50% refund
-- <24 hrs before departure   -> 0% refund
-- ------------------------------------------------------------
CREATE PROCEDURE cancel_booking(
    IN p_booking_id INT,
    OUT p_message VARCHAR(255)
)
proc_block: BEGIN
    DECLARE v_seat_id INT;
    DECLARE v_flight_id INT;
    DECLARE v_fare_paid DECIMAL(10,2);
    DECLARE v_departure DATETIME;
    DECLARE v_hours_remaining INT;
    DECLARE v_refund DECIMAL(10,2);
    DECLARE v_status VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'Error occurred. Cancellation rolled back.';
    END;

    START TRANSACTION;

    SELECT b.seat_id, b.flight_id, b.fare_paid, b.status, f.departure_time
    INTO v_seat_id, v_flight_id, v_fare_paid, v_status, v_departure
    FROM bookings b
    JOIN flights f ON b.flight_id = f.flight_id
    WHERE b.booking_id = p_booking_id
    FOR UPDATE;

    IF v_status IS NULL THEN
        SET p_message = 'Booking not found.';
        ROLLBACK;
        LEAVE proc_block;
    ELSEIF v_status = 'CANCELLED' THEN
        SET p_message = 'Booking already cancelled.';
        ROLLBACK;
        LEAVE proc_block;
    END IF;

    SET v_hours_remaining = TIMESTAMPDIFF(HOUR, NOW(), v_departure);

    IF v_hours_remaining >= 72 THEN
        SET v_refund = v_fare_paid * 0.90;
    ELSEIF v_hours_remaining >= 24 THEN
        SET v_refund = v_fare_paid * 0.50;
    ELSE
        SET v_refund = 0;
    END IF;

    -- Update booking status
    UPDATE bookings SET status = 'CANCELLED' WHERE booking_id = p_booking_id;

    -- Free up the seat
    UPDATE seats SET status = 'AVAILABLE' WHERE seat_id = v_seat_id;

    -- Log cancellation + refund
    INSERT INTO cancellations (booking_id, refund_amount, refund_status)
    VALUES (p_booking_id, v_refund, 'PENDING');

    -- Recalculate flight price since a seat freed up
    UPDATE flights SET current_price = calculate_dynamic_price(v_flight_id)
    WHERE flight_id = v_flight_id;

    SET p_message = CONCAT('Booking cancelled. Refund amount: ', v_refund);
    COMMIT;
END$$

DELIMITER ;
