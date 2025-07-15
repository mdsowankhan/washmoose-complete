import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class ExpertMooseServicesPage extends StatefulWidget {
  final String washerType;
  
  const ExpertMooseServicesPage({
    super.key,
    this.washerType = 'expert',
  });

  @override
  State<ExpertMooseServicesPage> createState() => _ExpertMooseServicesPageState();
}

class _ExpertMooseServicesPageState extends State<ExpertMooseServicesPage> {
  final Color themeColor = Colors.amber;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoading = false;
  bool _isUploadingImage = false;
  String? _errorMessage;
  
  // Portfolio management
  List<String> _portfolioImages = [];
  static const int maxPortfolioImages = 6;
  
  // Service packages for Expert Moose
  List<Map<String, dynamic>> servicePackages = [
    {
      'typeId': 'Type 1',
      'name': 'Basic Wash & Vacuum',
      'description': 'Standard exterior wash and interior vacuum service',
      'isActive': true,
      'pricing': {'Sedan': 35, 'SUV': 40, 'Large SUV': 45, 'Van': 55},
      'duration': {'Sedan': 45, 'SUV': 50, 'Large SUV': 55, 'Van': 70},
    },
    {
      'typeId': 'Type 2', 
      'name': 'Premium Detail',
      'description': 'Comprehensive interior and exterior detailing service',
      'isActive': true,
      'pricing': {'Sedan': 85, 'SUV': 95, 'Large SUV': 110, 'Van': 140},
      'duration': {'Sedan': 120, 'SUV': 135, 'Large SUV': 150, 'Van': 180},
    },
    {
      'typeId': 'Type 3',
      'name': 'Executive Polish',
      'description': 'Premium paint correction and protection service',
      'isActive': false,
      'pricing': {'Sedan': 150, 'SUV': 170, 'Large SUV': 190, 'Van': 230},
      'duration': {'Sedan': 180, 'SUV': 200, 'Large SUV': 220, 'Van': 260},
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadExpertData();
  }

  Future<void> _loadExpertData() async {
    setState(() => _isLoading = true);
    
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('washerProfiles').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            _portfolioImages = List<String>.from(data['portfolioImages'] ?? []);
            // Load saved service packages if available
            if (data['servicePackages'] != null) {
              servicePackages = List<Map<String, dynamic>>.from(data['servicePackages']);
            }
          });
        }
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expert Moose Services'),
        backgroundColor: themeColor,
        automaticallyImplyLeading: false,  // 👈 FIXED! Removes back button
        actions: [
          IconButton(
            icon: const Icon(Icons.preview),
            onPressed: () => _showMarketplacePreview(),
            tooltip: 'Preview Marketplace Profile',
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : SafeArea(
              child: Column(
                children: [
                  // Header info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.1),
                      border: Border(
                        bottom: BorderSide(color: themeColor.withOpacity(0.3)),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star, color: themeColor, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Custom Service Packages',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: themeColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Set your custom pricing and services for each vehicle type',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Services and Portfolio list
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Services section
                        ...servicePackages.map((service) => _buildServiceCard(service)),
                        
                        const SizedBox(height: 24),
                        
                        // Portfolio section
                        _buildPortfolioSection(),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  
                  // Bottom action
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      border: Border(
                        top: BorderSide(color: Colors.grey[800]!),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: themeColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.monetization_on, color: themeColor, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Expert Moose Commission: 90% on all completed jobs',
                                  style: TextStyle(
                                    color: themeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _saveServicePackages,
                            icon: const Icon(Icons.save, size: 20),
                            label: const Text('Save All Services'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildServiceCard(Map<String, dynamic> service) {
    final isActive = service['isActive'] as bool;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive ? themeColor.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      color: isActive ? Colors.grey[850] : Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with service name and toggle
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['typeId'], // Fixed Type 1, Type 2, etc.
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: isActive ? () => _editServiceName(service) : null,
                        child: Row(
                          children: [
                            Text(
                              service['name'], // Editable name
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.white : Colors.grey[500],
                              ),
                            ),
                            if (isActive) ...[
                              const SizedBox(width: 4),
                              Icon(Icons.edit, size: 16, color: themeColor),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isActive,
                  onChanged: (value) {
                    setState(() {
                      service['isActive'] = value;
                    });
                  },
                  activeColor: themeColor,
                ),
              ],
            ),
            
            if (isActive) ...[
              const SizedBox(height: 12),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _toggleServiceStatus(service),
                      icon: Icon(
                        service['isActive'] ? Icons.visibility_off : Icons.visibility,
                        size: 16,
                      ),
                      label: Text(service['isActive'] ? 'Deactivate' : 'Activate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: service['isActive'] ? Colors.red : themeColor,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _editServiceDescription(service),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit Description'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: themeColor,
                        side: BorderSide(color: themeColor),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _editServicePricing(service),
                      icon: const Icon(Icons.attach_money, size: 16),
                      label: const Text('Pricing'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: themeColor,
                        side: BorderSide(color: themeColor),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Text(
                'Description:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                service['description'],
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Pricing preview
              Text(
                'Current Pricing:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: themeColor.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    _buildPricingRow('Vehicle', 'Price', 'Duration', 'You Earn', isHeader: true),
                    const Divider(color: Colors.grey, height: 8),
                    ...(service['pricing'] as Map<String, dynamic>).entries.map((entry) {
                      final vehicleType = entry.key;
                      final price = entry.value as int;
                      final duration = (service['duration'] as Map<String, dynamic>)[vehicleType] as int;
                      final washerEarning = (price * 0.90).toInt(); // 90% to expert washer
                      
                      return _buildPricingRow(
                        vehicleType,
                        '\$${price}',
                        '${duration}min',
                        '\$${washerEarning}',
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildPricingRow(String vehicle, String price, String duration, String earning, {bool isHeader = false}) {
    final textStyle = TextStyle(
      fontSize: 12,
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      color: isHeader ? themeColor : Colors.white70,
    );
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(vehicle, style: textStyle)),
          Expanded(flex: 2, child: Text(price, style: textStyle, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(duration, style: textStyle, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(earning, style: textStyle, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
  
  Widget _buildPortfolioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Portfolio Images',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
            Text(
              '${_portfolioImages.length}/$maxPortfolioImages',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (_portfolioImages.isEmpty) ...[
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate, color: Colors.grey[500], size: 40),
                const SizedBox(height: 8),
                Text(
                  'Add portfolio images to showcase your work',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ] else ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _portfolioImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(_portfolioImages[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _deleteImage(_portfolioImages[index]),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
        
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isUploadingImage ? null : _pickAndUploadImage,
            icon: _isUploadingImage 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber),
                )
              : const Icon(Icons.add_a_photo),
            label: Text(_isUploadingImage ? 'Uploading...' : 'Add Portfolio Image'),
            style: OutlinedButton.styleFrom(
              foregroundColor: themeColor,
              side: BorderSide(color: themeColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
  
  // Service management methods
  void _editServiceName(Map<String, dynamic> service) {
    final controller = TextEditingController(text: service['name']);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text('Edit Service Name', style: TextStyle(color: themeColor)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Service Name',
            labelStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: themeColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                service['name'] = controller.text.trim();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: themeColor),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _editServiceDescription(Map<String, dynamic> service) {
    final controller = TextEditingController(text: service['description']);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text('Edit Description', style: TextStyle(color: themeColor)),
        content: TextField(
          controller: controller,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Service Description',
            labelStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: themeColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                service['description'] = controller.text.trim();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: themeColor),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _editServicePricing(Map<String, dynamic> service) {
    final Map<String, TextEditingController> priceControllers = {};
    final Map<String, TextEditingController> durationControllers = {};
    
    final vehicleTypes = ['Sedan', 'SUV', 'Large SUV', 'Van'];
    
    for (String vehicle in vehicleTypes) {
      priceControllers[vehicle] = TextEditingController(
        text: (service['pricing'][vehicle] ?? 0).toString(),
      );
      durationControllers[vehicle] = TextEditingController(
        text: (service['duration'][vehicle] ?? 0).toString(),
      );
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text('Edit Pricing & Duration', style: TextStyle(color: themeColor)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: vehicleTypes.map((vehicle) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(vehicle, style: const TextStyle(color: Colors.white)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: priceControllers[vehicle],
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Price',
                          prefixText: '\$',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: themeColor),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: durationControllers[vehicle],
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Min',
                          suffixText: 'min',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: themeColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                for (String vehicle in vehicleTypes) {
                  service['pricing'][vehicle] = int.tryParse(priceControllers[vehicle]!.text) ?? 0;
                  service['duration'][vehicle] = int.tryParse(durationControllers[vehicle]!.text) ?? 0;
                }
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: themeColor),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _toggleServiceStatus(Map<String, dynamic> service) {
    setState(() {
      service['isActive'] = !service['isActive'];
    });
  }
  
  // Portfolio management methods
  Future<void> _pickAndUploadImage() async {
    if (_portfolioImages.length >= maxPortfolioImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum $maxPortfolioImages images allowed'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      
      if (pickedFile == null) return;
      
      setState(() {
        _isUploadingImage = true;
      });
      
      final user = _auth.currentUser;
      if (user != null) {
        final fileName = path.basename(pickedFile.path);
        final destination = 'portfolio/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_$fileName';
        
        final ref = _storage.ref().child(destination);
        final uploadTask = ref.putFile(File(pickedFile.path));
        
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        
        _portfolioImages.add(downloadUrl);
        
        await _firestore.collection('washerProfiles').doc(user.uid).set({
          'portfolioImages': _portfolioImages,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }
  
  Future<void> _deleteImage(String imageUrl) async {
    try {
      setState(() {
        _isUploadingImage = true;
      });
      
      final user = _auth.currentUser;
      if (user != null) {
        try {
          final ref = _storage.refFromURL(imageUrl);
          await ref.delete();
        } catch (e) {
          print('Could not delete from storage: $e');
        }
        
        _portfolioImages.remove(imageUrl);
        
        await _firestore.collection('washerProfiles').doc(user.uid).set({
          'portfolioImages': _portfolioImages,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }
  
  // Save and preview methods
  Future<void> _saveServicePackages() async {
    setState(() => _isLoading = true);
    
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('washerProfiles').doc(user.uid).set({
          'servicePackages': servicePackages,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Service packages saved successfully! 🎉'),
            backgroundColor: themeColor,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error saving data: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showMarketplacePreview() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text('Marketplace Preview', style: TextStyle(color: themeColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This is how customers will see your profile in the marketplace:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              '• Your active service packages',
              style: TextStyle(color: Colors.grey[300]),
            ),
            Text(
              '• Portfolio images',
              style: TextStyle(color: Colors.grey[300]),
            ),
            Text(
              '• Custom pricing per vehicle type',
              style: TextStyle(color: Colors.grey[300]),
            ),
            Text(
              '• Service descriptions',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: themeColor.withOpacity(0.3)),
              ),
              child: Text(
                'Full marketplace preview coming soon!',
                style: TextStyle(
                  color: themeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: themeColor),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}