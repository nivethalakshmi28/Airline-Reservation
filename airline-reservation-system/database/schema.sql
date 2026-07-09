-- ============================================================
-- Airline Reservation System - Database Schema
-- ============================================================

DROP DATABASE IF EXISTS airline_reservation;
CREATE DATABASE airline_reservation;
USE airline_reservation;

-- ------------------------------------------------------------
-- Table: aircraft
-- ------------------------------------------------------------
CREATE TABLE aircraft (
    aircraft_id     INT AUTO_INCREMENT PRIMARY KEY,
    model           VARCHAR(50) NOT NULL,
    total_seats     INT NOT NULL,
    economy_seats   INT NOT NULL,
    business_seats  INT NOT NULL
);

-- ------------------------------------------------------------
-- Table: flights
-- ------------------------------------------------------------
CREATE TABLE flights (
    flight_id       INT AUTO_INCREMENT PRIMARY KEY,
    flight_number   VARCHAR(10) NOT NULL UNIQUE,
    source          VARCHAR(50) NOT NULL,
    destination     VARCHAR(50) NOT NULL,
    departure_time  DATETIME NOT NULL,
    arrival_time    DATETIME NOT NULL,
    aircraft_id     INT NOT NULL,
    base_price      DECIMAL(10,2) NOT NULL,
    current_price   DECIMAL(10,2) NOT NULL,
    status          ENUM('SCHEDULED','DELAYED','CANCELLED','COMPLETED') DEFAULT 'SCHEDULED',
    FOREIGN KEY (aircraft_id) REFERENCES aircraft(aircraft_id)
);

-- ------------------------------------------------------------
-- Table: seats
-- ------------------------------------------------------------
CREATE TABLE seats (
    seat_id         INT AUTO_INCREMENT PRIMARY KEY,
    flight_id       INT NOT NULL,
    seat_number     VARCHAR(5) NOT NULL,
    class           ENUM('ECONOMY','BUSINESS') NOT NULL,
    status          ENUM('AVAILABLE','BOOKED','LOCKED') DEFAULT 'AVAILABLE',
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id) ON DELETE CASCADE,
    UNIQUE KEY uq_flight_seat (flight_id, seat_number)
);

-- ------------------------------------------------------------
-- Table: passengers
-- ------------------------------------------------------------
CREATE TABLE passengers (
    passenger_id    INT AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(100) NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    phone           VARCHAR(15),
    passport_number VARCHAR(20),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- Table: bookings
-- ------------------------------------------------------------
CREATE TABLE bookings (
    booking_id      INT AUTO_INCREMENT PRIMARY KEY,
    passenger_id    INT NOT NULL,
    flight_id       INT NOT NULL,
    seat_id         INT NOT NULL,
    booking_date    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fare_paid       DECIMAL(10,2) NOT NULL,
    status          ENUM('CONFIRMED','CANCELLED','COMPLETED') DEFAULT 'CONFIRMED',
    FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id),
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id),
    FOREIGN KEY (seat_id) REFERENCES seats(seat_id)
);

-- ------------------------------------------------------------
-- Table: payments
-- ------------------------------------------------------------
CREATE TABLE payments (
    payment_id      INT AUTO_INCREMENT PRIMARY KEY,
    booking_id      INT NOT NULL,
    amount          DECIMAL(10,2) NOT NULL,
    method          ENUM('CARD','UPI','NETBANKING','WALLET') NOT NULL,
    payment_status  ENUM('SUCCESS','FAILED','PENDING') DEFAULT 'PENDING',
    payment_date    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

-- ------------------------------------------------------------
-- Table: cancellations
-- ------------------------------------------------------------
CREATE TABLE cancellations (
    cancellation_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id      INT NOT NULL,
    cancel_date     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    refund_amount   DECIMAL(10,2) NOT NULL,
    refund_status   ENUM('PENDING','PROCESSED','REJECTED') DEFAULT 'PENDING',
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

-- ------------------------------------------------------------
-- Table: booking_audit (for trigger logging)
-- ------------------------------------------------------------
CREATE TABLE booking_audit (
    audit_id        INT AUTO_INCREMENT PRIMARY KEY,
    booking_id      INT,
    action          VARCHAR(20),
    action_time     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    details         VARCHAR(255)
);

-- ------------------------------------------------------------
-- Indexes for performance
-- ------------------------------------------------------------
CREATE INDEX idx_flights_route ON flights(source, destination, departure_time);
CREATE INDEX idx_seats_flight_status ON seats(flight_id, status);
CREATE INDEX idx_bookings_passenger ON bookings(passenger_id);
