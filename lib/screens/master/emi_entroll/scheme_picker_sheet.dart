import 'package:flutter/material.dart';
import 'package:sri_murugan_chits/models/emi_scheme/emi_scheme_model.dart';
import 'package:sri_murugan_chits/services/repositary/emi_scheme/emi_scheme_repository.dart';

Future<EmiSchemeModel?> showSchemePicker(BuildContext context) {
  return showModalBottomSheet<EmiSchemeModel>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _SchemePickerSheet(),
  );
}

class _SchemePickerSheet extends StatefulWidget {
  const _SchemePickerSheet();

  @override
  State<_SchemePickerSheet> createState() => _SchemePickerSheetState();
}

class _SchemePickerSheetState extends State<_SchemePickerSheet> {
  final EmiSchemeRepository _repository = EmiSchemeRepository();
  List<EmiSchemeModel> _schemes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final result = await _repository.getSchemes(page: 1, limit: 50, status: 'Active');
      setState(() => _schemes = result['schemes'] as List<EmiSchemeModel>);
    } catch (_) {
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: [
              const Text('Select Scheme', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _schemes.isEmpty
                        ? const Center(child: Text('No active schemes'))
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: _schemes.length,
                            itemBuilder: (context, index) {
                              final s = _schemes[index];
                              return ListTile(
                                leading: const Icon(Icons.account_balance_wallet_outlined),
                                title: Text(s.name ?? 'Unnamed Scheme'),
                                subtitle: Text(
                                  '${s.defaultWeeks ?? 0} weeks • ${s.defaultCommissionValue ?? 0}${s.defaultCommissionType == 'percent' ? '%' : '₹'} commission',
                                ),
                                onTap: () => Navigator.pop(context, s),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}