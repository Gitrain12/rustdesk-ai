import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../common.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<AppSettings>(
        builder: (context, appSettings, _) {
          return ListView(
            children: [
              _buildSection(
                context,
                'AI Features',
                [
                  SwitchListTile(
                    title: const Text('Enable AI Features'),
                    subtitle: const Text('Show AI quick buttons during remote sessions'),
                    value: appSettings.aiEnabled,
                    onChanged: appSettings.toggleAI,
                  ),
                  SwitchListTile(
                    title: const Text('Offline AI'),
                    subtitle: const Text('Use local AI processing when possible'),
                    value: appSettings.offlineAI,
                    onChanged: appSettings.toggleOfflineAI,
                  ),
                ],
              ),
              _buildSection(
                context,
                'Appearance',
                [
                  SwitchListTile(
                    title: const Text('Custom Theme'),
                    subtitle: const Text('Use Material Design 3 theming'),
                    value: appSettings.customTheme,
                    onChanged: appSettings.toggleCustomTheme,
                  ),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return ListTile(
                        title: const Text('Theme Mode'),
                        subtitle: Text(_getThemeModeText(themeProvider.themeMode)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showThemeDialog(context, themeProvider),
                      );
                    },
                  ),
                ],
              ),
              _buildSection(
                context,
                'Interaction',
                [
                  SwitchListTile(
                    title: const Text('Gesture Optimization'),
                    subtitle: const Text('Optimize touch gestures for remote control'),
                    value: appSettings.gestureOptimization,
                    onChanged: appSettings.toggleGestureOptimization,
                  ),
                  ListTile(
                    title: const Text('Touch Sensitivity'),
                    subtitle: const Text('Adjust touch response speed'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showSensitivityDialog(context),
                  ),
                ],
              ),
              _buildSection(
                context,
                'Connection',
                [
                  ListTile(
                    title: const Text('Default Connection Mode'),
                    subtitle: const Text('Automatic (P2P with relay fallback)'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  ListTile(
                    title: const Text('Quality Preset'),
                    subtitle: const Text('Balanced'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showQualityDialog(context),
                  ),
                ],
              ),
              _buildSection(
                context,
                'Security',
                [
                  SwitchListTile(
                    title: const Text('Require Password'),
                    subtitle: const Text('Require password for all connections'),
                    value: true,
                    onChanged: (value) {},
                  ),
                  ListTile(
                    title: const Text('Manage Saved Passwords'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
              _buildSection(
                context,
                'About',
                [
                  ListTile(
                    title: const Text('Version'),
                    subtitle: const Text(APP_VERSION),
                  ),
                  ListTile(
                    title: const Text('Licenses'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: APP_NAME,
                        applicationVersion: APP_VERSION,
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Help & Feedback'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('System default'),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSensitivityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Touch Sensitivity'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text('Low')),
            ListTile(title: Text('Medium (Recommended)')),
            ListTile(title: Text('High')),
          ],
        ),
      ),
    );
  }

  void _showQualityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quality Preset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<int>(
              title: const Text('Performance'),
              subtitle: const Text('Lower bandwidth, faster response'),
              value: 0,
              groupValue: 1,
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<int>(
              title: const Text('Balanced'),
              subtitle: const Text('Good balance of quality and speed'),
              value: 1,
              groupValue: 1,
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<int>(
              title: const Text('Quality'),
              subtitle: const Text('Best visual quality'),
              value: 2,
              groupValue: 1,
              onChanged: (value) => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}