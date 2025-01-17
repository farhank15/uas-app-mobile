import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:uas_flutter_app/utils/guard_util.dart';

class EditCustomerModal extends StatefulWidget {
  final Map<String, dynamic> customer;
  final Function onCustomerUpdated;
  final String baseUrl;

  const EditCustomerModal({
    super.key,
    required this.customer,
    required this.onCustomerUpdated,
    required this.baseUrl,
  });

  @override
  State<EditCustomerModal> createState() => _EditCustomerModalState();
}

class _EditCustomerModalState extends State<EditCustomerModal> {
  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController zipController;
  late TextEditingController countryController;
  late TextEditingController phoneController;

  Timer? _debounceTimer;
  bool _hasChanges = false;
  bool _updateSuccess = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.customer['cust_name']);
    addressController =
        TextEditingController(text: widget.customer['cust_address']);
    cityController = TextEditingController(text: widget.customer['cust_city']);
    stateController =
        TextEditingController(text: widget.customer['cust_state']);
    zipController = TextEditingController(text: widget.customer['cust_zip']);
    countryController =
        TextEditingController(text: widget.customer['cust_country']);
    phoneController = TextEditingController(text: widget.customer['cust_telp']);

    // Add listeners to all controllers
    nameController.addListener(() => _onFieldChange());
    addressController.addListener(() => _onFieldChange());
    cityController.addListener(() => _onFieldChange());
    stateController.addListener(() => _onFieldChange());
    zipController.addListener(() => _onFieldChange());
    countryController.addListener(() => _onFieldChange());
    phoneController.addListener(() => _onFieldChange());
  }

  void _onFieldChange() {
    setState(() {
      _hasChanges = true;
    });
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), _updateCustomer);
  }

  Future<void> _updateCustomer() async {
    try {
      final token = await Vania.getAccessToken();
      final response = await http.put(
        Uri.parse('${widget.baseUrl}/customers/${widget.customer['id']}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'cust_name': nameController.text,
          'cust_address': addressController.text,
          'cust_city': cityController.text,
          'cust_state': stateController.text,
          'cust_zip': zipController.text,
          'cust_country': countryController.text,
          'cust_telp': phoneController.text,
        }),
      );

      if (response.statusCode == 200) {
        final updatedData = json.decode(response.body)['data'];
        widget.onCustomerUpdated(updatedData);
        setState(() {
          _updateSuccess = true;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal memperbarui data'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan saat memperbarui data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    nameController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipController.dispose();
    countryController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop && _hasChanges && _updateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Customer',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        if (_hasChanges && _updateSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data berhasil diperbarui'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          controller: nameController,
                          label: 'Nama',
                          icon: Icons.person_outline,
                        ),
                        _buildTextField(
                          controller: phoneController,
                          label: 'Telepon',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        _buildTextField(
                          controller: addressController,
                          label: 'Alamat',
                          icon: Icons.location_on_outlined,
                        ),
                        _buildTextField(
                          controller: cityController,
                          label: 'Kota',
                          icon: Icons.location_city_outlined,
                        ),
                        _buildTextField(
                          controller: stateController,
                          label: 'Provinsi',
                          icon: Icons.map_outlined,
                        ),
                        _buildTextField(
                          controller: zipController,
                          label: 'Kode Pos',
                          icon: Icons.local_post_office_outlined,
                        ),
                        _buildTextField(
                          controller: countryController,
                          label: 'Negara',
                          icon: Icons.flag_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1E88E5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
          ),
        ),
      ),
    );
  }
}
