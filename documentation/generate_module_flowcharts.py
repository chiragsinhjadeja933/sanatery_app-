import os
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch

OUT_DIR = r"d:\flutter Project\sanatery_app\documentation"
os.makedirs(OUT_DIR, exist_ok=True)

plt.rcParams['font.sans-serif'] = 'Arial'
plt.rcParams['font.family'] = 'sans-serif'

def draw_node(ax, x, y, w, h, text, shape='rect', fc='#FFFFFF', ec='#0F172A', tc='#0F172A', fs=8.5):
    if shape == 'start_end':
        box = FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.08,rounding_size=0.25",
                             facecolor=fc, edgecolor=ec, linewidth=1.5)
        ax.add_patch(box)
    elif shape == 'decision':
        poly = plt.Polygon([[x + w/2, y], [x + w, y + h/2], [x + w/2, y + h], [x, y + h/2]],
                           closed=True, facecolor=fc, edgecolor=ec, linewidth=1.5)
        ax.add_patch(poly)
    else:
        box = FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.06,rounding_size=0.06",
                             facecolor=fc, edgecolor=ec, linewidth=1.3)
        ax.add_patch(box)
    ax.text(x + w/2, y + h/2, text, ha='center', va='center', fontsize=fs, fontweight='bold', color=tc)

def create_attendance_flowchart():
    fig, ax = plt.subplots(figsize=(12, 7), dpi=300)
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 7)
    ax.axis('off')
    fig.patch.set_facecolor('#F8FAFC')
    ax.set_facecolor('#F8FAFC')

    ax.text(6, 6.6, "Daily Attendance & Overtime Processing Workflow", 
            ha='center', va='center', fontsize=14, fontweight='bold', color='#0F172A')

    # Start
    draw_node(ax, 0.5, 3.0, 1.8, 0.6, "START\nRoster View", 'start_end', fc='#0F172A', ec='#0F172A', tc='#FFFFFF')
    ax.annotate('', xy=(2.9, 3.3), xytext=(2.3, 3.3), arrowprops=dict(arrowstyle="->", color='#0F172A', lw=1.5))

    # Fetch Roster
    draw_node(ax, 2.9, 2.8, 2.2, 1.0, "Select Date &\nDepartment Filter\nFetch /daily_roster/", 'rect', fc='#E0F2FE', ec='#0284C7', tc='#0369A1')
    ax.annotate('', xy=(5.7, 3.3), xytext=(5.1, 3.3), arrowprops=dict(arrowstyle="->", color='#0F172A', lw=1.5))

    # Status Branches
    draw_node(ax, 5.7, 2.6, 2.4, 1.4, "Mark Status for\nEach Active Worker:\n• PRESENT (1.0)\n• HALF_DAY (0.5)\n• ABSENT / LEAVE (0.0)", 'rect', fc='#FEF3C7', ec='#D97706', tc='#92400E', fs=8)
    ax.annotate('', xy=(8.7, 3.3), xytext=(8.1, 3.3), arrowprops=dict(arrowstyle="->", color='#0F172A', lw=1.5))

    # Overtime Input
    draw_node(ax, 8.7, 2.7, 2.5, 1.2, "Enter Overtime Hours\n(0.00 to 12.00 hrs)\n& Optional Remarks", 'rect', fc='#F5F3FF', ec='#7C3AED', tc='#5B21B6', fs=8)

    # Down to atomic submit
    ax.annotate('', xy=(6.0, 1.8), xytext=(10.0, 2.7), arrowprops=dict(arrowstyle="->", color='#0F172A', lw=1.5, connectionstyle="angle,angleA=-90,angleB=0,rad=10"))
    draw_node(ax, 3.8, 1.0, 4.4, 0.8, "Atomic Bulk Submit via POST /bulk_mark/\nValidate Limits & Commit DB Transaction", 'rect', fc='#ECFDF5', ec='#10B981', tc='#065F46')

    # Arrow to done
    ax.annotate('', xy=(6.0, 0.6), xytext=(6.0, 1.0), arrowprops=dict(arrowstyle="->", color='#0F172A', lw=1.5))
    draw_node(ax, 5.0, 0.1, 2.0, 0.45, "ROSTER SAVED", 'start_end', fc='#0F172A', ec='#0F172A', tc='#FFFFFF')

    plt.tight_layout()
    plt.savefig(os.path.join(OUT_DIR, "Attendance_Flowchart.png"), dpi=300, facecolor=fig.get_facecolor(), edgecolor='none')
    plt.close()
    print("Attendance_Flowchart.png created successfully.")

def create_advance_flowchart():
    fig, ax = plt.subplots(figsize=(12, 6), dpi=300)
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 6)
    ax.axis('off')
    fig.patch.set_facecolor('#F8FAFC')
    ax.set_facecolor('#F8FAFC')

    ax.text(6, 5.6, "Salary Advance Lifecycle State Machine", 
            ha='center', va='center', fontsize=14, fontweight='bold', color='#0F172A')

    # 1. Staff Request
    draw_node(ax, 0.6, 2.5, 2.2, 0.9, "1. Staff Member\nRequests Cash Advance\nMid-Month", 'rect', fc='#FFFFFF', ec='#64748B', tc='#1E293B')
    ax.annotate('', xy=(3.4, 2.95), xytext=(2.8, 2.95), arrowprops=dict(arrowstyle="->", color='#0F172A', lw=1.5))

    # 2. Manager Approval & Record
    draw_node(ax, 3.4, 2.4, 2.5, 1.1, "2. Manager Verification\nPOST /api/advances/\nStatus: APPROVED\nCash Disbursed", 'rect', fc='#ECFDF5', ec='#10B981', tc='#047857')
    ax.annotate('', xy=(6.5, 2.95), xytext=(5.9, 2.95), arrowprops=dict(arrowstyle="->", color='#0F172A', lw=1.5))

    # 3. Monthly Payroll Calculation
    draw_node(ax, 6.5, 2.4, 2.5, 1.1, "3. Month-End Payroll Run\nAggregated into\nadvance_deduction\nfor Worker", 'rect', fc='#FEF3C7', ec='#D97706', tc='#B45309')
    ax.annotate('', xy=(9.6, 2.95), xytext=(9.0, 2.95), arrowprops=dict(arrowstyle="->", color='#0F172A', lw=1.5))

    # 4. Finalized & Deducted
    draw_node(ax, 9.6, 2.4, 2.0, 1.1, "4. Payroll Finalized\nStatus Locked to:\nDEDUCTED", 'rect', fc='#EFF6FF', ec='#3B82F6', tc='#1D4ED8')

    # Cancel branch
    ax.annotate('', xy=(4.65, 1.0), xytext=(4.65, 2.4), arrowprops=dict(arrowstyle="->", color='#EF4444', lw=1.5))
    draw_node(ax, 3.6, 0.2, 2.1, 0.7, "Optional: Cancelled\nStatus: CANCELLED", 'rect', fc='#FEF2F2', ec='#EF4444', tc='#991B1B')

    plt.tight_layout()
    plt.savefig(os.path.join(OUT_DIR, "Advance_Flowchart.png"), dpi=300, facecolor=fig.get_facecolor(), edgecolor='none')
    plt.close()
    print("Advance_Flowchart.png created successfully.")

def create_payroll_flowchart():
    fig, ax = plt.subplots(figsize=(12, 7), dpi=300)
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 7)
    ax.axis('off')
    fig.patch.set_facecolor('#F8FAFC')
    ax.set_facecolor('#F8FAFC')

    ax.text(6, 6.6, "Monthly Payroll Generation & Finalization Workflow", 
            ha='center', va='center', fontsize=14, fontweight='bold', color='#0F172A')

    # Start
    draw_node(ax, 0.5, 3.0, 1.8, 0.6, "START\nPayroll Run", 'start_end', fc='#0F172A', ec='#0F172A', tc='#FFFFFF')
    ax.annotate('', xy=(2.9, 3.3), xytext=(2.3, 3.3), arrowprops=dict(arrowstyle="->", color='#0F172A', lw=1.5))

    # Select Parameters
    draw_node(ax, 2.9, 2.7, 2.4, 1.2, "Select Month & Year\nPOST /payroll/generate/\nIterate Active Staff", 'rect', fc='#E0F2FE', ec='#0284C7', tc='#0369A1')
    ax.annotate('', xy=(5.9, 3.3), xytext=(5.3, 3.3), arrowprops=dict(arrowstyle="->", color='#0F172A', lw=1.5))

    # Computation Engine
    draw_node(ax, 5.9, 2.4, 2.8, 1.8, "Compute Financial Fields:\n• Paid Days = Pres + 0.5*Half\n• Base Payable = (Sal/30)*Days\n• OT Pay = OT_hours * OT_rate\n• Advances = Sum(Approved)\n• Net = BasePay + OT - Adv", 'rect', fc='#FEF3C7', ec='#D97706', tc='#92400E', fs=7.8)
    ax.annotate('', xy=(9.3, 3.3), xytext=(8.7, 3.3), arrowprops=dict(arrowstyle="->", color='#0F172A', lw=1.5))

    # Save Draft
    draw_node(ax, 9.3, 2.8, 2.2, 1.0, "Save Records as\nStatus: DRAFT\nHR Review Allowed", 'rect', fc='#F5F3FF', ec='#7C3AED', tc='#5B21B6')

    # Down to Finalize
    ax.annotate('', xy=(7.2, 1.3), xytext=(10.4, 2.8), arrowprops=dict(arrowstyle="->", color='#0F172A', lw=1.5, connectionstyle="angle,angleA=-90,angleB=0,rad=10"))
    draw_node(ax, 4.0, 0.7, 4.4, 0.9, "Admin Approves: POST /finalize_all/\nLock Status: FINALIZED • Advance Status: DEDUCTED\nGenerate Printable Payslips", 'rect', fc='#ECFDF5', ec='#10B981', tc='#065F46')

    ax.annotate('', xy=(2.3, 1.15), xytext=(4.0, 1.15), arrowprops=dict(arrowstyle="->", color='#0F172A', lw=1.5))
    draw_node(ax, 0.5, 0.9, 1.8, 0.5, "COMPLETED", 'start_end', fc='#0F172A', ec='#0F172A', tc='#FFFFFF')

    plt.tight_layout()
    plt.savefig(os.path.join(OUT_DIR, "Payroll_Flowchart.png"), dpi=300, facecolor=fig.get_facecolor(), edgecolor='none')
    plt.close()
    print("Payroll_Flowchart.png created successfully.")

if __name__ == '__main__':
    create_attendance_flowchart()
    create_advance_flowchart()
    create_payroll_flowchart()
