import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'vehicle_selection_page.dart';
import 'custom_booking_page.dart';
import 'washer_marketplace_page.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ProfilePage(),
    const VehicleSelectionPage(),
    const CustomBookingPage(),
    const WasherMarketplacePage(),
    Center(
      child: Text(
        "Settings", 
        style: TextStyle(
          fontSize: 20,
          color: Color(0xFF1A202C), // ✅ MUCH DARKER - readable black text
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const washMooseColor = Color(0xFF00C2CB); // WashMoose teal
    
    return Scaffold(
      // ✅ FIXED: Remove hardcoded black background, use theme
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        // ✅ FIXED: Use theme colors instead of hardcoded black
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: washMooseColor, // Keep WashMoose teal
        unselectedItemColor: const Color(0xFF4A5568), // ✅ DARKER GREY - much more readable
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        // ✅ IMPROVED: Better label styling
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_repair),
            label: 'My Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Post Job',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Find Washers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}