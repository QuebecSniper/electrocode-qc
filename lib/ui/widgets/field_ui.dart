import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

class DisclaimerBar extends StatelessWidget {
  const DisclaimerBar({super.key, this.compact = true});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF8E7),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, compact ? 8 : 12, 16, compact ? 8 : 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 18, color: ElectroTheme.muted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ElectroCode.disclaimer,
                  style: TextStyle(
                    fontSize: compact ? 12 : 13,
                    height: 1.3,
                    color: ElectroTheme.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.status,
    this.subtitle,
  });

  final ComplianceStatus status;
  final String? subtitle;

  Color get _bg {
    switch (status) {
      case ComplianceStatus.conforme:
        return const Color(0xFFE6F6EC);
      case ComplianceStatus.nonConforme:
        return const Color(0xFFFEECEC);
      case ComplianceStatus.questionsEnAttente:
        return const Color(0xFFFFF4E5);
    }
  }

  Color get _fg {
    switch (status) {
      case ComplianceStatus.conforme:
        return ElectroTheme.ok;
      case ComplianceStatus.nonConforme:
        return ElectroTheme.bad;
      case ComplianceStatus.questionsEnAttente:
        return ElectroTheme.wait;
    }
  }

  IconData get _icon {
    switch (status) {
      case ComplianceStatus.conforme:
        return Icons.check_circle;
      case ComplianceStatus.nonConforme:
        return Icons.cancel;
      case ComplianceStatus.questionsEnAttente:
        return Icons.pending;
    }
  }

  String get _label {
    switch (status) {
      case ComplianceStatus.conforme:
        return 'CONFORME';
      case ComplianceStatus.nonConforme:
        return 'NON CONFORME';
      case ComplianceStatus.questionsEnAttente:
        return 'À COMPLÉTER';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _fg.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(_icon, color: _fg, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _label,
                  style: TextStyle(
                    color: _fg,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(color: _fg, fontSize: 15, height: 1.3),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.hint,
  });

  final String label;
  final String value;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE4E7EC)),
        ),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ElectroTheme.muted,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: ElectroTheme.ink,
              ),
            ),
            if (hint != null) ...[
              const SizedBox(height: 2),
              Text(
                hint!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: ElectroTheme.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StepHeader extends StatelessWidget {
  const StepHeader({super.key, required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    const labels = ['Saisie', 'Questions', 'Résultat'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          for (var i = 1; i <= total; i++) ...[
            if (i > 1)
              Expanded(
                child: Container(
                  height: 2,
                  color: i <= current ? ElectroTheme.navy : const Color(0xFFD0D5DD),
                ),
              ),
            _dot(i, labels[i - 1], i <= current),
          ],
        ],
      ),
    );
  }

  Widget _dot(int i, String label, bool on) {
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: on ? ElectroTheme.navy : const Color(0xFFD0D5DD),
          child: Text(
            '$i',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: on ? Colors.white : ElectroTheme.muted,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: on ? FontWeight.w700 : FontWeight.w500,
            color: on ? ElectroTheme.navy : ElectroTheme.muted,
          ),
        ),
      ],
    );
  }
}

class KvRow extends StatelessWidget {
  const KvRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: ElectroTheme.muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ElectroTheme.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
