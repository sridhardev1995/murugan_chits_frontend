import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:sri_murugan_chits/models/collections/diwali_collection_model.dart';
import 'package:sri_murugan_chits/screens/master/diwali_entrollment/diwali_enrollment_controller.dart';
import 'package:sri_murugan_chits/services/repositary/collections/collection_repository.dart';


class CollectionController extends GetxController {
  final CollectionRepository repository =
      CollectionRepository();

  // ============================================================
  // LIST
  // ============================================================

  final RxList<DiwaliCollectionModel>
      todayDueList =
      <DiwaliCollectionModel>[].obs;

  final RxList<DiwaliCollectionModel>
      overdueList =
      <DiwaliCollectionModel>[].obs;

  // ============================================================
  // SUMMARY
  // ============================================================

  final RxDouble todayCollection =
      0.0.obs;

  final RxDouble cashCollection =
      0.0.obs;

  final RxDouble upiCollection =
      0.0.obs;

  // ============================================================
  // STATE
  // ============================================================

  final RxBool isLoading =
      false.obs;

  final RxBool isSummaryLoading =
      false.obs;

  final RxBool isCollecting =
      false.obs;

  final RxString errorMessage =
      ''.obs;

  // ============================================================
  // FILTER
  // ============================================================

  final RxInt selectedTab =
      0.obs;

  // 0 = Today Due
  // 1 = Overdue

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    loadCollections();
  }

  // ============================================================
  // LOAD ALL
  // ============================================================

  Future<void> loadCollections() async {
    await Future.wait([
      fetchTodayDue(),
      fetchOverdue(),
      fetchTodaySummary(),
    ]);
  }

  // ============================================================
  // TODAY DUE
  // ============================================================

  Future<void> fetchTodayDue({
    bool showLoader = true,
  }) async {
    try {
      if (showLoader) {
        isLoading.value = true;
      }

      errorMessage.value = '';

      debugPrint(
        '🔵 [Collection] Fetch today due',
      );

      final result =
          await repository.getTodayDue();

      todayDueList.assignAll(
        result,
      );

      debugPrint(
        '🟢 Today due: ${result.length}',
      );
    } catch (e) {
      debugPrint(
        '🔴 Today due error: $e',
      );

      errorMessage.value =
          e.toString().replaceFirst(
                'Exception: ',
                '',
              );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // OVERDUE
  // ============================================================

  Future<void> fetchOverdue({
    bool showLoader = false,
  }) async {
    try {
      final result =
          await repository.getOverdue();

      overdueList.assignAll(
        result,
      );

      debugPrint(
        '🟢 Overdue: ${result.length}',
      );
    } catch (e) {
      debugPrint(
        '🔴 Overdue error: $e',
      );
    }
  }

  // ============================================================
  // TODAY SUMMARY
  // ============================================================

  Future<void> fetchTodaySummary() async {
    try {
      isSummaryLoading.value = true;

      final result =
          await repository.getTodaySummary();

      final totalAmount =
          _toDouble(
        result['totalAmount'],
      );

      todayCollection.value =
          totalAmount;

      final byPaymentMode =
          result['byPaymentMode'];

      cashCollection.value = 0;

      upiCollection.value = 0;

      if (byPaymentMode is List) {
        for (final item
            in byPaymentMode) {
          if (item is! Map) {
            continue;
          }

          final mode =
              item['payment_mode']
                  ?.toString()
                  .toLowerCase();

          final amount =
              _toDouble(
            item['total_amount'],
          );

          if (mode == 'cash') {
            cashCollection.value +=
                amount;
          }

          if (mode == 'upi') {
            upiCollection.value +=
                amount;
          }
        }
      }

      debugPrint(
        '🟢 Today collection: '
        '${todayCollection.value}',
      );
    } catch (e) {
      debugPrint(
        '🔴 Summary error: $e',
      );
    } finally {
      isSummaryLoading.value =
          false;
    }
  }

  // ============================================================
  // COLLECT PAYMENT
  // ============================================================

  Future<bool> collectPayment({
    required DiwaliCollectionModel item,
    required double amount,
    required String paymentMode,
  }) async {
    if (isCollecting.value) {
      return false;
    }

    if (amount <= 0) {
      Get.snackbar(
        'Invalid Amount',
        'Please enter a valid collection amount.',
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return false;
    }

    if (amount > item.balanceDue) {
      Get.snackbar(
        'Invalid Amount',
        'Collection cannot exceed the balance due.',
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return false;
    }

    try {
      isCollecting.value = true;

      debugPrint(
        '🔵 [Collection] Starting payment',
      );

      debugPrint(
        '   enrollmentId=${item.enrollmentId}',
      );

      debugPrint(
        '   weekNumber=${item.weekNumber}',
      );

      debugPrint(
        '   amount=$amount',
      );

      debugPrint(
        '   paymentMode=$paymentMode',
      );

      // ----------------------------------------------------------
      // Get existing Diwali payment controller
      // ----------------------------------------------------------

      if (!Get.isRegistered<
          DiwaliEnrollmentController>()) {
        throw Exception(
          'DiwaliEnrollmentController is not registered.',
        );
      }

      final diwaliController =
          Get.find<
              DiwaliEnrollmentController>();

      // ----------------------------------------------------------
      // Use existing tested payment flow
      // ----------------------------------------------------------

      final success =
          await diwaliController.payWeek(
        enrollmentId:
            item.enrollmentId,
        weekNumber:
            item.weekNumber,
        payments: [
          {
            'amount': amount,
            'mode': paymentMode,
          },
        ],
      );

      if (!success) {
        debugPrint(
          '🔴 [Collection] Payment failed',
        );

        return false;
      }

      debugPrint(
        '🟢 [Collection] Payment successful',
      );

      // ----------------------------------------------------------
      // Refresh collection screen
      //
      // payWeek() already handles:
      // - backend payment
      // - receipt number
      // - receipt popup
      // - enrollment refresh
      //
      // Here we only refresh collection lists.
      // ----------------------------------------------------------

      await refreshCollections();

      debugPrint(
        '🟢 [Collection] Collection refreshed',
      );

      return true;
    } catch (e, st) {
      debugPrint(
        '🔴 [Collection] Payment error: $e',
      );

      debugPrint(
        '$st',
      );

      Get.snackbar(
        'Payment Failed',
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      isCollecting.value = false;
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshCollections() async {
    await loadCollections();
  }

  // ============================================================
  // SELECT TAB
  // ============================================================

  void changeTab(int index) {
    selectedTab.value = index;
  }

  // ============================================================
  // CURRENT LIST
  // ============================================================

  List<DiwaliCollectionModel>
      get currentList {
    if (selectedTab.value == 0) {
      return todayDueList;
    }

    return overdueList;
  }

  // ============================================================
  // TOTAL DUE
  // ============================================================

  double get todayDueAmount {
    return todayDueList.fold(
      0,
      (
        sum,
        item,
      ) =>
          sum + item.balanceDue,
    );
  }

  // ============================================================
  // OVERDUE AMOUNT
  // ============================================================

  double get overdueAmount {
    return overdueList.fold(
      0,
      (
        sum,
        item,
      ) =>
          sum + item.balanceDue,
    );
  }

  // ============================================================
  // PARSE
  // ============================================================

  double _toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }
}