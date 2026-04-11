// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/core/ui/res/app_colors.dart';
import 'package:track/src/core/ui/utility/paddings.dart';

class TypeAheadField extends StatefulWidget {
  final TextEditingController controller;
  final IconData icon;
  final String title;
  final String hintText;
  final List<String> options;
  final String? Function(String?)? validator;
  final String? noOptionsText;
  final void Function(String)? onChanged;

  const TypeAheadField({
    super.key,
    required this.controller,
    required this.icon,
    required this.title,
    required this.options,
    this.validator,
    String? hintText,
    this.noOptionsText,
    this.onChanged,
  }) : hintText = hintText ?? 'Enter $title';

  @override
  State<TypeAheadField> createState() => _TypeAheadFieldState();
}

class _TypeAheadFieldState extends State<TypeAheadField> {
  late ThemeData theme;
  bool _showSuggestions = false;
  List<String> _filteredOptions = [];
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    theme = Theme.of(context);
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _showSuggestions) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && !_focusNode.hasFocus) {
          _removeOverlay();
          setState(() {
            _showSuggestions = false;
          });
        }
      });
    }
  }

  void _filterOptions(String query) {
    if (query.isEmpty) {
      _filteredOptions = widget.options;
    } else {
      _filteredOptions = widget.options
          .where((option) => option.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    Offset offset = renderBox.localToGlobal(Offset.zero);

    // Calculate available space above and below
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final availableBottomSpace =
        screenHeight - offset.dy - size.height - keyboardHeight;
    final availableTopSpace = offset.dy;

    // Determine if overlay should appear above or below
    const overlayHeight = 160.0; // Fixed height to show ~3 options
    bool showAbove =
        availableBottomSpace < overlayHeight &&
        availableTopSpace > availableBottomSpace;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // The dropdown
          Positioned(
            width: size.width - 32,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(
                16.0,
                showAbove ? -(overlayHeight + 5) : size.height + 5,
              ),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: overlayHeight, // Strictly enforce max height
                    minHeight: 0,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: _filteredOptions.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            widget.noOptionsText ??
                                'No ${widget.title.toLowerCase()} found',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.tertiary.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        )
                      : Listener(
                          onPointerDown: (event) {
                            // Prevent the ListView from capturing scroll gestures
                            // This allows the parent to handle scrolling
                          },
                          child: ListView.builder(
                            physics: const ClampingScrollPhysics(),
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _filteredOptions.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  widget.controller.text =
                                      _filteredOptions[index];
                                  widget.onChanged?.call(
                                    _filteredOptions[index],
                                  );
                                  _removeOverlay();
                                  setState(() {
                                    _showSuggestions = false;
                                  });
                                  _focusNode.unfocus();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    _filteredOptions[index],
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),
            ),
          ),
          // Transparent background to capture taps outside dropdown
          Positioned.fill(
            child: IgnorePointer(
              ignoring:
                  true, // Ignore all pointer events except where explicitly handled
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _removeOverlay();
                  setState(() {
                    _showSuggestions = false;
                  });
                  _focusNode.unfocus();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Card(
        margin: const EdgeInsets.only(top: 8, right: 16, left: 16, bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    widget.icon,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const GapH(16),
                Expanded(
                  child: Text(widget.title, style: theme.textTheme.labelLarge),
                ),
              ],
            ),
            const GapV(12),
            TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              validator: widget.validator,
              onChanged: (value) {
                widget.onChanged?.call(value);
                _filterOptions(value);
                if (value.isNotEmpty && !_showSuggestions) {
                  setState(() {
                    _showSuggestions = true;
                  });
                  _showOverlay();
                } else if (value.isEmpty && _showSuggestions) {
                  setState(() {
                    _showSuggestions = false;
                  });
                  _removeOverlay();
                } else if (_showSuggestions) {
                  _showOverlay();
                }
              },
              onTap: () {
                if (!_showSuggestions) {
                  _filterOptions(widget.controller.text);
                  setState(() {
                    _showSuggestions = true;
                  });
                  _showOverlay();
                }
              },
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.black.withOpacity(0.9),
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: theme.colorScheme.tertiary.withOpacity(0.4),
                  fontSize: 14,
                ),
                suffixIcon: Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.tertiary.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ).pSymmetric(vertical: 8),
    );
  }
}

class TypeAheadFieldSleek extends StatefulWidget {
  final TextEditingController controller;
  final IconData icon;
  final String title;
  final String hintText;
  final List<String> options;
  final String? Function(String?)? validator;
  final String? noOptionsText;
  final void Function(String)? onChanged;

  const TypeAheadFieldSleek({
    super.key,
    required this.controller,
    required this.icon,
    required this.title,
    required this.options,
    this.validator,
    String? hintText,
    this.noOptionsText,
    this.onChanged,
  }) : hintText = hintText ?? 'Enter $title';

  @override
  State<TypeAheadFieldSleek> createState() => _TypeAheadFieldSleekState();
}

class _TypeAheadFieldSleekState extends State<TypeAheadFieldSleek> {
  late ThemeData theme;
  bool _showSuggestions = false;
  List<String> _filteredOptions = [];
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    theme = Theme.of(context);
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _showSuggestions) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && !_focusNode.hasFocus) {
          _removeOverlay();
          setState(() {
            _showSuggestions = false;
          });
        }
      });
    }
  }

  void _filterOptions(String query) {
    if (query.isEmpty) {
      _filteredOptions = widget.options;
    } else {
      _filteredOptions = widget.options
          .where((option) => option.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    Offset offset = renderBox.localToGlobal(Offset.zero);

    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final availableBottomSpace =
        screenHeight - offset.dy - size.height - keyboardHeight;
    final availableTopSpace = offset.dy;

    const overlayHeight = 160.0;
    bool showAbove =
        availableBottomSpace < overlayHeight &&
        availableTopSpace > availableBottomSpace;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(
                0,
                showAbove ? -(overlayHeight + 5) : size.height + 5,
              ),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: overlayHeight,
                    minHeight: 0,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: _filteredOptions.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            widget.noOptionsText ??
                                'No ${widget.title.toLowerCase()} found',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.tertiary.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _filteredOptions.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                widget.controller.text =
                                    _filteredOptions[index];
                                widget.onChanged?.call(_filteredOptions[index]);
                                _removeOverlay();
                                setState(() {
                                  _showSuggestions = false;
                                });
                                _focusNode.unfocus();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Text(
                                  _filteredOptions[index],
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _removeOverlay();
                  setState(() {
                    _showSuggestions = false;
                  });
                  _focusNode.unfocus();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.name,
        validator: widget.validator,
        onChanged: (value) {
          widget.onChanged?.call(value);
          _filterOptions(value);
          if (value.isNotEmpty && !_showSuggestions) {
            setState(() {
              _showSuggestions = true;
            });
            _showOverlay();
          } else if (value.isEmpty && _showSuggestions) {
            setState(() {
              _showSuggestions = false;
            });
            _removeOverlay();
          } else if (_showSuggestions) {
            _showOverlay();
          }
        },
        onTap: () {
          if (!_showSuggestions) {
            _filterOptions(widget.controller.text);
            setState(() {
              _showSuggestions = true;
            });
            _showOverlay();
          }
        },
        decoration: InputDecoration(
          labelText: widget.title,
          prefixIcon: Transform.scale(
            scale: 0.7,
            child: Icon(widget.icon, color: theme.iconTheme.color),
          ),
        ),
      ),
    );
  }
}
