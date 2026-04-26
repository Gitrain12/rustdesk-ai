import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/connection_service.dart';
import '../../common.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({super.key});

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _viewPassword = false;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanQRCode,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildConnectionTypeSelector(),
              const SizedBox(height: 24),
              _buildConnectionForm(),
              const SizedBox(height: 24),
              _buildAdvancedOptions(),
              const SizedBox(height: 24),
              _buildConnectButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connection Mode',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Consumer<ConnectionService>(
              builder: (context, connectionService, _) {
                return Column(
                  children: [
                    RadioListTile<ConnectionMode>(
                      title: const Text('Direct Connection (P2P)'),
                      subtitle: const Text('Best performance, may fail behind NAT'),
                      value: ConnectionMode.direct,
                      groupValue: ConnectionMode.direct,
                      onChanged: (value) {},
                    ),
                    RadioListTile<ConnectionMode>(
                      title: const Text('Relay Connection'),
                      subtitle: const Text('Always works, slightly higher latency'),
                      value: ConnectionMode.relay,
                      groupValue: ConnectionMode.direct,
                      onChanged: (value) {},
                    ),
                    RadioListTile<ConnectionMode>(
                      title: const Text('Automatic'),
                      subtitle: const Text('Try direct, fall back to relay'),
                      value: ConnectionMode.automatic,
                      groupValue: ConnectionMode.direct,
                      onChanged: (value) {},
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connection Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Remote ID',
                hintText: 'Enter the remote device ID',
                prefixIcon: Icon(Icons.tag),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter connection password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _viewPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _viewPassword = !_viewPassword;
                    });
                  },
                ),
              ),
              obscureText: !_viewPassword,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Remember this device'),
              subtitle: const Text('Store credentials for quick reconnect'),
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedOptions() {
    return Card(
      child: ExpansionTile(
        title: const Text('Advanced Options'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Custom Resolution'),
                  subtitle: const Text('Use custom screen resolution'),
                  value: false,
                  onChanged: (value) {},
                ),
                SwitchListTile(
                  title: const Text('Enable Clipboard Sync'),
                  subtitle: const Text('Synchronize clipboard between devices'),
                  value: true,
                  onChanged: (value) {},
                ),
                SwitchListTile(
                  title: const Text('Enable File Transfer'),
                  subtitle: const Text('Allow file transfers during session'),
                  value: true,
                  onChanged: (value) {},
                ),
                SwitchListTile(
                  title: const Text('Record Session'),
                  subtitle: const Text('Record remote session to file'),
                  value: false,
                  onChanged: (value) {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectButton() {
    return Consumer<ConnectionService>(
      builder: (context, connectionService, _) {
        return ElevatedButton(
          onPressed: connectionService.status == ConnectionStatus.connecting
              ? null
              : _initiateConnection,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: connectionService.status == ConnectionStatus.connecting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Connect'),
        );
      },
    );
  }

  void _scanQRCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Scanner not implemented')),
    );
  }

  void _initiateConnection() {
    final id = _idController.text.trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a remote ID')),
      );
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      REMOTE_ROUTE,
      arguments: {
        'remoteId': id,
        'password': _passwordController.text,
      },
    );
  }
}

enum ConnectionMode {
  direct,
  relay,
  automatic,
}