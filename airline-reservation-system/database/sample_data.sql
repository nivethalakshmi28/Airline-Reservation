-- ============================================================
-- Airline Reservation System - Sample Data
-- ============================================================
USE airline_reservation;

-- Aircraft
INSERT INTO aircraft (model, total_seats, economy_seats, business_seats) VALUES
('Boeing 737', 20, 16, 4),
('Airbus A320', 16, 12, 4);

-- Flights
INSERT INTO flights (flight_number, source, destination, departure_time, arrival_time, aircraft_id, base_price, current_price) VALUES
('AI101', 'Chennai', 'Delhi', '2026-08-15 06:00:00', '2026-08-15 08:30:00', 1, 4500.00, 4500.00),
('AI202', 'Mumbai', 'Bengaluru', '2026-08-16 10:00:00', '2026-08-16 11:45:00', 2, 3800.00, 3800.00),
('AI303', 'Delhi', 'Kolkata', '2026-08-17 14:00:00', '2026-08-17 16:15:00', 1, 5200.00, 5200.00);

-- Seats for Flight 1 (AI101) - aircraft_id 1 -> 16 economy + 4 business
INSERT INTO seats (flight_id, seat_number, class) VALUES
(1,'E1','ECONOMY'),(1,'E2','ECONOMY'),(1,'E3','ECONOMY'),(1,'E4','ECONOMY'),
(1,'E5','ECONOMY'),(1,'E6','ECONOMY'),(1,'E7','ECONOMY'),(1,'E8','ECONOMY'),
(1,'E9','ECONOMY'),(1,'E10','ECONOMY'),(1,'E11','ECONOMY'),(1,'E12','ECONOMY'),
(1,'E13','ECONOMY'),(1,'E14','ECONOMY'),(1,'E15','ECONOMY'),(1,'E16','ECONOMY'),
(1,'B1','BUSINESS'),(1,'B2','BUSINESS'),(1,'B3','BUSINESS'),(1,'B4','BUSINESS');

-- Seats for Flight 2 (AI202) - aircraft_id 2 -> 12 economy + 4 business
INSERT INTO seats (flight_id, seat_number, class) VALUES
(2,'E1','ECONOMY'),(2,'E2','ECONOMY'),(2,'E3','ECONOMY'),(2,'E4','ECONOMY'),
(2,'E5','ECONOMY'),(2,'E6','ECONOMY'),(2,'E7','ECONOMY'),(2,'E8','ECONOMY'),
(2,'E9','ECONOMY'),(2,'E10','ECONOMY'),(2,'E11','ECONOMY'),(2,'E12','ECONOMY'),
(2,'B1','BUSINESS'),(2,'B2','BUSINESS'),(2,'B3','BUSINESS'),(2,'B4','BUSINESS');

-- Seats for Flight 3 (AI303) - aircraft_id 1 -> 16 economy + 4 business
INSERT INTO seats (flight_id, seat_number, class) VALUES
(3,'E1','ECONOMY'),(3,'E2','ECONOMY'),(3,'E3','ECONOMY'),(3,'E4','ECONOMY'),
(3,'E5','ECONOMY'),(3,'E6','ECONOMY'),(3,'E7','ECONOMY'),(3,'E8','ECONOMY'),
(3,'E9','ECONOMY'),(3,'E10','ECONOMY'),(3,'E11','ECONOMY'),(3,'E12','ECONOMY'),
(3,'E13','ECONOMY'),(3,'E14','ECONOMY'),(3,'E15','ECONOMY'),(3,'E16','ECONOMY'),
(3,'B1','BUSINESS'),(3,'B2','BUSINESS'),(3,'B3','BUSINESS'),(3,'B4','BUSINESS');

-- Passengers
INSERT INTO passengers (full_name, email, phone, passport_number) VALUES
('Arun Kumar', 'arun.kumar@example.com', '9876543210', 'P1234567'),
('Priya Sharma', 'priya.sharma@example.com', '9123456780', 'P7654321'),
('Rahul Verma', 'rahul.verma@example.com', '9988776655', 'P1122334');

-- ------------------------------------------------------------
-- Sample bookings using the stored procedure
-- (Run these AFTER procedures.sql has been executed)
-- ------------------------------------------------------------
-- CALL book_seat(1, 1, 1, @booking_id, @message);
-- SELECT @booking_id, @message;

-- CALL book_seat(2, 1, 2, @booking_id2, @message2);
-- SELECT @booking_id2, @message2;

-- Example cancellation:
-- CALL cancel_booking(1, @cancel_message);
-- SELECT @cancel_message;
