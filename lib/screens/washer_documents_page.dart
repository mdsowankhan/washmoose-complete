import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class WasherDocumentsPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function(Map<String, dynamic>) onDocumentsUpdated;

  const WasherDocumentsPage({
    super.key,
    required this.userData,
    required this.onDocumentsUpdated,
  });

  @override
  State<WasherDocumentsPage> createState() => _WasherDocumentsPageState();
}

class _WasherDocumentsPageState extends State<WasherDocumentsPage> with TickerProviderStateMixin {
  late Map<String, dynamic> currentData;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
  // Document upload states
  Map<String, bool> isUploadingDocument = {
    'driverLicence': false,
    'visa': false,
    'policeCheck': false,
    'profilePhoto': false,
  };

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Document information
  final List<Map<String, dynamic>> documentTypes = [
    {
      'key': 'driverLicence',
      'title': 'Driver License',
      'subtitle': 'Valid driver license or ID',
      'icon': Icons.credit_card,
      'color': Colors.blue,
    },
    {
      'key': 'visa',
      'title': 'Work Authorization',
      'subtitle': 'Visa or citizenship proof',
      'icon': Icons.assignment_ind,
      'color': Colors.purple,
    },
    {
      'key': 'policeCheck',
      'title': 'Police Check',
      'subtitle': 'Background verification',
      'icon': Icons.security,
      'color': Colors.green,
    },
    {
      'key': 'profilePhoto',
      'title': 'Profile Photo',
      'subtitle': 'Clear verification photo',
      'icon': Icons.photo_camera,
      'color': Colors.orange,
    },
  ];

  @override
  void initState() {
    super.initState();
    currentData = Map<String, dynamic>.from(widget.userData);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ FIXED: Remove hardcoded black background, use theme
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: 1 - (_slideAnimation.value / 30),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildVerificationStatus(),
                    const SizedBox(height: 24),
                    _buildProgressIndicator(),
                    const SizedBox(height: 24),
                    _buildDocumentsList(),
                    const SizedBox(height: 24),
                    if (_canSubmitDocuments()) _buildSubmitButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      // ✅ FIXED: Use theme app bar styling
      title: const Text('Document Verification'),
      centerTitle: true,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // ✅ FIXED: Use theme colors instead of hardcoded gradients
        color: const Color(0xFF00C2CB).withOpacity(0.1), // WashMoose teal
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00C2CB).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user, 
                color: const Color(0xFF00C2CB), // WashMoose teal
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Get Verified',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00C2CB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your documents to start receiving orders. All information is kept secure and private.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF2D3748), // ✅ MUCH DARKER - was too light grey
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatus() {
    final String documentsStatus = currentData['documentsStatus'] ?? 'pending';
    final bool isVerified = currentData['isVerified'] ?? false;
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    if (isVerified) {
      statusColor = Colors.green;
      statusText = '✅ Verified & Ready to Work';
      statusIcon = Icons.check_circle;
    } else {
      switch (documentsStatus) {
        case 'submitted':
          statusColor = Colors.orange;
          statusText = '⏳ Documents Under Review';
          statusIcon = Icons.pending_actions;
          break;
        case 'rejected':
          statusColor = Colors.red;
          statusText = '❌ Documents Rejected - Please Re-upload';
          statusIcon = Icons.error_outline;
          break;
        default:
          statusColor = Colors.grey;
          statusText = '📋 Upload Documents to Get Started';
          statusIcon = Icons.upload_file;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final documentsData = currentData['documents'];
    Map<String, dynamic> documents = {};
    
    if (documentsData != null) {
      if (documentsData is Map<String, dynamic>) {
        documents = documentsData;
      } else if (documentsData is Map) {
        documents = Map<String, dynamic>.from(documentsData);
      }
    }
    
    final uploadedCount = documents.values.where((doc) => doc != null).length;
    final totalCount = documentTypes.length;
    final progress = uploadedCount / totalCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ✅ FIXED: Use theme card color instead of hardcoded dark grey
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$uploadedCount / $totalCount',
                style: TextStyle(
                  color: const Color(0xFF00C2CB), // WashMoose teal
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(context).colorScheme.outline,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00C2CB)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Documents',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...documentTypes.asMap().entries.map((entry) {
          final index = entry.key;
          final doc = entry.value;
          return AnimatedContainer(
            duration: Duration(milliseconds: 200 + (index * 100)),
            margin: const EdgeInsets.only(bottom: 12),
            child: _buildDocumentCard(doc),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> docInfo) {
    final String key = docInfo['key'];
    
    final documentsData = currentData['documents'];
    Map<String, dynamic> documents = {};
    
    if (documentsData != null) {
      if (documentsData is Map<String, dynamic>) {
        documents = documentsData;
      } else if (documentsData is Map) {
        documents = Map<String, dynamic>.from(documentsData);
      }
    }
    
    final bool hasDocument = documents[key] != null;
    final bool isUploading = isUploadingDocument[key] ?? false;
    final Color docColor = docInfo['color'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ✅ FIXED: Use theme colors instead of hardcoded dark grey
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasDocument 
            ? Colors.green.withOpacity(0.5) 
            : Theme.of(context).colorScheme.outline,
          width: hasDocument ? 2 : 1,
        ),
        boxShadow: hasDocument ? [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (hasDocument ? Colors.green : docColor).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              hasDocument ? Icons.check_circle : docInfo['icon'],
              color: hasDocument ? Colors.green : docColor,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  docInfo['title'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: hasDocument 
                      ? Colors.green 
                      : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasDocument ? 'Uploaded successfully ✓' : docInfo['subtitle'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: hasDocument 
                      ? Colors.green.shade600 // ✅ DARKER GREEN - was too light
                      : const Color(0xFF2D3748), // ✅ MUCH DARKER - was barely visible
                  ),
                ),
              ],
            ),
          ),
          
          // Action Button
          if (isUploading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF00C2CB), // WashMoose teal
              ),
            )
          else
            GestureDetector(
              onTap: () => _uploadDocument(key, docInfo['title']),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (hasDocument ? const Color(0xFF00C2CB) : docColor).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  hasDocument ? Icons.edit : Icons.upload_file,
                  color: hasDocument ? const Color(0xFF00C2CB) : docColor,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submitDocumentsForReview,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C2CB), // WashMoose teal
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send, size: 20),
            SizedBox(width: 8),
            Text(
              'Submit for Review',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadDocument(String documentKey, String documentTitle) async {
    try {
      final ImageSource? source = await _showSourceSelectionDialog();
      if (source == null) return;

      setState(() {
        isUploadingDocument[documentKey] = true;
      });

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) {
        setState(() {
          isUploadingDocument[documentKey] = false;
        });
        return;
      }

      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final String fileName = '${currentUser.uid}_${documentKey}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final Reference storageRef = _storage.ref().child('washer_documents/$fileName');
        
        final UploadTask uploadTask = storageRef.putFile(File(image.path));
        final TaskSnapshot snapshot = await uploadTask;
        final String downloadUrl = await snapshot.ref.getDownloadURL();

        await _firestore.collection('users').doc(currentUser.uid).update({
          'documents.$documentKey': downloadUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          if (currentData['documents'] == null) {
            currentData['documents'] = <String, dynamic>{};
          }
          
          if (currentData['documents'] is! Map<String, dynamic>) {
            currentData['documents'] = Map<String, dynamic>.from(currentData['documents'] as Map);
          }
          
          currentData['documents'][documentKey] = downloadUrl;
        });

        widget.onDocumentsUpdated(currentData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$documentTitle uploaded successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('Upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        isUploadingDocument[documentKey] = false;
      });
    }
  }

  Future<ImageSource?> _showSourceSelectionDialog() async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      // ✅ FIXED: Use theme colors for modal
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Document Source',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSourceButton(
                    'Camera',
                    Icons.camera_alt,
                    Colors.blue,
                    () => Navigator.pop(context, ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSourceButton(
                    'Gallery',
                    Icons.photo_library,
                    Colors.purple,
                    () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitDocumentsForReview() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'documentsStatus': 'submitted',
          'submittedAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          currentData['documentsStatus'] = 'submitted';
        });

        widget.onDocumentsUpdated(currentData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Documents submitted! You\'ll be notified once approved.'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 4),
            ),
          );
          
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  bool _canSubmitDocuments() {
    final documentsData = currentData['documents'];
    Map<String, dynamic> documents = {};
    
    if (documentsData != null) {
      if (documentsData is Map<String, dynamic>) {
        documents = documentsData;
      } else if (documentsData is Map) {
        documents = Map<String, dynamic>.from(documentsData);
      }
    }
    
    final String status = currentData['documentsStatus'] ?? 'pending';
    
    bool allUploaded = documentTypes.every((docType) => 
      documents[docType['key']] != null
    );
    
    return allUploaded && (status == 'pending' || status == 'rejected');
  }
}