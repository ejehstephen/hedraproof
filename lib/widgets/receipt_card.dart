import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ReceiptCard extends StatefulWidget {
  final String item;
  final String amount;
  final String tokenId;
  final String date;
  final String? qrCodeIpfsCid;
  final int? serial;
  final VoidCallback? onCopy;
  final VoidCallback? onExplore;
  final VoidCallback? onTap;

  const ReceiptCard({
    Key? key,
    required this.item,
    required this.amount,
    required this.tokenId,
    required this.date,
    this.serial,
    this.qrCodeIpfsCid,
    this.onCopy,
    this.onExplore,
    this.onTap,
  }) : super(key: key);

  @override
  State<ReceiptCard> createState() => _ReceiptCardState();
}

class _ReceiptCardState extends State<ReceiptCard> {
  Future<void> _saveQrCode() async {
    if (widget.qrCodeIpfsCid == null) return;

    try {
      final response = await http.get(
        Uri.parse("https://gateway.pinata.cloud/ipfs/${widget.qrCodeIpfsCid}"),
      );

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/receipt_qr.png';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QR Code saved to $filePath'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save QR Code')),
      );
    }
  }

  Future<void> _shareQrCode() async {
    if (widget.qrCodeIpfsCid == null) return;

    try {
      final response = await http.get(
        Uri.parse("https://gateway.pinata.cloud/ipfs/${widget.qrCodeIpfsCid}"),
      );

      final file = XFile.fromData(
        Uint8List.fromList(response.bodyBytes),
        name: "receipt_qr.png",
      );

      await Share.shareXFiles([file], text: "Hedera Receipt QR Code");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to share QR Code')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
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
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7A5CFF).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- QR CODE ----------------
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF7A5CFF).withOpacity(0.2),
                      const Color(0xFF00E7FF).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF00E7FF).withOpacity(0.3),
                  ),
                ),
                child: Center(
                  child: widget.qrCodeIpfsCid != null
                      ? Image.network(
                          "https://gateway.pinata.cloud/ipfs/${widget.qrCodeIpfsCid}",
                          fit: BoxFit.cover,
                          errorBuilder: (context, _, __) => _qrError(),
                        )
                      : _qrPlaceholder(),
                ),
              ),

              const SizedBox(height: 12),

              // --------- Save and Share Buttons ----------
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          widget.qrCodeIpfsCid != null ? _saveQrCode : null,
                      icon: const Icon(Icons.save_alt),
                      label: const Text("Save QR"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          widget.qrCodeIpfsCid != null ? _shareQrCode : null,
                      icon: const Icon(Icons.share),
                      label: const Text("Share QR"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ---------------- ITEM NAME ----------------
              const Text(
                "Item Name",
                style: TextStyle(color: Color(0xFFA0A0B3), fontSize: 11),
              ),
              Text(
                widget.item,
                style: const TextStyle(
                  color: Color(0xFFEAEAEA),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // ---------------- SERIAL OPTIONAL ----------------
              if (widget.serial != null) ...[
                const Text("Serial Number",
                    style: TextStyle(color: Color(0xFFA0A0B3), fontSize: 11)),
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(top: 4),
                  decoration: _boxStyle(),
                  child: Text(
                    widget.serial.toString(),
                    style: const TextStyle(
                        color: Color(0xFF00E7FF),
                        fontFamily: "monospace",
                        fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ---------------- AMOUNT & DATE ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoBlock("Amount (HBAR)", widget.amount),
                  _infoBlock("Date", widget.date),
                ],
              ),

              const SizedBox(height: 16),

              // ---------------- TOKEN ID ----------------
              const Text("Token ID",
                  style: TextStyle(color: Color(0xFFA0A0B3), fontSize: 11)),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: _boxStyle(),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.tokenId,
                        style: const TextStyle(
                          color: Color(0xFF00E7FF),
                          fontSize: 12,
                          fontFamily: "monospace",
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onCopy,
                      child: const Icon(Icons.content_copy,
                          size: 16, color: Color(0xFF00E7FF)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---------------- VIEW ON EXPLORER ----------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onExplore,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text("View on Hedera Explorer"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------- Helper Widgets -------
  Widget _qrError() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.error, size: 64, color: Color(0xFF00E7FF)),
          SizedBox(height: 8),
          Text("Error loading QR Code",
              style: TextStyle(color: Color(0xFFA0A0B3), fontSize: 12)),
        ],
      );

  Widget _qrPlaceholder() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.image, size: 64, color: Color(0xFF00E7FF)),
          SizedBox(height: 8),
          Text("NFT Receipt",
              style: TextStyle(color: Color(0xFFA0A0B3), fontSize: 12)),
        ],
      );

  BoxDecoration _boxStyle() => BoxDecoration(
        color: const Color(0xFF0A0A23).withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF00E7FF).withOpacity(0.2),
        ),
      );

  Widget _infoBlock(String title, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: Color(0xFFA0A0B3), fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFEAEAEA),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
}
