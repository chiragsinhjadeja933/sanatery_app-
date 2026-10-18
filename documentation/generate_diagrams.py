import os
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ArrowStyle

OUT_DIR = r"d:\flutter Project\sanatery_app\documentation"
os.makedirs(OUT_DIR, exist_ok=True)

# Set common font and style settings
plt.rcParams['font.sans-serif'] = 'Arial'
plt.rcParams['font.family'] = 'sans-serif'

def create_system_architecture():
    fig, ax = plt.subplots(figsize=(14, 10), dpi=300)
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 10)
    ax.axis('off')

    # Background canvas
    fig.patch.set_facecolor('#F8FAFC')
    ax.set_facecolor('#F8FAFC')

    # Header Title Banner
    ax.text(7, 9.6, "System Architecture: Sanitary Factory Workforce & Payroll ERP", 
            ha='center', va='center', fontsize=18, fontweight='bold', color='#0F172A')
    ax.text(7, 9.25, "Decoupled Cross-Platform Client • RESTful API Gateway • Django Modular Engine • Relational DB", 
            ha='center', va='center', fontsize=10, color='#64748B')

    # Layer 1: Presentation Layer (Flutter Client)
    p_rect = FancyBboxPatch((0.8, 6.7), 12.4, 2.2, boxstyle="round,pad=0.1,rounding_size=0.15",
                            facecolor='#FFFFFF', edgecolor='#06B6D4', linewidth=2)
    ax.add_patch(p_rect)
    ax.text(1.2, 8.6, "PRESENTATION LAYER — Cross-Platform Flutter Client App (Mobile / Tablet / Desktop)", 
            fontsize=11, fontweight='bold', color='#0891B2')

    # Client sub-boxes
    sub_modules = [
        ("Executive Dashboard\n& KPI Cards", 1.0, 6.9, 2.2, 1.4),
        ("Staff Master Directory\n& Profile Lifecycle", 3.4, 6.9, 2.2, 1.4),
        ("Daily Attendance Roster\n& Overtime Tracker", 5.8, 6.9, 2.2, 1.4),
        ("Advance Salary Ledger\n& Disbursal Modal", 8.2, 6.9, 2.2, 1.4),
        ("Payroll Computation\n& Payslip Generator", 10.6, 6.9, 2.4, 1.4)
    ]
    for title, x, y, w, h in sub_modules:
        box = FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.08,rounding_size=0.08",
                             facecolor='#F1F5F9', edgecolor='#CBD5E1', linewidth=1.2)
        ax.add_patch(box)
        ax.text(x + w/2, y + h/2, title, ha='center', va='center', fontsize=9, fontweight='bold', color='#1E293B')

    # Communication Bridge (HTTPS / JSON REST / JWT)
    ax.annotate('', xy=(7, 5.7), xytext=(7, 6.7),
                arrowprops=dict(arrowstyle="<->", color='#06B6D4', lw=2.5))
    ax.text(7, 6.2, "HTTPS RESTful APIs (JSON Payloads) • Bearer JWT Auth • Role Headers", 
            ha='center', va='center', fontsize=9, fontweight='bold', color='#0891B2',
            bbox=dict(boxstyle="round,pad=0.3", fc="#E0F2FE", ec="#0284C7", lw=1))

    # Layer 2: API Gateway & Application Middleware Layer
    gw_rect = FancyBboxPatch((0.8, 4.3), 12.4, 1.3, boxstyle="round,pad=0.1,rounding_size=0.15",
                             facecolor='#FFFFFF', edgecolor='#3B82F6', linewidth=2)
    ax.add_patch(gw_rect)
    ax.text(1.2, 5.3, "API GATEWAY & MIDDLEWARE LAYER (Django REST Framework 3.18 / Python 3.10+)", 
            fontsize=11, fontweight='bold', color='#1D4ED8')

    gw_items = [
        ("CORS Headers\nMiddleware", 1.0, 4.45, 2.2, 0.7),
        ("SimpleJWT Token\nAuthenticator", 3.4, 4.45, 2.2, 0.7),
        ("RBAC Permission\nClasses (Admin/Mgr/Sup)", 5.8, 4.45, 2.4, 0.7),
        ("Custom Exception\nStandard Renderer", 8.4, 4.45, 2.2, 0.7),
        ("Pagination &\nRate Limiting", 10.8, 4.45, 2.2, 0.7),
    ]
    for title, x, y, w, h in gw_items:
        box = FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.06,rounding_size=0.06",
                             facecolor='#EFF6FF', edgecolor='#BFDBFE', linewidth=1)
        ax.add_patch(box)
        ax.text(x + w/2, y + h/2, title, ha='center', va='center', fontsize=8.5, fontweight='bold', color='#1E40AF')

    # Communication Bridge to Backend Apps
    ax.annotate('', xy=(7, 3.4), xytext=(7, 4.3),
                arrowprops=dict(arrowstyle="->", color='#3B82F6', lw=2.5))

    # Layer 3: Backend Application Services (Django Modular Apps)
    app_rect = FancyBboxPatch((0.8, 1.9), 12.4, 1.4, boxstyle="round,pad=0.1,rounding_size=0.15",
                              facecolor='#FFFFFF', edgecolor='#10B981', linewidth=2)
    ax.add_patch(app_rect)
    ax.text(1.2, 3.05, "APPLICATION LOGIC & WORKFLOW LAYER (Django Modular Domain Apps)", 
            fontsize=11, fontweight='bold', color='#047857')

    app_modules = [
        ("apps.accounts\n(Custom User, Auth)", 1.0, 2.05, 2.2, 0.8),
        ("apps.staff / dept / shifts\n(Master Directories)", 3.4, 2.05, 2.3, 0.8),
        ("apps.attendance\n(Roster & Atomic Bulk)", 5.9, 2.05, 2.3, 0.8),
        ("apps.advances\n(Disbursal & Lifecycle)", 8.4, 2.05, 2.3, 0.8),
        ("apps.payroll & dashboard\n(Formula Engine & KPIs)", 10.9, 2.05, 2.1, 0.8)
    ]
    for title, x, y, w, h in app_modules:
        box = FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.06,rounding_size=0.06",
                             facecolor='#ECFDF5', edgecolor='#A7F3D0', linewidth=1)
        ax.add_patch(box)
        ax.text(x + w/2, y + h/2, title, ha='center', va='center', fontsize=8.5, fontweight='bold', color='#065F46')

    # Communication Bridge to Persistence Layer (Django ORM)
    ax.annotate('', xy=(7, 1.1), xytext=(7, 1.9),
                arrowprops=dict(arrowstyle="<->", color='#10B981', lw=2.5))
    ax.text(7, 1.5, "Django ORM • ACID Transactions • Foreign Key Integrity Constraints", 
            ha='center', va='center', fontsize=8.5, fontweight='bold', color='#047857',
            bbox=dict(boxstyle="round,pad=0.2", fc="#DCFCE7", ec="#16A34A", lw=0.8))

    # Layer 4: Relational Data Persistence Layer
    db_rect = FancyBboxPatch((0.8, 0.2), 12.4, 0.85, boxstyle="round,pad=0.1,rounding_size=0.15",
                             facecolor='#0F172A', edgecolor='#0F172A', linewidth=1.5)
    ax.add_patch(db_rect)
    ax.text(7, 0.62, "DATA PERSISTENCE LAYER — Relational Database Management System", 
            ha='center', va='center', fontsize=11, fontweight='bold', color='#FFFFFF')
    ax.text(7, 0.35, "PostgreSQL 15+ (Production Environment) / SQLite 3 (Staging & Testing)  |  ACID Transactional Guarantees", 
            ha='center', va='center', fontsize=9, color='#94A3B8')

    plt.tight_layout()
    plt.savefig(os.path.join(OUT_DIR, "System_Architecture.png"), dpi=300, facecolor=fig.get_facecolor(), edgecolor='none')
    plt.close()
    print("System_Architecture.png created successfully.")

def create_application_flowchart():
    fig, ax = plt.subplots(figsize=(13, 11), dpi=300)
    ax.set_xlim(0, 13)
    ax.set_ylim(0, 11)
    ax.axis('off')

    fig.patch.set_facecolor('#F8FAFC')
    ax.set_facecolor('#F8FAFC')

    # Header
    ax.text(6.5, 10.6, "Overall Application Flowchart: Factory Workforce & Payroll ERP", 
            ha='center', va='center', fontsize=17, fontweight='bold', color='#0F172A')
    ax.text(6.5, 10.3, "End-to-End Operational Workflow from Supervisor Login to Monthly Payslip Generation", 
            ha='center', va='center', fontsize=9.5, color='#64748B')

    # Helper function for nodes
    def draw_node(x, y, w, h, text, shape='rect', fc='#FFFFFF', ec='#0F172A', tc='#0F172A', fs=9):
        if shape == 'start_end':
            box = FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.1,rounding_size=0.3",
                                 facecolor=fc, edgecolor=ec, linewidth=1.8)
        elif shape == 'decision':
            # diamond patch
            poly = plt.Polygon([[x + w/2, y], [x + w, y + h/2], [x + w/2, y + h], [x, y + h/2]],
                               closed=True, facecolor=fc, edgecolor=ec, linewidth=1.8)
            ax.add_patch(poly)
            ax.text(x + w/2, y + h/2, text, ha='center', va='center', fontsize=fs, fontweight='bold', color=tc)
            return
        else: # rect
            box = FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.08,rounding_size=0.08",
                                 facecolor=fc, edgecolor=ec, linewidth=1.5)
        ax.add_patch(box)
        ax.text(x + w/2, y + h/2, text, ha='center', va='center', fontsize=fs, fontweight='bold', color=tc)

    # 1. Start Node
    draw_node(5.25, 9.5, 2.5, 0.55, "START APP", 'start_end', fc='#0F172A', ec='#0F172A', tc='#FFFFFF', fs=10)

    # Arrow down
    ax.annotate('', xy=(6.5, 8.85), xytext=(6.5, 9.5), arrowprops=dict(arrowstyle="->", color='#0F172A', lw=1.5))

    # 2. Login Screen
    draw_node(4.8, 8.2, 3.4, 0.65, "Input Credentials\n(Username & Password)", 'rect', fc='#FFFFFF', ec='#3B82F6', tc='#1E3A8A')

    # Arrow down
    ax.annotate('', xy=(6.5, 7.55), xytext=(6.5, 8.2), arrowprops=dict(arrowstyle="->", color='#0F172A', lw=1.5))

    # 3. Auth Check Decision
    draw_node(5.0, 6.7, 3.0, 0.85, "JWT Auth\nValid?", 'decision', fc='#FEF3C7', ec='#D97706', tc='#92400E', fs=9)

    # Fail path (loops back to login)
    ax.annotate('', xy=(8.2, 8.5), xytext=(8.0, 7.12), arrowprops=dict(arrowstyle="->", color='#EF4444', lw=1.5, connectionstyle="angle,angleA=0,angleB=90,rad=10"))
    ax.text(8.3, 7.7, "Invalid (401)\nShow Error", fontsize=8, fontweight='bold', color='#DC2626')

    # Success path
    ax.annotate('', xy=(6.5, 6.0), xytext=(6.5, 6.7), arrowprops=dict(arrowstyle="->", color='#10B981', lw=1.5))
    ax.text(6.65, 6.35, "Yes (200 OK)", fontsize=8, fontweight='bold', color='#059669')

    # 4. Role Dispatcher
    draw_node(4.5, 5.35, 4.0, 0.65, "Load Main Navigation Shell\n& Factory Dashboard KPIs", 'rect', fc='#ECFDF5', ec='#10B981', tc='#065F46')

    # Arrow down to Operations Branch
    ax.annotate('', xy=(6.5, 4.7), xytext=(6.5, 5.35), arrowprops=dict(arrowstyle="->", color='#0F172A', lw=1.5))

    # 5. Core Operational Modules Navigation
    draw_node(4.3, 4.0, 4.4, 0.7, "Operational Module Selection\n(Bottom Navigation & App Drawer)", 'rect', fc='#FFFFFF', ec='#64748B', tc='#0F172A')

    # Three Branch Arrows: Attendance (Left), Advances (Center), Month-End Payroll (Right)
    # Left Branch: Daily Attendance
    ax.annotate('', xy=(2.0, 3.3), xytext=(4.3, 4.35), arrowprops=dict(arrowstyle="->", color='#0284C7', lw=1.5, connectionstyle="angle,angleA=180,angleB=90,rad=8"))
    draw_node(0.5, 2.3, 3.0, 1.0, "Daily Attendance & OT\n1. Select Date & Dept\n2. Mark Status (P / H / A)\n3. Enter Overtime (0-12h)\n4. Submit Atomic Bulk Mark", 'rect', fc='#E0F2FE', ec='#0284C7', tc='#075985', fs=8)

    # Center Branch: Staff Master & Advances
    ax.annotate('', xy=(6.5, 3.3), xytext=(6.5, 4.0), arrowprops=dict(arrowstyle="->", color='#7C3AED', lw=1.5))
    draw_node(5.0, 2.3, 3.0, 1.0, "Mid-Month Advances\n1. Worker requests advance\n2. Manager records amount\n3. Status: APPROVED\n4. Disbursed to worker", 'rect', fc='#F5F3FF', ec='#7C3AED', tc='#5B21B6', fs=8)

    # Right Branch: Payroll Engine
    ax.annotate('', xy=(11.0, 3.3), xytext=(8.7, 4.35), arrowprops=dict(arrowstyle="->", color='#D97706', lw=1.5, connectionstyle="angle,angleA=0,angleB=90,rad=8"))
    draw_node(9.5, 2.3, 3.0, 1.0, "Monthly Payroll Generation\n1. Select Month & Year\n2. Compute Base & OT Pay\n3. Deduct Advances\n4. Review DRAFT Payroll", 'rect', fc='#FFFBEB', ec='#D97706', tc='#B45309', fs=8)

    # Converge into Finalization & Ledger Locking
    ax.annotate('', xy=(6.5, 1.45), xytext=(2.0, 2.3), arrowprops=dict(arrowstyle="->", color='#64748B', lw=1.2, connectionstyle="angle,angleA=-90,angleB=180,rad=8"))
    ax.annotate('', xy=(6.5, 1.45), xytext=(6.5, 2.3), arrowprops=dict(arrowstyle="->", color='#64748B', lw=1.2))
    ax.annotate('', xy=(6.5, 1.45), xytext=(11.0, 2.3), arrowprops=dict(arrowstyle="->", color='#64748B', lw=1.2, connectionstyle="angle,angleA=-90,angleB=0,rad=8"))

    draw_node(4.2, 0.95, 4.6, 0.65, "Admin Finalizes Payroll (Lock Records)\nAdvances Marked DEDUCTED  •  Generate Payslips", 'rect', fc='#FEF2F2', ec='#EF4444', tc='#991B1B')

    # Arrow down to Exit
    ax.annotate('', xy=(6.5, 0.55), xytext=(6.5, 0.95), arrowprops=dict(arrowstyle="->", color='#0F172A', lw=1.5))
    draw_node(5.3, 0.1, 2.4, 0.45, "LOGOUT / EXIT", 'start_end', fc='#0F172A', ec='#0F172A', tc='#FFFFFF', fs=9.5)

    plt.tight_layout()
    plt.savefig(os.path.join(OUT_DIR, "Application_Flowchart.png"), dpi=300, facecolor=fig.get_facecolor(), edgecolor='none')
    plt.close()
    print("Application_Flowchart.png created successfully.")

def create_er_diagram():
    fig, ax = plt.subplots(figsize=(15, 11), dpi=300)
    ax.set_xlim(0, 15)
    ax.set_ylim(0, 11)
    ax.axis('off')

    fig.patch.set_facecolor('#F8FAFC')
    ax.set_facecolor('#F8FAFC')

    # Header
    ax.text(7.5, 10.6, "Relational Entity-Relationship Diagram (ERD)", 
            ha='center', va='center', fontsize=18, fontweight='bold', color='#0F172A')
    ax.text(7.5, 10.25, "Production Database Schema: PostgreSQL 15+ / Django ORM Entities with Foreign Key Integrity", 
            ha='center', va='center', fontsize=10, color='#64748B')

    def draw_entity_table(x, y, w, title, fields, header_color='#0F172A'):
        row_height = 0.32
        header_height = 0.45
        total_height = header_height + len(fields) * row_height

        # Outer box
        rect = FancyBboxPatch((x, y - total_height), w, total_height, boxstyle="round,pad=0.04,rounding_size=0.08",
                              facecolor='#FFFFFF', edgecolor='#CBD5E1', linewidth=1.5)
        ax.add_patch(rect)

        # Header box
        h_rect = FancyBboxPatch((x, y - header_height), w, header_height, boxstyle="round,pad=0.04,rounding_size=0.08",
                                facecolor=header_color, edgecolor=header_color, linewidth=1)
        ax.add_patch(h_rect)
        ax.text(x + w/2, y - header_height/2, title, ha='center', va='center', fontsize=9.5, fontweight='bold', color='#FFFFFF')

        # Fields
        for i, (fname, ftype, fcon) in enumerate(fields):
            row_y = y - header_height - (i + 0.5) * row_height
            # Draw line separator
            if i > 0:
                ax.plot([x, x + w], [y - header_height - i * row_height, y - header_height - i * row_height], color='#F1F5F9', lw=1)
            
            # Key indicator
            if 'PK' in fcon:
                ax.text(x + 0.15, row_y, "PK", fontsize=7.5, fontweight='bold', color='#D97706', va='center')
            elif 'FK' in fcon:
                ax.text(x + 0.15, row_y, "FK", fontsize=7.5, fontweight='bold', color='#2563EB', va='center')
            elif 'UK' in fcon:
                ax.text(x + 0.15, row_y, "UK", fontsize=7.5, fontweight='bold', color='#059669', va='center')
            else:
                ax.text(x + 0.15, row_y, "•", fontsize=8, color='#94A3B8', va='center')

            ax.text(x + 0.6, row_y, fname, fontsize=8.5, fontweight='bold', color='#1E293B', va='center')
            ax.text(x + w - 0.15, row_y, f"{ftype} [{fcon}]", fontsize=7.5, color='#64748B', ha='right', va='center')

        return y - total_height

    # 1. ACCOUNTS_USER (Top Left)
    draw_entity_table(0.8, 9.8, 3.8, "accounts_user", [
        ("id", "BIGSERIAL", "PK"),
        ("username", "VARCHAR(150)", "UK"),
        ("password", "VARCHAR(128)", "NN"),
        ("role", "VARCHAR(20)", "ADMIN|MGR|SUP"),
        ("phone", "VARCHAR(20)", ""),
        ("is_active", "BOOLEAN", "DEFAULT TRUE"),
        ("date_joined", "TIMESTAMPTZ", "NN"),
    ], header_color='#1E293B')

    # 2. DEPARTMENTS_DEPARTMENT (Top Center)
    draw_entity_table(5.6, 9.8, 3.8, "departments_department", [
        ("id", "BIGSERIAL", "PK"),
        ("name", "VARCHAR(100)", "UK"),
        ("description", "TEXT", ""),
        ("is_active", "BOOLEAN", "DEFAULT TRUE"),
        ("created_at", "TIMESTAMPTZ", "NN"),
        ("updated_at", "TIMESTAMPTZ", "NN"),
    ], header_color='#0284C7')

    # 3. SHIFTS_SHIFT (Top Right)
    draw_entity_table(10.4, 9.8, 3.8, "shifts_shift", [
        ("id", "BIGSERIAL", "PK"),
        ("name", "VARCHAR(50)", "UK"),
        ("start_time", "TIME", "NN"),
        ("end_time", "TIME", "NN"),
        ("is_active", "BOOLEAN", "DEFAULT TRUE"),
        ("created_at", "TIMESTAMPTZ", "NN"),
        ("updated_at", "TIMESTAMPTZ", "NN"),
    ], header_color='#0284C7')

    # 4. STAFF_STAFF (Central Entity)
    draw_entity_table(5.4, 6.7, 4.2, "staff_staff", [
        ("id", "BIGSERIAL", "PK"),
        ("employee_code", "VARCHAR(30)", "UK, IDX"),
        ("full_name", "VARCHAR(150)", "NN"),
        ("phone", "VARCHAR(20)", "NN"),
        ("joining_date", "DATE", "NN"),
        ("department_id", "BIGINT", "FK -> departments"),
        ("designation", "VARCHAR(100)", "NN"),
        ("shift_id", "BIGINT", "FK -> shifts"),
        ("salary_type", "VARCHAR(20)", "MONTHLY"),
        ("monthly_salary", "NUMERIC(12,2)", ">= 0"),
        ("overtime_rate", "NUMERIC(10,2)", ">= 0"),
        ("status", "VARCHAR(20)", "ACTIVE|INACTIVE"),
        ("created_at", "TIMESTAMPTZ", "NN"),
        ("updated_at", "TIMESTAMPTZ", "NN"),
    ], header_color='#0F766E')

    # 5. ATTENDANCE_ATTENDANCE (Bottom Left)
    draw_entity_table(0.6, 3.3, 4.3, "attendance_attendance", [
        ("id", "BIGSERIAL", "PK"),
        ("staff_id", "BIGINT", "FK -> staff"),
        ("date", "DATE", "IDX"),
        ("status", "VARCHAR(20)", "P|H|A|L"),
        ("overtime_hours", "NUMERIC(4,2)", "0.0 - 12.0"),
        ("remarks", "VARCHAR(255)", ""),
        ("created_at", "TIMESTAMPTZ", "NN"),
        ("updated_at", "TIMESTAMPTZ", "NN"),
        ("CONSTRAINT", "UNIQUE", "staff_id, date"),
    ], header_color='#4338CA')

    # 6. ADVANCES_ADVANCESALARY (Bottom Center)
    draw_entity_table(5.4, 2.5, 4.2, "advances_advancesalary", [
        ("id", "BIGSERIAL", "PK"),
        ("staff_id", "BIGINT", "FK -> staff"),
        ("amount", "NUMERIC(12,2)", "> 0"),
        ("date", "DATE", "NN, IDX"),
        ("reason", "VARCHAR(255)", ""),
        ("status", "VARCHAR(20)", "APP|DED|CAN"),
        ("created_at", "TIMESTAMPTZ", "NN"),
        ("updated_at", "TIMESTAMPTZ", "NN"),
    ], header_color='#9333EA')

    # 7. PAYROLL_PAYROLL (Bottom Right)
    draw_entity_table(10.1, 3.5, 4.4, "payroll_payroll", [
        ("id", "BIGSERIAL", "PK"),
        ("staff_id", "BIGINT", "FK -> staff"),
        ("month", "SMALLINT", "1-12"),
        ("year", "SMALLINT", "NN"),
        ("base_salary", "NUMERIC(12,2)", "SNAPSHOT"),
        ("paid_days", "NUMERIC(4,2)", "0.0 - 31.0"),
        ("attendance_deduction", "NUMERIC(12,2)", "NN"),
        ("overtime_hours", "NUMERIC(6,2)", "SUM"),
        ("overtime_rate", "NUMERIC(10,2)", "SNAPSHOT"),
        ("overtime_amount", "NUMERIC(12,2)", "NN"),
        ("gross_salary", "NUMERIC(12,2)", "NN"),
        ("advance_deduction", "NUMERIC(12,2)", "SUM"),
        ("net_salary", "NUMERIC(12,2)", ">= 0"),
        ("status", "VARCHAR(20)", "DRAFT|FINAL"),
        ("generated_at", "TIMESTAMPTZ", "NN"),
        ("finalized_at", "TIMESTAMPTZ", "NULL"),
        ("CONSTRAINT", "UNIQUE", "staff, month, year"),
    ], header_color='#C2410C')

    # Relationships Lines
    # Dept to Staff
    ax.annotate("", xy=(7.2, 6.7), xytext=(7.2, 7.3),
                arrowprops=dict(arrowstyle="->", color='#0284C7', lw=2))
    ax.text(7.3, 7.0, "1 : N (employs)", fontsize=8, fontweight='bold', color='#0284C7')

    # Shift to Staff
    ax.annotate("", xy=(8.5, 6.7), xytext=(11.5, 7.5),
                arrowprops=dict(arrowstyle="->", color='#0284C7', lw=2, connectionstyle="arc3,rad=-0.2"))
    ax.text(10.2, 7.2, "1 : N (assigns)", fontsize=8, fontweight='bold', color='#0284C7')

    # Staff to Attendance
    ax.annotate("", xy=(3.5, 3.3), xytext=(5.5, 4.5),
                arrowprops=dict(arrowstyle="->", color='#4338CA', lw=2, connectionstyle="arc3,rad=0.2"))
    ax.text(3.7, 4.1, "1 : N (records)", fontsize=8, fontweight='bold', color='#4338CA')

    # Staff to Advances
    ax.annotate("", xy=(7.5, 2.5), xytext=(7.5, 2.8),
                arrowprops=dict(arrowstyle="->", color='#9333EA', lw=2))
    ax.text(7.6, 2.65, "1 : N (disburses)", fontsize=8, fontweight='bold', color='#9333EA')

    # Staff to Payroll
    ax.annotate("", xy=(11.5, 3.5), xytext=(9.6, 4.5),
                arrowprops=dict(arrowstyle="->", color='#C2410C', lw=2, connectionstyle="arc3,rad=-0.2"))
    ax.text(10.7, 4.2, "1 : N (computes)", fontsize=8, fontweight='bold', color='#C2410C')

    plt.tight_layout()
    plt.savefig(os.path.join(OUT_DIR, "ER_Diagram.png"), dpi=300, facecolor=fig.get_facecolor(), edgecolor='none')
    plt.close()
    print("ER_Diagram.png created successfully.")

if __name__ == '__main__':
    create_system_architecture()
    create_application_flowchart()
    create_er_diagram()
