import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../services/api_service.dart';
import '../models/donation_model.dart';
import '../models/request_model.dart';
import '../utils/enhanced_animations.dart';
import '../widgets/enhanced_ui_widgets.dart';
import '../utils/app_strings.dart';
import 'map_view_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EnhancedDashboard extends StatefulWidget {
  final String userRole;
  final String userName;

  const EnhancedDashboard({
    super.key,
    required this.userRole,
    required this.userName,
  });

  @override
  State<EnhancedDashboard> createState() => _EnhancedDashboardState();
}

class _EnhancedDashboardState extends State<EnhancedDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<DonationModel> _donations = [];
  List<RequestModel> _requests = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDashboardData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Add haptic feedback
      HapticFeedback.lightImpact();
      
      // Simulate loading delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (widget.userRole == AppStrings.roleDonor || widget.userRole == AppStrings.roleNGO) {
        _donations = await ApiService.getDonations();
      }
      
      if (widget.userRole == AppStrings.roleReceiver || widget.userRole == AppStrings.roleNGO) {
        _requests = await ApiService.getRequests();
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load data: $e';
        });
        
        EnhancedUIWidgets.showEnhancedSnackbar(
          context: context,
          message: 'Failed to refresh data',
          type: SnackbarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: _buildEnhancedAppBar(theme),
      body: _buildBody(theme),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  PreferredSizeWidget _buildEnhancedAppBar(ThemeProvider theme) {
    return EnhancedUIWidgets.enhancedAppBar(
      title: AppStrings.appName,
      actions: [
        // Map button with animation
        EnhancedAnimations.bouncyButton(
          onTap: () {
            Navigator.push(
              context,
              EnhancedAnimations.createRoute(
                MapViewScreen(
                  donations: _donations,
                  initialPosition: const LatLng(28.6139, 77.2090),
                ),
                type: AnimationType.slideFromRight,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.map_outlined,
              color: theme.textColor,
            ),
          ),
        ),
        
        // Theme toggle with animation
        EnhancedAnimations.bouncyButton(
          onTap: () => theme.toggleThemeWithAnimation(),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                theme.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey(theme.isDarkMode),
                color: theme.textColor,
              ),
            ),
          ),
        ),
        
        // Notifications
        EnhancedAnimations.bouncyButton(
          onTap: () {
            EnhancedUIWidgets.showEnhancedSnackbar(
              context: context,
              message: 'No new notifications',
              type: SnackbarType.info,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: theme.textColor,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(ThemeProvider theme) {
    return EnhancedRefreshIndicator(
      onRefresh: _loadDashboardData,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _hasError
              ? _buildErrorState(theme)
              : _buildDashboardContent(theme),
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeProvider theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.subtleTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.subtleTextColor,
            ),
          ),
          const SizedBox(height: 24),
          EnhancedUIWidgets.enhancedButton(
            text: 'Try Again',
            onPressed: _loadDashboardData,
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(ThemeProvider theme) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section with typewriter animation
          EnhancedAnimations.typewriterText(
            text: 'Welcome back, ${widget.userName}!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getWelcomeSubtitle(),
            style: TextStyle(
              fontSize: 16,
              color: theme.subtleTextColor,
            ),
          ),
          const SizedBox(height: 24),

          // Stats cards
          _buildStatsSection(theme),
          const SizedBox(height: 24),

          // Quick actions
          _buildQuickActionsSection(theme),
          const SizedBox(height: 24),

          // Recent activity
          _buildRecentActivitySection(theme),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ThemeProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: EnhancedAnimations.staggeredListItem(
                index: 0,
                child: _buildStatCard(
                  theme,
                  'Total Donations',
                  _donations.length.toString(),
                  Icons.volunteer_activism,
                  Colors.green,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: EnhancedAnimations.staggeredListItem(
                index: 1,
                child: _buildStatCard(
                  theme,
                  'Active Requests',
                  _requests.length.toString(),
                  Icons.help_outline,
                  Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeProvider theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return EnhancedUIWidgets.enhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: theme.subtleTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(ThemeProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildQuickActionsList(theme),
      ],
    );
  }

  Widget _buildQuickActionsList(ThemeProvider theme) {
    final actions = _getQuickActions();
    
    return Column(
      children: actions.asMap().entries.map((entry) {
        final index = entry.key;
        final action = entry.value;
        
        return EnhancedAnimations.staggeredListItem(
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: EnhancedUIWidgets.enhancedCard(
              onTap: action['onTap'],
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: action['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      action['icon'],
                      color: action['color'],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          action['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.textColor,
                          ),
                        ),
                        Text(
                          action['subtitle'],
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.subtleTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.subtleTextColor,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentActivitySection(ThemeProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: 16),
        _isLoading
            ? EnhancedUIWidgets.enhancedLoading(message: 'Loading activity...')
            : _buildActivityList(theme),
      ],
    );
  }

  Widget _buildActivityList(ThemeProvider theme) {
    final activities = _getRecentActivities();
    
    if (activities.isEmpty) {
      return EnhancedUIWidgets.enhancedCard(
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: theme.subtleTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No recent activity',
              style: TextStyle(
                fontSize: 16,
                color: theme.subtleTextColor,
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: activities.asMap().entries.map((entry) {
        final index = entry.key;
        final activity = entry.value;
        
        return EnhancedAnimations.staggeredListItem(
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: EnhancedUIWidgets.enhancedCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: activity['color'].withOpacity(0.1),
                    child: Icon(
                      activity['icon'],
                      color: activity['color'],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['title'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.textColor,
                          ),
                        ),
                        Text(
                          activity['time'],
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.subtleTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFloatingActionButton(ThemeProvider theme) {
    return EnhancedAnimations.pulsingFAB(
      onPressed: () {
        final route = _getPrimaryActionRoute();
        if (route != null) {
          Navigator.pushNamed(context, route);
        }
      },
      backgroundColor: theme.primaryColor,
      child: Icon(
        _getPrimaryActionIcon(),
        color: Colors.black,
      ),
    );
  }

  String _getWelcomeSubtitle() {
    if (widget.userRole == AppStrings.roleDonor) {
      return 'Ready to make a difference today?';
    } else if (widget.userRole == AppStrings.roleReceiver) {
      return 'Find the help you need';
    } else if (widget.userRole == AppStrings.roleNGO) {
      return 'Manage donations and requests';
    } else {
      return 'Welcome to FoodLink';
    }
  }

  List<Map<String, dynamic>> _getQuickActions() {
    if (widget.userRole == AppStrings.roleDonor) {
      return [
        {
          'title': 'Create Donation',
          'subtitle': 'Share surplus food with those in need',
          'icon': Icons.add_circle_outline,
          'color': Colors.green,
          'onTap': () => Navigator.pushNamed(context, AppStrings.routeCreateDonation),
        },
        {
          'title': 'My Donations',
          'subtitle': 'View and manage your donations',
          'icon': Icons.list_alt,
          'color': Colors.blue,
          'onTap': () => Navigator.pushNamed(context, AppStrings.routeViewDonations),
        },
      ];
    } else if (widget.userRole == AppStrings.roleReceiver) {
      return [
        {
          'title': 'Request Food',
          'subtitle': 'Submit a new food request',
          'icon': Icons.add_circle_outline,
          'color': Colors.orange,
          'onTap': () => Navigator.pushNamed(context, AppStrings.routeCreateRequest),
        },
        {
          'title': 'Browse Donations',
          'subtitle': 'Find available food donations',
          'icon': Icons.search,
          'color': Colors.green,
          'onTap': () => Navigator.pushNamed(context, AppStrings.routeViewDonations),
        },
      ];
    } else if (widget.userRole == AppStrings.roleNGO) {
      return [
        {
          'title': 'Verify Donations',
          'subtitle': 'Review and approve donations',
          'icon': Icons.verified_outlined,
          'color': Colors.green,
          'onTap': () {},
        },
        {
          'title': 'Manage Requests',
          'subtitle': 'Allocate food to requests',
          'icon': Icons.assignment_outlined,
          'color': Colors.blue,
          'onTap': () {},
        },
      ];
    } else {
      return [];
    }
  }

  List<Map<String, dynamic>> _getRecentActivities() {
    // Mock data - replace with actual API calls
    return [
      {
        'title': 'New donation created',
        'time': '2 hours ago',
        'icon': Icons.add_circle,
        'color': Colors.green,
      },
      {
        'title': 'Request fulfilled',
        'time': '5 hours ago',
        'icon': Icons.check_circle,
        'color': Colors.blue,
      },
      {
        'title': 'Profile updated',
        'time': '1 day ago',
        'icon': Icons.person,
        'color': Colors.orange,
      },
    ];
  }

  IconData _getPrimaryActionIcon() {
    if (widget.userRole == AppStrings.roleDonor) {
      return Icons.volunteer_activism;
    } else if (widget.userRole == AppStrings.roleReceiver) {
      return Icons.help_outline;
    } else if (widget.userRole == AppStrings.roleNGO) {
      return Icons.verified;
    } else {
      return Icons.add;
    }
  }

  String? _getPrimaryActionRoute() {
    if (widget.userRole == AppStrings.roleDonor) {
      return AppStrings.routeCreateDonation;
    } else if (widget.userRole == AppStrings.roleReceiver) {
      return AppStrings.routeCreateRequest;
    } else {
      return null;
    }
  }
}
