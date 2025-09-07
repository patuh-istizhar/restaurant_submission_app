import 'package:flutter/material.dart';
import '../data/services/api_service.dart';

sealed class ReviewState {}

class ReviewInitial extends ReviewState {}

class ReviewSubmitting extends ReviewState {}

class ReviewSuccess extends ReviewState {
  final String message;
  ReviewSuccess(this.message);
}

class ReviewError extends ReviewState {
  final String message;
  ReviewError(this.message);
}

class ReviewProvider with ChangeNotifier {
  final ApiService _apiService;

  ReviewProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  ReviewState _state = ReviewInitial();
  ReviewState get state => _state;

  Future<bool> submitReview(
    String restaurantId,
    String name,
    String review,
  ) async {
    _state = ReviewSubmitting();
    notifyListeners();

    try {
      final success = await _apiService.addReview(restaurantId, name, review);

      if (success) {
        _state = ReviewSuccess('Review berhasil ditambahkan!');
        notifyListeners();

        Future.delayed(const Duration(seconds: 2), () {
          if (_state is ReviewSuccess) {
            _state = ReviewInitial();
            notifyListeners();
          }
        });

        return true;
      } else {
        _state = ReviewError('Gagal menambahkan review. Silakan coba lagi.');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _state = ReviewError(e.toString().replaceFirst('Exception: ', ''));
      notifyListeners();
      return false;
    }
  }

  void resetState() {
    _state = ReviewInitial();
    notifyListeners();
  }

  bool get isSubmitting => _state is ReviewSubmitting;
}
