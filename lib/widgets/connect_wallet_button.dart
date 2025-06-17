import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/wallet_service.dart';

class ConnectWalletButton extends StatelessWidget {
  const ConnectWalletButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletService>(
      builder: (context, walletService, child) {
        if (walletService.isConnected) {
          return _buildConnectedButton(context, walletService);
        } else {
          return _buildConnectButton(context, walletService);
        }
      },
    );
  }

  Widget _buildConnectButton(BuildContext context, WalletService walletService) {
    return ElevatedButton.icon(
      onPressed: walletService.isLoading 
        ? null 
        : () => _showWalletOptions(context, walletService),
      icon: walletService.isLoading 
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.account_balance_wallet),
      label: Text(walletService.isLoading ? 'Connecting...' : 'Connect Wallet'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildConnectedButton(BuildContext context, WalletService walletService) {
    final wallet = walletService.currentWallet!;
    final shortAddress = '${wallet.publicKey.substring(0, 4)}...${wallet.publicKey.substring(wallet.publicKey.length - 4)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, color: Colors.green, size: 8),
          const SizedBox(width: 8),
          Text(
            shortAddress,
            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Text(
            '${wallet.balance.toStringAsFixed(2)} SOL',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showDisconnectDialog(context, walletService),
            child: const Icon(Icons.logout, size: 16, color: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showWalletOptions(BuildContext context, WalletService walletService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Connect Wallet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildOptionTile(
              icon: Icons.add,
              title: 'Create New Wallet',
              subtitle: 'Generate a new wallet with mnemonic phrase',
              onTap: () {
                Navigator.pop(context);
                walletService.createWallet();
              },
            ),
            const SizedBox(height: 16),
            _buildOptionTile(
              icon: Icons.download,
              title: 'Import Wallet',
              subtitle: 'Import existing wallet using mnemonic phrase',
              onTap: () {
                Navigator.pop(context);
                _showImportDialog(context, walletService);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.purple),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  void _showImportDialog(BuildContext context, WalletService walletService) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Import Wallet'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter your 12 or 24 word mnemonic phrase',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              walletService.importWallet(controller.text.trim());
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _showDisconnectDialog(BuildContext context, WalletService walletService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Disconnect Wallet'),
        content: const Text('Are you sure you want to disconnect your wallet?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              walletService.disconnectWallet();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}