import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sri_murugan_chits/models/customers/customer_model.dart';
import 'package:sri_murugan_chits/utils/colors/app_gradients.dart';
import 'package:sri_murugan_chits/utils/global/app_text_style.dart';

import 'customer_controller.dart';

class CustomerFormView extends GetView<CustomerController> {
  final CustomerModel? customer;

  const CustomerFormView({super.key, this.customer});

  bool get isEditing => customer != null;

  @override
  Widget build(BuildContext context) {
    return _CustomerForm(customer: customer, controller: controller);
  }
}

class _CustomerForm extends StatefulWidget {
  final CustomerModel? customer;
  final CustomerController controller;

  const _CustomerForm({required this.customer, required this.controller});

  @override
  State<_CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<_CustomerForm> {
  static final _phoneRegex = RegExp(r'^[0-9]{10}$');
  static final _aadharRegex = RegExp(r'^[0-9]{12}$');
  static final _panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _aadhar;
  late final TextEditingController _pan;
  late final TextEditingController _refName;
  late final TextEditingController _refPhone;
  late final TextEditingController _paymentNumber;

  bool get isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _name = TextEditingController(text: c?.name ?? '');
    _phone = TextEditingController(text: c?.phone ?? '');
    _address = TextEditingController(text: c?.address ?? '');
    _aadhar = TextEditingController(text: c?.aadharNumber ?? '');
    _pan = TextEditingController(text: c?.panNumber ?? '');
    _refName = TextEditingController(text: c?.refName ?? '');
    _refPhone = TextEditingController(text: c?.refPhone ?? '');
    _paymentNumber = TextEditingController(text: c?.paymentNumber ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _aadhar.dispose();
    _pan.dispose();
    _refName.dispose();
    _refPhone.dispose();
    _paymentNumber.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final body = {
      'name': _name.text.trim(),
      'phone': _phone.text.trim(),
      'address': _address.text.trim().isEmpty ? null : _address.text.trim(),
      'aadharNumber': _aadhar.text.trim().isEmpty ? null : _aadhar.text.trim(),
      'panNumber': _pan.text.trim().isEmpty
          ? null
          : _pan.text.trim().toUpperCase(),
      'refName': _refName.text.trim().isEmpty ? null : _refName.text.trim(),
      'refPhone': _refPhone.text.trim().isEmpty ? null : _refPhone.text.trim(),
      'paymentNumber': _paymentNumber.text.trim().isEmpty
          ? null
          : _paymentNumber.text.trim(),
    };

    final success = await widget.controller.saveCustomer(
      body,
      id: widget.customer?.id,
    );

    debugPrint('[_submit] saveCustomer returned: $success, mounted: $mounted');

    if (success && mounted) {
      final isEdit = widget.customer != null;
      Get.back(); // ✅ navigate FIRST — no overlay stealing this anymore
      // form screen already gone, list screen context la snackbar kaattum
      Get.snackbar(
        'Success',
        isEdit
            ? 'Customer updated successfully'
            : 'Customer created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Customer' : 'Add Customer',
          style: AppTextStyle.heading,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.primaryGradient,
          ),
        ),
        // backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        foregroundColor: const Color(0xFF1F2937),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _sectionLabel('Basic Details'),
            _field(_name, 'Full Name *', validator: _requiredValidator),
            _field(
              _phone,
              'Phone Number *',
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Phone number is required';
                if (!_phoneRegex.hasMatch(v.trim())) {
                  return 'Enter a valid 10-digit phone number';
                }
                return null;
              },
            ),
            _field(_address, 'Address', maxLines: 2),

            const SizedBox(height: 8),
            _sectionLabel('ID Details (optional)'),
            _field(
              _aadhar,
              'Aadhar Number',
              keyboardType: TextInputType.number,
              maxLength: 12,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                if (!_aadharRegex.hasMatch(v.trim())) {
                  return 'Aadhar number must be exactly 12 digits';
                }
                return null;
              },
            ),
            _field(
              _pan,
              'PAN Number',
              maxLength: 10,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                if (!_panRegex.hasMatch(v.trim().toUpperCase())) {
                  return 'Format must be ABCDE1234F';
                }
                return null;
              },
            ),

            const SizedBox(height: 8),
            _sectionLabel('Reference (optional)'),
            _field(_refName, 'Reference Name'),
            _field(
              _refPhone,
              'Reference Phone',
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                if (!_phoneRegex.hasMatch(v.trim())) {
                  return 'Enter a valid 10-digit phone number';
                }
                return null;
              },
            ),
            _field(_paymentNumber, 'Payment Number'),

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
                          isEditing ? 'Save Changes' : 'Add Customer',
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

  String? _requiredValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'This field is required';
    return null;
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
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        style: AppTextStyle.regular,
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyle.regular.copyWith(
            color: Colors.grey.shade600,
          ),
          counterText: '',
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
