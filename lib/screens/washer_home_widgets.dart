import 'package:flutter/material.dart';

mixin WasherHomeWidgets<T extends StatefulWidget> on State<T> {
  // Access to main widget properties and state
  bool get isExpertMoose;
  bool get isVerified;
  bool get isOnline;
  bool get canReceiveOrders;
  bool get isLoadingWorkload;
  String get documentsStatus;
  Map<String, dynamic>? get userData;
  Map<String, dynamic>? get washerWorkload;

  // Access to logic methods
  Future<void> goOnline();
  Future<void> goOffline();
  void navigateToProfile();
  Future<void> retryLoading();

  // Enhanced Verification Status Widget
  Widget buildVerificationBanner() {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    Widget? actionButton;
    Widget? workloadInfo;

    if (washerWorkload != null && canReceiveOrders) {
      final activeOrders = washerWorkload!['activeOrders'] ?? 0;
      final todayCompleted = washerWorkload!['todayCompleted'] ?? 0;
      final canAcceptASAP = washerWorkload!['canAcceptASAP'] ?? true;

      workloadInfo = Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA), // ✅ FIXED: Light theme surface color
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFE2E8F0), // ✅ ADDED: Light border for definition
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              child: buildWorkloadStat('Active', '$activeOrders', Colors.blue),
            ),
            Flexible(
              child: buildWorkloadStat(
                'Today',
                '$todayCompleted',
                Colors.green,
              ),
            ),
            Flexible(
              child: buildWorkloadStat(
                'ASAP',
                canAcceptASAP ? 'Available' : 'Busy',
                canAcceptASAP ? Colors.amber : Colors.red,
              ),
            ),
          ],
        ),
      );
    }

    if (isVerified) {
      if (isOnline) {
        statusColor = Colors.green;
        statusText = '🟢 Online & Ready for Orders';
        statusIcon = Icons.online_prediction;
        actionButton = ElevatedButton.icon(
          onPressed: goOffline,
          icon: const Icon(Icons.pause_circle_outline, size: 18),
          label: const Text('Go Offline'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      } else {
        statusColor = Colors.amber;
        statusText = '🟡 Verified - Go Online to Receive Orders';
        statusIcon = Icons.verified_user;
        actionButton = ElevatedButton.icon(
          onPressed: goOnline,
          icon: const Icon(Icons.play_circle_outline, size: 18),
          label: const Text('Go Online'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      }
    } else {
      switch (documentsStatus) {
        case 'submitted':
          statusColor = Colors.orange;
          statusText = '🟠 Documents Under Review';
          statusIcon = Icons.pending_actions;
          break;
        case 'rejected':
          statusColor = Colors.red;
          statusText = '🔴 Documents Rejected - Please Re-upload';
          statusIcon = Icons.error_outline;
          actionButton = ElevatedButton.icon(
            onPressed: navigateToProfile,
            icon: const Icon(Icons.upload_file, size: 18),
            label: const Text('Upload Documents'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
          break;
        default:
          statusColor = Colors.grey;
          statusText = '⚪ Upload Documents to Get Verified';
          statusIcon = Icons.upload_file;
          actionButton = ElevatedButton.icon(
            onPressed: navigateToProfile,
            icon: const Icon(Icons.upload_file, size: 18),
            label: const Text('Upload Documents'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
      }
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Column(
        children: [
          Row(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!canReceiveOrders)
                      const Text(
                        'Complete verification and go online to start receiving orders',
                        style: TextStyle(color: Color(0xFF4A5568), fontSize: 12), // ✅ FIXED: Darker readable grey
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (isLoadingWorkload)
                      const Text(
                        'Loading workload...',
                        style: TextStyle(color: Color(0xFF718096), fontSize: 12), // ✅ FIXED: Medium grey
                      ),
                  ],
                ),
              ),
              if (actionButton != null) ...[
                const SizedBox(width: 12),
                Flexible(child: actionButton),
              ],
            ],
          ),
          if (workloadInfo != null) workloadInfo,
        ],
      ),
    );
  }

  Widget buildWorkloadStat(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF4A5568), fontSize: 12), // ✅ FIXED: Darker readable grey
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // Blocked Jobs View
  Widget buildBlockedJobsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              !isVerified ? Icons.shield_outlined : Icons.power_settings_new,
              size: 80,
              color: const Color(0xFF718096), // ✅ FIXED: Medium grey for light theme
            ),
            const SizedBox(height: 24),
            Text(
              !isVerified ? 'Verification Required' : 'Go Online to See Jobs',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A202C), // ✅ FIXED: Dark text for light theme
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Text(
              !isVerified
                  ? 'Upload and verify your documents to start receiving job requests from customers.'
                  : 'Go online to start receiving job requests and earn money!',
              style: const TextStyle(fontSize: 16, color: Color(0xFF4A5568)), // ✅ FIXED: Darker readable grey
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 32),
            if (!isVerified)
              ElevatedButton.icon(
                onPressed: navigateToProfile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Complete Verification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: goOnline,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Go Online'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading jobs...',
            style: TextStyle(color: Color(0xFF1A202C)), // ✅ FIXED: Dark text
          ),
        ],
      ),
    );
  }

  Widget buildErrorView(String error, {bool isIndex = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isIndex ? Icons.build : Icons.error_outline,
              size: 48,
              color: isIndex ? Colors.orange : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              isIndex ? 'Setting Up Database' : 'Error Loading Data',
              style: const TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A202C), // ✅ FIXED: Dark text
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF4A5568)), // ✅ FIXED: Readable grey
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            if (isIndex) ...[
              const SizedBox(height: 16),
              const Text(
                'This is a one-time setup process.\nThe database index will be ready in 2-3 minutes.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orange),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: retryLoading,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isExpertMoose
                    ? Colors.amber
                    : const Color(0xFF00C2CB),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method name getters to ensure compatibility
  Widget _buildVerificationBanner() => buildVerificationBanner();
  Widget _buildWorkloadStat(String label, String value, Color color) =>
      buildWorkloadStat(label, value, color);
  Widget _buildBlockedJobsView() => buildBlockedJobsView();
  Widget _buildLoadingView() => buildLoadingView();
  Widget _buildErrorView(String error, {bool isIndex = false}) =>
      buildErrorView(error, isIndex: isIndex);
}