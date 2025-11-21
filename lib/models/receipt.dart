import 'package:hive/hive.dart';

part 'receipt.g.dart';

@HiveType(typeId: 0)
class Receipt extends HiveObject {
  @HiveField(0)
  String item;

  @HiveField(1)
  String amount;

  @HiveField(2)
  String tokenId;

  @HiveField(3)
  int? serial;

  @HiveField(4)
  String date;

  @HiveField(5)
  String? qrCodeIpfsCid;

  @HiveField(6)
  String? status; // Add status field

  Receipt({
    required this.item,
    required this.amount,
    required this.tokenId,
    this.serial,
    required this.date,
    this.qrCodeIpfsCid,
    this.status, // Add status to constructor
  });
}