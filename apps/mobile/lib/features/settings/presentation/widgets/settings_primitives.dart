import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.title,
    required this.children,
    this.trailing,
    super.key,
  });

  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: _withDividers(context, children)),
        ),
      ],
    );
  }

  static List<Widget> _withDividers(BuildContext context, List<Widget> items) {
    if (items.isEmpty) {
      return const <Widget>[];
    }
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i < items.length - 1) {
        out.add(
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        );
      }
    }
    return out;
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.enabled = true,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final canTap = enabled && onTap != null;
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      enabled: enabled,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Icon(icon, size: 20, color: colors.primary),
      ),
      title: Text(title),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: canTap
          ? Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant)
          : (!enabled
                ? Icon(
                    Icons.lock_outline_rounded,
                    color: colors.onSurfaceVariant,
                  )
                : null),
      onTap: canTap ? onTap : null,
    );
  }
}

class SettingsStatusCard extends StatelessWidget {
  const SettingsStatusCard({
    required this.title,
    required this.firstLabel,
    required this.secondLabel,
    required this.syncStatus,
    required this.notificationStatus,
    super.key,
  });

  final String title;
  final String firstLabel;
  final String secondLabel;
  final String syncStatus;
  final String notificationStatus;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          _StatusRow(
            icon: Icons.cloud_done_outlined,
            label: firstLabel,
            value: syncStatus,
          ),
          const SizedBox(height: AppSpacing.sm),
          Divider(height: 1, color: colors.outlineVariant),
          const SizedBox(height: AppSpacing.sm),
          _StatusRow(
            icon: Icons.notifications_active_outlined,
            label: secondLabel,
            value: notificationStatus,
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
