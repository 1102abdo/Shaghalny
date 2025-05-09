import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shaghalny/providers/auth_provider.dart';
import 'package:shaghalny/providers/job_provider.dart';
import 'package:shaghalny/services/api_service.dart';
import 'dart:math';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  _DebugScreenState createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String _statusText = '';
  bool _isLoading = false;

  Future<void> _createTestJob() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _statusText = 'Creating test job...';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final jobProvider = Provider.of<JobProvider>(context, listen: false);

      // First check if user is logged in
      if (authProvider.user == null) {
        if (!mounted) return;

        setState(() {
          _statusText = 'User is not logged in. Please login first.';
          _isLoading = false;
        });

        // Show login prompt dialog
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text('Login Required'),
                  content: Text(
                    'You need to login as an employer to create jobs.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _testLogin(); // Call the test login method
                      },
                      child: Text('Login'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                  ],
                ),
          );
        }
        return;
      }

      final result = await jobProvider.createJob(
        title: 'Test Job ${DateTime.now().millisecondsSinceEpoch}',
        description: 'This is a test job created for debugging',
        salary: 1000.0,
        location: 'Test Location',
      );

      if (!mounted) return;

      if (result) {
        setState(() {
          _statusText = 'Test job created successfully!';
        });
      } else {
        setState(() {
          _statusText = 'Failed to create test job: ${jobProvider.error}';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _statusText = 'Error creating test job: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserJobs() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _statusText = 'Loading user jobs...';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final jobProvider = Provider.of<JobProvider>(context, listen: false);

      if (authProvider.user != null) {
        await jobProvider.fetchUserJobs(authProvider.user!.id.toString());

        if (!mounted) return;

        setState(() {
          _statusText =
              'Jobs loaded: ${jobProvider.jobs.length}\n${jobProvider.jobs.map((job) => '${job.id}: ${job.title}').join('\n')}';
        });
      } else {
        if (!mounted) return;

        setState(() {
          _statusText = 'User is null, cannot load jobs. Please log in first.';
        });

        // Show dialog to prompt login
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text('Login Required'),
                  content: Text(
                    'You need to log in before you can load your jobs.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _testLogin(); // Call the test login method
                      },
                      child: Text('Login'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                  ],
                ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _statusText = 'Error loading jobs: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkApiConnection() async {
    setState(() {
      _isLoading = true;
      _statusText = 'Checking API connection...';
    });

    try {
      // Get current base URL
      final baseUrl = ApiService.getBaseUrl();

      // Check API status
      final statusResult = await ApiService.checkApiStatus();

      StringBuffer results = StringBuffer();
      results.writeln('API Connection Check:');
      results.writeln('---------------------------');
      results.writeln('Base URL: $baseUrl');
      results.writeln('Status: ${statusResult['status']}');
      results.writeln('Details: ${statusResult['details']}');
      results.writeln('Response Code: ${statusResult['code']}');
      results.writeln('---------------------------');

      // Check authentication token
      final token = await ApiService.getToken();
      results.writeln('\nAuthentication Status:');
      if (token != null && token.isNotEmpty) {
        results.writeln('Token exists: YES');
        results.writeln(
          'Token preview: ${token.substring(0, min(15, token.length))}...',
        );
      } else {
        results.writeln('Token exists: NO');
        results.writeln('You need to log in to create jobs');
      }

      setState(() {
        _statusText = results.toString();
      });
    } catch (e) {
      setState(() {
        _statusText = 'Error checking API: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _debugDirectApiCall() async {
    setState(() {
      _isLoading = true;
      _statusText = 'Testing direct API call...';
    });

    try {
      // Test raw API request for job creation
      final response = await ApiService.request(
        method: 'POST',
        endpoint: 'jobs',
        requiresAuth: true,
        data: {
          'title': 'Test Direct API Job',
          'description': 'Testing direct API call without provider',
          'salary': '1000.0',
          'location': 'Test Location',
          'type': 'دوام كامل',
          'num_workers': '1',
        },
      );

      StringBuffer results = StringBuffer();
      results.writeln('Direct API Job Creation Results:');
      results.writeln('---------------------------');
      results.writeln('Status: ${response['status']}');
      results.writeln('Message: ${response['msg']}');
      results.writeln('Data: ${response['data']}');
      results.writeln('---------------------------');
      results.writeln('Full Response: $response');

      // Get token information
      final token = await ApiService.getToken();
      results.writeln('\nToken Information:');
      results.writeln('Token exists: ${token != null}');
      if (token != null && token.isNotEmpty) {
        results.writeln('Token prefix: ${token.substring(0, 15)}...');
      } else {
        results.writeln('Token is empty or null');
      }

      setState(() {
        _statusText = results.toString();
      });
    } catch (e) {
      setState(() {
        _statusText = 'Error with direct API call: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSalaryParsing() async {
    setState(() {
      _isLoading = true;
      _statusText = 'Testing salary parsing...';
    });

    try {
      // Test different salary formats
      List<String> testCases = [
        '1000',
        '1,000',
        '1000.50',
        'ج.م 1000',
        '',
        'abc',
        '١٠٠٠', // Arabic numerals
      ];

      StringBuffer results = StringBuffer();
      results.writeln('Salary Parsing Test Results:');
      results.writeln('---------------------------');

      for (var testCase in testCases) {
        results.writeln('Original: "$testCase"');

        try {
          // Test cleaning and parsing
          String cleaned = testCase.replaceAll(RegExp(r'[^\d.]'), '');
          results.writeln('Cleaned: "$cleaned"');

          if (cleaned.isEmpty) {
            results.writeln('Result: Empty string detected');
          } else {
            double value = double.parse(cleaned);
            results.writeln('Parsed value: $value');
          }
        } catch (e) {
          results.writeln('Error: $e');
        }

        results.writeln('---------------------------');
      }

      // Test full job creation with a problematic salary
      results.writeln('\nTesting job creation with problematic salary:');
      final jobProvider = Provider.of<JobProvider>(context, listen: false);

      final result = await jobProvider.createJob(
        title: 'Test Job with Bad Salary',
        description: 'This is a test job with a problematic salary value',
        salary: 1000.0, // This should work fine
        location: 'Test Location',
      );

      results.writeln('Job creation result: $result');
      results.writeln('Error (if any): ${jobProvider.error}');

      setState(() {
        _statusText = results.toString();
      });
    } catch (e) {
      setState(() {
        _statusText = 'Error running tests: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _validateToken() async {
    setState(() {
      _isLoading = true;
      _statusText = 'Validating authentication token...';
    });

    try {
      // Get current token
      final token = await ApiService.getToken();

      StringBuffer results = StringBuffer();
      results.writeln('Token Validation Results:');
      results.writeln('---------------------------');

      if (token == null || token.isEmpty) {
        results.writeln('No token available - user is not logged in');
      } else {
        results.writeln(
          'Token exists: ${token.substring(0, min(15, token.length))}...',
        );

        // Validate the token
        final validationResult = await ApiService.validateToken();
        results.writeln('Valid: ${validationResult['valid']}');
        if (validationResult['valid'] == false) {
          results.writeln('Reason: ${validationResult['reason']}');
          results.writeln('Details: ${validationResult['details']}');
          results.writeln('\nSuggested action: Log out and log in again');
        } else {
          results.writeln('Details: ${validationResult['details']}');
        }
      }

      setState(() {
        _statusText = results.toString();
      });
    } catch (e) {
      setState(() {
        _statusText = 'Error validating token: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testLogin() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _statusText = 'Testing login functionality...';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Try to log in with test credentials
      final email = 'employer@test.com'; // Use a test account email
      final password = 'password123'; // Use a test account password

      final success = await authProvider.loginAsEmployer(email, password);

      if (!mounted) return;

      if (success) {
        final token = await ApiService.getToken();

        StringBuffer results = StringBuffer();
        results.writeln('Login Test Results:');
        results.writeln('---------------------------');
        results.writeln('Login Status: SUCCESS');

        if (token != null && token.isNotEmpty) {
          results.writeln(
            'Token obtained: ${token.substring(0, min(15, token.length))}...',
          );

          // Verify token is valid
          final isAuthenticated = await ApiService.ensureAuthenticated();
          results.writeln('Token is valid: $isAuthenticated');
        } else {
          results.writeln('Token is null or empty after login!');
        }

        // Check user details
        if (authProvider.user != null) {
          results.writeln('User ID: ${authProvider.user!.id}');
          results.writeln('User Name: ${authProvider.user!.name}');
        } else {
          results.writeln('User data is null after login!');
        }

        if (!mounted) return;

        setState(() {
          _statusText = results.toString();
        });
      } else {
        if (!mounted) return;

        setState(() {
          _statusText = 'Login failed. Check credentials or server connection.';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _statusText = 'Login testing error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug Screen'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Test Login'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _createTestJob,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Create Test Job'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _loadUserJobs,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Load User Jobs'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _checkApiConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Check API Connection'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _validateToken,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Validate Auth Token'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _debugDirectApiCall,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Debug Direct API Call'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _testSalaryParsing,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Test Salary Parsing'),
            ),
            SizedBox(height: 24),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(child: Text(_statusText)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
