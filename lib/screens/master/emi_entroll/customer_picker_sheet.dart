import 'package:flutter/material.dart';
import 'package:sri_murugan_chits/models/customers/customer_model.dart';
import 'package:sri_murugan_chits/services/api/api_servies.dart';
import 'package:sri_murugan_chits/services/repositary/customer/customer_repositary.dart';

/// Bottom sheet with search; returns the picked CustomerModel via Navigator.pop.
Future<CustomerModel?> showCustomerPicker(BuildContext context) {
  return showModalBottomSheet<CustomerModel>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _CustomerPickerSheet(),
  );
}

class _CustomerPickerSheet extends StatefulWidget {
  const _CustomerPickerSheet();

  @override
  State<_CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<_CustomerPickerSheet> {
  final CustomerRepository _repository =
    CustomerRepository(ApiService());
  final TextEditingController _search = TextEditingController();

  List<CustomerModel> _customers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch([String query = '']) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _repository.getCustomers(
        page: 1,
        limit: 30,
        search: query,
        status: 'Active',
      );
      setState(() {
        _customers = result['customers'];
      });
    } catch (e) {
      setState(() => _error = 'Unable to load customers');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: [
              const Text('Select Customer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _search,
                onChanged: (v) => _fetch(v.trim()),
                decoration: InputDecoration(
                  hintText: 'Search by name or phone...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text(_error!))
                        : _customers.isEmpty
                            ? const Center(child: Text('No customers found'))
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: _customers.length,
                                itemBuilder: (context, index) {
                                  final c = _customers[index];
                                  return ListTile(
                                    leading: const CircleAvatar(child: Icon(Icons.person)),
                                    title: Text(c.name ?? 'Unnamed'),
                                    subtitle: Text(c.phone ?? ''),
                                    onTap: () => Navigator.pop(context, c),
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