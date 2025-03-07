import 'package:diabetes_test/screens/home/widgets/action_card.dart';
import 'package:diabetes_test/screens/home/widgets/article_card.dart';
import 'package:diabetes_test/screens/home/widgets/health_metrics_card.dart';
import 'package:diabetes_test/screens/home/widgets/history_card.dart';
import 'package:diabetes_test/screens/home/widgets/profile_card.dart';
import 'package:diabetes_test/screens/home/widgets/section_header.dart';
import 'package:diabetes_test/screens/home/widgets/test_results_section.dart';
import 'package:diabetes_test/screens/settings/setting_screen.dart';
import 'package:diabetes_test/test_results_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:diabetes_test/providers/user_auth_provider.dart';
import 'package:diabetes_test/providers/connectivity_provider.dart';
import 'package:diabetes_test/widgets/offline_banner.dart';
import 'package:diabetes_test/screens/detection/diabetes_detection_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentIndex = index);
  }

  // Navigate to settings screen
  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Offline Banner
          Consumer<ConnectivityProvider>(
            builder: (context, connectivityProvider, _) => const OfflineBanner(),
          ),
          
          // Main content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              children: [
                _DashboardTab(onSettingsTap: _navigateToSettings),
                const _HistoryTab(),
                const _ProfileTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: Colors.white,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey.shade400,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget? _buildFloatingActionButton() {
    if (_currentIndex != 0) return null;
    
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DiabetesDetectionScreen(),
        ),
      ),
      label: const Text('Scan'),
      icon: const Icon(Icons.camera_alt_rounded),
      elevation: 4,
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final VoidCallback onSettingsTap;

  const _DashboardTab({required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Health Status Card
                const HealthMetricsCard(),
                const SizedBox(height: 24),
                
                // Recent Test Results
                SectionHeader(
                  title: 'Recent Test Results',
                  onSeeAll: () {},
                ),
                const SizedBox(height: 12),
                const TestResultsSection(),
                
                const SizedBox(height: 24),
                
                // Quick Actions
                SectionHeader(
                  title: 'Quick Actions',
                  onSeeAll: () {},
                ),
                const SizedBox(height: 12),
                _buildActionGrid(context),
                
                const SizedBox(height: 24),
                
                // Health Articles
                SectionHeader(
                  title: 'Health Articles',
                  onSeeAll: () {},
                ),
                const SizedBox(height: 12),
                _buildArticlesList(context),
                
                const SizedBox(height: 80), // Bottom padding for FAB
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAppBar(BuildContext context) {
    final userProvider = Provider.of<UserAuthProvider>(context);
    final userName = userProvider.currentUser?.name ?? 'User';
    final theme = Theme.of(context).colorScheme;
    
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: theme.primary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: const Text(
          'SugarPlus',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primary,
                theme.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    'Hello, $userName',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Today is ${DateFormat('EEEE, MMMM d').format(DateTime.now())}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_rounded, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings_rounded, color: Colors.white),
          onPressed: onSettingsTap, // Connect to settings screen
        ),
      ],
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        ActionCard(
          icon: Icons.camera_alt_rounded,
          title: 'New Scan',
          color: Colors.blue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DiabetesDetectionScreen(),
            ),
          ),
        ),
        ActionCard(
          icon: Icons.history_rounded,
          title: 'View History',
          color: Colors.purple,
          onTap: () {},
        ),
        ActionCard(
          icon: Icons.lightbulb_rounded,
          title: 'Health Tips',
          color: Colors.orange,
          onTap: () {},
        ),
        ActionCard(
          icon: Icons.settings_rounded,
          title: 'Settings',
          color: Colors.teal,
          onTap: onSettingsTap, // Connect to settings screen
        ),
      ],
    );
  }
  
  Widget _buildArticlesList(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ArticleCard(
            title: 'Managing Diabetes Naturally',
            imageAsset: 'assets/images/healthy_food.jpeg',
            onTap: () {},
          ),
          ArticleCard(
            title: 'Benefits of Regular Exercise',
            imageAsset: 'assets/images/exercise.jpeg',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text('Test History', style: TextStyle(color: Colors.white)),
          pinned: true,
          floating: true,
        ),
        _buildHistoryList(),
      ],
    );
  }

  Widget _buildHistoryList() {
    return Consumer<TestResultsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (provider.error != null) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        
        if (provider.results.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: Text('No test results found'),
            ),
          );
        }
        
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final result = provider.results[index];
              
              // Group by month
              final bool showHeader = index == 0 || 
                  result.timestamp.month != provider.results[index - 1].timestamp.month;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showHeader)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
                      child: Text(
                        DateFormat('MMMM yyyy').format(result.timestamp),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  HistoryCard(
                    result: result,
                    onTap: () {},
                  ),
                ],
              );
            },
            childCount: provider.results.length,
          ),
        );
      },
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserAuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        
        return CustomScrollView(
          slivers: [
            _buildProfileAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Profile Avatar
                    _buildProfileAvatar(context),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Account Info
                    ProfileInfoCard(
                      title: 'Account Information',
                      items: [
                        ProfileItem(
                          icon: Icons.email_rounded,
                          title: 'Email',
                          value: user?.email ?? 'Not set',
                        ),
                        ProfileItem(
                          icon: Icons.calendar_today_rounded,
                          title: 'Member Since',
                          value: user?.createdAt != null 
                              ? DateFormat('MMMM dd, yyyy').format(user!.createdAt) 
                              : 'Unknown',
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // App Settings
                    ProfileInfoCard(
                      title: 'App Settings',
                      items: [
                        ProfileItem(
                          icon: Icons.notifications_rounded,
                          title: 'Notifications',
                          value: 'On',
                          onTap: () {},
                        ),
                        ProfileItem(
                          icon: Icons.nightlight_round,
                          title: 'Dark Mode',
                          value: 'System Default',
                          onTap: () {},
                        ),
                        ProfileItem(
                          icon: Icons.language_rounded,
                          title: 'Language',
                          value: 'English',
                          onTap: () {},
                        ),
                        ProfileItem(
                          icon: Icons.settings_rounded,
                          title: 'All Settings',
                          value: 'App preferences, security, and more',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Sign Out Button
                    _buildSignOutButton(context, authProvider),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings_rounded, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SettingsScreen(),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildProfileAvatar(BuildContext context) {
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.grey.shade200,
      child: Icon(
        Icons.person,
        size: 50,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
  
  Widget _buildSignOutButton(BuildContext context, UserAuthProvider authProvider) {
    return ElevatedButton.icon(
      onPressed: () async {
        await authProvider.signOut();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      icon: const Icon(Icons.logout),
      label: const Text('Sign Out'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.red,
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }
}