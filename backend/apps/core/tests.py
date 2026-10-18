from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework import status
from decimal import Decimal
from datetime import date, time

from apps.accounts.models import User
from apps.departments.models import Department
from apps.shifts.models import Shift
from apps.staff.models import Staff
from apps.attendance.models import Attendance
from apps.advances.models import AdvanceSalary
from apps.payroll.models import Payroll
from apps.payroll.services import PayrollCalculator

class FactorySystemTests(TestCase):
    def setUp(self):
        self.client = APIClient()

        # Users
        self.admin = User.objects.create_superuser(username='test_admin', password='password123', role=User.Role.ADMIN)
        self.manager = User.objects.create_user(username='test_manager', password='password123', role=User.Role.MANAGER)
        self.supervisor = User.objects.create_user(username='test_supervisor', password='password123', role=User.Role.SUPERVISOR)

        # Department & Shift
        self.dept = Department.objects.create(name='Assembly', description='Assembly line')
        self.shift = Shift.objects.create(name='Day Shift', start_time=time(8, 0), end_time=time(16, 0))

        # Staff
        self.staff = Staff.objects.create(
            employee_code='STF100',
            full_name='Test Worker',
            phone='1234567890',
            joining_date=date(2024, 1, 1),
            department=self.dept,
            designation='Assembler',
            shift=self.shift,
            monthly_salary=Decimal('30000.00'),
            overtime_rate=Decimal('100.00'),
            status=Staff.Status.ACTIVE
        )

    def test_login_and_token_generation(self):
        """Verify JWT login returns token and user payload"""
        response = self.client.post('/api/auth/login/', {
            'username': 'test_admin',
            'password': 'password123'
        })
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # response.data contains 'access' and 'user' directly
        data = response.data.get('data', response.data)
        self.assertIn('access', data)
        self.assertEqual(data['user']['role'], 'ADMIN')

    def test_duplicate_employee_code_rejection(self):
        """Staff with existing employee_code must be rejected"""
        self.client.force_authenticate(user=self.admin)
        response = self.client.post('/api/staff/', {
            'employee_code': 'STF100', # Duplicate
            'full_name': 'Another Worker',
            'phone': '9999999999',
            'joining_date': '2024-01-01',
            'department': self.dept.id,
            'designation': 'Helper',
            'monthly_salary': '20000.00',
            'overtime_rate': '80.00',
        })
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_supervisor_cannot_change_salary(self):
        """Supervisor should not be allowed to modify staff salaries"""
        self.client.force_authenticate(user=self.supervisor)
        response = self.client.patch(f'/api/staff/{self.staff.id}/', {
            'monthly_salary': '50000.00'
        })
        # Supervisor cannot edit staff (requires IsManagerOrAdmin)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_duplicate_attendance_rejection(self):
        """Two attendance records on the same date for the same staff must be rejected"""
        test_date = date(2026, 9, 10)
        Attendance.objects.create(staff=self.staff, date=test_date, status=Attendance.Status.PRESENT)

        self.client.force_authenticate(user=self.supervisor)
        response = self.client.post('/api/attendance/', {
            'staff': self.staff.id,
            'date': '2026-09-10',
            'status': 'PRESENT',
            'overtime_hours': '0.00'
        })
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_overtime_hours_validation(self):
        """Overtime cannot be negative or exceed 12 hours"""
        self.client.force_authenticate(user=self.supervisor)
        response = self.client.post('/api/attendance/', {
            'staff': self.staff.id,
            'date': '2026-09-11',
            'status': 'PRESENT',
            'overtime_hours': '15.00' # Exceeds 12 max
        })
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_salary_calculation_math(self):
        """
        Test formula:
        Monthly Salary: 30,000 (Daily Rate: 1,000)
        Present: 26 days (26 * 1000 = 26,000)
        Half Day: 2 days (2 * 0.5 * 1000 = 1,000)
        Absent: 2 days (0)
        Paid days: 27 days => Base Payable = 27,000
        OT: 10 hrs * 100 = 1,000
        Gross: 30,000 + 1,000 = 31,000
        Advance: 2,000
        Net: 27,000 + 1,000 - 2,000 = 26,000
        """
        # Create attendance for 30 days
        for day in range(1, 27): # 26 present
            Attendance.objects.create(
                staff=self.staff,
                date=date(2026, 8, day),
                status=Attendance.Status.PRESENT,
                overtime_hours=Decimal('0.00')
            )
        # 2 half days with 5 OT hours each (Total 10 OT hours)
        Attendance.objects.create(staff=self.staff, date=date(2026, 8, 27), status=Attendance.Status.HALF_DAY, overtime_hours=Decimal('5.00'))
        Attendance.objects.create(staff=self.staff, date=date(2026, 8, 28), status=Attendance.Status.HALF_DAY, overtime_hours=Decimal('5.00'))
        # 2 absent days
        Attendance.objects.create(staff=self.staff, date=date(2026, 8, 29), status=Attendance.Status.ABSENT, overtime_hours=Decimal('0.00'))
        Attendance.objects.create(staff=self.staff, date=date(2026, 8, 30), status=Attendance.Status.ABSENT, overtime_hours=Decimal('0.00'))

        # Create advance of 2,000
        AdvanceSalary.objects.create(
            staff=self.staff,
            amount=Decimal('2000.00'),
            date=date(2026, 8, 15),
            status=AdvanceSalary.Status.APPROVED
        )

        # Calculate payroll for August 2026
        result = PayrollCalculator.calculate_employee_payroll(self.staff, month=8, year=2026)

        self.assertEqual(result['paid_days'], Decimal('27.00'))
        self.assertEqual(result['attendance_deduction'], Decimal('3000.00'))
        self.assertEqual(result['overtime_hours'], Decimal('10.00'))
        self.assertEqual(result['overtime_amount'], Decimal('1000.00'))
        self.assertEqual(result['gross_salary'], Decimal('31000.00'))
        self.assertEqual(result['advance_deduction'], Decimal('2000.00'))
        self.assertEqual(result['net_salary'], Decimal('26000.00'))

    def test_payroll_immutability_after_finalization(self):
        """Finalized payroll must be protected against automatic regeneration"""
        payroll = Payroll.objects.create(
            staff=self.staff,
            month=5,
            year=2026,
            base_salary=Decimal('30000.00'),
            paid_days=Decimal('30.00'),
            gross_salary=Decimal('30000.00'),
            net_salary=Decimal('30000.00'),
            status=Payroll.Status.FINALIZED
        )

        # Attempt to regenerate payroll
        generated, skipped = PayrollCalculator.generate_monthly_payroll(month=5, year=2026)
        self.assertIn(self.staff.employee_code, skipped)
        self.assertEqual(len(generated), 0)
