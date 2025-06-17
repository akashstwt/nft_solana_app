import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SolanaService extends ChangeNotifier {
  static const String mainnetRPC = 'https://api.mainnet-beta.solana.com';
  static const String devnetRPC = 'https://api.devnet.solana.com';
  
  bool _useMainnet = false;
  bool _isLoading = false;
  String _error = '';

  bool get useMainnet => _useMainnet;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get currentRPC => _useMainnet ? mainnetRPC : devnetRPC;

  void toggleNetwork() {
    _useMainnet = !_useMainnet;
    notifyListeners();
  }

  Future<double> getBalance(String publicKey) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await http.post(
        Uri.parse(currentRPC),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'getBalance',
          'params': [publicKey],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] != null) {
          throw Exception(data['error']['message']);
        }
        
        final lamports = data['result']['value'] as int;
        return lamports / 1000000000; // Convert lamports to SOL
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _setError('Failed to get balance: $e');
      return 0.0;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> requestAirdrop(String publicKey, {double amount = 1.0}) async {
    if (_useMainnet) {
      _setError('Airdrop not available on mainnet');
      return;
    }

    try {
      _setLoading(true);
      _clearError();

      final lamports = (amount * 1000000000).toInt();

      final response = await http.post(
        Uri.parse(currentRPC),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'requestAirdrop',
          'params': [publicKey, lamports],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] != null) {
          throw Exception(data['error']['message']);
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _setError('Failed to request airdrop: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = '';
  }
}
