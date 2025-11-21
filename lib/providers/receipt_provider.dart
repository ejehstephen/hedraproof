import 'package:flutter/foundation.dart';
import 'auth_provider.dart';

class ReceiptProvider with ChangeNotifier {
  final AuthProvider auth;
  ReceiptProvider(this.auth);
}