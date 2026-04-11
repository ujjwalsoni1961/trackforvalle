import 'package:flutter/material.dart';

class ClickableListButton extends StatefulWidget {
  final String title;
  final Function? onTap;
  final Widget icon;
  final String? subtitle;
  final Color? titleColor;
  final Color? subtitleColor;
  final Color? tileColor;
  final Widget? trailing;

  const ClickableListButton({
    super.key,
    required this.title,
    this.onTap,
    required this.icon,
    this.trailing,
    this.subtitle,
    this.titleColor,
    this.subtitleColor,
    this.tileColor,
  });

  @override
  State<ClickableListButton> createState() => _ClickableListButtonState();
}

class _ClickableListButtonState extends State<ClickableListButton>
    with SingleTickerProviderStateMixin {
  late ThemeData theme = Theme.of(context);
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: widget.tileColor ?? theme.colorScheme.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: isEnabled
              ? theme.colorScheme.primary.withOpacity(0.2)
              : Colors.transparent,
          highlightColor: isEnabled
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          onTap: isEnabled ? () => widget.onTap!() : null,
          onTapDown: (_) => _animationController.forward(),
          onTapUp: (_) => _animationController.reverse(),
          onTapCancel: () => _animationController.reverse(),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  // Icon
                  IconTheme(
                    data: IconThemeData(
                      color: isEnabled
                          ? theme.colorScheme.primary
                          : theme.colorScheme.tertiary.withOpacity(0.4),
                      size: 24,
                    ),
                    child: widget.icon,
                  ),
                  const SizedBox(width: 16),
                  // Title and Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                widget.titleColor ??
                                (isEnabled
                                    ? theme.colorScheme.tertiary
                                    : theme.colorScheme.tertiary.withOpacity(
                                        0.4,
                                      )),
                          ),
                        ),
                        if (widget.subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              widget.subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color:
                                    widget.subtitleColor ??
                                    (isEnabled
                                        ? theme.colorScheme.onSurfaceVariant
                                        : theme.colorScheme.onSurfaceVariant
                                              .withOpacity(0.4)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Trailing
                  if (widget.trailing != null)
                    IconTheme(
                      data: IconThemeData(
                        color: isEnabled
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurfaceVariant.withOpacity(
                                0.4,
                              ),
                        size: 20,
                      ),
                      child: widget.trailing!,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
