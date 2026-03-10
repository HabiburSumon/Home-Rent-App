// models/property_model.dart
class Property {
  final String? id;
  final String userId;
  final String title;
  final String category;
  final String type;
  final int rent;
  final bool isNegotiable;
  final int? minBidAmount;
  final int? bedrooms;
  final int? bathrooms;
  final int? floor;
  final int? size;
  final bool furnished;
  final DateTime? availableFrom;
  final List<String> amenities;
  final List<String> images;
  final String? featureImage;
  final Address? address;
  final Owner? owner;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Property({
    this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.type,
    required this.rent,
    this.isNegotiable = false,
    this.minBidAmount,
    this.bedrooms,
    this.bathrooms,
    this.floor,
    this.size,
    this.furnished = false,
    this.availableFrom,
    this.amenities = const [],
    this.images = const [],
    this.featureImage,
    this.address,
    this.owner,
    this.createdAt,
    this.updatedAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['_id'],
      userId: json['user'],
      title: json['title'],
      category: json['category'],
      type: json['type'],
      rent: json['rent'],
      isNegotiable: json['isNegotiable'] ?? false,
      minBidAmount: json['minBidAmount'],
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      floor: json['floor'],
      size: json['size'],
      furnished: json['furnished'] ?? false,
      availableFrom: json['availableFrom'] != null
          ? DateTime.parse(json['availableFrom'])
          : null,
      amenities: List<String>.from(json['amenities'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      featureImage: json['featureImage'],
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : null,
      owner: json['owner'] != null
          ? Owner.fromJson(json['owner'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'user': userId,
      'title': title,
      'category': category,
      'type': type,
      'rent': rent,
      'isNegotiable': isNegotiable,
      'minBidAmount': minBidAmount,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'floor': floor,
      'size': size,
      'furnished': furnished,
      'availableFrom': availableFrom?.toIso8601String(),
      'amenities': amenities,
      'images': images,
      'featureImage': featureImage,
      'address': address?.toJson(),
      'owner': owner?.toJson(),
    }..removeWhere((key, value) => value == null);
  }
}

class Address {
  final String? area;
  final String? road;
  final String? houseNo;
  final String? fullAddress;
  final double? latitude;
  final double? longitude;

  Address({
    this.area,
    this.road,
    this.houseNo,
    this.fullAddress,
    this.latitude,
    this.longitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      area: json['area'],
      road: json['road'],
      houseNo: json['houseNo'],
      fullAddress: json['fullAddress'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'area': area,
      'road': road,
      'houseNo': houseNo,
      'fullAddress': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
    }..removeWhere((key, value) => value == null);
  }
}

class Owner {
  final String name;
  final String phone;
  final String? altPhone;
  final String? email;
  final bool allowCall;
  final bool messageOnly;

  Owner({
    required this.name,
    required this.phone,
    this.altPhone,
    this.email,
    this.allowCall = true,
    this.messageOnly = false,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      name: json['name'],
      phone: json['phone'],
      altPhone: json['altPhone'],
      email: json['email'],
      allowCall: json['allowCall'] ?? true,
      messageOnly: json['messageOnly'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'altPhone': altPhone,
      'email': email,
      'allowCall': allowCall,
      'messageOnly': messageOnly,
    }..removeWhere((key, value) => value == null);
  }
}

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>)? fromJson,
      ) {
    return ApiResponse(
      success: json['success'],
      message: json['message'],
      data: fromJson != null && json['data'] != null
          ? fromJson(json['data'])
          : null,
    );
  }
}