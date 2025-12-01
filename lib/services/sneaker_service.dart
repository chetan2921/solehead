import '../models/sneaker_model.dart';
import '../utils/api_endpoints.dart';
import 'api_service.dart';

class SneakerService {
  // Get all sneakers
  static Future<List<SneakerModel>> getAllSneakers({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await ApiService.get(
        ApiEndpoints.getAllSneakers,
        queryParams: _withDetailParams({
          'page': page.toString(),
          'limit': limit.toString(),
        }),
      );

      return (response['sneakers'] as List)
          .map((sneaker) => SneakerModel.fromJson(sneaker))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get top rated sneakers
  static Future<List<SneakerModel>> getTopSneakers({int limit = 10}) async {
    try {
      final response = await ApiService.get(
        ApiEndpoints.getTopSneakers,
        queryParams: _withDetailParams({'limit': limit.toString()}),
      );

      return (response['sneakers'] as List)
          .map((sneaker) => SneakerModel.fromJson(sneaker))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get sneaker details
  static Future<SneakerModel> getSneaker(String sneakerId) async {
    try {
      final response = await ApiService.get(ApiEndpoints.getSneaker(sneakerId));
      return SneakerModel.fromJson(response['sneaker']);
    } catch (e) {
      rethrow;
    }
  }

  // Rate sneaker
  static Future<SneakerModel> rateSneaker(
    String sneakerId,
    double rating,
  ) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.rateSneaker(sneakerId),
        {'rating': rating},
        requireAuth: true,
      );

      return SneakerModel.fromJson(response['sneaker']);
    } catch (e) {
      rethrow;
    }
  }

  // Search sneakers
  static Future<List<SneakerModel>> searchSneakers(String query) async {
    try {
      final response = await ApiService.get(
        ApiEndpoints.searchSneakers(query),
        queryParams: _withDetailParams({}),
      );
      return (response['sneakers'] as List)
          .map((sneaker) => SneakerModel.fromJson(sneaker))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get sneakers by brand
  static Future<List<SneakerModel>> getSneakersByBrand(String brand) async {
    try {
      final response = await ApiService.get(
        ApiEndpoints.getSneakersByBrand(brand),
        queryParams: _withDetailParams({}),
      );
      return (response['sneakers'] as List)
          .map((sneaker) => SneakerModel.fromJson(sneaker))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get popular brands
  static Future<List<String>> getPopularBrands() async {
    try {
      final response = await ApiService.get(
        '${ApiEndpoints.getAllSneakers}/brands',
      );
      return List<String>.from(response['brands']);
    } catch (e) {
      rethrow;
    }
  }

  static Map<String, String> _withDetailParams(Map<String, String> baseParams) {
    return {...baseParams, 'includeDetails': 'true', 'includeMetadata': 'true'};
  }
}
