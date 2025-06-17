import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/wallet_service.dart';
import '../services/nft_service.dart';
import '../services/solana_service.dart';
import '../widgets/connect_wallet_button.dart';
import '../widgets/nft_card.dart';
import 'wallet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize services
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  void _initializeApp() async {
    final walletService = Provider.of<WalletService>(context, listen: false);
    final nftService = Provider.of<NFTService>(context, listen: false);
    
    // Try to load stored wallet
    await walletService.loadStoredWallet();
    
    // Load marketplace NFTs
    await nftService.fetchMarketplaceNFTs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        elevation: 0,
        title: const Text(
          'NFT Marketplace',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<SolanaService>(
            builder: (context, solanaService, child) {
              return IconButton(
                onPressed: solanaService.toggleNetwork,
                icon: Icon(
                  solanaService.useMainnet ? Icons.public : Icons.developer_mode,
                  color: solanaService.useMainnet ? Colors.green : Colors.orange,
                ),
                tooltip: solanaService.useMainnet ? 'Mainnet' : 'Devnet',
              );
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WalletScreen()),
              );
            },
            icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: ConnectWalletButton(),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.purple,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Marketplace'),
                  Tab(text: 'My NFTs'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMarketplaceTab(),
          _buildMyNFTsTab(),
        ],
      ),
    );
  }

  Widget _buildMarketplaceTab() {
    return Consumer<NFTService>(
      builder: (context, nftService, child) {
        if (nftService.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.purple),
                SizedBox(height: 16),
                Text('Loading NFTs...', style: TextStyle(color: Colors.white70)),
              ],
            ),
          );
        }

        if (nftService.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  nftService.error,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: nftService.fetchMarketplaceNFTs,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (nftService.nfts.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.collections, color: Colors.grey, size: 48),
                SizedBox(height: 16),
                Text(
                  'No NFTs found',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: nftService.fetchMarketplaceNFTs,
          color: Colors.purple,
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: nftService.nfts.length,
            itemBuilder: (context, index) {
              return NFTCard(nft: nftService.nfts[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildMyNFTsTab() {
    return Consumer2<NFTService, WalletService>(
      builder: (context, nftService, walletService, child) {
        if (!walletService.isConnected) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.grey, size: 48),
                SizedBox(height: 16),
                Text(
                  'Connect your wallet to view your NFTs',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (nftService.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.purple),
                SizedBox(height: 16),
                Text('Loading your NFTs...', style: TextStyle(color: Colors.white70)),
              ],
            ),
          );
        }

        if (nftService.userNfts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.collections, color: Colors.grey, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'You don\'t own any NFTs yet',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => nftService.fetchUserNFTs(
                    walletService.currentWallet!.publicKey,
                  ),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => nftService.fetchUserNFTs(
            walletService.currentWallet!.publicKey,
          ),
          color: Colors.purple,
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: nftService.userNfts.length,
            itemBuilder: (context, index) {
              return NFTCard(nft: nftService.userNfts[index]);
            },
          ),
        );
      },
    );
  }
}
