import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/connection_service.dart';
import '../../common.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _idController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(APP_NAME),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, SETTINGS_ROUTE),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildServerStatusCard(),
              const SizedBox(height: 16),
              _buildQuickConnectCard(),
              const SizedBox(height: 16),
              _buildRecentConnectionsCard(),
              const Spacer(),
              _buildVersionInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServerStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<ConnectionService>(
          builder: (context, connectionService, _) {
            return Row(
              children: [
                Icon(
                  connectionService.isConnected
                      ? Icons.cloud_done
                      : Icons.cloud_off,
                  color: connectionService.isConnected
                      ? Colors.green
                      : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Server Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        connectionService.isConnected
                            ? 'Connected to self-hosted server'
                            : 'Using public server',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, SERVER_ROUTE),
                  child: const Text('Configure'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickConnectCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Connect',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _idController,
                    decoration: const InputDecoration(
                      labelText: 'Remote ID',
                      hintText: 'Enter remote device ID',
                      prefixIcon: Icon(Icons.computer),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _connectToRemote,
                  icon: const Icon(Icons.link),
                  label: const Text('Connect'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentConnectionsCard() {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Connections',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.computer),
                      ),
                      title: Text('Device ${index + 1}'),
                      subtitle: Text('192.168.1.${100 + index}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.link),
                        onPressed: () {
                          _idController.text = 'device-${index + 1}';
                          _connectToRemote();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Center(
      child: Text(
        'Version $APP_VERSION',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  void _connectToRemote() {
    final id = _idController.text.trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a remote ID')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      REMOTE_ROUTE,
      arguments: {'remoteId': id},
    );
  }
}