import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive
import '../widgets/status_chip.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../models/receipt.dart'; // Import Receipt model

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedStatus = 'All';
  String _searchQuery = '';
  List<Receipt> get _filteredReceipts { // Change type to List<Receipt>
    List<Receipt> filtered = _receipts;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((receipt) {
        final query = _searchQuery.toLowerCase();
        return (receipt.item.toLowerCase().contains(query) ?? false) ||
               (receipt.tokenId.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (_selectedStatus != 'All') {
      filtered = filtered.where((receipt) {
        return (receipt.status?.toLowerCase() == _selectedStatus.toLowerCase()); // Access status property
      }).toList();
    }

    return filtered;
  }

  List<Receipt> _receipts = []; // Change type to List<Receipt>
  bool _isLoadingReceipts = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOwnerReceipts();
  }

  Future<void> _fetchOwnerReceipts() async {
    setState(() {
      _isLoadingReceipts = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accountId = authProvider.user?.walletAddress;

      if (accountId == null) {
        print('HistoryScreen: Account ID is null. User not logged in or wallet address not found.');
        setState(() {
          _errorMessage = 'User not logged in or wallet address not found.';
          _isLoadingReceipts = false;
        });
        return;
      }

      print('HistoryScreen: Fetching receipts for account ID: $accountId');
      final fetchedReceiptsJson = await ApiService.getOwnerReceipts(accountId);
      final fetchedReceipts = fetchedReceiptsJson.map((json) => Receipt(
        item: json['item'],
        amount: json['amount'],
        tokenId: json['token_id'],
        serial: json['serial'],
        date: json['date'],
        qrCodeIpfsCid: json['qrCodeIpfsCid'],
        status: json['status'],
      )).toList();

      final receiptBox = Hive.box<Receipt>('receipts');
      if (fetchedReceipts.isNotEmpty) {
        // Clear existing receipts and add new ones from API
        await receiptBox.clear();
        await receiptBox.addAll(fetchedReceipts);
        print('HistoryScreen: Fetched receipts from API and stored in Hive.');
      } else {
        print('HistoryScreen: No receipts from API. Loading from Hive.');
      }

      setState(() {
        _receipts = receiptBox.values.toList();
        _isLoadingReceipts = false;
      });
    } catch (e) {
      print('HistoryScreen: Error fetching receipts from API: $e. Attempting to load from Hive.');
      final receiptBox = Hive.box<Receipt>('receipts');
      setState(() {
        _receipts = receiptBox.values.toList();
        _isLoadingReceipts = false;
        if (_receipts.isEmpty) {
          _errorMessage = 'Failed to load receipts. No internet connection and no local data available.';
        } else {
          _errorMessage = 'Failed to load latest receipts from API. Displaying local data.';
        }
      });
    }
  }

  // ---------------- FILTERS ----------------
  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: _titleStyle(),
          ),
          const SizedBox(height: 16),

          // Search Box
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search Token ID or Item...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFFA0A0B3)),
              hintStyle: TextStyle(
                color: const Color(0xFFA0A0B3).withOpacity(0.5),
              ),
            ),
            style: const TextStyle(color: Color(0xFFEAEAEA)),
          ),
          const SizedBox(height: 16),

          const Text(
            'Status',
            style: TextStyle(
              color: Color(0xFFA0A0B3),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            children: ['All', 'Verified', 'Pending', 'Invalid'].map((status) {
              final isSelected = _selectedStatus == status;
              return FilterChip(
                label: Text(status),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => _selectedStatus = status);
                },
                backgroundColor: const Color(0xFF0A0A23).withOpacity(0.5),
                selectedColor: const Color(0xFF7A5CFF),
                labelStyle: TextStyle(
                  color: isSelected
                      ? const Color(0xFFEAEAEA)
                      : const Color(0xFFA0A0B3),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ---------------- RECEIPTS TABLE ----------------
  Widget _buildReceiptsTable() {
    if (_isLoadingReceipts) {
      return _tableContainer(
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF00E7FF)),
        ),
      );
    }

    if (_errorMessage != null) {
      return _tableContainer(
        child: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Color(0xFFFF5A6A)),
          ),
        ),
      );
    }

    if (_receipts.isEmpty) {
      return _tableContainer(
        child: const Center(
          child: Text(
            'No receipts found.',
            style: TextStyle(color: Color(0xFFA0A0B3)),
          ),
        ),
      );
    }

    return _tableContainer(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(
              label: Text('Item',
                  style: TextStyle(
                      color: Color(0xFFEAEAEA), fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('Date',
                  style: TextStyle(
                      color: Color(0xFFEAEAEA), fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('Amount',
                  style: TextStyle(
                      color: Color(0xFFEAEAEA), fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('Status',
                  style: TextStyle(
                      color: Color(0xFFEAEAEA), fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('Actions',
                  style: TextStyle(
                      color: Color(0xFFEAEAEA), fontWeight: FontWeight.bold)),
            ),
          ],
          rows: _filteredReceipts.map((receipt) {
            return DataRow(
              cells: [
                DataCell(Text(receipt.item ?? '',
                    style: const TextStyle(color: Color(0xFFEAEAEA)))),
                DataCell(Text(receipt.date ?? '',
                    style: const TextStyle(color: Color(0xFFA0A0B3)))),
                DataCell(Text(
                  receipt.amount?.toString() ?? '',
                  style: const TextStyle(
                    color: Color(0xFF00E7FF),
                    fontWeight: FontWeight.bold,
                  ),
                )),
                DataCell(StatusChip(status: receipt.status ?? '')),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility),
                      color: const Color(0xFF00E7FF),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_new),
                      color: const Color(0xFF7A5CFF),
                      onPressed: () {},
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ---------------- RECEIPT PREVIEW ----------------
  Widget _buildReceiptPreview() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Receipt Preview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEAEAEA),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Select a receipt from the table to see its details here.',
            style: TextStyle(color: Color(0xFFA0A0B3)),
          ),
        ],
      ),
    );
  }

  // ---------------- UI HELPERS ----------------
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0E0E2C).withOpacity(0.7),
          const Color(0xFF1A1A40).withOpacity(0.7),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: const Color(0xFF7A5CFF).withOpacity(0.3),
      ),
    );
  }

  TextStyle _titleStyle() {
    return const TextStyle(
      color: Color(0xFFEAEAEA),
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
  }

  Widget _tableContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: _boxDecoration(),
      child: child,
    );
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFiltersSection(),
            const SizedBox(height: 24),
            _buildReceiptsTable(),
            const SizedBox(height: 24),
            _buildReceiptPreview(),
          ],
        ),
      ),
    );
  }
}
