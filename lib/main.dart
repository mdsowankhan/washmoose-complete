import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

// Screens
import 'screens/choose_role_page.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/my_bookings_page.dart';
import 'screens/washer_marketplace_coming_soon_page.dart';
import 'screens/customer_settings_page.dart';
import 'screens/app_theme.dart';
import 'screens/service_selection_page.dart';
import 'screens/profile_page.dart';
import 'screens/summary_screen.dart';
import 'screens/not_found_page.dart';
import 'screens/splash_screen.dart';
import 'screens/washer_main_navigation.dart';
import 'screens/customer_jobposting_page.dart';
import 'screens/payment_deposit_page.dart';
import 'screens/payment_success_page.dart';
import 'screens/address_collection_page.dart';
import 'services/job_expiration_service.dart';

// ✅ Global key for accessing ScaffoldMessenger from anywhere
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

// ✅ Handle background FCM messages (when app is terminated/background)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 [Background] FCM message received: ${message.messageId}');
  print('🔔 [Background] Title: ${message.notification?.title}');
  print('🔔 [Background] Body: ${message.notification?.body}');
  // System notification will be shown automatically by Firebase
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Use try-catch that handles both scenarios
  try {
    // Check if Firebase is already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized successfully');
    } else {
      print('✅ Firebase already initialized');
    }
    
    // ✅ Initialize FCM background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // ✅ Initialize Job Expiration Service
    JobExpirationService().initialize();
    print('✅ Job Expiration Service initialized');
    
  } catch (e) {
    // If duplicate app error, Firebase is already initialized - continue anyway
    if (e.toString().contains('duplicate-app')) {
      print('✅ Firebase already initialized (auto-init)');
      
      // Still setup FCM background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Initialize Job Expiration Service
      JobExpirationService().initialize();
      print('✅ Job Expiration Service initialized');
    } else {
      print('❌ Services init error: $e');
    }
  }

  // ✅ Initialize FCM after app starts
  _initializeFCMDelayed();

  runApp(const WashMooseApp());
}

// ✅ Initialize FCM with delay to ensure Firebase is ready
void _initializeFCMDelayed() {
  print('⏱️ Scheduling FCM initialization in 1 second...');
  Future.delayed(Duration(seconds: 1), () async {
    await _initializeFCM();
  });
}

// ✅ Separate FCM initialization function
Future<void> _initializeFCM() async {
  try {
    print('🔧 Starting FCM initialization...');
    
    // Request notification permissions (iOS/Android 13+)
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
    
    print('🔔 FCM Permission status: ${settings.authorizationStatus}');
    
    // Get FCM token for push notification testing
    print('🔧 Requesting FCM token...');
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print('🟢 FCM Token: $token');
    } else {
      print('❌ FCM Token is null - check internet connection');
    }
    
    // Listen for token refresh (when user reinstalls app, etc.)
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('🔄 FCM Token refreshed: $newToken');
      // TODO: Send updated token to your backend
    });
    
    print('✅ FCM initialization completed');
    
  } catch (e) {
    print('❌ FCM initialization error: $e');
  }
}

class WashMooseApp extends StatelessWidget {
  const WashMooseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WashMoose',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightTheme(),
      scaffoldMessengerKey: scaffoldMessengerKey, // ✅ Global key for notifications
      initialRoute: '/splash', // ✅ FIXED: Start with splash screen
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/choose_role': (context) => const ChooseRolePage(), // ✅ FIXED: Added proper route
        '/': (context) => const ChooseRolePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/customer_main': (context) => const MainNavigationPage(), // ✅ FIXED: Added customer main route
        '/main': (context) => const MainNavigationPage(),
        '/washer_main': (context) => const WasherMainNavigation(washerType: 'everyday'),
        '/washer_expert': (context) => const WasherMainNavigation(washerType: 'expert'),
        '/my_bookings': (context) => const MyBookingsPage(),
        '/profile': (context) => const ProfilePage(),
        '/settings': (context) => const CustomerSettingsPage(),
        '/washer_marketplace': (context) => const WasherMarketplaceComingSoonPage(),
        '/service_selection': (context) => const ServiceSelectionPage(),
        '/customer_jobposting': (context) => const CustomerJobPostingPage(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const NotFoundPage(),
        );
      },
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ServiceSelectionPage(),
    MyBookingsPage(),
    WasherMarketplaceComingSoonPage(),
    CustomerJobPostingPage(),
    CustomerSettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    // ✅ Setup foreground FCM listener ONCE in initState
    _setupForegroundFCMListener();
  }

  // ✅ Handle foreground FCM messages (when app is open)
  void _setupForegroundFCMListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 [Foreground] FCM message received: ${message.messageId}');
      print('🔔 [Foreground] Title: ${message.notification?.title}');
      print('🔔 [Foreground] Body: ${message.notification?.body}');
      
      // ✅ Show in-app snackbar for foreground notifications
      if (message.notification != null) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.notification!.title != null)
                  Text(
                    message.notification!.title!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                if (message.notification!.body != null)
                  Text(message.notification!.body!),
              ],
            ),
            backgroundColor: const Color(0xFF00C2CB),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'My Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Washers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: 'Post Job',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00C2CB),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}