import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // ✅ NEW: For kDebugMode (ONLY NEW IMPORT)
import '../services/washer_connection_service.dart'; // ✅ NEW: Import connection service (ONLY NEW IMPORT)
import 'washer_home_page.dart';       // ✅ NEW - main file
import 'washer_home_logic.dart';      // ✅ NEW - logic file  
import 'washer_home_widgets.dart';    // ✅ NEW - widgets file
import 'washer_profile_page.dart';
import 'washer_earnings_page.dart';
import 'washer_browse_offers_page.dart';
import 'washer_myservices_page.dart';

class WasherMainNavigation extends StatefulWidget {
  final String washerType;
  
  const WasherMainNavigation({
    super.key, 
    this.washerType = 'everyday',  // Default to everyday if not specified
  });

  @override
  State<WasherMainNavigation> createState() => _WasherMainNavigationState();
}

// ✅ NEW: Add WidgetsBindingObserver for app lifecycle detection (SMALL ADDITION)
class _WasherMainNavigationState extends State<WasherMainNavigation> 
    with WidgetsBindingObserver {
  int _selectedIndex = 0;
  
  // ✅ NEW: Connection service instance (SMALL ADDITION)
  final WasherConnectionService _connectionService = WasherConnectionService();
  
  // ✅ NEW: Track app lifecycle state (SMALL ADDITION)
  AppLifecycleState? _lastLifecycleState;

  @override
  void initState() {
    super.initState();
    
    // ✅ NEW: Add lifecycle observer (SMALL ADDITION)
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // ✅ NEW: Remove lifecycle observer (SMALL ADDITION)
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ✅ NEW: Handle app lifecycle changes (NEW METHOD)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (kDebugMode) {
      print('🔄 App lifecycle changed: $_lastLifecycleState -> $state');
    }
    
    // Handle different lifecycle transitions
    switch (state) {
      case AppLifecycleState.paused:
        // App is minimized/backgrounded
        _handleAppPaused();
        break;
        
      case AppLifecycleState.detached:
        // App is being terminated
        _handleAppDetached();
        break;
        
      case AppLifecycleState.resumed:
        // App is back to foreground
        _handleAppResumed();
        break;
        
      case AppLifecycleState.inactive:
        // App is transitioning (e.g., phone call, notification panel)
        // Don't take action here as it's temporary
        break;
        
      default:
        break;
    }
    
    _lastLifecycleState = state;
  }

  // ✅ NEW: Handle app being paused/minimized (NEW METHOD)
  Future<void> _handleAppPaused() async {
    try {
      if (kDebugMode) {
        print('📱 App paused - scheduling auto-offline check');
      }
      
      // Wait 30 seconds, then check if app is still paused
      await Future.delayed(const Duration(seconds: 30));
      
      // If app is still paused, go offline
      if (_lastLifecycleState == AppLifecycleState.paused) {
        await _connectionService.forceOfflineOnAppClose();
        
        if (kDebugMode) {
          print('📱 Auto-offline: App minimized for 30+ seconds');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in app pause handler: $e');
      }
    }
  }

  // ✅ NEW: Handle app being terminated (NEW METHOD)
  Future<void> _handleAppDetached() async {
    try {
      await _connectionService.forceOfflineOnAppClose();
      
      if (kDebugMode) {
        print('📱 Auto-offline: App terminated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in app detach handler: $e');
      }
    }
  }

  // ✅ NEW: Handle app returning to foreground (NEW METHOD)
  void _handleAppResumed() {
    if (kDebugMode) {
      print('📱 App resumed - connection monitoring continues');
    }
    
    // App is back - connection service will resume normal monitoring
    // No action needed here as connection service handles this automatically
  }

  // ✅ Navigation callback function
  void _navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF00C2CB); // WashMoose teal color
    final expertColor = Colors.amber;       // Color for expert moose
    
    // Use different color based on washer type
    final themeColor = widget.washerType == 'expert' ? expertColor : primaryColor;
    
    // Build pages based on selected index
    Widget buildPages() {
      switch (_selectedIndex) {
        case 0:
          return WasherHomePage(
            washerType: widget.washerType,
            onNavigateToTab: _navigateToTab, // ✅ Pass callback to enable navigation
          );
        case 1:
          return WasherEarningsPage(washerType: widget.washerType);
        case 2:
          return WasherBrowseOffersPage(washerType: widget.washerType);
        case 3:
          return WasherMyServicesPage(washerType: widget.washerType);
        case 4:
          return const WasherProfilePage();
        default:
          return const Center(child: Text('Page not found'));
      }
    }
    
    return Scaffold(
      body: buildPages(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: themeColor, // Use the appropriate theme color
        unselectedItemColor: const Color(0xFF4A5568), // ✅ FIXED: Much darker grey for better readability
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Browse & Offers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tune),
            label: 'My Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}