import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/connection_service.dart';
import '../../common.dart';

class ServerPage extends StatefulWidget {
  const ServerPage({super.key});

  @override
  State<ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  final TextEditingController _idServerController = TextEditingController();
  final TextEditingController _relayServerController = TextEditingController();
  final TextEditingController _apiServerController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();

  bool _useCustomServer = false;
  bool _alwaysUseRelay = false;
  bool _encryptedOnly = true;

  @override
  void initState() {
    super.initState();
    _loadServerSettings();
  }

  @override
  void dispose() {
    _idServerController.dispose();
    _relayServerController.dispose();
    _apiServerController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  void _loadServerSettings() {
    _idServerController.text = 'pub.hws.ru';
    _relayServerController.text = 'pub.hws.ru';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Configuration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _testConnection,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildServerTypeSelector(),
            const SizedBox(height: 24),
            if (_useCustomServer) ...[
              _buildCustomServerForm(),
              const SizedBox(height: 24),
            ],
            _buildConnectionOptions(),
            const SizedBox(height: 24),
            _buildKeySection(),
            const SizedBox(height: 24),
            _buildTestConnectionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildServerTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Server Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            RadioListTile<bool>(
              title: const Text('Public Server'),
              subtitle: const Text('Use RustDesk public server (relay may be limited)'),
              value: false,
              groupValue: _useCustomServer,
              onChanged: (value) {
                setState(() {
                  _useCustomServer = value!;
                });
              },
            ),
            RadioListTile<bool>(
              title: const Text('Self-Hosted Server'),
              subtitle: const Text('Use your own RustDesk server'),
              value: true,
              groupValue: _useCustomServer,
              onChanged: (value) {
                setState(() {
                  _useCustomServer = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomServerForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Custom Server Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _idServerController,
              decoration: const InputDecoration(
                labelText: 'ID Server',
                hintText: 'e.g., your-server.com',
                prefixIcon: Icon(Icons.dns),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _relayServerController,
              decoration: const InputDecoration(
                labelText: 'Relay Server',
                hintText: 'e.g., your-server.com',
                prefixIcon: Icon(Icons.swap_horiz),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiServerController,
              decoration: const InputDecoration(
                labelText: 'API Server (Optional)',
                hintText: 'For RustDesk Pro features',
                prefixIcon: Icon(Icons.api),
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connection Options',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Always Use Relay'),
              subtitle: const Text('Never attempt direct P2P connection'),
              value: _alwaysUseRelay,
              onChanged: (value) {
                setState(() {
                  _alwaysUseRelay = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Encrypted Only'),
              subtitle: const Text('Only allow encrypted connections'),
              value: _encryptedOnly,
              onChanged: (value) {
                setState(() {
                  _encryptedOnly = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Server Key',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.paste),
                  onPressed: _pasteKey,
                  tooltip: 'Paste from clipboard',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Public key for secure connection to your server',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _keyController,
              decoration: const InputDecoration(
                hintText: 'Paste your server public key here',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            Text(
              'Get this key from your server: cat /root/id_ed25519.pub',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestConnectionButton() {
    return Consumer<ConnectionService>(
      builder: (context, connectionService, _) {
        return ElevatedButton.icon(
          onPressed: connectionService.status == ConnectionStatus.connecting
              ? null
              : _testConnection,
          icon: connectionService.status == ConnectionStatus.connecting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.network_check),
          label: const Text('Test Connection'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        );
      },
    );
  }

  void _pasteKey() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Clipboard access not implemented')),
    );
  }

  void _testConnection() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connection test not implemented in demo'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}