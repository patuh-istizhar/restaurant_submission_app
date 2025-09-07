import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/data/models/restaurant.dart';
import 'package:restaurant_app/data/services/api_service.dart';
import 'package:restaurant_app/providers/restaurant_provider.dart';

class FakeApiServiceSuccess extends ApiService {
  @override
  Future<List<Restaurant>> getRestaurants() async {
    return [
      Restaurant(
        id: 'r1',
        name: 'Test Resto',
        description: 'Desc',
        pictureId: 'pic1',
        city: 'City',
        rating: 4.5,
      ),
    ];
  }
}

class FakeApiServiceFailure extends ApiService {
  @override
  Future<List<Restaurant>> getRestaurants() async {
    throw Exception('Network error');
  }
}

void main() {
  group('RestaurantProvider', () {
    test('initial state is RestaurantInitial', () {
      final provider = RestaurantProvider(
        apiService: FakeApiServiceSuccess() as dynamic,
      );
      expect(provider.state.runtimeType.toString(), 'RestaurantInitial');
    });

    test(
      'fetchRestaurants sets state to RestaurantSuccess when API returns data',
      () async {
        final provider = RestaurantProvider(
          apiService: FakeApiServiceSuccess() as dynamic,
        );
        await provider.fetchRestaurants();

        expect(provider.state, isA<RestaurantSuccess>());
        final successState = provider.state as RestaurantSuccess;
        expect(successState.restaurants, isNotEmpty);
        expect(successState.restaurants.first.id, 'r1');
      },
    );

    test(
      'fetchRestaurants sets state to RestaurantError when API fails',
      () async {
        final provider = RestaurantProvider(
          apiService: FakeApiServiceFailure() as dynamic,
        );
        await provider.fetchRestaurants();

        expect(provider.state, isA<RestaurantError>());
        final errorState = provider.state as RestaurantError;
        expect(errorState.message, contains('Network error'));
      },
    );
  });
}
