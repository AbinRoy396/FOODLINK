import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../utils/enhanced_animations.dart';
import '../widgets/enhanced_ui_widgets.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();
  final _foodTypeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();

  String _selectedCategory = 'Any';
  String _selectedUrgency = 'Medium';
  int _familySize = 1;
  bool _isLoading = false;
  bool _useCurrentLocation = false;

  final List<String> _categories = [
    'Any',
    'Cooked Food',
    'Raw Ingredients',
    'Packaged Food',
    'Fruits & Vegetables',
    'Dairy Products',
    'Beverages',
    'Bakery Items',
  ];

  final List<String> _urgencyLevels = [
    'Low',
    'Medium',
    'High',
    'Emergency',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
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
    _reasonController.dispose();
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
        'Request Food',
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
              _buildRequestDetailsSection(theme),
              const SizedBox(height: 24),
              _buildFamilyInfoSection(theme),
              const SizedBox(height: 24),
              _buildUrgencySection(theme),
              const SizedBox(height: 24),
              _buildLocationSection(theme),
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

  Widget _buildRequestDetailsSection(ThemeProvider theme) {
    return EnhancedUIWidgets.enhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          EnhancedUIWidgets.enhancedTextField(
            controller: _foodTypeController,
            label: 'Food Type (Optional)',
            hint: 'e.g., Rice, Vegetables, Any cooked food',
            prefixIcon: Icons.restaurant,
          ),
          const SizedBox(height: 16),
          Text(
            'Preferred Category',
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
            controller: _quantityController,
            label: 'Quantity Needed',
            hint: 'e.g., 5 servings, 2 kg, For 4 people',
            prefixIcon: Icons.scale,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter quantity needed';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          EnhancedUIWidgets.enhancedTextField(
            controller: _reasonController,
            label: 'Reason for Request',
            hint: 'Brief explanation of your situation...',
            prefixIcon: Icons.description,
            keyboardType: TextInputType.multiline,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please provide a reason for the request';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyInfoSection(ThemeProvider theme) {
    return EnhancedUIWidgets.enhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Family Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Family Size:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.textColor,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _familySize > 1 ? () {
                        setState(() => _familySize--);
                        HapticFeedback.selectionClick();
                      } : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _familySize.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.textColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _familySize < 20 ? () {
                        setState(() => _familySize++);
                        HapticFeedback.selectionClick();
                      } : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Number of people who will be fed',
            style: TextStyle(
              fontSize: 12,
              color: theme.subtleTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencySection(ThemeProvider theme) {
    return EnhancedUIWidgets.enhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Urgency Level',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: _urgencyLevels.map((urgency) {
              final isSelected = _selectedUrgency == urgency;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? theme.primaryColor : theme.borderColor,
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected ? theme.primaryColor.withOpacity(0.1) : theme.cardColor,
                ),
                child: RadioListTile<String>(
                  value: urgency,
                  groupValue: _selectedUrgency,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedUrgency = value);
                      HapticFeedback.selectionClick();
                    }
                  },
                  title: Text(
                    urgency,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: theme.textColor,
                    ),
                  ),
                  subtitle: Text(
                    _getUrgencyDescription(urgency),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.subtleTextColor,
                    ),
                  ),
                  activeColor: theme.primaryColor,
                ),
              );
            }).toList(),
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
            'Delivery Location',
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
            label: 'Delivery Address',
            hint: 'Enter complete address...',
            prefixIcon: Icons.location_on,
            enabled: !_useCurrentLocation,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter delivery address';
              }
              return null;
            },
          ),
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
                text: 'Submit Request',
                onPressed: () => _submitRequest(),
                isLoading: _isLoading,
                isEnabled: !_isLoading,
                icon: Icons.send,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getUrgencyDescription(String urgency) {
    switch (urgency) {
      case 'Low':
        return 'Can wait a few days';
      case 'Medium':
        return 'Needed within 24 hours';
      case 'High':
        return 'Needed within a few hours';
      case 'Emergency':
        return 'Immediate assistance required';
      default:
        return '';
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'Low':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.red;
      case 'Emergency':
        return Colors.red.shade800;
      default:
        return Colors.grey;
    }
  }

  Future<void> _submitRequest() async {
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
          message: 'Request submitted successfully! You will be notified when a donor responds.',
          type: SnackbarType.success,
        );
        
        // Navigate back to dashboard
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        EnhancedUIWidgets.showEnhancedSnackbar(
          context: context,
          message: 'Error submitting request: $e',
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
}
