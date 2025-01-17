import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uas_flutter_app/screens/customer/widgets/edit_customer_modal.dart';
import 'package:uas_flutter_app/utils/guard_util.dart';
import './widgets/custom_sidebar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? userEmail;
  String? userName;
  List<dynamic> customers = [];
  bool isLoading = true;

  static const String baseUrl = 'http://192.168.1.37:8000/api/v1';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCustomers();
  }

  Future<void> _loadUserData() async {
    final userData = await Vania.getCurrentUser();
    if (userData != null) {
      setState(() {
        userEmail = userData['email'];
        userName = userData['name'];
      });
    }
  }

  Future<void> _loadCustomers() async {
    try {
      final token = await Vania.getAccessToken();
      final response = await http.get(
        Uri.parse('$baseUrl/customers'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          customers = data['data'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal memuat data'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal terhubung ke server'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Add this method to the _HomeScreenState class

  Future<void> _deleteCustomer(String customerId) async {
    try {
      final token = await Vania.getAccessToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/customers/$customerId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          customers.removeWhere(
              (customer) => customer['id'].toString() == customerId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Customer berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menghapus customer'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan saat menghapus customer'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Data Customer',
          style: TextStyle(
            color: Color(0xFF1E88E5),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1E88E5)),
            onPressed: _loadCustomers,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
              child: const CircleAvatar(
                backgroundColor: Color(0xFF1E88E5),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      endDrawer: CustomSidebar(
        email: userEmail ?? 'Loading...',
        name: userName ?? 'Loading...',
        onClose: () {
          _scaffoldKey.currentState?.closeEndDrawer();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/add-customer'),
        backgroundColor: const Color(0xFF1E88E5),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Customer',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1E88E5),
              ),
            )
          : customers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada data customer',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/add-customer'),
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Customer Baru'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCustomers,
                  color: const Color(0xFF1E88E5),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            // Navigate to detail
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      backgroundColor: Color(0xFF1E88E5),
                                      child: Icon(
                                        Icons.person_outline,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            customer['cust_name'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            customer['cust_telp'],
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton(
                                      icon: const Icon(Icons.more_vert),
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Hapus',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (value) async {
                                        switch (value) {
                                          case 'edit':
                                            showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  EditCustomerModal(
                                                customer: customer,
                                                baseUrl: baseUrl,
                                                onCustomerUpdated:
                                                    (updatedCustomer) {
                                                  setState(() {
                                                    final index = customers
                                                        .indexWhere((c) =>
                                                            c['id'] ==
                                                            updatedCustomer[
                                                                'id']);
                                                    if (index != -1) {
                                                      customers[index] =
                                                          updatedCustomer;
                                                    }
                                                  });
                                                },
                                              ),
                                            );
                                            break;
                                          case 'delete':
                                            final shouldDelete =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                    'Konfirmasi Hapus'),
                                                content: Text(
                                                    'Apakah Anda yakin ingin menghapus customer ${customer['cust_name']}?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(false),
                                                    child: const Text('Batal'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(true),
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.red,
                                                    ),
                                                    child: const Text('Hapus'),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (shouldDelete == true) {
                                              await _deleteCustomer(
                                                  customer['id'].toString());
                                            }
                                            break;
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                _buildInfoRow(
                                  Icons.location_on,
                                  'Alamat',
                                  '${customer['cust_address']}, ${customer['cust_city']}, ${customer['cust_state']} ${customer['cust_zip']}',
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  Icons.flag,
                                  'Negara',
                                  customer['cust_country'],
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  Icons.access_time,
                                  'Terdaftar',
                                  _formatDate(customer['created_at']),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
