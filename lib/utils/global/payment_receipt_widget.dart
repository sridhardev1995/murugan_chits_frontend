import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// ================================================================
/// PAYMENT RECEIPT WIDGET — CLASSIC TICKET STYLE
/// ----------------------------------------------------------------
///   - Cream paper background
///   - Logo (assets/images/logo.png) at the top, centered
///   - Monospace-style title + dashed dividers (classic receipt look)
///   - Receipt number stamped in a bordered box
///   - Label ........ Value rows with dotted leaders
///   - "Weeks Covered" chips (bulk payment only)
///   - Bold "TOTAL PAID" ticket stub
///   - Remaining balance row
///   - Torn/zigzag bottom edge like a real paper receipt
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

  /// Shown under the logo. Defaults to the shop name.
  final String companyName;

  /// Path to the logo asset. Defaults to assets/images/logo.png
  /// (remember to register this path under `flutter: assets:` in
  /// pubspec.yaml).
  final String logoAssetPath;

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
    this.logoAssetPath = 'assets/images/logo.png',
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
  // COLORS / STYLE
  // ============================================================

  static const _paper = Color(0xFFFFFDF6); // warm receipt-paper white
  static const _gold = Color(0xFFF6C244);
  static const _goldDark = Color(0xFFC99A2E);
  static const _black = Color(0xFF1A1A1A);
  static const _textDark = Color(0xFF1F2937);
  static const _textGrey = Color(0xFF7C7C7C);
  static const _dashGrey = Color(0xFFBFBFBF);

  static const _mono = TextStyle(fontFamily: 'Courier', letterSpacing: 0.2);

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
  // RECEIPT CARD (with torn zigzag bottom edge)
  // ============================================================

  Widget _buildReceiptCard() {
    return ClipPath(
      clipper: _ReceiptEdgeClipper(),
      child: Container(
        decoration: BoxDecoration(
          color: _paper,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLogoHeader(),
            const SizedBox(height: 14),
            _buildDashedDivider(),
            const SizedBox(height: 16),
            _buildReceiptNumberBox(),
            const SizedBox(height: 16),
            _dottedRow('CUSTOMER', widget.customerName),
            _dottedRow('CUSTOMER CODE', widget.customerCode),
            _dottedRow('SCHEME', widget.schemeName),
            _dottedRow('INSTALLMENT / WEEK', widget.installmentLabel),
            _dottedRow('PAYMENT MODE', widget.paymentMode),
            _dottedRow('PAYMENT DATE', widget.paymentDate),
            if (widget.coveredWeeks != null &&
                widget.coveredWeeks!.isNotEmpty) ...[
              const SizedBox(height: 6),
              _buildDashedDivider(),
              const SizedBox(height: 12),
              _buildWeeksCovered(),
            ],
            const SizedBox(height: 16),
            _buildDashedDivider(),
            const SizedBox(height: 16),
            _buildTotalPaidStub(),
            const SizedBox(height: 12),
            _buildRemainingBalanceRow(),
            const SizedBox(height: 18),
            _buildDashedDivider(),
            const SizedBox(height: 14),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOGO HEADER
  // ============================================================

  Widget _buildLogoHeader() {
    return Column(
      children: [
        SizedBox(
          height: 130,
          child: Image.asset(
            widget.logoAssetPath,
            fit: BoxFit.contain,
            // Falls back to a check-mark badge if the logo asset
            // is missing so the receipt never breaks in dev/build.
            errorBuilder: (context, error, stackTrace) => Container(
              width: 120,
              height: 56,
              decoration: const BoxDecoration(
                color: _black,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.check, color: _gold, size: 26),
            ),
          ),
        ),
        // const SizedBox(height: 10),
        // Text(
        //   widget.companyName,
        //   style: const TextStyle(
        //     fontSize: 16,
        //     fontWeight: FontWeight.w800,
        //     color: _black,
        //     letterSpacing: 0.4,
        //   ),
        // ),
        // const SizedBox(height: 4),
        const Text(
          'PAYMENT RECEIPT',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: _textGrey,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DASHED DIVIDER
  // ============================================================

  Widget _buildDashedDivider() {
    return SizedBox(
      height: 1,
      child: CustomPaint(
        painter: _DashedLinePainter(color: _dashGrey),
        size: const Size(double.infinity, 1),
      ),
    );
  }

  // ============================================================
  // RECEIPT NUMBER BOX
  // ============================================================

  Widget _buildReceiptNumberBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: _goldDark, width: 1.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          const Text(
            'RECEIPT NO.',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: _textGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.receiptNumber ?? '-',
            style: _mono.copyWith(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: _black,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LABEL ..... VALUE ROW (classic dotted leader)
  // ============================================================

  Widget _dottedRow(String label, String? value) {
    final display = (value == null || value.isEmpty) ? '-' : value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: _mono.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textGrey,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2, left: 4, right: 4),
              child: CustomPaint(
                painter: _DottedLeaderPainter(color: _dashGrey),
                size: const Size(double.infinity, 1),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              display,
              textAlign: TextAlign.right,
              style: _mono.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
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
          style: _mono.copyWith(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
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
                    horizontal: 11,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _gold,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    week,
                    style: _mono.copyWith(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
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
  // TOTAL PAID STUB
  // ============================================================

  Widget _buildTotalPaidStub() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _black,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            'TOTAL PAID',
            style: _mono.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.paidAmount ?? '₹0.00',
            style: _mono.copyWith(
              fontSize: 25,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'REMAINING BALANCE',
          style: _mono.copyWith(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: _textGrey,
            letterSpacing: 1,
          ),
        ),
        Text(
          widget.remainingBalance ?? '₹0.00',
          style: _mono.copyWith(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: _textDark,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'THANK YOU FOR YOUR PAYMENT',
          textAlign: TextAlign.center,
          style: _mono.copyWith(
            fontSize: 11.5,
            letterSpacing: 1.5,
            color: _textGrey,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'This is a digitally generated receipt',
          textAlign: TextAlign.center,
          style: _mono.copyWith(
            fontSize: 9.5,
            letterSpacing: 0.4,
            color: _textGrey.withOpacity(0.75),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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

/// ================================================================
/// PAINTERS / CLIPPERS FOR THE CLASSIC PAPER-RECEIPT LOOK
/// ================================================================

/// Horizontal dashed divider line.
class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Fine dotted leader used between a label and its value
/// (e.g. "CUSTOMER ..................... Ramesh Kumar").
class _DottedLeaderPainter extends CustomPainter {
  final Color color;
  const _DottedLeaderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    const dotSpace = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawCircle(Offset(x, size.height / 2), 0.6, paint);
      x += dotSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Clips the bottom edge of the receipt into a torn zigzag,
/// like a real paper ticket. Top/side edges stay straight.
class _ReceiptEdgeClipper extends CustomClipper<Path> {
  static const double _zigzagHeight = 9;
  static const double _zigzagWidth = 16;

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - _zigzagHeight);

    // Zigzag along the bottom, right to left.
    double x = size.width;
    bool up = true;
    while (x > 0) {
      final nextX = math.max(0.0, x - _zigzagWidth);
      final y = up
          ? size.height
          : size.height - _zigzagHeight;
      path.lineTo(nextX, y);
      up = !up;
      x = nextX;
    }

    path.lineTo(0, size.height - _zigzagHeight);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}