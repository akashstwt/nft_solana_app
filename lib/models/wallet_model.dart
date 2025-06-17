class WalletModel {
  final String publicKey;
  final String privateKey;
  final double balance;
  final String mnemonic;

  WalletModel({
    required this.publicKey,
    required this.privateKey,
    required this.balance,
    required this.mnemonic,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      publicKey: json['publicKey'] ?? '',
      privateKey: json['privateKey'] ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      mnemonic: json['mnemonic'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'publicKey': publicKey,
      'privateKey': privateKey,
      'balance': balance,
      'mnemonic': mnemonic,
    };
  }

  WalletModel copyWith({
    String? publicKey,
    String? privateKey,
    double? balance,
    String? mnemonic,
  }) {
    return WalletModel(
      publicKey: publicKey ?? this.publicKey,
      privateKey: privateKey ?? this.privateKey,
      balance: balance ?? this.balance,
      mnemonic: mnemonic ?? this.mnemonic,
    );
  }
}