import 'package:flutter/material.dart';
import '../data/models/restaurant.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(restaurant.name)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: 'restaurant-${restaurant.id}',
              child: Image.network(restaurant.imageUrl),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_city),
                      const SizedBox(width: 8),
                      Text(restaurant.city),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star),
                      const SizedBox(width: 8),
                      Text(restaurant.rating.toString()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(restaurant.description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
