import 'dart:convert'; // For jsonEncode and jsonDecode
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/user_service.dart';

class ProfileDisplayPage extends StatefulWidget {
  const ProfileDisplayPage({super.key});

  @override
  State<ProfileDisplayPage> createState() => _ProfileDisplayPageState();
}

class _ProfileDisplayPageState extends State<ProfileDisplayPage> {
  final TextEditingController _spotifyUrlController = TextEditingController();
  final UserService _userService = UserService();
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  String? _error;

  Map<String, dynamic>? _spotifyAnalytics;
  bool _isFetchingSpotifyData = false;
  String? _spotifyError;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _userService.getCurrentUserProfile();
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _spotifyUrlController.dispose();
    super.dispose();
  }

  Future<void> _fetchSpotifyAnalytics(String url) async {
    if (url.isEmpty) {
      setState(() {
        _spotifyError = "Spotify URL cannot be empty.";
      });
      return;
    }

    setState(() {
      _isFetchingSpotifyData = true;
      _spotifyAnalytics = null;
      _spotifyError = null;
    });

    try {
      // IMPORTANT: Replace with your actual backend URL.
      // For local development with Android emulator, use 10.0.2.2
      // For web or iOS simulator on same machine, localhost or 127.0.0.1 might work.
      final backendUrl = Uri.parse('http://127.0.0.1:8000/analyze-spotify-profile');

      final response = await http.post(
        backendUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'spotify_url': url}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true && responseBody['data'] != null) {
          setState(() {
            _spotifyAnalytics = responseBody['data'] as Map<String, dynamic>;
          });
        } else {
          setState(() {
            _spotifyError = responseBody['detail'] ?? 'Failed to get Spotify data.';
          });
        }
      } else {
        final responseBody = jsonDecode(response.body);
        setState(() {
          _spotifyError = "Error: ${response.statusCode}. ${responseBody['detail'] ?? 'Could not connect to server.'}";
        });
      }
    } catch (e) {
      setState(() {
        _spotifyError = "An error occurred: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isFetchingSpotifyData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.1),
          ],
        ),
      ),
      child: _isLoading
          ? Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Loading Your Profile...',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn().scale()
          : _error != null
              ? Center(
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.withOpacity(0.1),
                          Colors.red.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Oops! Something went wrong',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.7),
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loadProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn().shake()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Profile Header Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Avatar Section
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.transparent,
                                backgroundImage: _profile?['avatar_url'] != null
                                    ? NetworkImage(_profile!['avatar_url'])
                                    : null,
                                child: _profile?['avatar_url'] == null
                                    ? Icon(
                                        Icons.person,
                                        size: 80,
                                        color: Colors.white.withOpacity(0.8),
                                      )
                                    : null,
                              ),
                            ).animate().fadeIn().scale(),
                            
                            const SizedBox(height: 24),
                            
                            // Username
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  Colors.white,
                                  Theme.of(context).colorScheme.primary,
                                  Colors.white,
                                ],
                              ).createShader(bounds),
                              child: Text(
                                _profile?['username'] ?? 'Anonymous',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 28,
                                    ),
                              ),
                            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                            
                            const SizedBox(height: 8),
                            
                            // Email
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.1),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _profile?['email'] ?? 'No email',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.white.withOpacity(0.8),
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
                            
                            if (_profile?['bio'] != null && _profile!['bio'].toString().isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.08),
                                      Colors.white.withOpacity(0.03),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_pin_outlined,
                                          color: Theme.of(context).colorScheme.primary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'About',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _profile!['bio'],
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            color: Colors.white.withOpacity(0.8),
                                            height: 1.6,
                                          ),
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Stats Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.music_note,
                              title: 'Beats',
                              value: '0',
                              color: Colors.purple,
                            ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.3),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.favorite,
                              title: 'Likes',
                              value: '0',
                              color: Colors.red,
                            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.visibility,
                              title: 'Views',
                              value: '0',
                              color: Colors.blue,
                            ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.3),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32), // Spacing

                      // Spotify Analysis Section
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.withOpacity(0.1), // Spotify-like green
                              Colors.black.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Analyze Spotify Profile',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _spotifyUrlController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Paste Spotify artist/profile URL here',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                                prefixIcon: Icon(Icons.link, color: Colors.green.shade300),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.green.shade300),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                final url = _spotifyUrlController.text.trim();
                                if (url.isNotEmpty) {
                                  _fetchSpotifyAnalytics(url);
                                } else {
                                  // Optionally show a snackbar or inline error if URL is empty
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please enter a Spotify URL.'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.analytics_outlined, color: Colors.white),
                              label: const Text('Get Insights', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            // Display Area for Loading, Error, or Analytics Data
                            const SizedBox(height: 20),
                            if (_isFetchingSpotifyData)
                              const Center(child: CircularProgressIndicator(color: Colors.green))
                            else if (_spotifyError != null)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red.shade300, size: 28),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _spotifyError!,
                                        style: TextStyle(color: Colors.red.shade200, fontSize: 15),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (_spotifyAnalytics != null)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.05),
                                      Colors.white.withOpacity(0.02),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _spotifyAnalytics!['username'] ?? 'Unknown Artist',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.people_alt_outlined, color: Colors.green.shade300, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${_spotifyAnalytics!['followers'] ?? 0} followers',
                                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    if (_spotifyAnalytics!['growth_metrics'] != null && _spotifyAnalytics!['growth_metrics']['monthly_listeners'] != null) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.headset_mic_outlined, color: Colors.green.shade300, size: 18),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${_spotifyAnalytics!['growth_metrics']['monthly_listeners']} monthly listeners',
                                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    Text(
                                      'Top Content:',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    if ((_spotifyAnalytics!['top_content'] as List?)?.isNotEmpty ?? false)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: (_spotifyAnalytics!['top_content'] as List)
                                            .map<Widget>((contentItem) {
                                          final item = contentItem as Map<String, dynamic>;
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0),
                                            child: Row(
                                              children: [
                                                Icon(Icons.music_note_outlined, color: Colors.green.shade400, size: 16),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    item['title'] ?? 'Unknown Track',
                                                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                // If play counts are available and non-zero:
                                                // if (item['plays'] != null && item['plays'] > 0)
                                                //   Text(
                                                //     ' - ${item['plays']} plays',
                                                //     style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                                                //   ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      )
                                    else
                                      Text(
                                        'No top content found or available.',
                                        style: TextStyle(color: Colors.white.withOpacity(0.6)),
                                      ),
                                  ],
                                ),
                              ).animate().fadeIn(),
                          ],
                        ),
                      ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.3),

                      const SizedBox(height: 32), // Spacing before next element (e.g., Recent Activity)
                      
                      // Recent Activity Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.timeline,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Recent Activity',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.05),
                                    Colors.white.withOpacity(0.02),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.music_note_outlined,
                                    color: Colors.white.withOpacity(0.5),
                                    size: 32,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      'No beats uploaded yet. Start creating your first beat!',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            color: Colors.white.withOpacity(0.7),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.3),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
} 