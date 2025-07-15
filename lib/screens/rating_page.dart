// rating_page.dart
import 'package:flutter/material.dart';
import '../services/rating_service.dart';

class RatingPage extends StatefulWidget {
  final String bookingId;
  final String washerName;
  final String serviceDetails;
  
  const RatingPage({
    super.key,
    required this.bookingId,
    required this.washerName,
    required this.serviceDetails,
  });

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  final RatingService _ratingService = RatingService();
  final TextEditingController _reviewController = TextEditingController();
  
  int _selectedRating = 0;
  bool _isSubmitting = false;
  String? _errorMessage;
  
  Future<void> _submitRating() async {
    if (_selectedRating == 0) {
      setState(() {
        _errorMessage = 'Please select a rating';
      });
      return;
    }
    
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    
    try {
      await _ratingService.submitRating(
        bookingId: widget.bookingId,
        rating: _selectedRating,
        review: _reviewController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating submitted successfully')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to submit rating: ${e.toString()}';
        _isSubmitting = false;
      });
    }
  }
  
  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const washMooseColor = Color(0xFF00C2CB);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Your Experience'),
        backgroundColor: washMooseColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            
            // Washer name and service details
            Text(
              'How was your experience with ${widget.washerName}?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.serviceDetails,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Star rating selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return IconButton(
                  iconSize: 40,
                  padding: const EdgeInsets.all(4),
                  icon: Icon(
                    _selectedRating >= starValue 
                        ? Icons.star 
                        : Icons.star_border,
                    color: _selectedRating >= starValue 
                        ? Colors.amber 
                        : Colors.grey,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedRating = starValue;
                    });
                  },
                );
              }),
            ),
            
            const SizedBox(height: 8),
            
            // Rating description
            Text(
              _getRatingDescription(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Review text field
            const Text(
              'Leave a review (optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                hintText: 'Share your experience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[800],
              ),
              style: const TextStyle(fontSize: 16),
              maxLines: 5,
            ),
            
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: washMooseColor,
                  disabledBackgroundColor: washMooseColor.withOpacity(0.5),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Rating',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getRatingDescription() {
    switch (_selectedRating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Tap to rate';
    }
  }
}