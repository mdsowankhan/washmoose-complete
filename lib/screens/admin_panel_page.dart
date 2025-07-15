import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String filterStatus = "pending"; // For washers filter
  String bookingFilterStatus = "all"; // For bookings filter
  String serviceFilterType = "all"; // For services filter

  // Dashboard date range
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    // Adding Dashboard and Bookings tabs, plus Services tab
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const washMooseColor = Color(0xFF00C2CB);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WashMoose Admin'),
        backgroundColor: washMooseColor,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.book_online), text: 'Bookings'),
            Tab(icon: Icon(Icons.cleaning_services), text: 'Services'),
            Tab(icon: Icon(Icons.person), text: 'Customers'),
            Tab(icon: Icon(Icons.work), text: 'Washers'),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      body: TabBarView(
        controller: _tabController,
        children: [
          // DASHBOARD TAB
          _buildDashboardTab(),
          // BOOKINGS TAB
          _buildBookingsTab(),
          // SERVICES TAB
          _buildServicesTab(),
          // CUSTOMERS TAB
          _buildCustomersTab(),
          // WASHERS TAB
          _buildWashersTab(),
        ],
      ),
    );
  }

  /// DASHBOARD TAB
  Widget _buildDashboardTab() {
    const washMooseColor = Color(0xFF00C2CB);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date range selector
          _buildDateRangeSelector(),
          
          const SizedBox(height: 24),
          
          // Key metrics cards
          _buildMetricsGrid(),
          
          const SizedBox(height: 24),
          
          // Revenue chart
          _buildRevenueChart(),
          
          const SizedBox(height: 24),
          
          // Recent activity
          _buildRecentActivityList(),
          
          const SizedBox(height: 24),
          
          // Washer performance
          _buildWasherPerformance(),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.date_range, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('MMM d, y').format(_dateRange.start)} - ${DateFormat('MMM d, y').format(_dateRange.end)}',
                  style: const TextStyle(color: Colors.white),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final DateTimeRange? result = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2023),
                      lastDate: DateTime.now(),
                      initialDateRange: _dateRange,
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Color(0xFF00C2CB),
                              onPrimary: Colors.white,
                              surface: Color(0xFF303030),
                              onSurface: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (result != null) {
                      setState(() {
                        _dateRange = result;
                      });
                    }
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMetricCard(
          title: 'Total Revenue',
          value: '\$3,542.50',
          icon: Icons.attach_money,
          color: Colors.green,
          change: '+15.2%',
        ),
        _buildMetricCard(
          title: 'Total Bookings',
          value: '128',
          icon: Icons.calendar_today,
          color: const Color(0xFF00C2CB),
          change: '+8.7%',
        ),
        _buildMetricCard(
          title: 'Active Washers',
          value: '24',
          icon: Icons.cleaning_services,
          color: Colors.orange,
          change: '+4',
        ),
        _buildMetricCard(
          title: 'Avg. Rating',
          value: '4.8',
          icon: Icons.star,
          color: Colors.amber,
          change: '+0.2',
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String change,
  }) {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              change,
              style: TextStyle(
                color: change.startsWith('+') ? Colors.green : Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Revenue Trend',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                DropdownButton<String>(
                  value: 'Monthly',
                  dropdownColor: Colors.grey[800],
                  style: const TextStyle(color: Colors.white),
                  underline: Container(),
                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
                  items: <String>['Daily', 'Weekly', 'Monthly', 'Yearly']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    // Handle time period change
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildLineChart(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildChartLegendItem('Regular Wash', const Color(0xFF00C2CB)),
                const SizedBox(width: 24),
                _buildChartLegendItem('Detail Wash', Colors.amber),
                const SizedBox(width: 24),
                _buildChartLegendItem('Custom Jobs', Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    // This is a placeholder for a real chart - in a real app, you'd use data from Firestore
    const washMooseColor = Color(0xFF00C2CB);
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  color: Colors.white60,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                );
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = 'APR';
                    break;
                  case 4:
                    text = 'MAY';
                    break;
                  default:
                    return Container();
                }
                return Text(text, style: style);
              },
              reservedSize: 22,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 3),
              FlSpot(1, 2),
              FlSpot(2, 2.5),
              FlSpot(3, 3.1),
              FlSpot(4, 4),
              FlSpot(5, 3.8),
              FlSpot(6, 4.5),
              FlSpot(7, 4.7),
              FlSpot(8, 5),
              FlSpot(9, 5.2),
              FlSpot(10, 5.5),
            ],
            isCurved: true,
            color: washMooseColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: washMooseColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList() {
    // This would typically be a stream from Firestore
    final recentActivities = [
      {
        'type': 'booking',
        'title': 'New Booking',
        'description': 'Alex Chen booked a Full Detail service',
        'time': '10 minutes ago',
      },
      {
        'type': 'washer',
        'title': 'New Washer',
        'description': 'Sarah Wilson registered as Expert Moose',
        'time': '1 hour ago',
      },
      {
        'type': 'booking',
        'title': 'Booking Completed',
        'description': 'James Peterson completed a booking',
        'time': '2 hours ago',
      },
      {
        'type': 'customer',
        'title': 'New Customer',
        'description': 'Michael Jones created an account',
        'time': '3 hours ago',
      },
    ];
    
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // View all activity log
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recentActivities.map((activity) => _buildActivityItem(activity)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, String> activity) {
    IconData icon;
    Color color;
    
    switch (activity['type']) {
      case 'booking':
        icon = Icons.book_online;
        color = const Color(0xFF00C2CB);
        break;
      case 'washer':
        icon = Icons.cleaning_services;
        color = Colors.amber;
        break;
      case 'customer':
        icon = Icons.person;
        color = Colors.blue;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  activity['description']!,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['time']!,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWasherPerformance() {
    // Sample data for washer performance
    final topWashers = [
      {
        'name': 'James Wilson',
        'type': 'Expert Moose',
        'jobs': 28,
        'rating': 4.9,
        'earnings': 1850.00,
      },
      {
        'name': 'Sarah Martinez',
        'type': 'Expert Moose',
        'jobs': 24,
        'rating': 4.8,
        'earnings': 1640.00,
      },
      {
        'name': 'Michael Thompson',
        'type': 'Everyday Moose',
        'jobs': 32,
        'rating': 4.7,
        'earnings': 1320.00,
      },
    ];
    
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Top Performing Washers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // View all washers
                    _tabController.animateTo(4); // Switch to Washers tab
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...topWashers.map((washer) => _buildWasherPerformanceItem(washer)),
          ],
        ),
      ),
    );
  }

  Widget _buildWasherPerformanceItem(Map<String, dynamic> washer) {
    final Color typeColor = washer['type'] == 'Expert Moose' ? Colors.amber : const Color(0xFF00C2CB);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          // Avatar with initial
          CircleAvatar(
            backgroundColor: typeColor.withOpacity(0.2),
            radius: 20,
            child: Text(
              washer['name'].toString()[0],
              style: TextStyle(
                color: typeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Washer info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  washer['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        washer['type'],
                        style: TextStyle(
                          color: typeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.star, color: Colors.amber, size: 14),
                    Text(
                      ' ${washer['rating']}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Jobs count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${washer['jobs']} jobs',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Earnings
          Text(
            '\$${washer['earnings'].toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// BOOKINGS TAB
  Widget _buildBookingsTab() {
    final List<String> statusFilters = ['all', 'pending', 'confirmed', 'completed', 'cancelled'];
    
    return Column(
      children: [
        // Booking status filters
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: statusFilters.map((status) {
                bool isSelected = bookingFilterStatus == status;
                Color chipColor = _getStatusColor(status);
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      status.substring(0, 1).toUpperCase() + status.substring(1),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => bookingFilterStatus = status);
                    },
                    backgroundColor: Colors.grey[800],
                    selectedColor: chipColor,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        
        // Bookings list
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getBookingsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading bookings: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final docs = snapshot.data!.docs;
              
              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book_online, size: 64, color: Colors.grey[700]),
                      const SizedBox(height: 16),
                      Text(
                        bookingFilterStatus == 'all' 
                            ? 'No bookings found' 
                            : 'No $bookingFilterStatus bookings found',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final bookingData = docs[index].data() as Map<String, dynamic>;
                  final bookingId = docs[index].id;
                  
                  return _buildBookingCard(bookingId, bookingData);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Stream<QuerySnapshot> _getBookingsStream() {
    Query query = FirebaseFirestore.instance.collection('bookings');
    
    // Apply status filter if not "all"
    if (bookingFilterStatus != 'all') {
      query = query.where('status', isEqualTo: bookingFilterStatus);
    }
    
    // Apply date range filter
    query = query.where('createdAt', 
        isGreaterThanOrEqualTo: Timestamp.fromDate(_dateRange.start));
    query = query.where('createdAt', 
        isLessThanOrEqualTo: Timestamp.fromDate(_dateRange.end));
    
    // Order by creation date, newest first
    return query.orderBy('createdAt', descending: true).snapshots();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return const Color(0xFF00C2CB);
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Widget _buildBookingCard(String bookingId, Map<String, dynamic> booking) {
    final status = booking['status'] ?? 'pending';
    final statusColor = _getStatusColor(status);
    
    // Parse Firebase Timestamp to DateTime
    DateTime? createdAt;
    if (booking['createdAt'] != null) {
      createdAt = (booking['createdAt'] as Timestamp).toDate();
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.5), width: 1),
      ),
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with booking ID and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking #${bookingId.substring(0, 6)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Customer and Service details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        booking['customerName'] ?? 'Unknown Customer',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Service info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Service',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        booking['packageName'] ?? 'Unknown Service',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Additional details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Scheduled For',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${booking['date'] ?? 'Unknown Date'} at ${booking['time'] ?? 'Unknown Time'}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Price info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Price',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '\$${(booking['totalPrice'] ?? 0).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Booking date
            if (createdAt != null) ...[
              const SizedBox(height: 12),
              Text(
                'Booked on: ${DateFormat('MMM d, y HH:mm').format(createdAt)}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 16),
            
            // Action buttons

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status == 'pending' || status == 'confirmed') ...[
                  OutlinedButton(
                    onPressed: () => _showCancelBookingDialog(bookingId),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                ],
                ElevatedButton(
                  onPressed: () => _showBookingDetails(bookingId, booking),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C2CB),
                  ),
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelBookingDialog(String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Cancel Booking',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('bookings')
                    .doc(bookingId)
                    .update({
                  'status': 'cancelled',
                  'cancelledByAdmin': true,
                  'cancelledAt': FieldValue.serverTimestamp(),
                });
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking cancelled successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showBookingDetails(String bookingId, Map<String, dynamic> booking) {
    final status = booking['status'] ?? 'pending';
    final statusColor = _getStatusColor(status);
    
    // Parse timestamps if they exist
    DateTime? createdAt;
    if (booking['createdAt'] != null) {
      createdAt = (booking['createdAt'] as Timestamp).toDate();
    }
    
    DateTime? completedAt;
    if (booking['completedAt'] != null) {
      completedAt = (booking['completedAt'] as Timestamp).toDate();
    }
    
    DateTime? cancelledAt;
    if (booking['cancelledAt'] != null) {
      cancelledAt = (booking['cancelledAt'] as Timestamp).toDate();
    }
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with booking ID and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Booking #${bookingId.substring(0, 6)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Status badge
                Row(
                  children: [
                    const Text(
                      'Status:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Booking details
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailGroup('Booking Information', [
                          _buildDetailItem('Booking ID', bookingId),
                          if (createdAt != null)
                            _buildDetailItem('Created', DateFormat('MMM d, y HH:mm').format(createdAt)),
                          if (completedAt != null)
                            _buildDetailItem('Completed', DateFormat('MMM d, y HH:mm').format(completedAt)),
                          if (cancelledAt != null)
                            _buildDetailItem('Cancelled', DateFormat('MMM d, y HH:mm').format(cancelledAt)),
                          _buildDetailItem('Location', booking['location'] ?? 'Unknown'),
                        ]),
                        
                        const SizedBox(height: 16),
                        
                        _buildDetailGroup('Customer Information', [
                          _buildDetailItem('Name', booking['customerName'] ?? 'Unknown'),
                          _buildDetailItem('ID', booking['customerId'] ?? 'Unknown'),
                        ]),
                        
                        const SizedBox(height: 16),
                        
                        _buildDetailGroup('Washer Information', [
                          _buildDetailItem('Name', booking['washerName'] ?? 'Not Assigned'),
                          _buildDetailItem('ID', booking['washerId'] ?? 'Not Assigned'),
                          _buildDetailItem('Type', booking['washerType'] ?? 'Unknown'),
                        ]),
                        
                        const SizedBox(height: 16),
                        
                        _buildDetailGroup('Service Details', [
                          _buildDetailItem('Package', booking['packageName'] ?? 'Unknown'),
                          _buildDetailItem('Vehicle', booking['vehicleType'] ?? 'Unknown'),
                          _buildDetailItem('Add-ons', (booking['addOns'] as List<dynamic>?)?.join(', ') ?? 'None'),
                          _buildDetailItem('Date', booking['date'] ?? 'Unknown'),
                          _buildDetailItem('Time', booking['time'] ?? 'Unknown'),
                          _buildDetailItem('Duration', '${booking['duration'] ?? 0} minutes'),
                          _buildDetailItem('Price', '\$${(booking['totalPrice'] ?? 0).toStringAsFixed(2)}'),
                        ]),
                        
                        if (booking['rating'] != null) ...[
                          const SizedBox(height: 16),
                          
                          _buildDetailGroup('Customer Review', [
                            _buildDetailItem('Rating', '${booking['rating']}/5'),
                            _buildDetailItem('Review', booking['review'] ?? 'No comment provided'),
                          ]),
                        ],
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (status == 'pending') ...[
                      OutlinedButton(
                        onPressed: () async {
                          try {
                            await FirebaseFirestore.instance
                                .collection('bookings')
                                .doc(bookingId)
                                .update({'status': 'confirmed'});
                            
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Booking confirmed')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00C2CB),
                          side: const BorderSide(color: Color(0xFF00C2CB)),
                        ),
                        child: const Text('Confirm'),
                      ),
                      const SizedBox(width: 8),
                    ],
                    
                    if (status == 'pending' || status == 'confirmed') ...[
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showCancelBookingDialog(bookingId);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Cancel Booking'),
                      ),
                      const SizedBox(width: 8),
                    ],
                    
                    if (status == 'confirmed') ...[
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await FirebaseFirestore.instance
                                .collection('bookings')
                                .doc(bookingId)
                                .update({
                              'status': 'completed',
                              'completedAt': FieldValue.serverTimestamp(),
                              'completedByAdmin': true,
                            });
                            
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Booking marked as completed')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Mark Completed'),
                      ),
                    ],
                    
                    if (status == 'completed' || status == 'cancelled') ...[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C2CB),
                        ),
                        child: const Text('Close'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// SERVICES TAB
  Widget _buildServicesTab() {
    return Column(
      children: [
        // Service type filters
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildServiceFilterChip('all', 'All Services', Colors.blue),
                _buildServiceFilterChip('regular', 'Regular Wash', const Color(0xFF00C2CB)),
                _buildServiceFilterChip('detail', 'Detail Wash', Colors.green),
                _buildServiceFilterChip('custom', 'Custom Jobs', Colors.purple),
                _buildServiceFilterChip('addons', 'Add-ons', Colors.orange),
              ],
            ),
          ),
        ),
        
        // Services Management
        Expanded(
          child: _buildServicesList(),
        ),
      ],
    );
  }

  Widget _buildServiceFilterChip(String value, String label, Color color) {
    final bool isSelected = serviceFilterType == value;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => serviceFilterType = value);
        },
        backgroundColor: Colors.grey[800],
        selectedColor: color,
      ),
    );
  }

  Widget _buildServicesList() {
    // Sample data for services - in a real app, you'd fetch from Firestore
    final regularServices = [
      {
        'id': 'RS001',
        'name': 'Interior Only',
        'description': 'Complete interior cleaning including vacuum, dashboard, and surface sanitization.',
        'type': 'regular',
        'pricing': {'Sedan': 25, 'SUV': 25, 'Large SUV': 30, 'Van': 40},
        'duration': {'Sedan': 25, 'SUV': 25, 'Large SUV': 30, 'Van': 40},
        'isActive': true,
      },
      {
        'id': 'RS002',
        'name': 'Exterior Only',
        'description': 'Thorough exterior wash with foam, hand wash, and wheel cleaning.',
        'type': 'regular',
        'pricing': {'Sedan': 25, 'SUV': 30, 'Large SUV': 35, 'Van': 45},
        'duration': {'Sedan': 25, 'SUV': 30, 'Large SUV': 35, 'Van': 45},
        'isActive': true,
      },
      {
        'id': 'RS003',
        'name': 'Full Inside & Out',
        'description': 'Complete interior and exterior cleaning service.',
        'type': 'regular',
        'pricing': {'Sedan': 45, 'SUV': 50, 'Large SUV': 60, 'Van': 80},
        'duration': {'Sedan': 55, 'SUV': 60, 'Large SUV': 70, 'Van': 90},
        'isActive': true,
      },
    ];
    
    final detailServices = [
      {
        'id': 'DS001',
        'name': 'Interior Detail',
        'description': 'Deep leather cleaning & conditioning, carpet & fabric extraction, and premium interior treatment.',
        'type': 'detail',
        'pricing': {'Sedan': 129, 'SUV': 155, 'Large SUV': 180, 'Van': 220},
        'duration': {'Sedan': 120, 'SUV': 135, 'Large SUV': 150, 'Van': 180},
        'isActive': true,
      },
      {
        'id': 'DS002',
        'name': 'Exterior Detail',
        'description': 'Clay bar decontamination, light scratch correction, and professional paint sealant.',
        'type': 'detail',
        'pricing': {'Sedan': 129, 'SUV': 155, 'Large SUV': 180, 'Van': 220},
        'duration': {'Sedan': 120, 'SUV': 135, 'Large SUV': 150, 'Van': 180},
        'isActive': true,
      },
      {
        'id': 'DS003',
        'name': 'Full Detail',
        'description': 'Complete interior restoration, paint correction, and premium care.',
        'type': 'detail',
        'pricing': {'Sedan': 219, 'SUV': 265, 'Large SUV': 305, 'Van': 375},
        'duration': {'Sedan': 220, 'SUV': 245, 'Large SUV': 270, 'Van': 320},
        'isActive': true,
      },
      {
        'id': 'DS004',
        'name': 'Paint Protection',
        'description': 'Advanced paint correction and protection system.',
        'type': 'detail',
        'pricing': {'Sedan': 279, 'SUV': 335, 'Large SUV': 390, 'Van': 475},
        'duration': {'Sedan': 240, 'SUV': 270, 'Large SUV': 300, 'Van': 360},
        'isActive': false,
      },
    ];
    
    final addOns = [
      {
        'id': 'AO001',
        'name': 'Light Pet Hair Removal',
        'description': 'Remove pet hair from interior surfaces.',
        'type': 'addon',
        'pricing': {'Sedan': 15, 'SUV': 20, 'Large SUV': 25, 'Van': 40},
        'duration': {'Sedan': 15, 'SUV': 20, 'Large SUV': 20, 'Van': 30},
        'isActive': true,
      },
      {
        'id': 'AO002',
        'name': 'Heavy Pet Hair Removal',
        'description': 'Deep removal of embedded pet hair.',
        'type': 'addon',
        'pricing': {'Sedan': 20, 'SUV': 30, 'Large SUV': 35, 'Van': 50},
        'duration': {'Sedan': 20, 'SUV': 20, 'Large SUV': 25, 'Van': 40},
        'isActive': true,
      },
      {
        'id': 'AO003',
        'name': 'Fragrance',
        'description': 'Add a pleasant fragrance to your vehicle.',
        'type': 'addon',
        'pricing': {'Sedan': 5, 'SUV': 5, 'Large SUV': 5, 'Van': 10},
        'duration': {'Sedan': 5, 'SUV': 5, 'Large SUV': 5, 'Van': 5},
        'isActive': true,
      },
    ];
    
    // Combine or filter services based on selected service type
    List<Map<String, dynamic>> displayedServices = [];
    
    if (serviceFilterType == 'all') {
      displayedServices = [...regularServices, ...detailServices, ...addOns];
    } else if (serviceFilterType == 'regular') {
      displayedServices = regularServices;
    } else if (serviceFilterType == 'detail') {
      displayedServices = detailServices;
    } else if (serviceFilterType == 'addons') {
      displayedServices = addOns;
    }
    
    return Column(
      children: [
        // Header with add service button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manage ${serviceFilterType == 'all' ? 'Services' : '${serviceFilterType.substring(0, 1).toUpperCase()}${serviceFilterType.substring(1)} Services'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddServiceDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add New'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C2CB),
                ),
              ),
            ],
          ),
        ),
        
        // Services list
        Expanded(
          child: displayedServices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category, size: 64, color: Colors.grey[700]),
                      const SizedBox(height: 16),
                      Text(
                        'No ${serviceFilterType == 'all' ? 'services' : serviceFilterType} found',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: displayedServices.length,
                  itemBuilder: (context, index) {
                    final service = displayedServices[index];
                    return _buildServiceCard(service);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    Color serviceColor;
    switch (service['type']) {
      case 'regular':
        serviceColor = const Color(0xFF00C2CB);
        break;
      case 'detail':
        serviceColor = Colors.green;
        break;
      case 'addon':
        serviceColor = Colors.orange;
        break;
      default:
        serviceColor = Colors.blue;
    }
    
    final isActive = service['isActive'] as bool;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive ? serviceColor.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with service name, type, and status toggle
            Row(
              children: [
                // Service type badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: serviceColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    service['type'].toString().toUpperCase(),
                    style: TextStyle(
                      color: serviceColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Service name
                Expanded(
                  child: Text(
                    service['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
                
                // Status toggle
                Switch(
                  value: isActive,
                  onChanged: (value) {
                    // In a real app, update Firestore here
                    setState(() {
                      service['isActive'] = value;
                    });
                  },
                  activeColor: serviceColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Service description
            Text(
              service['description'],
              style: TextStyle(
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            
            // Pricing table
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pricing & Duration by Vehicle Type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildPricingRow('Sedan', service['pricing']['Sedan'], service['duration']['Sedan']),
                      _buildPricingRow('SUV', service['pricing']['SUV'], service['duration']['SUV']),
                      _buildPricingRow('Large SUV', service['pricing']['Large SUV'], service['duration']['Large SUV']),
                      _buildPricingRow('Van', service['pricing']['Van'], service['duration']['Van']),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showEditServiceDialog(service),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showDeleteServiceDialog(service),
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingRow(String vehicleType, int price, int duration) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            vehicleType,
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            '\$$price • ${duration}min',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddServiceDialog() {
    final serviceTypes = ['regular', 'detail', 'addon'];
    String selectedType = 'regular';
    
    // Show a dialog to add a new service
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Add New Service',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Service Type',
                border: OutlineInputBorder(),
              ),
              value: selectedType,
              items: serviceTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    type.substring(0, 1).toUpperCase() + type.substring(1),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedType = value;
                }
              },
              dropdownColor: Colors.grey[800],
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Service Name',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
            ),
            // Note: In a real implementation, you'd need more fields for pricing and duration
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // In a real app, save to Firestore here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Service added successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C2CB),
            ),
            child: const Text('Add Service'),
          ),
        ],
      ),
    );
  }

  void _showEditServiceDialog(Map<String, dynamic> service) {
    // Show a dialog to edit a service
    // This would be similar to the add dialog but pre-filled with service data
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Edit ${service['name']}',
          style: const TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Service editing form would go here.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // In a real app, update Firestore here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Service updated successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C2CB),
            ),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showDeleteServiceDialog(Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Service',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${service['name']}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // In a real app, delete from Firestore here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Service deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// CUSTOMERS TAB - Enhanced version
  Widget _buildCustomersTab() {
    return Column(
      children: [
        // Search and filter bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search customers by name or email...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[850],
            ),
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              // Filter customers based on search
              // In a real app, this would update a stream or query
            },
          ),
        ),
        
        // Customers list
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('userType', isEqualTo: 'customer')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Error loading customers',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final docs = snapshot.data!.docs;
              
              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No customers found.",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  final docId = docs[i].id;
                  
                  return _buildEnhancedCustomerCard(docId, data);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedCustomerCard(String customerId, Map<String, dynamic> customerData) {
    final isBanned = customerData['status'] == 'banned';
    final fullName = customerData['fullName'] ?? 'No Name';
    final email = customerData['email'] ?? 'No Email';
    final phone = customerData['phone'] ?? 'No Phone';
    
    // Get registration date if available
    DateTime? registrationDate;
    if (customerData['createdAt'] != null) {
      registrationDate = (customerData['createdAt'] as Timestamp).toDate();
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isBanned ? Colors.red.withOpacity(0.5) : Colors.transparent,
          width: isBanned ? 1 : 0,
        ),
      ),
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer name and status
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isBanned ? Colors.red.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                  radius: 24,
                  child: Text(
                    fullName.isNotEmpty ? fullName[0] : '?',
                    style: TextStyle(
                      color: isBanned ? Colors.red : Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (isBanned) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'BANNED',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white70),
                  onPressed: () => _showCustomerActions(customerId, customerData),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Contact and registration info
            Row(
              children: [
                // Phone
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey[400]),
                      const SizedBox(width: 8),
                      Text(
                        phone,
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                // Registration date
                if (registrationDate != null) ...[
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
                        const SizedBox(width: 8),
                        Text(
                          'Joined: ${DateFormat('MMM d, y').format(registrationDate)}',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Quick stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCustomerStat('Bookings', '12', Icons.book_online),
                _buildCustomerStat('Total Spent', '\$345.50', Icons.attach_money),
                _buildCustomerStat('Avg. Rating', '4.8', Icons.star),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _viewCustomerBookings(customerId),
                  icon: const Icon(Icons.history),
                  label: const Text('Bookings'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00C2CB),
                    side: const BorderSide(color: Color(0xFF00C2CB)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showCustomerDetails(customerId, customerData),
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C2CB),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF00C2CB)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showCustomerActions(String customerId, Map<String, dynamic> customerData) {
    final isBanned = customerData['status'] == 'banned';
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.visibility, color: Color(0xFF00C2CB)),
            title: const Text('View Profile', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _showCustomerDetails(customerId, customerData);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.blue),
            title: const Text('View Bookings', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _viewCustomerBookings(customerId);
            },
          ),
          ListTile(
            leading: const Icon(Icons.message, color: Colors.green),
            title: const Text('Contact Customer', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              // Show contact dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contact feature coming soon')),
              );
            },
          ),
          ListTile(
            leading: Icon(
              isBanned ? Icons.restore : Icons.block, 
              color: isBanned ? Colors.green : Colors.red,
            ),
            title: Text(
              isBanned ? 'Unban Customer' : 'Ban Customer', 
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () async {
              Navigator.pop(context);
              
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(customerId)
                    .update({
                  'status': isBanned ? 'active' : 'banned',
                  'updatedAt': FieldValue.serverTimestamp(),
                });
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isBanned 
                      ? 'Customer unbanned successfully' 
                      : 'Customer banned successfully')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showCustomerDetails(String customerId, Map<String, dynamic> customerData) {
    // Here you'd show a detailed customer profile
    // For demo purposes, we'll just show a dialog with basic information
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          customerData['fullName'] ?? 'Customer Details',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Email', customerData['email'] ?? 'N/A'),
            _buildDetailItem('Phone', customerData['phone'] ?? 'N/A'),
            _buildDetailItem('Status', customerData['status'] ?? 'active'),
            // Add more details as needed
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewCustomerBookings(String customerId) {
    // Change to bookings tab and filter by this customer
    _tabController.animateTo(1); // Switch to Bookings tab
    
    // Ideally, you'd set a customer filter here
    // For now, we'll just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Viewing customer bookings')),
    );
  }

  /// WASHERS TAB - Enhanced version
  Widget _buildWashersTab() {
    return Column(
      children: [
        // Search and filter bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[900],
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search washers by name or email...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[850],
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  // Filter washers based on search
                  // In a real app, this would update a stream or query
                },
              ),
              const SizedBox(height: 16),
              
              // Washer type/status filters
              Row(
                children: [
                  // Status filters
                  FilterChip(
                    label: const Text('Pending'),
                    selected: filterStatus == "pending",
                    onSelected: (selected) {
                      setState(() => filterStatus = "pending");
                    },
                    backgroundColor: Colors.grey[800],
                    selectedColor: Colors.amber,
                    labelStyle: TextStyle(
                      color: filterStatus == "pending" ? Colors.black : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Approved'),
                    selected: filterStatus == "approved",
                    onSelected: (selected) {
                      setState(() => filterStatus = "approved");
                    },
                    backgroundColor: Colors.grey[800],
                    selectedColor: const Color(0xFF00C2CB),
                    labelStyle: TextStyle(
                      color: filterStatus == "approved" ? Colors.black : Colors.white,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Type dropdown
                  DropdownButton<String>(
                    value: 'All Types',
                    dropdownColor: Colors.grey[900],
                    style: const TextStyle(color: Colors.white),
                    underline: Container(
                      height: 1,
                      color: Colors.white24,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'All Types', child: Text('All Types')),
                      DropdownMenuItem(value: 'Expert Moose', child: Text('Expert Moose')),
                      DropdownMenuItem(value: 'Everyday Moose', child: Text('Everyday Moose')),
                    ],
                    onChanged: (String? newValue) {
                      // Filter by washer type
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Washers list
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('userType', isEqualTo: 'washer')
                .where('status', isEqualTo: filterStatus)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading washers: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final docs = snapshot.data!.docs;
              
              if (docs.isEmpty) {
                return Center(
                  child: Text(
                    filterStatus == "pending"
                        ? "No pending washers."
                        : "No approved washers.",
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  final docId = docs[i].id;
                  
                  return _buildEnhancedWasherCard(docId, data);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedWasherCard(String washerId, Map<String, dynamic> washerData) {
    final fullName = washerData['fullName'] ?? 'No Name';
    final email = washerData['email'] ?? 'No Email';
    final phone = washerData['phone'] ?? 'No Phone';
    final washerType = washerData['washerType'] ?? 'unknown';
    final status = washerData['status'] ?? 'pending';
    
    // Determine color based on washer type
    final typeColor = washerType == 'expert' ? Colors.amber : const Color(0xFF00C2CB);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: status == 'pending' ? Colors.amber.withOpacity(0.5) : Colors.transparent,
          width: status == 'pending' ? 1 : 0,
        ),
      ),
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Washer name and type
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: typeColor.withOpacity(0.2),
                  radius: 24,
                  child: Icon(
                    Icons.cleaning_services,
                    color: typeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              washerType == 'expert' ? 'Expert Moose' : 'Everyday Moose',
                              style: TextStyle(
                                color: typeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: status == 'approved' 
                                  ? Colors.green.withOpacity(0.2) 
                                  : Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: status == 'approved' ? Colors.green : Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Contact information
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.email, size: 16, color: Colors.grey[400]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          email,
                          style: TextStyle(color: Colors.grey[400]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey[400]),
                      const SizedBox(width: 8),
                      Text(
                        phone,
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status == 'pending') ...[
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(washerId)
                            .update({'status': 'approved'});
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Washer approved!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Approve'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () async {
                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(washerId)
                            .update({'status': 'rejected'});
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Washer rejected')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Reject'),
                  ),
                ] else ...[
                  OutlinedButton(
                    onPressed: () => _viewWasherBookings(washerId),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00C2CB),
                      side: const BorderSide(color: Color(0xFF00C2CB)),
                    ),
                    child: const Text('View Bookings'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _showWasherDetails(washerId, washerData),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C2CB),
                    ),
                    child: const Text('View Profile'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _viewWasherBookings(String washerId) {
    // Change to bookings tab and filter by this washer
    _tabController.animateTo(1); // Switch to Bookings tab
    
    // Ideally, you'd set a washer filter here
    // For now, we'll just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Viewing washer bookings')),
    );
  }

  void _showWasherDetails(String washerId, Map<String, dynamic> washerData) {
    // Show detailed washer information
    // This would be a more comprehensive view than what we have in the card
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          washerData['fullName'] ?? 'Washer Details',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Email', washerData['email'] ?? 'N/A'),
            _buildDetailItem('Phone', washerData['phone'] ?? 'N/A'),
            _buildDetailItem('Type', washerData['washerType'] ?? 'unknown'),
            _buildDetailItem('Status', washerData['status'] ?? 'pending'),
            // Add more details as needed
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
            