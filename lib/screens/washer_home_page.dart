import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/washer_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_panel_page.dart';
import 'package:url_launcher/url_launcher.dart';

// Import the helper files
import 'washer_home_logic.dart';
import 'washer_home_widgets.dart';
// ✅ NEW: Add these 4 imports
import 'washer_available_jobs_widgets.dart';
import 'washer_my_jobs_widgets.dart';
import 'washer_marketplace_widgets.dart';
import 'washer_shared_widgets.dart';

class WasherHomePage extends StatefulWidget {
  final String washerType;
  final Function(int)? onNavigateToTab;

  const WasherHomePage({
    super.key,
    this.washerType = 'everyday',
    this.onNavigateToTab,
  });

  @override
  State<WasherHomePage> createState() => _WasherHomePageState();
}

// ✅ UPDATED: Add the new mixins here (ONLY CHANGE)
class _WasherHomePageState extends State<WasherHomePage> 
    with SingleTickerProviderStateMixin, WasherHomeLogic, WasherHomeWidgets,
         WasherAvailableJobsWidgets, WasherMyJobsWidgets, WasherMarketplaceWidgets, WasherSharedWidgets {
  
  // ✅ UPDATED: Filter state variable
  String _selectedJobFilter = 'All Jobs';
  
  // TabController
  late TabController _tabController;
  
  // Services
  final WasherService _washerService = WasherService();

  // Data Lists
  List<Map<String, dynamic>> _availableBookings = [];
  List<Map<String, dynamic>> _myBookings = [];
  List<Map<String, dynamic>> _marketplaceBookings = [];

  // Loading States
  bool _isLoadingAvailable = true;
  bool _isLoadingMyBookings = true;
  bool _isLoadingMarketplace = true;
  String? _availableError;
  String? _myBookingsError;
  String? _marketplaceError;
  bool _indexError = false;

  // User Data
  Map<String, dynamic>? _userData;
  bool _isLoadingUser = true;

  // Enhanced workload tracking
  Map<String, dynamic>? _washerWorkload;
  bool _isLoadingWorkload = false;

  // Audio notification support
  bool _soundEnabled = true;

  // ✅ NEW: Getter and setter for job filter (for mixin compatibility)
  @override
  String get selectedJobFilter => _selectedJobFilter;
  @override
  set selectedJobFilter(String value) => _selectedJobFilter = value;

  // Getters for mixins
  @override
  WasherService get washerService => _washerService;
  @override
  List<Map<String, dynamic>> get availableBookings => _availableBookings;
  @override
  List<Map<String, dynamic>> get myBookings => _myBookings;
  @override
  List<Map<String, dynamic>> get marketplaceBookings => _marketplaceBookings;
  @override
  Map<String, dynamic>? get userData => _userData;
  @override
  Map<String, dynamic>? get washerWorkload => _washerWorkload;
  @override
  bool get soundEnabled => _soundEnabled;
  @override
  bool get isExpertMoose => widget.washerType == 'expert';
  @override
  bool get isVerified => _userData?['isVerified'] ?? false;
  @override
  bool get isOnline => _userData?['isOnline'] ?? false;
  @override
  String get documentsStatus => _userData?['documentsStatus'] ?? 'pending';
  @override
  bool get canReceiveOrders => isVerified && isOnline;
  @override
  bool get isLoadingWorkload => _isLoadingWorkload;
  @override
  bool get isLoadingUser => _isLoadingUser;
  @override
  bool get isLoadingAvailable => _isLoadingAvailable;
  @override
  bool get isLoadingMyBookings => _isLoadingMyBookings;
  @override
  bool get isLoadingMarketplace => _isLoadingMarketplace;
  @override
  Function(int)? get onNavigateToTab => widget.onNavigateToTab;

  // Setters for mixins
  @override
  set availableBookings(List<Map<String, dynamic>> value) => _availableBookings = value;
  @override
  set myBookings(List<Map<String, dynamic>> value) => _myBookings = value;
  @override
  set marketplaceBookings(List<Map<String, dynamic>> value) => _marketplaceBookings = value;
  @override
  set userData(Map<String, dynamic>? value) => _userData = value;
  @override
  set washerWorkload(Map<String, dynamic>? value) => _washerWorkload = value;
  @override
  set isLoadingAvailable(bool value) => _isLoadingAvailable = value;
  @override
  set isLoadingMyBookings(bool value) => _isLoadingMyBookings = value;
  @override
  set isLoadingMarketplace(bool value) => _isLoadingMarketplace = value;
  @override
  set isLoadingWorkload(bool value) => _isLoadingWorkload = value;
  @override
  set isLoadingUser(bool value) => _isLoadingUser = value;
  @override
  set availableError(String? value) => _availableError = value;
  @override
  set myBookingsError(String? value) => _myBookingsError = value;
  @override
  set marketplaceError(String? value) => _marketplaceError = value;
  @override
  set indexError(bool value) => _indexError = value;

  @override
  void initState() {
    super.initState();
    
    // ✅ NEW: Initialize connection service (SMALL ADDITION)
    initializeConnectionService();
    
    _tabController = TabController(
      length: isExpertMoose ? 3 : 2,
      vsync: this,
    );
    getCurrentUserData();
    loadWasherWorkload();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        loadAvailableBookings();
        loadMyBookings();
        if (isExpertMoose) {
          loadMarketplaceBookings();
        }
      }
    });
  }

  @override
  void dispose() {
    // ✅ NEW: Dispose connection service (SMALL ADDITION)
    disposeConnectionService();
    
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = isExpertMoose ? Colors.amber : const Color(0xFF00C2CB);

    if (_isLoadingUser) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // ✅ FIXED: Remove back button
        title: Row(
          children: [
            Icon(
              isExpertMoose ? Icons.star : Icons.water_drop,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                isExpertMoose ? 'Expert Moose Dashboard' : 'Everyday Moose Dashboard',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: themeColor,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          // ✅ SIMPLIFIED: Status summary (using existing method)
          if (_userData != null && _washerWorkload != null)
            buildVerificationBanner(),
          
          // Tab navigation
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF00C2CB),
              labelColor: const Color(0xFF00C2CB),
              unselectedLabelColor: const Color(0xFF4A5568),
              isScrollable: isExpertMoose,
              tabs: [
                Tab(
                  icon: Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.work),
                        if (_availableBookings.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_availableBookings.length}',
                              style: const TextStyle(fontSize: 10, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  child: const Text(
                    'Available',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Tab(
                  icon: Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.assignment),
                        if (_myBookings.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_myBookings.length}',
                              style: const TextStyle(fontSize: 10, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  child: const Text(
                    'My Jobs',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isExpertMoose)
                  const Tab(
                    icon: Icon(Icons.storefront),
                    child: Text(
                      'Market',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: canReceiveOrders
                ? TabBarView(
                    controller: _tabController,
                    children: [
                      _isLoadingAvailable
                          ? buildLoadingView()
                          : _availableError != null
                              ? buildErrorView(_availableError!, isIndex: _indexError)
                              : _availableBookings.isEmpty
                                  ? buildEmptyAvailableJobs()
                                  : buildAvailableJobsList(),
                      _isLoadingMyBookings
                          ? buildLoadingView()
                          : _myBookingsError != null
                              ? buildErrorView(_myBookingsError!)
                              : buildMyJobsList(),
                      if (isExpertMoose)
                        _isLoadingMarketplace
                            ? buildLoadingView()
                            : _marketplaceError != null
                                ? buildErrorView(_marketplaceError!)
                                : buildMarketplaceJobsList(),
                    ],
                  )
                : buildBlockedJobsView(),
          ),
          if (_userData != null && _userData!['isAdmin'] == true)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminPanelPage()),
                  );
                },
                child: const Text("Open Admin Panel"),
              ),
            ),
        ],
      ),
    );
  }
}