// lib/screens/home/home_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:diabetes_test/providers/connectivity_provider.dart';
import 'package:diabetes_test/providers/user_auth_provider.dart';
import 'package:diabetes_test/screens/detection/diabetes_detection_screen.dart';
import 'package:diabetes_test/services/database_service.dart';
import 'package:diabetes_test/test_results_provider.dart';
import 'package:diabetes_test/widgets/offline_banner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Offline Banner
          Consumer<ConnectivityProvider>(
            builder: (context, connectivityProvider, _) => OfflineBanner(),
          ),
          
          // Main content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              children: const [
                _DashboardTab(),
                _HistoryTab(),
                _ProfileTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DiabetesDetectionScreen(),
                ),
              ),
              child: const Icon(Icons.camera_alt),
            )
          : null,
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserAuthProvider>(context);
    final userName = userProvider.currentUser?.name ?? 'User';
    
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('SugarPlus'),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/animations/plus.jpg',
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $userName',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Track your health status and manage your diabetes detection results',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Recent test section
                _RecentTestSection(),
                
                const SizedBox(height: 24),
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Feature cards
                _buildFeatureCard(
                  icon: Icons.camera_alt,
                  title: 'New Eye Test',
                  description: 'Detect diabetes through eye scanning',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DiabetesDetectionScreen(),
                    ),
                  ),
                ),
                _buildFeatureCard(
                  icon: Icons.info,
                  title: 'About Diabetes',
                  description: 'Learn more about diabetes and prevention',
                  onTap: () => Navigator.pushNamed(context, '/about'),
                ),
                _buildFeatureCard(
                  icon: Icons.health_and_safety,
                  title: 'Health Tips',
                  description: 'View personalized health recommendations',
                  onTap: () => Navigator.pushNamed(context, '/health-tips'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Icon(icon, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentTestSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TestResultsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (provider.error != null) {
          return Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(provider.error!),
                  TextButton(
                    onPressed: () => provider.setState(() => provider.update(
                      Provider.of<UserAuthProvider>(context, listen: false).userId,
                      Provider.of<DatabaseService>(context, listen: false),
                    )),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        
        if (provider.results.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.medical_services_outlined, size: 48, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text(
                    'No Test Results Yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Take your first eye test to start monitoring your health',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DiabetesDetectionScreen(),
                      ),
                    ),
                    child: const Text('Take Eye Test'),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Show most recent test
        final latestResult = provider.results.first;
        
        return Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Latest Test Result',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(latestResult.timestamp),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: latestResult.isNormal
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      child: Icon(
                        latestResult.isNormal ? Icons.check_circle : Icons.warning,
                        color: latestResult.isNormal ? Colors.green : Colors.orange,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sugar Level',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${latestResult.sugarLevel.toStringAsFixed(1)} mg/dL',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          latestResult.isNormal
                              ? 'Normal Range'
                              : 'Elevated Range',
                          style: TextStyle(
                            color: latestResult.isNormal ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                TextButton(
                  onPressed: () => _onTabTapped(1),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('View All Test Results'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _onTabTapped(int index) {
    // Navigate to history tab
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          title: Text('Test History'),
          pinned: true,
        ),
        Consumer<TestResultsProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }
            
            if (provider.error != null) {
              return SliverFillRemaining(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(provider.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => provider.setState(() => provider.update(
                          Provider.of<UserAuthProvider>(context, listen: false).userId,
                          Provider.of<DatabaseService>(context, listen: false),
                        )),
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
                  return _buildTestHistoryCard(context, result);
                },
                childCount: provider.results.length,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTestHistoryCard(BuildContext context, TestResult result) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sugar Level: ${result.sugarLevel.toStringAsFixed(1)} mg/dL',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Icon(
                  result.isNormal ? Icons.check_circle : Icons.warning,
                  color: result.isNormal ? Colors.green : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Test Date: ${DateFormat('MMM dd, yyyy HH:mm').format(result.timestamp)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              result.isNormal ? 'Normal Range' : 'Above Normal Range',
              style: TextStyle(
                color: result.isNormal ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
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
        
        return ListView(
          children: [
            AppBar(
              title: const Text('Profile'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {},
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'User',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildProfileTile(
                    icon: Icons.email,
                    title: 'Email',
                    subtitle: user?.email ?? 'Not set',
                  ),
                  _buildProfileTile(
                    icon: Icons.calendar_today,
                    title: 'Member Since',
                    subtitle: user?.createdAt != null 
                        ? DateFormat('MMMM dd, yyyy').format(user!.createdAt) 
                        : 'Unknown',
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
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
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}