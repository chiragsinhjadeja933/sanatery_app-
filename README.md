# Sanitary & Ceramic Factory Workforce & Payroll Management System

An industrial ERP and workforce management platform tailored for Sanitary & Ceramic manufacturing facilities. Built with **Flutter (Riverpod 2.6, Dio 5.7)** on the frontend and **Django REST Framework (DRF)** with **SQLite / PostgreSQL** on the backend.

---

## 🌟 Key Features

- **Role-Based Access Control (RBAC):** Distinct dashboards and workflows for `ADMIN`, `MANAGER`, and `SUPERVISOR`.
- **Flexible Work Shifts:** Dynamic shift duration calculation (6h, 8h, 10h, 12h, and overnight shifts).
- **Automated Overtime Engine:** Proportional hourly wage calculation and **1.5× Overtime Formulation** based on assigned shift duration.
- **Daily Attendance Roster:** Atomic bulk upsert for entire production lines with real-time overtime hour capture.
- **Salary Advances & Loan Tracking:** Mid-month advance disbursement lifecycle with automated deductions during payroll calculation.
- **Formula-Driven Payroll:** 30-day standard industrial payroll generation with draft adjustments and finalization locking.
- **Offline Attendance Caching:** Local draft persistence in Flutter when factory floor connectivity is spotty.
- **Silent JWT Token Refresh:** Seamless auto-renewal of sessions on 401 Unauthorized via refresh tokens.

---

## 🏗️ Architecture & Database Tables

```
users ──< staff >── attendance
             │
             ├──< advances
             │
             └──< payroll
```

* **`users`**: System operator accounts with roles (`ADMIN`, `MANAGER`, `SUPERVISOR`).
* **`departments`**: Factory production divisions (Moulding, Kiln, Glazing, Quality, Packing).
* **`shifts`**: Work shift schedules with dynamic duration hours.
* **`staff`**: Master employee directory, wage rates, and shift assignments.
* **`attendance`**: Daily presence records and overtime hours.
* **`advances`**: Cash advances and loan ledger.
* **`payroll`**: Monthly payroll calculation snapshots with audit locking.

---

## 🚀 Quick Start Guide

### 1. Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.12+ / Dart 3+)
- [Python](https://www.python.org/downloads/) (v3.10+)

---

### 2. Backend Setup (Django REST Framework)

1. Open a terminal in the root directory and navigate to `backend/`:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   pip install django djangorestframework djangorestframework-simplejwt django-cors-headers python-dotenv psycopg2-binary
   ```

3. Configure environment:
   ```bash
   copy .env.example .env
   ```

4. Run migrations:
   ```bash
   python manage.py migrate
   ```

5. Seed demo factory data (departments, shifts, staff, users):
   ```bash
   python manage.py seed_factory_data
   ```

6. Start the backend server:
   ```bash
   python manage.py runserver 127.0.0.1:8000
   ```

---

### 3. Frontend Setup (Flutter App)

1. In the project root, fetch dependencies:
   ```bash
   flutter pub get
   ```

2. Launch the application:
   * **Chrome (Web):**
     ```bash
     flutter run -d chrome --web-port=3000
     ```
   * **Windows Desktop:**
     ```bash
     flutter run -d windows
     ```

---

### 🔑 Default Credentials

| Role | Username | Password |
| :--- | :--- | :--- |
| **Admin** | `admin` | `admin123` |
| **Manager** | `manager` | `manager123` |
| **Supervisor** | `supervisor` | `supervisor123` |

---

## 📄 License
This project is licensed under the MIT License.
