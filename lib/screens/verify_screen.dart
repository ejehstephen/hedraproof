import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/receipt.dart';
import '../services/api_service.dart';
import '../widgets/gradient_button.dart';

class VerifyScreen extends StatefulWidget {
const VerifyScreen({Key? key}) : super(key: key);

@override
State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
final _tokenIdController = TextEditingController();
final _txHashController = TextEditingController();
String _selectedNetwork = 'Testnet';
bool _isVerifying = false;
bool _hasVerified = false;
bool _isValid = false;

@override
void dispose() {
_tokenIdController.dispose();
_txHashController.dispose();
super.dispose();
}

Future<void> scanQrCode() async {
bool popped = false;
final Barcode? result = await Navigator.push(
context,
MaterialPageRoute(
builder: (context) => Scaffold(
appBar: AppBar(title: const Text('Scan QR Code')),
body: MobileScanner(
onDetect: (capture) {
if (popped) return;
final List<Barcode> barcodes = capture.barcodes;
if (barcodes.isNotEmpty) {
popped = true;
Navigator.pop(context, barcodes.first);
}
},
),
),
),
);

if (result != null && result.rawValue != null) {
  final uri = Uri.tryParse(result.rawValue!);
  if (uri != null &&
      uri.queryParameters.containsKey('tokenId') &&
      uri.queryParameters.containsKey('serial')) {
    _tokenIdController.text = uri.queryParameters['tokenId']!;
    _txHashController.text = uri.queryParameters['serial']!;
    if (!mounted) return;
    _verifyReceipt();
  } else {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid QR Code format')),
    );
  }
}

}

 Future<void> _verifyReceipt() async {
final int? serial = int.tryParse(_txHashController.text);
if (_tokenIdController.text.isEmpty || serial == null) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Please fill all fields and ensure serial is a number')),
);
return;
}

setState(() => _isVerifying = true);

try {
  final verificationResult = await ApiService.verifyReceipt(
    tokenId: _tokenIdController.text,
    serial: serial,
  );

  final receiptBox = Hive.box<Receipt>('receipts');
  Receipt? existingReceipt;

  for (var receipt in receiptBox.values) {
    if (receipt.tokenId == _tokenIdController.text &&
        receipt.serial == serial) {
      existingReceipt = receipt;
      break;
    }
  }

  if (verificationResult['verified'] == true) {
    setState(() => _isValid = true);

    if (existingReceipt != null) {
      existingReceipt.status = 'verified';
      await existingReceipt.save();
    } else {
      final newReceipt = Receipt(
        item: verificationResult['item'] ?? 'Unknown Item',
        amount: verificationResult['amount'] ?? 0,
        tokenId: _tokenIdController.text,
        serial: serial,
        date: verificationResult['timestamp'] ??
            DateTime.now().toIso8601String(),
        qrCodeIpfsCid: verificationResult['qrCodeIpfsCid'],
        status: 'verified',
      );
      await receiptBox.add(newReceipt);
    }
  } else {
    setState(() => _isValid = false);
    if (existingReceipt != null) {
      existingReceipt.status = 'invalid';
      await existingReceipt.save();
    }
  }
} catch (e) {
  print('Error during verification: $e');
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Verification failed: $e')),
    );
  }
  setState(() => _isValid = false);
} finally {
  setState(() {
    _isVerifying = false;
    _hasVerified = true;
  });
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
          'Verify Receipt',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Verify NFT ownership and authenticity',
          style: const TextStyle(fontSize: 16, color: Color(0xFFA0A0B3)),
        ),
        const SizedBox(height: 32),
        if (!isMobile && !isTablet) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: _buildVerifyForm()),
              const SizedBox(width: 32),
              Expanded(flex: 1, child: _buildTipsPanel()),
            ],
          ),
        ] else ...[
          _buildVerifyForm(),
          const SizedBox(height: 24),
          _buildTipsPanel(),
        ],
        if (_hasVerified) ...[
          const SizedBox(height: 32),
          _buildVerificationResult(),
        ],
      ],
    ),
  ),
);

}

Widget _buildVerifyForm() {
return Container(
padding: const EdgeInsets.all(24),
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
const Color(0xFF0E0E2C).withAlpha((255 * 0.7).round()),
const Color(0xFF1A1A40).withAlpha((255 * 0.7).round()),
],
),
borderRadius: BorderRadius.circular(20),
border: Border.all(
color: const Color(0xFF7A5CFF).withAlpha((255 * 0.3).round()),
),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Enter Details',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
color: Color(0xFFEAEAEA),
),
),
const SizedBox(height: 20),
_buildFormField('Token ID', _tokenIdController, '0x...'),
const SizedBox(height: 16),
_buildFormField('Serial Number', _txHashController, '0x...'),
const SizedBox(height: 16),
const Text(
'Network',
style: TextStyle(
fontSize: 13,
fontWeight: FontWeight.w600,
color: Color(0xFFA0A0B3),
),
),
const SizedBox(height: 8),
DropdownButtonFormField<String>(
value: _selectedNetwork,
items: ['Testnet', 'Mainnet'].map((network) {
return DropdownMenuItem(
value: network,
child: Text(network),
);
}).toList(),
onChanged: (value) {
setState(() => _selectedNetwork = value ?? 'Testnet');
},
decoration: InputDecoration(
filled: true,
fillColor: const Color(0xFF0E0E2C).withAlpha((255 * 0.6).round()),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
borderSide: BorderSide(
color: const Color(0xFF7A5CFF).withAlpha((255 * 0.3).round()),
),
),
),
style: const TextStyle(color: Color(0xFFEAEAEA)),
dropdownColor: const Color(0xFF1A1A40),
),
const SizedBox(height: 24),
GradientButton(
label: 'Verify Receipt',
onPressed: _verifyReceipt,
isLoading: _isVerifying,
icon: Icons.verified_user_rounded,
),
const SizedBox(height: 12),
SizedBox(
width: double.infinity,
child: OutlinedButton.icon(
onPressed: scanQrCode,
icon: const Icon(Icons.qr_code_2),
label: const Text('Scan QR Code'),
style: OutlinedButton.styleFrom(
foregroundColor: const Color(0xFF00E7FF),
side: BorderSide(
color: const Color(0xFF00E7FF).withAlpha((255 * 0.5).round()),
),
padding: const EdgeInsets.symmetric(vertical: 12),
),
),
),
],
),
);
}

Widget _buildFormField(String label, TextEditingController controller, String hint) {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
label,
style: const TextStyle(
fontSize: 13,
fontWeight: FontWeight.w600,
color: Color(0xFFA0A0B3),
),
),
const SizedBox(height: 8),
TextField(
controller: controller,
style: const TextStyle(
color: Color(0xFFEAEAEA),
fontSize: 14,
),
decoration: InputDecoration(
hintText: hint,
hintStyle: TextStyle(
color: const Color(0xFFA0A0B3).withAlpha((255 * 0.5).round()),
),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
),
),
),
],
);
}

Widget _buildTipsPanel() {
return Container(
padding: const EdgeInsets.all(24),
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
const Color(0xFF0E0E2C).withAlpha((255 * 0.7).round()),
const Color(0xFF1A1A40).withAlpha((255 * 0.7).round()),
],
),
borderRadius: BorderRadius.circular(20),
border: Border.all(
color: const Color(0xFF00E7FF).withAlpha((255 * 0.3).round()),
),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'How It Works',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
color: Color(0xFFEAEAEA),
),
),
const SizedBox(height: 16),
_buildTip('1', 'Enter Token ID', 'Paste the unique identifier of your NFT receipt.'),
const SizedBox(height: 12),
_buildTip('2', 'Enter Serial Number', 'Enter the serial number printed on the receipt.'),
const SizedBox(height: 12),
_buildTip('3', 'Select Network', 'Choose the network (Testnet or Mainnet) for verification.'),
const SizedBox(height: 12),
_buildTip('4', 'Verify', 'Tap "Verify Receipt" to check authenticity.'),
],
),
);
}

Widget _buildTip(String step, String title, String description) {
return Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
CircleAvatar(
radius: 14,
backgroundColor: const Color(0xFF7A5CFF),
child: Text(step, style: const TextStyle(color: Colors.white)),
),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(title, style: const TextStyle(color: Color(0xFFEAEAEA), fontWeight: FontWeight.bold)),
const SizedBox(height: 4),
Text(description, style: const TextStyle(color: Color(0xFFA0A0B3), fontSize: 13)),
],
),
),
],
);
}

Widget _buildVerificationResult() {
return Container(
padding: const EdgeInsets.all(24),
decoration: BoxDecoration(
color: _isValid ? Colors.green[800] : Colors.red[800],
borderRadius: BorderRadius.circular(20),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
_isValid ? 'Receipt Verified ✅' : 'Invalid Receipt ❌',
style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
),
const SizedBox(height: 12),
_buildResultField('Token ID', _tokenIdController.text),
_buildResultField('Serial Number', _txHashController.text),
_buildResultField('Network', _selectedNetwork),
],
),
);
}

Widget _buildResultField(String label, String value) {
return Padding(
padding: const EdgeInsets.only(bottom: 8.0),
child: Row(
children: [
Text('$label: ', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
Expanded(child: Text(value, style: const TextStyle(color: Colors.white))),
],
),
);
}
}
