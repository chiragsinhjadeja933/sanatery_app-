from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import date, time, timedelta
from decimal import Decimal
import random

from apps.accounts.models import User
from apps.departments.models import Department
from apps.shifts.models import Shift
from apps.staff.models import Staff
from apps.attendance.models import Attendance
from apps.advances.models import AdvanceSalary
from apps.payroll.services import PayrollCalculator

class Command(BaseCommand):
    help = 'Seeds initial departments, shifts, staff, users, and realistic attendance/advance data for testing.'

    def handle(self, *args, **options):
        self.stdout.write("--- Starting Factory Data Seeding ---")

        # 1. Create Default Users for each role
        users_data = [
            ('admin', 'admin123', User.Role.ADMIN, 'System Admin', '9876543210', True),
            ('manager', 'manager123', User.Role.MANAGER, 'Factory Manager', '9876543211', False),
            ('supervisor', 'supervisor123', User.Role.SUPERVISOR, 'Floor Supervisor', '9876543212', False),
        ]

        for username, password, role, name, phone, is_super in users_data:
            user, created = User.objects.get_or_create(
                username=username,
                defaults={
                    'role': role,
                    'first_name': name.split()[0],
                    'last_name': name.split()[1] if len(name.split()) > 1 else '',
                    'phone': phone,
                    'is_staff': is_super,
                    'is_superuser': is_super,
                }
            )
            if created:
                user.set_password(password)
                user.save()
                self.stdout.write(self.style.SUCCESS(f"Created user: {username} (Role: {role}, Pass: {password})"))
            else:
                self.stdout.write(f"User {username} already exists.")

        # 2. Create Departments
        depts_data = [
            ("Production", "Main production floor and machine assembly"),
            ("Packaging", "Finished goods packing and sorting"),
            ("Quality Control", "Quality assessment and compliance"),
            ("Maintenance", "Machine and electrical repair operations"),
            ("Warehouse", "Raw materials and inventory logistics"),
        ]
        dept_objs = {}
        for name, desc in depts_data:
            dept, _ = Department.objects.get_or_create(
                name=name,
                defaults={'description': desc, 'is_active': True}
            )
            dept_objs[name] = dept
            self.stdout.write(f"Department: {name}")

        # 3. Create Shifts
        shifts_data = [
            ("Morning Shift", time(8, 0), time(16, 0)),
            ("Evening Shift", time(16, 0), time(0, 0)),
            ("Night Shift", time(0, 0), time(8, 0)),
        ]
        shift_objs = {}
        for name, st, et in shifts_data:
            shift, _ = Shift.objects.get_or_create(
                name=name,
                defaults={'start_time': st, 'end_time': et, 'is_active': True}
            )
            shift_objs[name] = shift
            self.stdout.write(f"Shift: {name} ({st.strftime('%H:%M')} - {et.strftime('%H:%M')})")

        # 4. Create Staff Members
        staff_data = [
            ("EMP001", "Rahul Patel", "9876500001", date(2024, 1, 15), "Production", "Senior Operator", "Morning Shift", Decimal("32000.00"), Decimal("150.00")),
            ("EMP002", "Amit Sharma", "9876500002", date(2024, 2, 1), "Packaging", "Packer Lead", "Morning Shift", Decimal("25000.00"), Decimal("100.00")),
            ("EMP003", "Priya Verma", "9876500003", date(2024, 3, 10), "Quality Control", "QC Inspector", "Evening Shift", Decimal("28000.00"), Decimal("120.00")),
            ("EMP004", "Suresh Kumar", "9876500004", date(2024, 4, 5), "Maintenance", "Electrician", "Morning Shift", Decimal("30000.00"), Decimal("130.00")),
            ("EMP005", "Ramesh Joshi", "9876500005", date(2024, 5, 20), "Warehouse", "Forklift Driver", "Evening Shift", Decimal("26000.00"), Decimal("110.00")),
            ("EMP006", "Vikram Singh", "9876500006", date(2024, 6, 12), "Production", "Helper", "Night Shift", Decimal("20000.00"), Decimal("90.00")),
        ]

        created_staff = []
        for code, name, phone, jdate, dept_name, desig, s_name, salary, ot_rate in staff_data:
            staff, created = Staff.objects.get_or_create(
                employee_code=code,
                defaults={
                    'full_name': name,
                    'phone': phone,
                    'joining_date': jdate,
                    'department': dept_objs[dept_name],
                    'designation': desig,
                    'shift': shift_objs[s_name],
                    'monthly_salary': salary,
                    'overtime_rate': ot_rate,
                    'status': Staff.Status.ACTIVE
                }
            )
            created_staff.append(staff)
            if created:
                self.stdout.write(self.style.SUCCESS(f"Created staff: {name} ({code}) - {dept_name}"))

        # 5. Create Sample Attendance for current month up to today
        today = timezone.localdate()
        current_month = today.month
        current_year = today.year

        start_of_month = date(current_year, current_month, 1)
        num_days = min(today.day, 28)

        self.stdout.write(f"Generating attendance from {start_of_month} to {today}...")
        for day_offset in range(num_days):
            att_date = start_of_month + timedelta(days=day_offset)
            for staff in created_staff:
                if Attendance.objects.filter(staff=staff, date=att_date).exists():
                    continue

                # Realistic distribution: 85% Present, 5% Half-day, 5% Leave, 5% Absent
                dice = random.random()
                if dice < 0.85:
                    status = Attendance.Status.PRESENT
                    # Some overtime on 25% of days
                    ot = Decimal(random.choice([0, 0, 0, 1.5, 2.0, 3.0]))
                elif dice < 0.90:
                    status = Attendance.Status.HALF_DAY
                    ot = Decimal('0.00')
                elif dice < 0.95:
                    status = Attendance.Status.LEAVE
                    ot = Decimal('0.00')
                else:
                    status = Attendance.Status.ABSENT
                    ot = Decimal('0.00')

                Attendance.objects.create(
                    staff=staff,
                    date=att_date,
                    status=status,
                    overtime_hours=ot,
                    remarks="Regular floor shift" if status == Attendance.Status.PRESENT else ""
                )

        # 6. Create Advance Salary
        if not AdvanceSalary.objects.filter(staff=created_staff[0], date__year=current_year, date__month=current_month).exists():
            AdvanceSalary.objects.create(
                staff=created_staff[0],
                amount=Decimal('2000.00'),
                date=date(current_year, current_month, min(10, today.day)),
                reason="Medical expense advance",
                status=AdvanceSalary.Status.APPROVED
            )
            self.stdout.write("Created advance of Rs. 2,000 for Rahul Patel.")

        # 7. Generate Draft Monthly Payroll
        generated, skipped = PayrollCalculator.generate_monthly_payroll(month=current_month, year=current_year)
        self.stdout.write(self.style.SUCCESS(f"Generated {len(generated)} draft payroll records for {current_month:02d}/{current_year}."))

        self.stdout.write(self.style.SUCCESS("--- Factory Data Seeding Finished Successfully ---"))
