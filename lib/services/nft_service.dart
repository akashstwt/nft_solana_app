import 'package:flutter/foundation.dart';
import '../models/nft_model.dart';

class NFTService extends ChangeNotifier {
  // Replace with your actual Helius API key
  static const String heliusApiKey = 'YOUR_HELIUS_API_KEY';
  static const String heliusBaseUrl = 'https://mainnet.helius.xyz/v0';
  
  List<NFTModel> _nfts = [];
  List<NFTModel> _userNfts = [];
  bool _isLoading = false;
  String _error = '';

  List<NFTModel> get nfts => _nfts;
  List<NFTModel> get userNfts => _userNfts;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchUserNFTs(String walletAddress) async {
    try {
      _setLoading(true);
      _clearError();

      // Mock data for demo purposes since Helius API requires a key
      await _loadMockNFTs(walletAddress, isUserNFTs: true);
      
      // Uncomment and modify this section when you have a Helius API key
      /*
      final url = '$heliusBaseUrl/addresses/$walletAddress/nfts?api-key=$heliusApiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        _userNfts = data.map((json) => NFTModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch NFTs: ${response.statusCode}');
      }
      */

    } catch (e) {
      _setError('Failed to fetch user NFTs: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMarketplaceNFTs() async {
    try {
      _setLoading(true);
      _clearError();

      // Mock data for demo purposes
      await _loadMockNFTs('marketplace');

      // Implement actual marketplace API calls here
      // This could be Magic Eden API or other marketplace APIs

    } catch (e) {
      _setError('Failed to fetch marketplace NFTs: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadMockNFTs(String context, {bool isUserNFTs = false}) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    final mockNFTs = [
      NFTModel(
        name: 'Solana Monkey #1234',
        image: 'https://picsum.photos/400/400?random=1',
        mintAddress: '7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU',
        description: 'A unique Solana Monkey Business NFT',
        owner: '9WzDXwBbmkg8ZTbNMqUxvQRAyrZzDsGYdLVL9zYtAWWM',
        collection: 'Solana Monkey Business',
        price: 2.5,
        isListed: true,
        attributes: {
          'Background': 'Blue',
          'Fur': 'Brown',
          'Eyes': 'Sunglasses',
          'Mouth': 'Smile',
        },
      ),
      NFTModel(
        name: 'DeGods #5678',
        image: 'https://picsum.photos/400/400?random=2',
        mintAddress: '8xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsV',
        description: 'DeGods Genesis Collection',
        owner: '8WzDXwBbmkg8ZTbNMqUxvQRAyrZzDsGYdLVL9zYtAWWN',
        collection: 'DeGods',
        price: 15.0,
        isListed: true,
        attributes: {
          'Background': 'Red',
          'Skin': 'Gold',
          'Eyes': 'Laser',
          'Clothes': 'Hoodie',
        },
      ),
      NFTModel(
        name: 'Okay Bears #9012',
        image: 'https://picsum.photos/400/400?random=3',
        mintAddress: '9xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsW',
        description: 'Okay Bears NFT Collection',
        owner: '7WzDXwBbmkg8ZTbNMqUxvQRAyrZzDsGYdLVL9zYtAWWO',
        collection: 'Okay Bears',
        price: 3.2,
        isListed: false,
        attributes: {
          'Background': 'Purple',
          'Fur': 'White',
          'Expression': 'Happy',
          'Accessory': 'Crown',
        },
      ),
    ];

    if (isUserNFTs) {
      _userNfts = mockNFTs.take(2).toList(); // User owns first 2 NFTs
    } else {
      _nfts = mockNFTs;
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