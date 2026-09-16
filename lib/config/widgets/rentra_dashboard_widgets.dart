import 'package:flutter/material.dart';

class RentraBrandMark extends StatelessWidget {
  const RentraBrandMark({
    super.key,
    this.size = 52,
    this.showBackground = true,
  });

  final double size;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mark = CustomPaint(
      size: Size.square(size),
      painter: _RentraMarkPainter(
        roofColor: scheme.secondary,
        bodyColor: scheme.primary,
        surfaceColor: scheme.surface,
      ),
    );

    if (!showBackground) return mark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(size * .18),
        child: mark,
      ),
    );
  }
}

class RentraBrandLockup extends StatelessWidget {
  const RentraBrandLockup({
    super.key,
    this.center = true,
    this.compact = false,
  });

  final bool center;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final content = [
      RentraBrandMark(size: compact ? 34 : 58),
      SizedBox(width: compact ? 10 : 0, height: compact ? 0 : 16),
      Column(
        crossAxisAlignment:
            center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Homvaro',
            style: (compact
                    ? Theme.of(context).textTheme.titleLarge
                    : Theme.of(context).textTheme.headlineMedium)
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          Text(
            'Find. Rent. Live Better.',
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: .68),
              fontSize: compact ? 11 : 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ];

    if (compact) {
      return Row(mainAxisSize: MainAxisSize.min, children: content);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: content,
    );
  }
}

class RentraAppBarTitle extends StatelessWidget {
  const RentraAppBarTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(children: [
      const RentraBrandMark(size: 28, showBackground: false),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: .62),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}

class RentraChromeButton extends StatelessWidget {
  const RentraChromeButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final buttonIcon = badgeCount > 0
        ? Badge.count(
            count: badgeCount > 99 ? 99 : badgeCount,
            backgroundColor: scheme.secondary,
            textColor: scheme.onSecondary,
            child: Icon(icon),
          )
        : Icon(icon);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: scheme.surface,
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outlineVariant),
          minimumSize: const Size.square(44),
          fixedSize: const Size.square(44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: buttonIcon,
      ),
    );
  }
}

class RentraDashboardHeader extends StatelessWidget {
  const RentraDashboardHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.action,
    this.metrics = const [],
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? action;
  final List<RentraMetricData> metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(scheme.primary, Colors.black, dark ? .18 : .04)!,
              Color.lerp(scheme.primary, scheme.secondary, .42)!,
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: .14)),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: dark ? .16 : .14),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(children: [
          Positioned(
            right: -36,
            top: -58,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: .11)),
              ),
              child: const SizedBox.square(dimension: 150),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .18),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: .26)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(9),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .82),
                          height: 1.22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(width: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 116),
                    child: FittedBox(fit: BoxFit.scaleDown, child: action!),
                  ),
                ],
              ]),
              if (metrics.isNotEmpty) ...[
                const SizedBox(height: 14),
                LayoutBuilder(builder: (context, constraints) {
                  final columns = constraints.maxWidth > 560 ? 3 : 2;
                  return GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: columns == 3 ? 2.75 : 2.45,
                    children: metrics.map(RentraMetricTile.new).toList(),
                  );
                }),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}

class _RentraMarkPainter extends CustomPainter {
  const _RentraMarkPainter({
    required this.roofColor,
    required this.bodyColor,
    required this.surfaceColor,
  });

  final Color roofColor;
  final Color bodyColor;
  final Color surfaceColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = w * .12;

    final roof = Path()
      ..moveTo(w * .16, h * .44)
      ..lineTo(w * .50, h * .15)
      ..lineTo(w * .84, h * .44);
    canvas.drawPath(roof, stroke..color = roofColor);

    final home = Path()
      ..moveTo(w * .24, h * .47)
      ..lineTo(w * .24, h * .82)
      ..lineTo(w * .42, h * .82)
      ..lineTo(w * .42, h * .62)
      ..lineTo(w * .58, h * .62)
      ..lineTo(w * .58, h * .82)
      ..lineTo(w * .76, h * .82)
      ..lineTo(w * .76, h * .47);
    canvas.drawPath(home, stroke..color = bodyColor);

    final highlight = Path()
      ..moveTo(w * .24, h * .47)
      ..lineTo(w * .50, h * .25)
      ..lineTo(w * .76, h * .47);
    canvas.drawPath(
      highlight,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .035
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = surfaceColor.withValues(alpha: .58),
    );
  }

  @override
  bool shouldRepaint(covariant _RentraMarkPainter oldDelegate) =>
      oldDelegate.roofColor != roofColor ||
      oldDelegate.bodyColor != bodyColor ||
      oldDelegate.surfaceColor != surfaceColor;
}

class RentraMetricData {
  const RentraMetricData({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class RentraMetricTile extends StatelessWidget {
  const RentraMetricTile(this.metric, {super.key});

  final RentraMetricData metric;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .16),
          border: Border.all(color: Colors.white.withValues(alpha: .22)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          child: Row(children: [
            Icon(metric.icon, color: Colors.white, size: 18),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    metric.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    metric.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .78),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      );
}

class RentraSectionTitle extends StatelessWidget {
  const RentraSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle!,
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: .64),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ]),
      ),
      if (trailing != null) ...[
        const SizedBox(width: 12),
        trailing!,
      ],
    ]);
  }
}

class RentraDetailHero extends StatelessWidget {
  const RentraDetailHero({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.status,
    this.metrics = const [],
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? status;
  final List<RentraMetricData> metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: scheme.primary, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: .66),
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            if (status != null) ...[
              const SizedBox(width: 10),
              status!,
            ],
          ]),
          if (metrics.isNotEmpty) ...[
            const SizedBox(height: 16),
            LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth > 560 ? 3 : 2;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: columns == 3 ? 2.75 : 2.5,
                children: metrics.map(_RentraSoftMetricTile.new).toList(),
              );
            }),
          ],
        ]),
      ),
    );
  }
}

class _RentraSoftMetricTile extends StatelessWidget {
  const _RentraSoftMetricTile(this.metric);

  final RentraMetricData metric;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: .62),
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(children: [
          Icon(metric.icon, color: scheme.secondary, size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                ),
                Text(
                  metric.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: .6),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class RentraInfoPanel extends StatelessWidget {
  const RentraInfoPanel({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.secondaryContainer.withValues(alpha: .72),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Icon(icon, color: scheme.secondary, size: 17),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 11),
          ...children,
        ]),
      ),
    );
  }
}

class RentraInfoRow extends StatelessWidget {
  const RentraInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: .72),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 16, color: scheme.primary),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: .56),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class RentraQuickActionStrip extends StatelessWidget {
  const RentraQuickActionStrip({
    super.key,
    required this.actions,
  });

  final List<RentraQuickAction> actions;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 98,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: actions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) => actions[index],
        ),
      );
}

class RentraQuickAction extends StatelessWidget {
  const RentraQuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 132,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, color: scheme.secondary, size: 20),
              const Spacer(),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900, height: 1.05),
              ),
              const SizedBox(height: 1),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: .62),
                  fontSize: 11,
                  height: 1.05,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
