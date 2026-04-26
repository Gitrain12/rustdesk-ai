import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/ai_service.dart';
import '../../services/connection_service.dart';
import '../../common.dart';
import '../../widgets/ai_quick_buttons.dart';

class RemotePage extends StatefulWidget {
  final String remoteId;
  final String? password;

  const RemotePage({
    super.key,
    required this.remoteId,
    this.password,
  });

  @override
  State<RemotePage> createState() => _RemotePageState();
}

class _RemotePageState extends State<RemotePage> {
  bool _showAIButton = true;
  bool _showToolbar = true;
  double _toolbarOpacity = 1.0;
  bool _isAIAssistantOpen = false;

  @override
  void initState() {
    super.initState();
    _connectToRemote();
  }

  @override
  void dispose() {
    _disconnect();
    super.dispose();
  }

  Future<void> _connectToRemote() async {
    final connectionService = context.read<ConnectionService>();
    await connectionService.connect(widget.remoteId);
  }

  Future<void> _disconnect() async {
    final connectionService = context.read<ConnectionService>();
    await connectionService.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _buildRemoteDesktop(),
            if (_showToolbar) _buildToolbar(),
            if (_showAIButton) _buildAIQuickBar(),
            if (_isAIAssistantOpen) _buildAIAssistantOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteDesktop() {
    return GestureDetector(
      onTap: _toggleToolbar,
      child: Container(
        color: Colors.black,
        child: Center(
          child: Consumer<ConnectionService>(
            builder: (context, connectionService, _) {
              if (connectionService.status == ConnectionStatus.connecting) {
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Connecting...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                );
              }

              if (connectionService.status == ConnectionStatus.connected) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.desktop_windows,
                      size: 120,
                      color: Colors.white24,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Remote Desktop: ${widget.remoteId}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      connectionService.currentConnection?.isP2P == true
                          ? 'P2P Connection'
                          : 'Relay Connection',
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ],
                );
              }

              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 120,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Connection Failed',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: _toolbarOpacity,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  widget.remoteId,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: _showConnectionSettings,
              ),
              IconButton(
                icon: const Icon(Icons.fullscreen, color: Colors.white),
                onPressed: _toggleFullscreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIQuickBar() {
    final aiService = context.watch<AIService>();

    final aiActions = [
      AIQuickAction(
        icon: Icons.auto_awesome,
        label: 'AI助手',
        description: '打开AI助手面板',
        onTap: _launchAIAssistant,
      ),
      AIQuickAction(
        icon: Icons.screenshot,
        label: '截图分析',
        description: '截取当前画面并分析',
        onTap: () => _handleAIAction('screenshot'),
      ),
      AIQuickAction(
        icon: Icons.text_fields,
        label: 'OCR',
        description: '文字识别',
        onTap: () => _handleAIAction('ocr'),
      ),
      AIQuickAction(
        icon: Icons.code,
        label: '代码',
        description: '代码分析',
        onTap: () => _handleAIAction('code'),
      ),
    ];

    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Center(
        child: aiService.isProcessing
            ? _buildAIProcessingIndicator()
            : AIQuickButtonBar(
                actions: aiActions,
                direction: Axis.horizontal,
                buttonSize: 56,
                spacing: 16,
              ),
      ),
    );
  }

  Widget _buildAIProcessingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 12),
          Text(
            'AI Processing...',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAssistantOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  setState(() {
                    _isAIAssistantOpen = false;
                  });
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI助手',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isAIAssistantOpen = false;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  _buildAIFeatureTile(
                    icon: Icons.chat_bubble_outline,
                    title: '智能问答',
                    subtitle: '针对当前屏幕内容提问，获取AI解答',
                    onTap: () => _handleAIAction('chat'),
                  ),
                  _buildAIFeatureTile(
                    icon: Icons.text_fields,
                    title: 'OCR文字识别',
                    subtitle: '提取屏幕中的文字内容',
                    onTap: () => _handleAIAction('ocr'),
                  ),
                  _buildAIFeatureTile(
                    icon: Icons.code,
                    title: '代码审查',
                    subtitle: '分析远程屏幕中的代码',
                    onTap: () => _handleAIAction('code_review'),
                  ),
                  _buildAIFeatureTile(
                    icon: Icons.summarize,
                    title: '内容摘要',
                    subtitle: '快速了解当前屏幕的主要内容',
                    onTap: () => _handleAIAction('summarize'),
                  ),
                  _buildAIFeatureTile(
                    icon: Icons.translate,
                    title: '实时翻译',
                    subtitle: '翻译屏幕中的外语文本',
                    onTap: () => _handleAIAction('translate'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _toggleToolbar() {
    setState(() {
      _showToolbar = !_showToolbar;
      _toolbarOpacity = _showToolbar ? 1.0 : 0.0;
    });
  }

  void _toggleFullscreen() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  }

  void _showConnectionSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connection settings not implemented')),
    );
  }

  void _launchAIAssistant() {
    HapticFeedback.lightImpact();
    setState(() {
      _isAIAssistantOpen = true;
    });
  }

  void _handleAIAction(String action) {
    HapticFeedback.lightImpact();
    final aiService = context.read<AIService>();

    switch (action) {
      case 'chat':
        _showChatDialog();
        break;
      case 'ocr':
        _performOCR();
        break;
      case 'code':
      case 'code_review':
        _analyzeCode();
        break;
      case 'screenshot':
        _captureAndAnalyze();
        break;
      case 'summarize':
        _summarizeContent();
        break;
      case 'translate':
        _translateText();
        break;
    }
  }

  void _showChatDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Chat'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Ask a question about the remote screen...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendChatMessage(controller.text);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _sendChatMessage(String message) async {
    final aiService = context.read<AIService>();
    final response = await aiService.smartChat(message);

    if (mounted) {
      _showAIResponse(response);
    }
  }

  void _performOCR() async {
    final aiService = context.read<AIService>();
    final dummyImage = Uint8List(100);

    final response = await aiService.performOCR(dummyImage);

    if (mounted) {
      _showAIResponse(response);
    }
  }

  void _analyzeCode() async {
    final aiService = context.read<AIService>();
    final dummyImage = Uint8List(100);

    final response = await aiService.analyzeCode(dummyImage);

    if (mounted) {
      _showAIResponse(response);
    }
  }

  void _captureAndAnalyze() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Screen capture not implemented in demo')),
    );
  }

  void _summarizeContent() async {
    final aiService = context.read<AIService>();
    final dummyImage = Uint8List(100);

    final response = await aiService.summarizeContent(dummyImage);

    if (mounted) {
      _showAIResponse(response);
    }
  }

  void _translateText() {
    _showChatDialog();
  }

  void _showAIResponse(AIResponse response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              response.success ? Icons.check_circle : Icons.error,
              color: response.success ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            const Text('AI Response'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (response.result != null)
                Text(response.result!)
              else if (response.error != null)
                Text(
                  response.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              const Divider(),
              Text(
                'Processing time: ${response.processingTime.inMilliseconds}ms',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}