class NFTModel {
  final String name;
  final String image;
  final String mintAddress;
  final String? description;
  final String owner;
  final Map<String, dynamic>? attributes;
  final String? collection;
  final double? price;
  final bool isListed;

  NFTModel({
    required this.name,
    required this.image,
    required this.mintAddress,
    this.description,
    required this.owner,
    this.attributes,
    this.collection,
    this.price,
    this.isListed = false,
  });

  factory NFTModel.fromJson(Map<String, dynamic> json) {
    return NFTModel(
      name: json['name'] ?? 'Unknown NFT',
      image: json['image'] ?? '',
      mintAddress: json['mint'] ?? json['mintAddress'] ?? '',
      description: json['description'],
      owner: json['owner'] ?? '',
      attributes: json['attributes'] as Map<String, dynamic>?,
      collection: json['collection'],
      price: (json['price'] as num?)?.toDouble(),
      isListed: json['isListed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'mintAddress': mintAddress,
      'description': description,
      'owner': owner,
      'attributes': attributes,
      'collection': collection,
      'price': price,
      'isListed': isListed,
    };
  }

  NFTModel copyWith({
    String? name,
    String? image,
    String? mintAddress,
    String? description,
    String? owner,
    Map<String, dynamic>? attributes,
    String? collection,
    double? price,
    bool? isListed,
  }) {
    return NFTModel(
      name: name ?? this.name,
      image: image ?? this.image,
      mintAddress: mintAddress ?? this.mintAddress,
      description: description ?? this.description,
      owner: owner ?? this.owner,
      attributes: attributes ?? this.attributes,
      collection: collection ?? this.collection,
      price: price ?? this.price,
      isListed: isListed ?? this.isListed,
    );
  }
}