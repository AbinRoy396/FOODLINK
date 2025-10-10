import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/state_preservation_mixin.dart';
import '../services/validators.dart';
import '../services/error_handler.dart';
import '../models/request_model.dart';
import '../models/app_strings.dart';
import '../theme/app_colors.dart';

// --- Create Request Screen ---
class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen>
    with StatePreservationMixin {

  final _formKey = GlobalKey<FormState>();
  String? _foodType;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _deliveryAddressController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _deliveryAddressController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate() && _foodType != null) {
      setState(() => _loading = true);
      try {
        final request = await ApiService.createRequest(
          foodType: _foodType!,
          quantity: _quantityController.text,
          deliveryAddress: _deliveryAddressController.text,
        );
        if (request != null) {
          if (!mounted) return;
          ErrorHandler.showSuccess(
            context,
            'Request submitted successfully!',
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (!mounted) return;
        ErrorHandler.showError(context, e);
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    } else {
      ErrorHandler.showWarning(context, 'Please fill all fields and select food type.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Request'),
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.foregroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: Container(
        color: AppColors.backgroundLight,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Food Type', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.foregroundLight,
                )),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _foodType,
                  decoration: InputDecoration(
                    hintText: 'Select Food Type',
                    filled: true,
                    fillColor: AppColors.inputLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  items: const <String>['Fruits & Vegetables', 'Packaged Meals', 'Bakery Items', 'Dairy Products']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() => _foodType = newValue);
                  },
                  validator: (value) => value == null ? 'Please select a food type' : null,
                ),
                const SizedBox(height: 16),
                Text('Quantity Needed', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.foregroundLight,
                )),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    hintText: 'e.g., 2 kg',
                    helperText: 'Enter quantity needed with unit',
                    filled: true,
                    fillColor: AppColors.inputLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  keyboardType: TextInputType.text,
                  validator: Validators.validateQuantity,
                ),
                const SizedBox(height: 16),
                Text('Delivery Address', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.foregroundLight,
                )),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _deliveryAddressController,
                  decoration: InputDecoration(
                    hintText: 'Enter full delivery address',
                    helperText: 'Include street, city, and postal code',
                    filled: true,
                    fillColor: AppColors.inputLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  maxLines: 2,
                  validator: Validators.validateAddress,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _loading ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Track Request Status Screen ---
class TrackRequestStatusScreen extends StatefulWidget {
  const TrackRequestStatusScreen({super.key});

  @override
  State<TrackRequestStatusScreen> createState() => _TrackRequestStatusScreenState();
}

class _TrackRequestStatusScreenState extends State<TrackRequestStatusScreen>
    with AutomaticKeepAliveClientMixin {

  List<RequestModel> requests = [];
  bool isLoading = true;
  String? error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => isLoading = true);

    try {
      final stateUser = context.read<UserState>().user;
      if (stateUser != null) {
        requests = await ApiService.getUserRequests(stateUser.id);
        error = null;
      } else {
        error = 'User not logged in';
      }
    } catch (e) {
      error = e.toString();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load requests: $e'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadRequests,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.foregroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: Container(
        color: AppColors.backgroundLight,
        child: error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.subtleLight),
                    const SizedBox(height: 16),
                    Text(error!, style: const TextStyle(color: AppColors.subtleLight)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadRequests,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : isLoading
                ? const Center(child: CircularProgressIndicator())
                : requests.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inbox_outlined, size: 64, color: AppColors.subtleLight),
                            const SizedBox(height: 16),
                            Text('No requests found', style: TextStyle(color: AppColors.subtleLight)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final request = requests[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        request.foodType,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(request.status).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          request.status,
                                          style: TextStyle(
                                            color: _getStatusColor(request.status),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Quantity: ${request.quantity}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.subtleLight,
                                    ),
                                  ),
                                  Text(
                                    'Delivery: ${request.deliveryAddress}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.subtleLight,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Requested: ${request.createdAt.toLocal().toString().split(' ')[0]}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.subtleLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'matched':
        return Colors.blue;
      case 'fulfilled':
        return AppColors.primary;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.subtleLight;
    }
  }
}
