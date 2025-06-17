import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/wallet_service.dart';
import 'services/nft_service.dart';
import 'services/solana_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletService()),
        ChangeNotifierProvider(create: (_) => NFTService()),
        ChangeNotifierProvider(create: (_) => SolanaService()),
      ],
      child: MaterialApp(
        title: 'NFT Marketplace',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0D1117),
          cardColor: const Color(0xFF161B22),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
