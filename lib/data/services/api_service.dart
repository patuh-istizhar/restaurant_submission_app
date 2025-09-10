import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/restaurant.dart';
import '../models/restaurant_detail.dart';

class ApiService {
  static const String _baseUrl = 'https://restaurant-api.dicoding.dev';

  String _getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.';
    } else if (error is HttpException) {
      return 'Terjadi masalah dengan server. Silakan coba lagi nanti.';
    } else if (error is FormatException) {
      return 'Data yang diterima tidak valid. Silakan coba lagi.';
    } else {
      return 'Terjadi kesalahan tak terduga. Silakan coba lagi.';
    }
  }

  Future<List<Restaurant>> getRestaurants() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/list'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['error'] == false && data['restaurants'] != null) {
          return (data['restaurants'] as List)
              .map((json) => Restaurant.fromJson(json))
              .toList();
        }

        throw Exception('Data restoran tidak ditemukan');
      }

      if (response.statusCode == 404) {
        throw Exception('Layanan tidak tersedia saat ini');
      }

      throw Exception('Server sedang bermasalah (${response.statusCode})');
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<RestaurantDetail> getRestaurantDetail(String id) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/detail/$id'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['error'] == false && data['restaurant'] != null) {
          return RestaurantDetail.fromJson(data['restaurant']);
        } else {
          throw Exception('Detail restoran tidak ditemukan');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Restoran tidak ditemukan');
      } else {
        throw Exception('Server sedang bermasalah (${response.statusCode})');
      }
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<List<Restaurant>> searchRestaurants(String query) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/search?q=${Uri.encodeQueryComponent(query)}'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['error'] == false && data['restaurants'] != null) {
          final restaurants = (data['restaurants'] as List)
              .map((json) => Restaurant.fromJson(json))
              .toList();
          return restaurants;
        } else {
          return [];
        }
      } else if (response.statusCode == 404) {
        throw Exception('Layanan pencarian tidak tersedia');
      } else {
        throw Exception('Server sedang bermasalah (${response.statusCode})');
      }
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<bool> addReview(String id, String name, String review) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/review'),
            headers: {
              'Content-Type': 'application/json',
              'X-Auth-Token': '12345',
            },
            body: json.encode({
              'id': id,
              'name': name.trim(),
              'review': review.trim(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['error'] == false;
      } else if (response.statusCode == 400) {
        throw Exception('Data review tidak valid. Periksa isian Anda.');
      } else if (response.statusCode == 404) {
        throw Exception('Restoran tidak ditemukan');
      } else {
        throw Exception('Gagal mengirim review. Coba lagi nanti.');
      }
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }
}
