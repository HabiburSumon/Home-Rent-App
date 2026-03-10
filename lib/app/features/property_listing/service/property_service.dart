// services/property_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/property_model.dart';

class PropertyService {
  static const String _baseUrl = 'http://172.17.15.102:3000/api';

  final String userId; // You should get this from your auth system

  PropertyService({required this.userId});

  Future<ApiResponse<Property>> createProperty(Property property) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/properties'),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if needed
          // 'Authorization': 'Bearer $token',
        },
        body: json.encode(property.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ApiResponse<Property>.fromJson(
          jsonResponse,
              (data) => Property.fromJson(data),
        );
      } else {
        return ApiResponse<Property>(
          success: false,
          message: 'Failed to create property. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<Property>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  Future<ApiResponse<List<Property>>> getProperties() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/properties'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ApiResponse<List<Property>>.fromJson(
          jsonResponse,
              (data) {
            if (data is List) {
              return data.map((item) => Property.fromJson(item)).toList();
            }
            return [];
          },
        );
      } else {
        return ApiResponse<List<Property>>(
          success: false,
          message: 'Failed to fetch properties',
        );
      }
    } catch (e) {
      return ApiResponse<List<Property>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  Future<ApiResponse<Property>> getPropertyById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/properties/$id'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ApiResponse<Property>.fromJson(
          jsonResponse,
              (data) => Property.fromJson(data),
        );
      } else {
        return ApiResponse<Property>(
          success: false,
          message: 'Failed to fetch property',
        );
      }
    } catch (e) {
      return ApiResponse<Property>(
        success: false,
        message: 'Error: $e',
      );
    }
  }
}