import 'package:flutter/material.dart'
import '../psychiatrist_dashboard/repository.dart';
import 'models.dart';
import 'result_entry_screen.dart';

class LabDashboardScreen extends StatefulWidget {
  const LabDashboardScreen({super.key});

  @override
  State<LabDashboardScreen> createState() => _LabDashboardScreenState();
}

class _LabDashboardScreenState extends State<LabDashboardScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all'; // 'all', 'pending', 'completed'

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            'Lab Technician Dashboard',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF1565C0), // Blue primary
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Color(0xFFFFC107), // Yellow
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Pending Requests', icon: Icon(Icons.pending_actions)),
              Tab(text: 'Completed Tests', icon: Icon(Icons.check_circle)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRequestList(isPending: true),
            _buildRequestList(isPending: false),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestList({required bool isPending}) {
    return Column(
      children: [
        // Search and Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search by patient name or test type...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF1565C0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE3F2FD)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE3F2FD)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1565C0),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                ),
                onChanged: (v) =>
                    setState(() => _searchQuery = v.toLowerCase()),
              ),
              const SizedBox(height: 12),
              // Filter Chips
              Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed', 'completed'),
                ],
              ),
            ],
          ),
        ),
        // Request List
        Expanded(
          child: StreamBuilder<List<LabRequest>>(
            stream: repository.fetchLabRequests(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF1565C0),
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading requests: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              var requests = snapshot.data ?? [];
              requests = requests
                  .where(
                    (r) => isPending
                        ? r.status == 'pending'
                        : r.status == 'completed',
                  )
                  .toList();

              if (_searchQuery.isNotEmpty) {
                requests = requests
                    .where(
                      (r) =>
                          r.patientName.toLowerCase().contains(_searchQuery) ||
                          r.testType.toLowerCase().contains(_searchQuery) ||
                          r.doctorName.toLowerCase().contains(_searchQuery),
                    )
                    .toList();
              }

              if (_statusFilter != 'all') {
                requests = requests
                    .where((r) => r.status == _statusFilter)
                    .toList();
              }

              if (requests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isPending ? Icons.pending_actions : Icons.check_circle,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No ${isPending ? "pending" : "completed"} requests found.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_searchQuery.isNotEmpty ||
                          _statusFilter != 'all') ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _statusFilter = 'all';
                            });
                          },
                          child: const Text(
                            'Clear filters',
                            style: TextStyle(color: Color(0xFF1565C0)),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final r = requests[index];
                  return _buildRequestCard(r, isPending);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String filterValue) {
    final isSelected = _statusFilter == filterValue;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF1565C0),
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _statusFilter = selected ? filterValue : 'all');
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF1565C0),
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE3F2FD)),
      ),
    );
  }

  Widget _buildRequestCard(LabRequest request, bool isPending) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isPending
              ? const Color(0xFFFFC107).withValues(alpha: 0.3)
              : const Color(0xFF4CAF50).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToResultEntry(request),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and priority
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request.patientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isPending
                          ? const Color(0xFFFFC107).withValues(alpha: 0.1)
                          : const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isPending
                            ? const Color(0xFFFFC107)
                            : const Color(0xFF4CAF50),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isPending ? 'PENDING' : 'COMPLETED',
                      style: TextStyle(
                        color: isPending
                            ? const Color(0xFFFF6F00)
                            : const Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Test Type
              _buildInfoChip(
                Icons.science,
                request.testType,
                const Color(0xFFE3F2FD),
                const Color(0xFF1565C0),
              ),
              const SizedBox(height: 8),

              // Doctor and Date
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      Icons.person,
                      'Dr. ${request.doctorName}',
                      const Color(0xFFF3E5F5),
                      const Color(0xFF6A1B9A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.access_time,
                    _formatDateTime(request.orderedAt),
                    const Color(0xFFFFF3E0),
                    const Color(0xFFEF6C00),
                  ),
                ],
              ),

              // Result preview for completed tests
              if (!isPending && request.result.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Result Summary:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.result.length > 100
                            ? '${request.result.substring(0, 100)}...'
                            : request.result,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF424242),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Action buttons
              const SizedBox(height: 16),
              Row(
                children: [
                  if (isPending) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToResultEntry(request),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Enter Result'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _showRequestDetails(request),
                      icon: const Icon(Icons.info_outline),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFE3F2FD),
                        foregroundColor: const Color(0xFF1565C0),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showRequestDetails(request),
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('View Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4CAF50),
                          side: const BorderSide(color: Color(0xFF4CAF50)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _showResultDialog(request),
                      icon: const Icon(Icons.description),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F8E9),
                        foregroundColor: const Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String label,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _navigateToResultEntry(LabRequest request) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LabResultEntryScreen(request: request)),
    );
  }

  void _showRequestDetails(LabRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Request Details',
          style: const TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Patient ID', request.patientId),
            _buildDetailRow('Patient Name', request.patientName),
            _buildDetailRow('Doctor', request.doctorName),
            _buildDetailRow('Test Type', request.testType),
            _buildDetailRow('Status', request.status.toUpperCase()),
            _buildDetailRow('Ordered At', _formatDateTime(request.orderedAt)),
            if (request.completedAt != null)
              _buildDetailRow(
                'Completed At',
                _formatDateTime(request.completedAt!),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF1565C0)),
            ),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(LabRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Test Result',
          style: const TextStyle(
            color: Color(0xFF4CAF50),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            request.result,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF424242),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF616161)),
            ),
          ),
        ],
      ),
    );
  }
}
