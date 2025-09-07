import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/restaurant_detail.dart';
import '../providers/restaurant_provider.dart';
import '../providers/review_provider.dart';

class ReviewSection extends StatelessWidget {
  final RestaurantDetail restaurant;

  const ReviewSection({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews (${restaurant.customerReviews.length})',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16.0),
        _ReviewInputForm(restaurantId: restaurant.id),
        const SizedBox(height: 16.0),
        if (restaurant.customerReviews.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 48.0,
                      color: colorScheme.onSurfaceVariant.withAlpha(
                        (0.5 * 255).round(),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Belum ada review',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Jadilah yang pertama memberikan review!',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withAlpha(
                          (0.7 * 255).round(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: restaurant.customerReviews.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8.0),
            itemBuilder: (context, index) {
              final review = restaurant.customerReviews[index];
              return _ReviewListItem(review: review);
            },
          ),
      ],
    );
  }
}

class _ReviewInputForm extends StatefulWidget {
  final String restaurantId;

  const _ReviewInputForm({required this.restaurantId});

  @override
  State<_ReviewInputForm> createState() => _ReviewInputFormState();
}

class _ReviewInputFormState extends State<_ReviewInputForm> {
  final _nameController = TextEditingController();
  final _reviewController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    final reviewProvider = context.read<ReviewProvider>();
    final restaurantProvider = context.read<RestaurantProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    final success = await reviewProvider.submitReview(
      widget.restaurantId,
      _nameController.text.trim(),
      _reviewController.text.trim(),
    );

    if (success) {
      _nameController.clear();
      _reviewController.clear();
      if (!mounted) return;
      FocusScope.of(context).unfocus();

      await restaurantProvider.fetchRestaurantDetail(widget.restaurantId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Review berhasil ditambahkan!'),
          backgroundColor: colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tulis Review Anda',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  hintText: 'Masukkan nama Anda',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  if (value.trim().length < 2) {
                    return 'Nama minimal 2 karakter';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _reviewController,
                decoration: InputDecoration(
                  labelText: 'Review',
                  hintText: 'Bagikan pengalaman Anda di sini...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  prefixIcon: const Icon(Icons.rate_review_outlined),
                  filled: true,
                ),
                maxLines: 4,
                maxLength: 500,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Review tidak boleh kosong';
                  }
                  if (value.trim().length < 10) {
                    return 'Review minimal 10 karakter';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submitReview(),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                child: Consumer<ReviewProvider>(
                  builder: (context, reviewProvider, child) {
                    final isSubmitting = reviewProvider.isSubmitting;

                    if (reviewProvider.state is ReviewError) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final errorState = reviewProvider.state as ReviewError;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorState.message),
                            backgroundColor: colorScheme.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        reviewProvider.resetState();
                      });
                    }

                    return FilledButton.icon(
                      onPressed: isSubmitting ? null : _submitReview,
                      icon: isSubmitting
                          ? SizedBox(
                              height: 16.0,
                              width: 16.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: Text(
                        isSubmitting ? 'Mengirim...' : 'Kirim Review',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewListItem extends StatelessWidget {
  final CustomerReview review;

  const _ReviewListItem({required this.review});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24.0,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    review.name.isNotEmpty ? review.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16.0,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            review.date,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(
                  (0.3 * 255).round(),
                ),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: colorScheme.outline.withAlpha((0.2 * 255).round()),
                ),
              ),
              child: Text(
                review.review,
                style: textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
