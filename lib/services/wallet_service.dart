import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import '../models/wallet_model.dart';

class WalletService extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  WalletModel? _currentWallet;
  bool _isLoading = false;
  String _error = '';

  WalletModel? get currentWallet => _currentWallet;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isConnected => _currentWallet != null;

  Future<void> createWallet() async {
    try {
      _setLoading(true);
      _clearError();

      // Generate mnemonic
      final mnemonic = bip39.generateMnemonic();
      
      // Create wallet from mnemonic
      await _createWalletFromMnemonic(mnemonic);
      
      // Store mnemonic securely
      await _storage.write(key: 'mnemonic', value: mnemonic);
      
    } catch (e) {
      _setError('Failed to create wallet: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> importWallet(String mnemonic) async {
    try {
      _setLoading(true);
      _clearError();

      if (!bip39.validateMnemonic(mnemonic)) {
        throw Exception('Invalid mnemonic phrase');
      }

      await _createWalletFromMnemonic(mnemonic);
      await _storage.write(key: 'mnemonic', value: mnemonic);

    } catch (e) {
      _setError('Failed to import wallet: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _createWalletFromMnemonic(String mnemonic) async {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final keyPair = await ED25519_HD_KEY.derivePath("m/44'/501'/0'/0'", seed);
    
    final publicKey = keyPair.key;
    final privateKey = keyPair.key;

    _currentWallet = WalletModel(
      publicKey: publicKey.toString(),
      privateKey: privateKey.toString(),
      balance: 0.0, // Will be updated by SolanaService
      mnemonic: mnemonic,
    );
  }

  Future<void> loadStoredWallet() async {
    try {
      _setLoading(true);
      _clearError();

      final mnemonic = await _storage.read(key: 'mnemonic');
      if (mnemonic != null) {
        await _createWalletFromMnemonic(mnemonic);
      }
    } catch (e) {
      _setError('Failed to load wallet: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> disconnectWallet() async {
    try {
      await _storage.delete(key: 'mnemonic');
      _currentWallet = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to disconnect wallet: $e');
    }
  }

  void updateBalance(double balance) {
    if (_currentWallet != null) {
      _currentWallet = _currentWallet!.copyWith(balance: balance);
      notifyListeners();
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
