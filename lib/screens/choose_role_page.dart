import 'package:flutter/material.dart';
import 'customer_login_page.dart';
import 'washer_type_selection_page.dart';

class ChooseRolePage extends StatelessWidget {
  const ChooseRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    // WashMoose teal color
    const washMooseColor = Color(0xFF00C2CB);
    
    return Scaffold(
      // ✅ FIXED: Remove hardcoded dark gradient, use theme background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 1),
              
              // ✅ IMPROVED: Professional logo section with theme colors
              Column(
                children: [
                  // Logo with modern styling
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: washMooseColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: washMooseColor,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: washMooseColor.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.cleaning_services,
                        size: 64,
                        color: washMooseColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // ✅ FIXED: Use theme text colors instead of hardcoded white
                  Text(
                    'WashMoose',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // ✅ FIXED: Use theme colors for tagline
                  Text(
                    'Car washing, at your doorstep',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              
              const Spacer(flex: 1),
              
              // ✅ FIXED: Use theme text colors
              Text(
                'Continue as',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              
              // Customer Card
              _buildRoleCard(
                context: context,
                title: 'Customer',
                description: 'Book a car wash at your location',
                icon: Icons.person,
                color: washMooseColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CustomerLoginPage()),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Washer Card
              _buildRoleCard(
                context: context,
                title: 'Washer',
                description: 'Join our team of professional car washers',
                icon: Icons.cleaning_services,
                color: Colors.amber,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WasherTypeSelectionPage()),
                  );
                },
              ),
              
              const Spacer(flex: 1),
              
              // ✅ FIXED: Use theme colors for footer text
              Text(
                'Version 1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '© 2025 WashMoose. All rights reserved.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4, // ✅ REDUCED: More subtle shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      // ✅ Card automatically uses theme cardColor (white)
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon with professional styling
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              
              // ✅ FIXED: Use theme text colors
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow with theme colors
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}