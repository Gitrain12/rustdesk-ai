import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AIQuickAction {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;
  final Color? backgroundColor;

  const AIQuickAction({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    this.backgroundColor,
  });
}

class AIQuickButtonBar extends StatelessWidget {
  final List<AIQuickAction> actions;
  final Axis direction;
  final double buttonSize;
  final double spacing;

  const AIQuickButtonBar({
    super.key,
    required this.actions,
    this.direction = Axis.horizontal,
    this.buttonSize = 56,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: direction == Axis.horizontal
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: _buildButtons(context),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: _buildButtons(context),
            ),
    );
  }

  List<Widget> _buildButtons(BuildContext context) {
    return actions.map((action) {
      return Padding(
        padding: EdgeInsets.all(spacing / 2),
        child: _AIQuickButton(
          action: action,
          size: buttonSize,
          onTap: () {
            HapticFeedback.lightImpact();
            action.onTap();
          },
        ),
      );
    }).toList();
  }
}

class _AIQuickButton extends StatelessWidget {
  final AIQuickAction action;
  final double size;
  final VoidCallback onTap;

  const _AIQuickButton({
    required this.action,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: action.backgroundColor ??
                  Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(size / 3),
            ),
            child: Icon(
              action.icon,
              color: action.backgroundColor != null
                  ? Colors.white
                  : Theme.of(context).colorScheme.onPrimaryContainer,
              size: size * 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            action.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class AIAssistantPanel extends StatelessWidget {
  final Function(String action, Map<String, dynamic> params) onAction;

  const AIAssistantPanel({
    super.key,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Center(
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                _AIFeatureTile(
                  icon: Icons.chat_bubble_outline,
                  title: '智能问答',
                  subtitle: '针对当前屏幕内容提问，获取AI解答',
                  onTap: () => onAction('chat', {}),
                ),
                _AIFeatureTile(
                  icon: Icons.text_fields,
                  title: 'OCR文字识别',
                  subtitle: '提取屏幕中的文字内容',
                  onTap: () => onAction('ocr', {}),
                ),
                _AIFeatureTile(
                  icon: Icons.code,
                  title: '代码审查',
                  subtitle: '分析远程屏幕中的代码',
                  onTap: () => onAction('code_review', {}),
                ),
                _AIFeatureTile(
                  icon: Icons.summarize,
                  title: '内容摘要',
                  subtitle: '快速了解当前屏幕的主要内容',
                  onTap: () => onAction('summarize', {}),
                ),
                _AIFeatureTile(
                  icon: Icons.translate,
                  title: '实时翻译',
                  subtitle: '翻译屏幕中的外语文本',
                  onTap: () => onAction('translate', {}),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AIFeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AIFeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
}