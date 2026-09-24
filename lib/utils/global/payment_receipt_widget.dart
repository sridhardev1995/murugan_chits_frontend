import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// ================================================================
/// PAYMENT RECEIPT WIDGET
/// ----------------------------------------------------------------
/// Ticket-style payment receipt card (matches the reference mockup):
///   - Amber/gold header with a check icon + title
///   - Receipt number highlight box
///   - Customer / scheme / payment info rows
///   - "Weeks Covered" chips (bulk payment only)
///   - Black "Total Paid" highlight box
///   - Remaining balance row
///   - Thank-you footer
///   - "Share Receipt" button below the card that captures the card
///     as a PNG and opens the native share sheet (WhatsApp, etc.)
/// ================================================================
class PaymentReceiptWidget extends StatefulWidget {
  final String? receiptNumber;
  final String? customerName;
  final String? customerCode;
  final String? schemeName;
  final String? installmentLabel;
  final String? paidAmount; // already formatted, e.g. "₹5,000.00"
  final String? paymentMode;
  final String? paymentDate;
  final String? remainingBalance; // already formatted, e.g. "₹25,000.00"
  final List<String>? coveredWeeks;

  /// Shown in the header subtitle. Defaults to the shop name.
  final String companyName;

  const PaymentReceiptWidget({
    super.key,
    this.receiptNumber,
    this.customerName,
    this.customerCode,
    this.schemeName,
    this.installmentLabel,
    this.paidAmount,
    this.paymentMode,
    this.paymentDate,
    this.remainingBalance,
    this.coveredWeeks,
    this.companyName = 'Sri Murugan Chits',
  });

  @override
  State<PaymentReceiptWidget> createState() => _PaymentReceiptWidgetState();
}

class _PaymentReceiptWidgetState extends State<PaymentReceiptWidget> {
  // Key on the RepaintBoundary that wraps ONLY the receipt card
  // (not the share button) so the shared image is just the receipt.
  final GlobalKey _receiptKey = GlobalKey();

  bool _isSharing = false;

  // ============================================================
  // COLORS
  // ============================================================

  static const _gold = Color(0xFFF6C244);
  static const _goldDark = Color(0xFFE7C75F);
  static const _highlightBg = Color(0xFFFFF8E1);
  static const _black = Color(0xFF1A1A1A);
  static const _textDark = Color(0xFF1F2937);
  static const _textGrey = Color(0xFF6B7280);
  static const _footerBg = Color(0xFFF3F4F6);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RepaintBoundary(
          key: _receiptKey,
          child: _buildReceiptCard(),
        ),
        const SizedBox(height: 14),
        _buildShareButton(),
      ],
    );
  }

  // ============================================================
  // RECEIPT CARD
  // ============================================================

  Widget _buildReceiptCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReceiptNumberBox(),
                const SizedBox(height: 16),
                _infoRow('Customer', widget.customerName),
                _infoRow('Customer Code', widget.customerCode),
                _infoRow('Scheme', widget.schemeName),
                _infoRow('Installment / Week', widget.installmentLabel),
                _infoRow('Payment Mode', widget.paymentMode),
                _infoRow('Payment Date', widget.paymentDate),
                if (widget.coveredWeeks != null &&
                    widget.coveredWeeks!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _buildWeeksCovered(),
                ],
                const SizedBox(height: 16),
                _buildTotalPaidBox(),
                const SizedBox(height: 12),
                _buildRemainingBalanceRow(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildFooter(),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: _gold,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: _black,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: _gold,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PAYMENT RECEIPT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _black,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.companyName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _black.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECEIPT NUMBER BOX
  // ============================================================

  Widget _buildReceiptNumberBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: _highlightBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _goldDark),
      ),
      child: Column(
        children: [
          Text(
            'RECEIPT NUMBER',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: _textGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.receiptNumber ?? '-',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: _black,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              color: _textGrey,
            ),
          ),
          Flexible(
            child: Text(
              (value == null || value.isEmpty) ? '-' : value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WEEKS COVERED
  // ============================================================

  Widget _buildWeeksCovered() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WEEKS COVERED',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: _textGrey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.coveredWeeks!
              .map(
                (week) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _gold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    week,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _black,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // ============================================================
  // TOTAL PAID BOX
  // ============================================================

  Widget _buildTotalPaidBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'TOTAL PAID',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.paidAmount ?? '₹0.00',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _gold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REMAINING BALANCE
  // ============================================================

  Widget _buildRemainingBalanceRow() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _footerBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Remaining Balance',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
          Text(
            widget.remainingBalance ?? '₹0.00',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: _footerBg,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Text(
        'Thank you for your payment',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          color: _textGrey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ============================================================
  // SHARE BUTTON
  // ============================================================

  Widget _buildShareButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSharing ? null : _shareReceipt,
        icon: _isSharing
            ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.share_rounded, size: 20),
        label: Text(_isSharing ? 'Preparing...' : 'Share Receipt'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF25D366), // WhatsApp green
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CAPTURE + SHARE
  // ============================================================

  Future<void> _shareReceipt() async {
    setState(() {
      _isSharing = true;
    });

    try {
      // 1. Locate the RepaintBoundary that wraps just the receipt card.
      final boundary = _receiptKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Could not capture receipt');
      }

      // 2. Render it to an image. pixelRatio 3.0 keeps text crisp
      //    when viewed full-screen in WhatsApp etc.
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Could not encode receipt image');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // 3. Save to a temp file — share_plus needs a real file path.
      final tempDir = await getTemporaryDirectory();

      final fileName =
          'receipt_${widget.receiptNumber ?? DateTime.now().millisecondsSinceEpoch}.png';

      final file = File('${tempDir.path}/$fileName');

      await file.writeAsBytes(pngBytes);

      // 4. Open the native share sheet (WhatsApp, etc. show up here).
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text:
              'Payment Receipt${widget.receiptNumber != null ? ' - ${widget.receiptNumber}' : ''}\n'
              '${widget.companyName}',
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Share Failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }
}