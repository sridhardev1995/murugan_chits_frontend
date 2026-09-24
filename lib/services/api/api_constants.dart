class ApiConstants {
  // ============================================================
  // BASE
  // ============================================================

  static const String baseUrl = "http://192.168.1.31:5000/api";

  // ============================================================
  // AUTH
  // ============================================================

  static const String login = "/auth/login";

  static const String changePassword = "/auth/change-password";

  static const String profile = "/auth/profile";

  // ============================================================
  // CUSTOMERS
  // ============================================================

  static const String customers = "/customers";

  static String customerById(int id) {
    return "/customers/$id";
  }

  static String customerStatus(int id) {
    return "/customers/$id/status";
  }

  // ============================================================
  // DIWALI SCHEMES
  // ============================================================

  static const String diwaliSchemes = "/diwali-schemes";

  static String diwaliSchemeById(int id) {
    return "/diwali-schemes/$id";
  }

  static String diwaliSchemeStatus(int id) {
    return "/diwali-schemes/$id/status";
  }

  // ============================================================
  // DIWALI ENROLLMENTS
  // ============================================================

  static const String diwaliEnrollments = "/diwali-enrollments";

  static String diwaliEnrollmentById(int id) {
    return "/diwali-enrollments/$id";
  }

  // ------------------------------------------------------------
  // Diwali Weekly Payment
  // POST
  // /api/diwali-enrollments/:id/weeks/:weekNumber/pay
  // ------------------------------------------------------------

  static String diwaliWeekPayment(int enrollmentId, int weekNumber) {
    return "/diwali-enrollments/"
        "$enrollmentId/weeks/$weekNumber/pay";
  }

  // ------------------------------------------------------------
  // Diwali Bulk Payment
  // POST
  // /api/diwali-enrollments/:id/bulk-pay
  // ------------------------------------------------------------

  static String diwaliBulkPayment(int enrollmentId) {
    return "/diwali-enrollments/"
        "$enrollmentId/bulk-pay";
  }

  // ------------------------------------------------------------
  // Diwali Payment History
  // GET
  // /api/diwali-enrollments/:id/payment-history
  // ------------------------------------------------------------

  static String diwaliPaymentHistory(int enrollmentId) {
    return "/diwali-enrollments/"
        "$enrollmentId/payment-history";
  }

  // ------------------------------------------------------------
  // Revert Single Payment
  // POST
  // /api/diwali-enrollments/payments/:transactionId/revert
  // ------------------------------------------------------------

  static String diwaliRevertPayment(int transactionId) {
    return "/diwali-enrollments/"
        "payments/$transactionId/revert";
  }

  // ------------------------------------------------------------
  // Revert Bulk Payment
  // POST
  // /api/diwali-enrollments/payment-groups/:paymentGroupId/revert
  // ------------------------------------------------------------

  static String diwaliRevertPaymentGroup(String paymentGroupId) {
    return "/diwali-enrollments/"
        "payment-groups/$paymentGroupId/revert";
  }

  // ------------------------------------------------------------
  // Modify Chits
  // PATCH
  // /api/diwali-enrollments/:id/modify-chits
  // ------------------------------------------------------------

  static String diwaliModifyChits(int enrollmentId) {
    return "/diwali-enrollments/"
        "$enrollmentId/modify-chits";
  }

  // ------------------------------------------------------------
  // Adjustment Logs
  // GET
  // /api/diwali-enrollments/:id/adjustment-logs
  // ------------------------------------------------------------

  static String diwaliAdjustmentLogs(int enrollmentId) {
    return "/diwali-enrollments/"
        "$enrollmentId/adjustment-logs";
  }

  // ============================================================
  // DIWALI COLLECTION DASHBOARD
  // ============================================================

  static const String diwaliTodayDue =
      "/diwali-enrollments/collections/today-due";

  static const String diwaliOverdue = "/diwali-enrollments/collections/overdue";

  static const String diwaliTodaySummary =
      "/diwali-enrollments/collections/today-summary";

  // ============================================================
  // EMI SCHEMES
  // ============================================================

  static const String schemes = "/schemes";

  static String schemeById(int id) {
    return "/schemes/$id";
  }

  static String schemeStatus(int id) {
    return "/schemes/$id/status";
  }

  // ============================================================
  // EMI ENROLLMENTS
  //
  // IMPORTANT:
  // baseUrl already contains /api
  // ============================================================

  static const String enrollments = "/enrollments";

  static String enrollmentById(int id) {
    return "/enrollments/$id";
  }

  static String enrollmentStatus(int id) {
    return "/enrollments/$id/status";
  }

  // ============================================================
  // EMI INSTALLMENTS
  // ============================================================

  // GET
  // /api/enrollments/:enrollmentId/emis
  static String enrollmentEmis(int enrollmentId) {
    return "/enrollments/"
        "$enrollmentId/emis";
  }

  // ============================================================
  // EMI COLLECTION
  // ============================================================

  // PATCH
  // /api/emis/:emiId/collect
  //
  // Supports:
  // - Cash
  // - UPI
  // - Partial
  // - Paid
  // - Split payment
  static String collectEmi(int emiId) {
    return "/emis/$emiId/collect";
  }

  // ============================================================
  // EMI PAYMENT HISTORY
  // ============================================================

  // GET
  // /api/emis/:emiId/payments
  //
  // Returns:
  // - Payment history
  // - Total paid
  // - Cash total
  // - UPI total
  static String emiPaymentHistory(int emiId) {
    return "/emis/$emiId/payments";
  }

  // ============================================================
  // EMI REVERSE PAYMENT
  // ============================================================

  // POST
  // /api/emis/:paymentId/reverse-payment
  //
  // IMPORTANT:
  // paymentId means emi_payment_transactions.id
  // NOT installment id.
  static String emiReversePayment(int paymentId) {
    return "/emis/$paymentId/reverse-payment";
  }

  // ============================================================
  // EMI BASE
  // ============================================================

  static const String emis = "/emis";

  // ============================================================
  // REPORTS
  // ============================================================

  static const String emiPaymentReport = '/reports/emi-payments';

  // ============================================================
  // HEALTH
  // ============================================================

  static const String health = "/health";
}
