# WASS Beauty – Salon Reservation Database

A relational database for a beauty salon that manages customers, services, employees, appointments and payments. Built as a team project for **CS311 – Database Systems** at Yanbu Industrial College.

The project covers the full database design cycle: requirements and business rules, conceptual design (ERD), normalization up to 3NF, and implementation in MySQL with constraints and triggers.

📄 **[Full project report](CS311_Report.pdf)**

## Business Rules

- Customers can book appointments only during working hours (9:00 AM – 11:00 PM)
- Payment method must be either Mada or Bank Transfer
- Every appointment has a status: Booked, Cancelled or Completed
- Every service has a duration
- A manager oversees all service categories and supervises the employees in them

## Database Design

Seven tables:

| Table                | Description                                   | Key relationships                         |
|----------------------|-----------------------------------------------|-------------------------------------------|
| `Customer`           | Salon customers                               | –                                         |
| `Employee`           | Staff, each with a manager and a category     | Self-reference (`ManagerID`), `ServiceCategory` |
| `ServiceCategory`    | Hair, Face, Manicure and Pedicure             | Managed by an `Employee`                  |
| `Services`           | Services with duration and price              | Belongs to a `ServiceCategory`            |
| `Appointment`        | Bookings with date, time, status and price    | `Customer`, `Employee`, `Services`        |
| `AppointmentService` | Composite entity: services in an appointment  | `Appointment` + `Services`                |
| `Payment`            | One payment per appointment                   | `Appointment` (unique), `Customer`        |

### Normalization

- **1NF:** the original `Appointment` table stored several service IDs in one field. These repeating values were moved to the composite table `AppointmentService`, so every column holds a single value.
- **2NF:** every non-key attribute depends on the whole primary key.
- **3NF:** transitive dependencies were removed, for example service details live in `Services` and are referenced by ID rather than repeated in appointments.

## Data Integrity

Business rules are enforced inside the database, not only in the application:

- **CHECK constraints** on appointment status and payment method
- **UNIQUE** on customer and employee emails, and on `Payment.AppointmentID` (one payment per appointment)
- **Trigger `checktime`:** rejects appointments outside working hours
- **Trigger `prevent_double_booking`:** rejects a booking if the employee already has an appointment at the same date and time

## Files

| File                  | Contents                                                       |
|-----------------------|----------------------------------------------------------------|
| `salon_database.sql`  | Creates the database, tables, constraints, triggers and sample data |
| `queries.sql`         | Sample queries (filters, JOIN, GROUP BY), trigger tests and ALTER TABLE examples |

## How to Run

1. Open MySQL Workbench (or any MySQL 8 client).
2. Run `salon_database.sql`.
3. Run the statements in `queries.sql` one by one. The trigger tests are expected to fail with error 1644, which shows the rules working.

## Team

Developed by Amjad Baali and teammates as part of CS311.

> Sample data is fictional.
