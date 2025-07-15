import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'summary_screen.dart';

class AddressCollectionPage extends StatefulWidget {
  final String serviceType; // 'regular' or 'detail'

  const AddressCollectionPage({
    super.key,
    required this.serviceType,
  });

  @override
  State<AddressCollectionPage> createState() => _AddressCollectionPageState();
}

class _AddressCollectionPageState extends State<AddressCollectionPage> {
  final _streetController = TextEditingController();
  final _suburbController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // Validation states
  bool _isStreetValid = false;
  bool _isSuburbValid = false;
  bool _isPostcodeValid = false;
  
  // Booking data passed from previous screen
  Map<String, dynamic>? bookingData;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      bookingData = args;
    }
  }

  // Street validation: min 5 chars, contains numbers and letters
  bool _validateStreet(String value) {
    if (value.trim().length < 5) return false;
    bool hasNumber = value.contains(RegExp(r'\d'));
    bool hasLetter = value.contains(RegExp(r'[a-zA-Z]'));
    return hasNumber && hasLetter;
  }

  // Suburb validation: min 3 chars, letters and spaces only
  bool _validateSuburb(String value) {
    if (value.trim().length < 3) return false;
    return RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim());
  }

  // Postcode validation: exactly 4 digits, valid Australian postcodes
  bool _validatePostcode(String value) {
    if (value.length != 4) return false;
    int? postcode = int.tryParse(value);
    if (postcode == null) return false;
    // Australian postcode ranges: 1000-9999
    return postcode >= 1000 && postcode <= 9999;
  }

  bool get _isFormValid => _isStreetValid && _isSuburbValid && _isPostcodeValid;

  // ✅ FIXED: Added isASAP parameter to SummaryScreen
  void _proceedToSummary() {
    if (_isFormValid && bookingData != null) {
      final fullAddress = '${_streetController.text.trim()}, ${_suburbController.text.trim()}, ${_postcodeController.text.trim()}';
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SummaryScreen(
            vehicleType: bookingData!['vehicleType'] ?? 'Unknown Vehicle',
            packageName: bookingData!['packageName'] ?? 'Unknown Package',
            addOns: List<String>.from(bookingData!['addOns'] ?? []),
            date: bookingData!['date'] ?? 'Unknown Date',
            time: bookingData!['time'] ?? '',
            totalPrice: (bookingData!['totalPrice'] ?? 0.0).toDouble(),
            duration: bookingData!['duration'] ?? 0,
            serviceType: bookingData!['serviceType'] ?? 'regular',
            address: fullAddress,
            specialInstructions: _instructionsController.text.trim(),
            isASAP: bookingData!['isASAP'] ?? false, // ✅ FIXED: Added missing isASAP parameter
          ),
        ),
      );
    }
  }

  Widget _buildValidatedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool Function(String) validator,
    required Function(bool) onValidationChanged,
    bool isValid = false,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: widget.serviceType == 'regular' ? AppTheme.primaryColor : Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A202C), // ✅ CHANGED: Dark text for light theme
              ),
            ),
            const Text(' *', style: TextStyle(color: Colors.red, fontSize: 16)),
            const Spacer(),
            if (controller.text.isNotEmpty)
              Icon(
                isValid ? Icons.check_circle : Icons.cancel,
                color: isValid ? Colors.green : Colors.red,
                size: 20,
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(color: Color(0xFF1A202C)), // ✅ CHANGED: Dark text for input
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)), // ✅ CHANGED: Light grey hint
            filled: true,
            fillColor: const Color(0xFFF7F8FA), // ✅ CHANGED: Light grey background
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // ✅ CHANGED: Light border
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // ✅ CHANGED: Light border
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.serviceType == 'regular' ? AppTheme.primaryColor : Colors.green, 
                width: 2
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          onChanged: (value) {
            bool valid = validator(value);
            onValidationChanged(valid);
            setState(() {});
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color serviceColor = widget.serviceType == 'regular' 
        ? AppTheme.primaryColor 
        : Colors.green;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC), // ✅ CHANGED: Light theme background
      appBar: AppBar(
        title: Text('${widget.serviceType == 'regular' ? 'Regular' : 'Detail'} Wash - Address'),
        backgroundColor: serviceColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: serviceColor,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Where should we come?',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A202C), // ✅ CHANGED: Dark text
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Please provide your complete address',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF4A5568), // ✅ CHANGED: Medium dark text
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Street Address
                      _buildValidatedTextField(
                        controller: _streetController,
                        label: 'Street Address',
                        hint: 'e.g., 123 Main Street',
                        icon: Icons.home,
                        validator: _validateStreet,
                        onValidationChanged: (valid) => _isStreetValid = valid,
                        isValid: _isStreetValid,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Suburb
                      _buildValidatedTextField(
                        controller: _suburbController,
                        label: 'Suburb',
                        hint: 'e.g., Bondi Beach',
                        icon: Icons.location_city,
                        validator: _validateSuburb,
                        onValidationChanged: (valid) => _isSuburbValid = valid,
                        isValid: _isSuburbValid,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Postcode
                      _buildValidatedTextField(
                        controller: _postcodeController,
                        label: 'Postcode',
                        hint: 'e.g., 2026',
                        icon: Icons.markunread_mailbox,
                        validator: _validatePostcode,
                        onValidationChanged: (valid) => _isPostcodeValid = valid,
                        isValid: _isPostcodeValid,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Warning message
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.withOpacity(0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning_amber, color: Colors.amber, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Please double-check your address',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Our professional washer will come to this exact location. Make sure it\'s accurate and accessible.',
                                    style: TextStyle(
                                      color: Color(0xFF4A5568), // ✅ CHANGED: Dark text for readability
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Special Instructions
                      const Text(
                        'Special Instructions (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A202C), // ✅ CHANGED: Dark text
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _instructionsController,
                        maxLines: 3,
                        style: const TextStyle(color: Color(0xFF1A202C)), // ✅ CHANGED: Dark text
                        decoration: InputDecoration(
                          hintText: 'Gate code, parking instructions, special requests...',
                          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)), // ✅ CHANGED: Light grey hint
                          prefixIcon: Icon(Icons.notes, color: serviceColor),
                          filled: true,
                          fillColor: const Color(0xFFF7F8FA), // ✅ CHANGED: Light background
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // ✅ CHANGED: Light border
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // ✅ CHANGED: Light border
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: serviceColor, width: 2),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Service info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: serviceColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: serviceColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: serviceColor, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Service Requirements',
                                  style: TextStyle(
                                    color: serviceColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.water_drop, color: Color(0xFF4A5568), size: 16), // ✅ CHANGED: Dark icon
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Access to water and power required',
                                    style: TextStyle(color: Color(0xFF4A5568), fontSize: 14), // ✅ CHANGED: Dark text
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.directions_car, color: Color(0xFF4A5568), size: 16), // ✅ CHANGED: Dark icon
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Accessible parking space for washer',
                                    style: TextStyle(color: Color(0xFF4A5568), fontSize: 14), // ✅ CHANGED: Dark text
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Show booking summary if available
                      if (bookingData != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF), // ✅ CHANGED: White card background
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)), // ✅ CHANGED: Light border
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04), // ✅ CHANGED: Subtle shadow
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Booking Summary',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A202C), // ✅ CHANGED: Dark text
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text('Vehicle: ${bookingData!['vehicleType'] ?? 'Unknown'}', 
                                   style: const TextStyle(color: Color(0xFF4A5568))), // ✅ CHANGED: Dark text
                              Text('Package: ${bookingData!['packageName'] ?? 'Unknown'}', 
                                   style: const TextStyle(color: Color(0xFF4A5568))), // ✅ CHANGED: Dark text
                              if (bookingData!['addOns'] != null && (bookingData!['addOns'] as List).isNotEmpty)
                                Text('Add-ons: ${(bookingData!['addOns'] as List).join(', ')}', 
                                     style: const TextStyle(color: Color(0xFF4A5568))), // ✅ CHANGED: Dark text
                              Text('Date: ${bookingData!['date'] ?? 'Unknown'}', 
                                   style: const TextStyle(color: Color(0xFF4A5568))), // ✅ CHANGED: Dark text
                              if (bookingData!['time'] != null && bookingData!['time'].toString().isNotEmpty)
                                Text('Time: ${bookingData!['time'].toString()}', 
                                     style: const TextStyle(color: Color(0xFF4A5568))), // ✅ CHANGED: Dark text
                              Text('Duration: ${bookingData!['duration'] ?? 0} minutes', 
                                   style: const TextStyle(color: Color(0xFF4A5568))), // ✅ CHANGED: Dark text
                              Text('Total: \$${(bookingData!['totalPrice'] ?? 0.0).toStringAsFixed(2)}', 
                                   style: TextStyle(color: serviceColor, fontWeight: FontWeight.bold)),
                              // ✅ NEW: Show ASAP status if applicable
                              if (bookingData!['isASAP'] == true) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.amber),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.flash_on, color: Colors.amber, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'ASAP Service',
                                        style: TextStyle(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Continue Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF), // ✅ CHANGED: White background for button area
                  border: Border(
                    top: BorderSide(color: Color(0xFFE2E8F0), width: 1), // ✅ CHANGED: Light border
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isFormValid ? _proceedToSummary : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFormValid ? serviceColor : const Color(0xFF9CA3AF), // ✅ CHANGED: Light grey when disabled
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: _isFormValid ? 2 : 0, // ✅ CHANGED: Add elevation when active
                    ),
                    child: Text(
                      _isFormValid ? 'CONTINUE TO SUMMARY' : 'PLEASE COMPLETE ALL FIELDS',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _streetController.dispose();
    _suburbController.dispose();
    _postcodeController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }
}