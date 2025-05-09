import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class DevSettingsScreen extends StatefulWidget {
  const DevSettingsScreen({Key? key}) : super(key: key);

  @override
  _DevSettingsScreenState createState() => _DevSettingsScreenState();
}

class _DevSettingsScreenState extends State<DevSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  bool _isLoading = false;
  String? _currentUrl;

  @override
  void initState() {
    super.initState();
    _loadCurrentUrl();
  }

  Future<void> _loadCurrentUrl() async {
    final customUrl = await ApiConfig.getCustomDevUrl();
    setState(() {
      _currentUrl = customUrl ?? ApiService.getBaseUrl();
      _urlController.text = _currentUrl ?? '';
    });
  }

  Future<void> _saveUrl() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final url = _urlController.text.trim();
      await ApiService.setBaseUrl(url);

      // Test the connection
      final response = await ApiService.checkApiStatus();

      if (!mounted) return;

      if (response['status'] == 'online' || response['status'] == 'reachable') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully connected to: $url')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Warning: Could not connect to server. Status: ${response['status']}',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Development Settings'),
        backgroundColor: Color(0xFFFF9800),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Configure API Server',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'API Server URL',
                  hintText: 'http://192.168.1.xxx:8000/api',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the API server URL';
                  }
                  if (!value.startsWith('http://') &&
                      !value.startsWith('https://')) {
                    return 'URL must start with http:// or https://';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveUrl,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF9800),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Save and Test Connection'),
              ),
              SizedBox(height: 24),
              Text(
                'Current API URL:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              Text(
                _currentUrl ?? 'Not set',
                style: TextStyle(fontFamily: 'monospace'),
              ),
              SizedBox(height: 16),
              Text(
                'Note: Each team member should set their own API server URL to point to their local or team development server.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
