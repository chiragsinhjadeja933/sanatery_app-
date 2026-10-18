from decimal import Decimal
from django.db import transaction
from django.db.models import Sum, Q
from django.utils import timezone
from apps.staff.models import Staff
from apps.attendance.models import Attendance
from apps.advances.models import AdvanceSalary
from .models import Payroll

class PayrollCalculator:
    """
    Authoritative Payroll Calculation Engine.
    Enforces the 30-day standard payroll calculation, overtime,
    attendance deduction, and advance deductions with complete snapshot preservation.
    """

    @classmethod
    def calculate_employee_payroll(cls, staff: Staff, month: int, year: int, pre_attendances=None, pre_advances=None) -> dict:
        """
        Computes all financial fields for a staff member for a given month/year.
        Returns a dictionary of snapshot values ready for Payroll model insertion.
        Supports pre-fetched attendance & advance collections for high-speed batch execution.
        """
        payroll_days = Decimal('30.00')
        base_salary = staff.monthly_salary
        overtime_rate = staff.overtime_rate
        daily_salary = (base_salary / payroll_days).quantize(Decimal('0.01'))

        # 1. Attendance aggregation
        if pre_attendances is not None:
            present_count = Decimal(sum(1 for a in pre_attendances if a.status == Attendance.Status.PRESENT))
            half_day_count = Decimal(sum(1 for a in pre_attendances if a.status == Attendance.Status.HALF_DAY))
            total_ot_hours = sum((Decimal(str(a.overtime_hours)) for a in pre_attendances), Decimal('0.00'))
        else:
            attendances = Attendance.objects.filter(
                staff=staff,
                date__year=year,
                date__month=month
            )
            present_count = Decimal(attendances.filter(status=Attendance.Status.PRESENT).count())
            half_day_count = Decimal(attendances.filter(status=Attendance.Status.HALF_DAY).count())
            total_ot_hours = attendances.aggregate(total_ot=Sum('overtime_hours'))['total_ot'] or Decimal('0.00')
        
        paid_days = (present_count * Decimal('1.0') + half_day_count * Decimal('0.5')).quantize(Decimal('0.01'))
        
        # Base payable earned
        base_payable = (paid_days * daily_salary).quantize(Decimal('0.01'))
        
        # Attendance deduction = (30 - paid_days) * daily_salary
        unpaid_days = max(Decimal('0.00'), payroll_days - paid_days)
        attendance_deduction = (unpaid_days * daily_salary).quantize(Decimal('0.01'))

        # 2. Overtime calculation
        overtime_amount = (total_ot_hours * overtime_rate).quantize(Decimal('0.01'))

        # Gross Salary = Base monthly salary + Overtime amount
        gross_salary = (base_salary + overtime_amount).quantize(Decimal('0.01'))

        # 3. Advance Salary Deductions for this month
        if pre_advances is not None:
            advance_deduction = sum((Decimal(str(adv.amount)) for adv in pre_advances), Decimal('0.00'))
        else:
            advances = AdvanceSalary.objects.filter(
                staff=staff,
                date__year=year,
                date__month=month,
                status__in=[AdvanceSalary.Status.APPROVED, AdvanceSalary.Status.DEDUCTED]
            )
            advance_deduction = advances.aggregate(total_adv=Sum('amount'))['total_adv'] or Decimal('0.00')

        # 4. Net Salary = Base Payable + Overtime Amount - Advance Deductions
        raw_net = base_payable + overtime_amount - advance_deduction
        net_salary = max(Decimal('0.00'), raw_net).quantize(Decimal('0.01'))

        return {
            'staff': staff,
            'month': month,
            'year': year,
            'base_salary': base_salary,
            'payroll_days': payroll_days,
            'paid_days': paid_days,
            'attendance_deduction': attendance_deduction,
            'overtime_hours': total_ot_hours,
            'overtime_rate': overtime_rate,
            'overtime_amount': overtime_amount,
            'gross_salary': gross_salary,
            'advance_deduction': advance_deduction,
            'other_deductions': Decimal('0.00'),
            'net_salary': net_salary,
            'status': Payroll.Status.DRAFT,
        }

    @classmethod
    def generate_monthly_payroll(cls, month: int, year: int, department_id: int = None) -> list:
        """
        Generates or updates DRAFT payrolls for active staff for the target month/year.
        Optimized with pre-aggregated batch queries to eliminate N+1 database round-trips.
        Will NOT overwrite records already in FINALIZED status.
        """
        from collections import defaultdict

        staff_qs = list(Staff.objects.filter(status=Staff.Status.ACTIVE))
        if department_id:
            staff_qs = [s for s in staff_qs if s.department_id == department_id]

        if not staff_qs:
            return [], []

        staff_ids = [s.id for s in staff_qs]

        # 1. Pre-query existing payroll records
        existing_payrolls = {
            p.staff_id: p for p in Payroll.objects.filter(month=month, year=year, staff_id__in=staff_ids)
        }

        # 2. Pre-query all monthly attendance records in ONE query
        all_attendances = Attendance.objects.filter(
            staff_id__in=staff_ids,
            date__year=year,
            date__month=month
        )
        attendances_by_staff = defaultdict(list)
        for att in all_attendances:
            attendances_by_staff[att.staff_id].append(att)

        # 3. Pre-query all approved/deducted advances in ONE query
        all_advances = AdvanceSalary.objects.filter(
            staff_id__in=staff_ids,
            date__year=year,
            date__month=month,
            status__in=[AdvanceSalary.Status.APPROVED, AdvanceSalary.Status.DEDUCTED]
        )
        advances_by_staff = defaultdict(list)
        for adv in all_advances:
            advances_by_staff[adv.staff_id].append(adv)

        generated_records = []
        skipped_finalized = []

        with transaction.atomic():
            for staff in staff_qs:
                existing = existing_payrolls.get(staff.id)
                if existing and existing.is_finalized:
                    skipped_finalized.append(staff.employee_code)
                    continue

                payroll_data = cls.calculate_employee_payroll(
                    staff, 
                    month, 
                    year,
                    pre_attendances=attendances_by_staff.get(staff.id, []),
                    pre_advances=advances_by_staff.get(staff.id, [])
                )

                if existing:
                    for key, val in payroll_data.items():
                        setattr(existing, key, val)
                    existing.save()
                    generated_records.append(existing)
                else:
                    payroll_record = Payroll.objects.create(**payroll_data)
                    generated_records.append(payroll_record)

        return generated_records, skipped_finalized

    @classmethod
    def finalize_payroll_record(cls, payroll: Payroll) -> Payroll:
        """
        Finalizes a single payroll record and marks corresponding advances as DEDUCTED.
        """
        if payroll.is_finalized:
            return payroll

        with transaction.atomic():
            payroll.status = Payroll.Status.FINALIZED
            payroll.finalized_at = timezone.now()
            payroll.save(update_fields=['status', 'finalized_at', 'updated_at'])

            # Mark associated advances as DEDUCTED
            AdvanceSalary.objects.filter(
                staff=payroll.staff,
                date__year=payroll.year,
                date__month=payroll.month,
                status=AdvanceSalary.Status.APPROVED
            ).update(status=AdvanceSalary.Status.DEDUCTED)

        return payroll
