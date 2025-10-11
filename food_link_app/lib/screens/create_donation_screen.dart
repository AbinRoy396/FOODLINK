import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/theme_provider.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../utils/enhanced_animations.dart';
import '../widgets/enhanced_ui_widgets.dart';

class CreateDonationScreen extends StatefulWidget {
  const CreateDonationScreen({super.key});

  @override
  State<CreateDonationScreen> createState() => _CreateDonationScreenState();
}

class _CreateDonationScreenState extends State<CreateDonationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();
  final _foodTypeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();

  String _selectedCategory = 'Cooked Food';
  DateTime _selectedExpiryDate = DateTime.now().add(const Duration(days: 1));
  File? _selectedImage;
  bool _isLoading = false;
  bool _useCurrentLocation = false;

  final List<String> _categories = [
    'Cooked Food',
    'Raw Ingredients',
    'Packaged Food',
    'Fruits & Vegetables',
    'Dairy Products',
    'Beverages',
    'Bakery Items',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCurrentLocation();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _foodTypeController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    if (_useCurrentLocation) {
      setState(() => _isLoading = true);
      
      try {
        final locationResult = await LocationService.getCurrentLocationWithStatus();
        if (locationResult['success'] && locationResult['position'] != null) {
          final position = locationResult['position'];
          final address = await LocationService.getFormattedAddress(
            position.latitude,
            position.longitude,
          );
          
          if (mounted) {
            _addressController.text = address;
            EnhancedUIWidgets.showEnhancedSnackbar(
              context: context,
              message: 'Current location loaded!',
              type: SnackbarType.success,
            );
          }
        } else {
          if (mounted) {
            EnhancedUIWidgets.showEnhancedSnackbar(
              context: context,
              message: locationResult['error'] ?? 'Failed to get location',
              type: SnackbarType.error,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          EnhancedUIWidgets.showEnhancedSnackbar(
            context: context,
            message: 'Error getting location: $e',
            type: SnackbarType.error,
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: _buildAppBar(theme),
      body: _buildBody(theme),
      bottomNavigationBar: _buildBottomActions(theme),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeProvider theme) {
    return AppBar(
      title: Text(
        'Create Donation',
        style: TextStyle(
          color: theme.textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: theme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: theme.textColor),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => _saveDraft(),
          child: Text(
            'Save Draft',
            style: TextStyle(color: theme.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(ThemeProvider theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressIndicator(theme),
              const SizedBox(height: 24),
              _buildFoodDetailsSection(theme),
              const SizedBox(height: 24),
              _buildQuantitySection(theme),
              const SizedBox(height: 24),
              _buildExpirySection(theme),
              const SizedBox(height: 24),
              _buildLocationSection(theme),
              const SizedBox(height: 24),
              _buildImageSection(theme),
              const SizedBox(height: 24),
              _buildContactSection(theme),
              const SizedBox(height: 100), // Space for bottom actions
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 1 of 1',
          style: TextStyle(
            fontSize: 14,
            color: theme.subtleTextColor,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: 1.0,
          backgroundColor: theme.borderColor,
          valueColor: AlwaysStoppedAnimation(theme.primaryColor),
        ),
      ],
    );
  }

  Widget _buildFoodDetailsSection(ThemeProvider theme) {
    return EnhancedUIWidgets.enhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Food Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          EnhancedUIWidgets.enhancedTextField(
            controller: _foodTypeController,
            label: 'Food Type',
            hint: 'e.g., Rice, Curry, Bread',
            prefixIcon: Icons.restaurant,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter food type';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Category',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.borderColor),
              color: theme.cardColor,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(
                      category,
                      style: TextStyle(color: theme.textColor),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                    HapticFeedback.selectionClick();
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          EnhancedUIWidgets.enhancedTextField(
            controller: _descriptionController,
            label: 'Description (Optional)',
            hint: 'Additional details about the food...',
            prefixIcon: Icons.description,
            keyboardType: TextInputType.multiline,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySection(ThemeProvider theme) {
    return EnhancedUIWidgets.enhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quantity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          EnhancedUIWidgets.enhancedTextField(
            controller: _quantityController,
            label: 'Quantity',
            hint: 'e.g., 10 servings, 5 kg, 20 pieces',
            prefixIcon: Icons.scale,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter quantity';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpirySection(ThemeProvider theme) {
    return EnhancedUIWidgets.enhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expiry Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.borderColor),
              color: theme.cardColor,
            ),
            child: ListTile(
              leading: Icon(Icons.calendar_today, color: theme.subtleTextColor),
              title: Text(
                'Expiry Date',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.textColor,
                ),
              ),
              subtitle: Text(
                _formatDate(_selectedExpiryDate),
                style: TextStyle(color: theme.subtleTextColor),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.subtleTextColor),
              onTap: () => _selectExpiryDate(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(ThemeProvider theme) {
    return EnhancedUIWidgets.enhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pickup Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _useCurrentLocation,
                onChanged: (value) {
                  setState(() => _useCurrentLocation = value ?? false);
                  if (_useCurrentLocation) {
                    _loadCurrentLocation();
                  } else {
                    _addressController.clear();
                  }
                  HapticFeedback.selectionClick();
                },
                activeColor: theme.primaryColor,
              ),
              Expanded(
                child: Text(
                  'Use current location',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          EnhancedUIWidgets.enhancedTextField(
            controller: _addressController,
            label: 'Pickup Address',
            hint: 'Enter complete address...',
            prefixIcon: Icons.location_on,
            enabled: !_useCurrentLocation,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter pickup address';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(ThemeProvider theme) {
    return EnhancedUIWidgets.enhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Food Image (Optional)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedImage != null) ...[
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(_selectedImage!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: EnhancedUIWidgets.enhancedButton(
                    text: 'Change Image',
                    onPressed: () => _pickImage(),
                    type: ButtonType.outline,
                    icon: Icons.camera_alt,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: EnhancedUIWidgets.enhancedButton(
                    text: 'Remove',
                    onPressed: () => setState(() => _selectedImage = null),
                    type: ButtonType.outline,
                    icon: Icons.delete,
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.borderColor, style: BorderStyle.solid),
                color: theme.backgroundColor,
              ),
              child: InkWell(
                onTap: () => _pickImage(),
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: theme.subtleTextColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to add photo',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.subtleTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactSection(ThemeProvider theme) {
    return EnhancedUIWidgets.enhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          EnhancedUIWidgets.enhancedTextField(
            controller: _contactController,
            label: 'Contact Number',
            hint: 'Phone number for coordination',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter contact number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: EnhancedUIWidgets.enhancedButton(
                text: 'Create Donation',
                onPressed: () => _createDonation(),
                isLoading: _isLoading,
                isEnabled: !_isLoading,
                icon: Icons.volunteer_activism,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null) {
      setState(() => _selectedExpiryDate = date);
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Show options for camera or gallery
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 80,
        );

        if (image != null) {
          setState(() => _selectedImage = File(image.path));
          HapticFeedback.lightImpact();
        }
      }
    } catch (e) {
      EnhancedUIWidgets.showEnhancedSnackbar(
        context: context,
        message: 'Error picking image: $e',
        type: SnackbarType.error,
      );
    }
  }

  Future<void> _createDonation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      HapticFeedback.mediumImpact();
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 3));
      
      if (mounted) {
        EnhancedUIWidgets.showEnhancedSnackbar(
          context: context,
          message: 'Donation created successfully!',
          type: SnackbarType.success,
        );
        
        // Navigate back to dashboard
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        EnhancedUIWidgets.showEnhancedSnackbar(
          context: context,
          message: 'Error creating donation: $e',
          type: SnackbarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _saveDraft() {
    HapticFeedback.lightImpact();
    EnhancedUIWidgets.showEnhancedSnackbar(
      context: context,
      message: 'Draft saved successfully!',
      type: SnackbarType.success,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
