import 'package:flutter/material.dart';
import 'package:shaghalny/services/api_service.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  String _result = 'No test run yet';
  bool _isLoading = false;
  final TextEditingController _endpointController = TextEditingController(
    text: 'login',
  );
  String _currentBaseUrl = ApiService.getBaseUrl();

  @override
  void dispose() {
    _endpointController.dispose();
    super.dispose();
  }

  Future<void> _testApi() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing...';
    });

    try {
      final response = await ApiService.request(
        method: 'GET',
        endpoint: _endpointController.text,
        requiresAuth: false,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _result = 'Response:\n${response.toString()}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _result = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _testPing() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing basic server ping...';
    });

    try {
      final result = await ApiService.checkApiStatus();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _result = 'Ping Result:\n${result.toString()}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _result = 'Ping Error: ${e.toString()}';
      });
    }
  }

  Future<void> _testWithMethod(String method) async {
    setState(() {
      _isLoading = true;
      _result = 'Testing with $method method...';
    });

    try {
      final response = await ApiService.request(
        method: method,
        endpoint: _endpointController.text,
        requiresAuth: false,
        data:
            method != 'GET'
                ? {
                  'test': 'data',
                  'email': 'test@example.com',
                  'password': 'password123',
                }
                : null,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _result = '$method Response:\n${response.toString()}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _result = '$method Error: ${e.toString()}';
      });
    }
  }

  Future<void> _updateBaseUrl(String newUrl) async {
    ApiService.setBaseUrl(newUrl);
    setState(() {
      _currentBaseUrl = ApiService.getBaseUrl();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('API Connection Test')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Base URL:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_currentBaseUrl),
            SizedBox(height: 16),

            Text(
              'Change Base URL:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        () => _updateBaseUrl('http://localhost:8000/api'),
                    child: Text('localhost'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateBaseUrl('http://10.0.2.2:8000/api'),
                    child: Text('10.0.2.2'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        () => _updateBaseUrl('http://127.0.0.1:8000/api'),
                    child: Text('127.0.0.1'),
                  ),
                ),
              ],
            ),

            // Add custom URL field
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Custom API URL',
                      hintText: 'http://your-api-url:port/api',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _updateBaseUrl(value);
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                      () => _updateBaseUrl('http://192.168.1.105:8000/api'),
                  child: Text('Local IP'),
                ),
              ],
            ),

            // API Test URL specifically for testing without API server
            SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  () => _updateBaseUrl('https://jsonplaceholder.typicode.com'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text('Use Test API (JSONPlaceholder)'),
            ),

            // Port selection
            SizedBox(height: 16),
            Text('Change Port:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                for (final port in ['8000', '3000', '8080', '5000'])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: () {
                          final currentUrl = _currentBaseUrl;
                          final uri = Uri.parse(currentUrl);
                          final newUrl =
                              uri.replace(port: int.parse(port)).toString();
                          _updateBaseUrl(newUrl);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(port),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 24),

            Text(
              'Test Methods:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testPing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('PING Test'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _testWithMethod('GET'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('GET'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : () => _testWithMethod('POST'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('POST'),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            Text(
              'Test an API Endpoint:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            TextField(
              controller: _endpointController,
              decoration: InputDecoration(
                labelText: 'Endpoint (e.g., login, register)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _testApi,
                child:
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Test Connection'),
              ),
            ),
            SizedBox(height: 24),

            Text('Result:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              width: double.infinity,
              child: SelectableText(_result),
            ),
          ],
        ),
      ),
    );
  }
}
