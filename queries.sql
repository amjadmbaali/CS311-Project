-- =====================================================================
-- WASS Beauty: sample queries, schema changes and trigger tests
-- Run salon_database.sql first.
-- =====================================================================

USE WASSBeautySalon;

-- ---------------------------------------------------------------------
-- Query samples
-- ---------------------------------------------------------------------

-- Services that cost more than 150 SAR and take over an hour
SELECT *
FROM Services
WHERE Price > 150 AND Duration > '01:00:00';

-- Active and finished appointments
SELECT *
FROM Appointment
WHERE Status = 'Booked' OR Status = 'Completed';

-- Appointments with customer names (JOIN)
SELECT Customer.FirstName, Customer.LastName,
       Appointment.Date, Appointment.Time, Appointment.Status
FROM Appointment
INNER JOIN Customer ON Appointment.CustomerID = Customer.CustomerID;

-- Number of appointments per status (GROUP BY)
SELECT Status, COUNT(*) AS TotalAppointments
FROM Appointment
GROUP BY Status;

-- ---------------------------------------------------------------------
-- Trigger tests (each statement is expected to FAIL with error 1644)
-- ---------------------------------------------------------------------

-- Outside working hours -> "Appointment time must be between 09:00 and 23:00."
INSERT INTO Appointment (CustomerID, EmployeeID, ServiceID, Date, Time, Price)
VALUES (1, 2, 1, '2025-06-01', '08:00:00', 80.00);

-- Same employee, same date and time as appointment 1 -> double booking error
INSERT INTO Appointment (CustomerID, EmployeeID, ServiceID, Date, Time, Price)
VALUES (3, 2, 1, '2025-04-28', '09:00:00', 80.00);

-- Invalid payment method -> CHECK constraint violation
INSERT INTO Payment (AppointmentID, CustomerID, PaymentDate, PaymentMethod, InvoiceNumber)
VALUES (8, 2, '2025-05-11', 'Cash', '006');

-- ---------------------------------------------------------------------
-- ALTER TABLE examples (add, modify, drop column)
-- ---------------------------------------------------------------------

ALTER TABLE AppointmentService ADD ServiceName VARCHAR(50);
ALTER TABLE AppointmentService MODIFY ServiceName VARCHAR(60);
ALTER TABLE AppointmentService DROP COLUMN ServiceName;
