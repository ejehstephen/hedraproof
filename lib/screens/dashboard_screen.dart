import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../widgets/receipt_card.dart';
import '../widgets/gradient_button.dart';
import '../services/api_service.dart';
import '../models/receipt.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _itemController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _walletController = TextEditingController();
  bool _isLoading = false;
  String _lastTokenId = '';
  String _lastItem = '';
  String _lastAmount = '';
  int? _lastSerial;
  String _lastTimestamp = '';
  String? _lastQrCodeIpfsCid;
  List<Receipt> _recentReceipts = [];

  @override
  void initState() {
    super.initState();
    _loadRecentReceipts();
  }

  void _loadRecentReceipts() {
    final receiptBox = Hive.box<Receipt>('receipts');
    setState(() {
      _recentReceipts = receiptBox.values.toList().cast<Receipt>();
    });
  }

  @override
  void dispose() {
    _itemController.dispose();
    _amountController.dispose();
    _walletController.dispose();
    super.dispose();
  }

  String _formatDate(String isoString) {
    if (isoString.isEmpty) return '';
    final dateTime = DateTime.parse(isoString);
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  void _generateReceipt() async {
    final int? amount = int.tryParse(_amountController.text);
    if (_itemController.text.isEmpty ||
        amount == null ||
        _walletController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields and ensure amount is a number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.mintReceipt(
      item: _itemController.text,
      amount: amount,
      userWalletAddress: _walletController.text,
      appName: 'HederaProofDashboard',
      actionType: 'MintReceipt',
    );

    setState(() => _isLoading = false);

    if (result['success'] ?? false) {

      setState(() {
        _lastTokenId = result['tokenId'] ?? '';
        _lastSerial = result['serial'] as int?;
        _lastTimestamp = _formatDate(result['timestamp'] ?? '');
        _lastItem = _itemController.text;
        _lastAmount = _amountController.text;
        _lastQrCodeIpfsCid = result['qrCodeIpfsCid'] as String?;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('NFT Minted Successfully'),
          backgroundColor: const Color(0xFF00D77F),
        ),
      );

      final receiptBox = Hive.box<Receipt>('receipts');
      final newReceipt = Receipt(
        item: _itemController.text,
        amount: _amountController.text,
        tokenId: _lastTokenId,
        serial: _lastSerial,
        date: _formatDate(_lastTimestamp),
      qrCodeIpfsCid: _lastQrCodeIpfsCid,
      );
      receiptBox.add(newReceipt);
      _loadRecentReceipts();

      _itemController.clear();
    _amountController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Failed to mint receipt'),
          backgroundColor: const Color(0xFFFF5A6A),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width < 1024;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Create and manage your NFT receipts',
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFFA0A0B3),
              ),
            ),
            const SizedBox(height: 32),
            if (!isMobile && !isTablet) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: _buildMintForm()),
                  const SizedBox(width: 32),
                  Expanded(flex: 1, child: _buildReceiptViewer()),
                ],
              ),
            ] else ...[
              _buildMintForm(),
              const SizedBox(height: 32),
              _buildReceiptViewer(),
            ],
            const SizedBox(height: 32),
            _buildRecentReceipts(),
          ],
        ),
      ),
    );
  }

  Widget _buildMintForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mint Your NFT Receipt',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFEAEAEA),
            ),
          ),
          const SizedBox(height: 20),
          _buildFormField('Item Name', _itemController, 'Enter item name'),
          const SizedBox(height: 16),
          _buildFormField('Amount (HBAR)', _amountController, 'e.g., 100'),
          const SizedBox(height: 16),
          _buildFormField(
            'Description',
            _descriptionController,
            'Enter description',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildFormField(
            'User Wallet Address',
            _walletController,
            '0x...',
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: 'Generate Receipt',
            onPressed: _generateReceipt,
            isLoading: _isLoading,
            icon: Icons.card_giftcard,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_file),
              label: const Text('Import Metadata'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF00E7FF),
                side: BorderSide(
                  color: const Color(0xFF00E7FF).withOpacity(0.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFA0A0B3),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
            color: Color(0xFFEAEAEA),
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: const Color(0xFFA0A0B3).withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptViewer() {
    if (_lastTokenId.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
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
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long,
                size: 64,
                color: const Color(0xFF00E7FF).withOpacity(0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'No Receipt Yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFA0A0B3),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Generate your first receipt to see it here',
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFFA0A0B3).withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ReceiptCard(
      item: _lastItem.isNotEmpty ? _lastItem : 'Item',
      amount: _lastAmount.isNotEmpty ? _lastAmount : '0',
      tokenId: _lastTokenId,
      serial: _lastSerial,
      date: _lastTimestamp,
      qrCodeIpfsCid: _lastQrCodeIpfsCid,
      onCopy: () {
        Clipboard.setData(ClipboardData(text: _lastTokenId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token ID copied to clipboard')),
        );
      },
      onExplore: () {},
    );
  }

  Widget _buildRecentReceipts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Receipts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFEAEAEA),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width < 600 ? 1 : 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,

          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentReceipts.length,
          itemBuilder: (context, index) {
            final receipt = _recentReceipts[index];
            return ReceiptCard(
              item: receipt.item,
              amount: receipt.amount,
              tokenId: receipt.tokenId,
              date: _formatDate(receipt.date),
              serial: receipt.serial,
              qrCodeIpfsCid: receipt.qrCodeIpfsCid,
              onCopy: () {
                Clipboard.setData(ClipboardData(text: receipt.tokenId));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Token ID copied to clipboard')),
                );
              },
              onExplore: () {
                // TODO: Implement navigation to explorer for recent receipts
              },
              onTap: () {
                setState(() {
                  _lastTokenId = receipt.tokenId;
                  _lastSerial = receipt.serial;
                  _lastTimestamp = _formatDate(receipt.date);
                  _lastItem = receipt.item;
                  _lastAmount = receipt.amount;
                  _lastQrCodeIpfsCid = receipt.qrCodeIpfsCid;
                });
              },
            );
          },
        ),
      ],
    );
  }
}
