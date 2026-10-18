-- =====================================================================
-- WASS Beauty: Salon Reservation Management System
-- Database Systems (CS311) course project
-- MySQL 8+
--
-- Sample data is fictional.
-- =====================================================================

DROP DATABASE IF EXISTS WASSBeautySalon;
CREATE DATABASE WASSBeautySalon;
USE WASSBeautySalon;

-- ---------------------------------------------------------------------
-- 1. DDL: tables
-- ---------------------------------------------------------------------

CREATE TABLE Customer (
  CustomerID    INT AUTO_INCREMENT PRIMARY KEY,
  FirstName     VARCHAR(50)  NOT NULL,
  LastName      VARCHAR(50)  NOT NULL,
  PhoneNumber   VARCHAR(15)  NOT NULL,
  CustomerEmail VARCHAR(100) NOT NULL UNIQUE
);

-- Employee and ServiceCategory reference each other
-- (an employee belongs to a category, a category is overseen by a manager),
-- so the Employee -> ServiceCategory foreign key is added after both exist.
CREATE TABLE Employee (
  EmployeeID  INT AUTO_INCREMENT PRIMARY KEY,
  ManagerID   INT NULL,
  CategoryID  INT NULL,
  Salary      DECIMAL(10,2) NOT NULL,
  FirstName   VARCHAR(50)  NOT NULL,
  LastName    VARCHAR(50)  NOT NULL,
  PhoneNumber VARCHAR(15)  NOT NULL,
  Email       VARCHAR(100) NOT NULL UNIQUE,
  FOREIGN KEY (ManagerID) REFERENCES Employee(EmployeeID)
);

CREATE TABLE ServiceCategory (
  CategoryID   INT AUTO_INCREMENT PRIMARY KEY,
  CategoryName VARCHAR(50) NOT NULL,
  ManagerID    INT NOT NULL,
  FOREIGN KEY (ManagerID) REFERENCES Employee(EmployeeID)
);

ALTER TABLE Employee
  ADD FOREIGN KEY (CategoryID) REFERENCES ServiceCategory(CategoryID);

CREATE TABLE Services (
  ServiceID   INT AUTO_INCREMENT PRIMARY KEY,
  CategoryID  INT NOT NULL,
  ServiceName VARCHAR(50) NOT NULL,
  Duration    TIME NOT NULL,
  Price       DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (CategoryID) REFERENCES ServiceCategory(CategoryID)
);

CREATE TABLE Appointment (
  AppointmentID INT AUTO_INCREMENT PRIMARY KEY,
  CustomerID    INT NOT NULL,
  EmployeeID    INT NOT NULL,
  ServiceID     INT NOT NULL,
  Status        VARCHAR(50) NOT NULL DEFAULT 'Booked',
  CHECK (Status IN ('Booked', 'Cancelled', 'Completed')),
  Date          DATE NOT NULL,
  Time          TIME NOT NULL,
  Price         DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
  FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID),
  FOREIGN KEY (ServiceID)  REFERENCES Services(ServiceID)
);

-- Composite entity created during normalization (1NF):
-- one appointment can include several services.
CREATE TABLE AppointmentService (
  AppointmentID INT NOT NULL,
  ServiceID     INT NOT NULL,
  PRIMARY KEY (AppointmentID, ServiceID),
  FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID),
  FOREIGN KEY (ServiceID)     REFERENCES Services(ServiceID)
);

CREATE TABLE Payment (
  PaymentID     INT AUTO_INCREMENT PRIMARY KEY,
  AppointmentID INT UNIQUE,
  CustomerID    INT NOT NULL,
  PaymentDate   DATE NOT NULL,
  PaymentMethod VARCHAR(50) NOT NULL,
  CHECK (PaymentMethod IN ('Mada', 'Bank Transfer')),
  InvoiceNumber VARCHAR(50) NOT NULL,
  FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID),
  FOREIGN KEY (CustomerID)    REFERENCES Customer(CustomerID)
);

-- ---------------------------------------------------------------------
-- 2. Triggers: business rules enforced in the database
-- ---------------------------------------------------------------------

DELIMITER //

-- Appointments are allowed only during working hours (09:00 - 23:00)
CREATE TRIGGER checktime
BEFORE INSERT ON Appointment
FOR EACH ROW
BEGIN
  IF NEW.Time < '09:00:00' OR NEW.Time > '23:00:00' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Appointment time must be between 09:00 and 23:00.';
  END IF;
END//

-- An employee cannot have two appointments at the same date and time
CREATE TRIGGER prevent_double_booking
BEFORE INSERT ON Appointment
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1
    FROM Appointment
    WHERE EmployeeID = NEW.EmployeeID
      AND Date = NEW.Date
      AND Time = NEW.Time
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'This appointment is already booked for this employee at this time.';
  END IF;
END//

DELIMITER ;

-- ---------------------------------------------------------------------
-- 3. DML: sample data (fictional)
-- ---------------------------------------------------------------------

-- Salon manager first (no manager or category of her own)
INSERT INTO Employee (EmployeeID, ManagerID, CategoryID, Salary, FirstName, LastName, PhoneNumber, Email) VALUES
(1, NULL, NULL, 8000.00, 'Manager', 'One', '0500000001', 'manager@example.com');

INSERT INTO ServiceCategory (CategoryID, CategoryName, ManagerID) VALUES
(1, 'Hair Services', 1),
(2, 'Face Services', 1),
(3, 'Manicure and Pedicure', 1);

INSERT INTO Employee (ManagerID, CategoryID, Salary, FirstName, LastName, PhoneNumber, Email) VALUES
(1, 1, 6000.00, 'Stylist', 'A', '0500000002', 'stylist.a@example.com'),
(1, 1, 5500.80, 'Stylist', 'B', '0500000003', 'stylist.b@example.com'),
(1, 1, 5000.20, 'Stylist', 'C', '0500000004', 'stylist.c@example.com'),
(1, 2, 6500.25, 'Beautician', 'A', '0500000005', 'beautician.a@example.com'),
(1, 2, 5670.00, 'Beautician', 'B', '0500000006', 'beautician.b@example.com'),
(1, 2, 5200.80, 'Beautician', 'C', '0500000007', 'beautician.c@example.com'),
(1, 3, 5300.80, 'Nail Tech', 'A', '0500000008', 'nails.a@example.com'),
(1, 3, 5400.00, 'Nail Tech', 'B', '0500000009', 'nails.b@example.com'),
(1, 3, 5700.60, 'Nail Tech', 'C', '0500000010', 'nails.c@example.com');

INSERT INTO Services (CategoryID, ServiceName, Duration, Price) VALUES
(1, 'Haircut',          '00:30:00',  80.00),
(1, 'Hair Coloring',    '02:00:00', 250.00),
(1, 'Hair Straightening','02:00:00', 200.00),
(1, 'Hair Curling',     '01:30:00', 200.00),
(1, 'Hair Treatment',   '02:00:00', 300.00),
(1, 'Hair Extensions',  '02:30:00', 500.00),
(2, 'Facial Cleaning',  '01:00:00', 150.00),
(2, 'Makeup',           '01:30:00', 200.00),
(2, 'Bridal Makeup',    '02:00:00', 250.00),
(2, 'Eyebrow Shaping',  '00:30:00',  50.00),
(2, 'Lash Extension',   '00:45:00', 150.00),
(3, 'Manicure',         '00:30:00',  80.00),
(3, 'Pedicure',         '00:45:00',  90.00),
(3, 'Gel Manicure',     '00:45:00', 150.00),
(3, 'Nail Art',         '01:00:00', 200.00),
(3, 'French Manicure',  '00:45:00', 100.00);

INSERT INTO Customer (FirstName, LastName, PhoneNumber, CustomerEmail) VALUES
('Customer', 'One',   '0510000001', 'customer1@example.com'),
('Customer', 'Two',   '0510000002', 'customer2@example.com'),
('Customer', 'Three', '0510000003', 'customer3@example.com'),
('Customer', 'Four',  '0510000004', 'customer4@example.com'),
('Customer', 'Five',  '0510000005', 'customer5@example.com'),
('Customer', 'Six',   '0510000006', 'customer6@example.com');

INSERT INTO Appointment (CustomerID, EmployeeID, ServiceID, Status, Date, Time, Price) VALUES
(1, 2,  1, 'Booked',    '2025-04-28', '09:00:00', 300.00),
(2, 3,  5, 'Booked',    '2025-05-05', '10:00:00', 250.00),
(3, 5,  7, 'Booked',    '2025-05-06', '12:00:00', 400.00),
(4, 8, 12, 'Cancelled', '2025-05-06', '13:00:00', 100.00),
(5, 4,  4, 'Cancelled', '2025-05-06', '14:00:00', 350.00),
(6, 6,  8, 'Completed', '2025-05-09', '15:30:00', 250.00),
(1, 9, 13, 'Completed', '2025-05-10', '16:20:00', 170.00),
(2, 7, 10, 'Booked',    '2025-05-11', '18:00:00', 160.00);

INSERT INTO AppointmentService (AppointmentID, ServiceID) VALUES
(1, 1), (1, 2),
(2, 5),
(3, 7), (3, 10),
(4, 12),
(5, 4),
(6, 8),
(7, 13),
(8, 10);

INSERT INTO Payment (AppointmentID, CustomerID, PaymentDate, PaymentMethod, InvoiceNumber) VALUES
(1, 1, '2025-04-28', 'Bank Transfer', '001'),
(2, 2, '2025-05-05', 'Mada',          '002'),
(3, 3, '2025-05-06', 'Bank Transfer', '003'),
(6, 6, '2025-05-09', 'Mada',          '004'),
(7, 1, '2025-05-10', 'Mada',          '005');
