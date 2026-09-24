import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sri_murugan_chits/models/diwali_scheme.dart/diwali_scheme_model.dart';
import 'package:sri_murugan_chits/utils/colors/app_gradients.dart';
import 'package:sri_murugan_chits/utils/global/app_text_style.dart';
import 'diwali_scheme_controller.dart';

class DiwaliSchemeFormView extends GetView<DiwaliSchemeController> {
  final DiwaliSchemeModel? scheme;

  const DiwaliSchemeFormView({super.key, this.scheme});

  bool get isEditing => scheme != null;

  @override
  Widget build(BuildContext context) {
    return _SchemeForm(scheme: scheme, controller: controller);
  }
}

class _SchemeForm extends StatefulWidget {
  final DiwaliSchemeModel? scheme;
  final DiwaliSchemeController controller;

  const _SchemeForm({required this.scheme, required this.controller});

  @override
  State<_SchemeForm> createState() => _SchemeFormState();
}

class _SchemeFormState extends State<_SchemeForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _schemeName;
  late final TextEditingController _chitValue;
  late final TextEditingController _durationWeeks;
  late final TextEditingController _bonusPerChit;
  late final TextEditingController _startDate;

  DateTime? _pickedDate;

  bool get isEditing => widget.scheme != null;

  @override
  void initState() {
    super.initState();
    final s = widget.scheme;
    _schemeName = TextEditingController(text: s?.schemeName ?? '');
    _chitValue = TextEditingController(
      text: s != null ? s.chitValue.toStringAsFixed(0) : '',
    );
    _durationWeeks = TextEditingController(
      text: s != null ? s.durationWeeks.toString() : '52',
    );
    _bonusPerChit = TextEditingController(
      text: s != null ? s.bonusPerChit.toStringAsFixed(0) : '',
    );
    _startDate = TextEditingController(text: s?.startDate ?? '');
    if (s != null && s.startDate.isNotEmpty) {
      _pickedDate = DateTime.tryParse(s.startDate);
    }
  }

  @override
  void dispose() {
    _schemeName.dispose();
    _chitValue.dispose();
    _durationWeeks.dispose();
    _bonusPerChit.dispose();
    _startDate.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _pickedDate = picked;
        _startDate.text = _formatDate(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final body = {
      'schemeName': _schemeName.text.trim(),
      'chitValue': num.tryParse(_chitValue.text.trim()) ?? 0,
      'durationWeeks': int.tryParse(_durationWeeks.text.trim()) ?? 52,
      'bonusPerChit': num.tryParse(_bonusPerChit.text.trim()) ?? 0,
      'startDate': _startDate.text.trim(),
    };

    final success = await widget.controller.saveScheme(
      body,
      id: widget.scheme?.id,
    );

    if (success && mounted) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Scheme' : 'Add Scheme',
          style: AppTextStyle.heading,
        ),
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.primaryGradient,
          ),
        ),
        foregroundColor: const Color(0xFF1F2937),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _sectionLabel('Scheme Details'),
            _field(
              _schemeName,
              'Scheme Name *',
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Scheme name is required'
                  : null,
            ),
            _field(
              _chitValue,
              'Chit Value *',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
              ],
              validator: (v) {
                final n = num.tryParse(v?.trim() ?? '');
                if (n == null || n <= 0) return 'Enter a valid chit value';
                return null;
              },
            ),
            _field(
              _durationWeeks,
              'Duration (weeks)',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return null; // defaults to 52
                }
                final n = int.tryParse(v.trim());
                if (n == null || n <= 0) return 'Enter a valid number of weeks';
                return null;
              },
            ),
            _field(
              _bonusPerChit,
              'Bonus Per Chit *',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
              ],
              validator: (v) {
                final n = num.tryParse(v?.trim() ?? '');
                if (n == null || n < 0) return 'Enter a valid bonus amount';
                return null;
              },
            ),

            const SizedBox(height: 8),
            _sectionLabel('Start Date'),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: _field(
                  _startDate,
                  'Start Date (YYYY-MM-DD) *',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Start date is required'
                      : null,
                  suffixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),
            Obx(() {
              final saving = widget.controller.isSaving.value;
              return SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          isEditing ? 'Save Changes' : 'Add Scheme',
                          style: AppTextStyle.button,
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 6),
      child: Text(
        text,
        style: AppTextStyle.semiBold.copyWith(color: const Color(0xFF6B7280)),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        style: AppTextStyle.regular,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyle.regular.copyWith(
            color: Colors.grey.shade600,
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
