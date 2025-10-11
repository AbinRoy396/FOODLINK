import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/image_upload_service.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';
import '../user_state.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';

class EnhancedCreateDonationScreen extends StatefulWidget {
  const EnhancedCreateDonationScreen({super.key});

  @override
  State<EnhancedCreateDonationScreen> createState() => _EnhancedCreateDonationScreenState();
}

class _EnhancedCreateDonationScreenState extends State<EnhancedCreateDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodTypeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  
  List<File> _selectedImages = [];
  List<String> _uploadedImageUrls = [];
  DateTime? _expiryDate;
  TimeOfDay? _expiryTime;
  bool _loading = false;
  bool _locationLoading = false;
  double? _latitude;
  double? _longitude;

  final List<String> _foodCategories = [
    'Cooked Food',
    'Raw Vegetables',
    'Fruits',
    'Packaged Food',
    'Dairy Products',
    'Bakery Items',
    'Beverages',
    'Other',
  ];

  String _selectedCategory = 'Cooked Food';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _locationLoading = true);
    
    try {
      final result = await LocationService.getCurrentLocationWithStatus();
      
      if (result['success']) {
        final position = result['position'];
        final address = await LocationService.getFormattedAddress(
          position.latitude, 
          position.longitude,
        );
        
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _addressController.text = address;
        });
      }
    } catch (e) {
      print('Location error: $e');
    } finally {
      setState(() => _locationLoading = false);
    }
  }

  Future<void> _pickImages() async {
    final images = await ImageUploadService.showImagePickerDialog(context, multiple: true);
    if (images != null && images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _selectExpiryDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: AppColors.primary),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _expiryDate = date;
          _expiryTime = time;
        });
      }
    }
  }

  Future<void> _createDonation() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_expiryDate == null || _expiryTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select expiry date and time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    
    try {
      // Upload images first
      if (_selectedImages.isNotEmpty) {
        _uploadedImageUrls = await ImageUploadService.uploadMultipleImages(_selectedImages, 'food');
      }

      // Create expiry datetime
      final expiryDateTime = DateTime(
        _expiryDate!.year,
        _expiryDate!.month,
        _expiryDate!.day,
        _expiryTime!.hour,
        _expiryTime!.minute,
      );

      // Create donation
      final donationData = await ApiService.createDonation(
        foodType: '$_selectedCategory - ${_foodTypeController.text}',
        quantity: _quantityController.text,
        description: _descriptionController.text,
        pickupAddress: _addressController.text,
        latitude: _latitude ?? 10.5276,
        longitude: _longitude ?? 76.2144,
        expiryTime: expiryDateTime.toIso8601String(),
        images: _uploadedImageUrls,
      );

      if (donationData != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Donation created successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Text('Failed to create donation: $e'),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text('Create Donation', style: TextStyle(color: AppColors.foregroundLight)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.foregroundLight),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Share Your Food',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.foregroundLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Help reduce food waste by sharing surplus food with those in need.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.subtleLight,
                ),
              ),
              const SizedBox(height: 32),

              // Food Category Dropdown
              Text(
                'Food Category',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.foregroundLight,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.category, color: AppColors.subtleLight, size: 22),
                  filled: true,
                  fillColor: AppColors.cardLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                items: _foodCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Food Type
              _buildTextField(
                controller: _foodTypeController,
                label: 'Food Type',
                icon: Icons.fastfood,
                hint: 'e.g., Rice and Curry, Sandwiches, Fruits',
                validator: (value) => value?.isEmpty == true ? 'Food type is required' : null,
              ),
              const SizedBox(height: 20),

              // Quantity
              _buildTextField(
                controller: _quantityController,
                label: 'Quantity',
                icon: Icons.scale,
                hint: 'e.g., 5 kg, 20 servings, 10 packets',
                validator: (value) => value?.isEmpty == true ? 'Quantity is required' : null,
              ),
              const SizedBox(height: 20),

              // Description
              _buildTextField(
                controller: _descriptionController,
                label: 'Description (Optional)',
                icon: Icons.description,
                hint: 'Additional details about the food...',
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Pickup Address
              _buildTextField(
                controller: _addressController,
                label: 'Pickup Address',
                icon: Icons.location_on,
                hint: 'Where can people pick up the food?',
                maxLines: 2,
                suffixIcon: IconButton(
                  icon: _locationLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location, color: AppColors.primary),
                  onPressed: _locationLoading ? null : _getCurrentLocation,
                ),
                validator: (value) => value?.isEmpty == true ? 'Pickup address is required' : null,
              ),
              const SizedBox(height: 20),

              // Expiry Date & Time
              Text(
                'Expiry Date & Time',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.foregroundLight,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectExpiryDateTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, color: AppColors.subtleLight, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _expiryDate != null && _expiryTime != null
                              ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year} at ${_expiryTime!.format(context)}'
                              : 'Select expiry date and time',
                          style: TextStyle(
                            color: _expiryDate != null ? AppColors.foregroundLight : AppColors.subtleLight,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.subtleLight),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Food Images
              Text(
                'Food Images',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.foregroundLight,
                ),
              ),
              const SizedBox(height: 8),
              
              // Image Grid
              if (_selectedImages.isNotEmpty) ...[
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(_selectedImages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
              
              // Add Images Button
              InkWell(
                onTap: _pickImages,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.cardLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight, style: BorderStyle.solid),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 32, color: AppColors.primary),
                        SizedBox(height: 8),
                        Text(
                          'Add Food Images',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Tap to select images',
                          style: TextStyle(color: AppColors.subtleLight, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Create Donation Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _createDonation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                        )
                      : const Text(
                          'Create Donation',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.foregroundLight,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.subtleLight, size: 22),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.cardLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _foodTypeController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
