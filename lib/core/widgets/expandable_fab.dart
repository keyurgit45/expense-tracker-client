import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/color_constants.dart';

class ExpandableFab extends StatefulWidget {
  const ExpandableFab({super.key});

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;
  bool _isExpanded = false;
  OverlayEntry? _backdropOverlay;
  OverlayEntry? _menuOverlay;

  final List<_FabMenuItem> _menuItems = const [
    _FabMenuItem(
      icon: Icons.chat,
      label: 'AI Chat',
      route: '/chat',
    ),
    _FabMenuItem(
      icon: Icons.analytics,
      label: 'Analytics',
      route: '/analytics',
    ),
    _FabMenuItem(
      icon: Icons.category,
      label: 'Categories',
      route: '/categories',
    ),
    _FabMenuItem(
      icon: Icons.sms,
      label: 'SMS',
      route: '/sms',
    ),
    _FabMenuItem(
      icon: Icons.settings,
      label: 'Settings',
      route: '/settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.125, // 45 degrees in turns
    ).animate(_expandAnimation);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeOverlays();
    super.dispose();
  }

  void _toggle() {
    if (!mounted) return;
    
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
        _showOverlays();
      } else {
        _animationController.reverse().then((_) {
          if (mounted) {
            _removeOverlays();
          }
        });
      }
    });
  }

  void _showOverlays() {
    final renderObject = context.findRenderObject();
    if (renderObject == null || renderObject is! RenderBox) return;
    
    final RenderBox renderBox = renderObject;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    // Create backdrop overlay
    _backdropOverlay = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          return Positioned.fill(
            child: GestureDetector(
              onTap: _toggle,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 3 * _expandAnimation.value,
                  sigmaY: 3 * _expandAnimation.value,
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.5 * _expandAnimation.value),
                ),
              ),
            ),
          );
        },
      ),
    );

    // Create menu overlay with Material wrapper
    _menuOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        right: 0,
        bottom: MediaQuery.of(context).size.height - offset.dy + 16,
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Menu items container with proper alignment
              Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Menu items
                    ..._menuItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return AnimatedBuilder(
                        animation: _expandAnimation,
                        builder: (context, child) {
                          final staggerDelay = index * 0.1;
                          final denominator = 1.0 - staggerDelay;
                          final staggerValue = denominator > 0 
                              ? ((_expandAnimation.value - staggerDelay).clamp(0.0, 1.0) / denominator)
                              : 1.0;

                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - staggerValue)),
                            child: Opacity(
                              opacity: staggerValue,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildMenuItem(item, staggerValue),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Insert overlays in order
    Overlay.of(context).insert(_backdropOverlay!);
    Overlay.of(context).insert(_menuOverlay!);
  }

  void _removeOverlays() {
    _backdropOverlay?.remove();
    _backdropOverlay = null;
    _menuOverlay?.remove();
    _menuOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainFab();
  }

  Widget _buildMenuItem(_FabMenuItem item, double animationValue) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Label - now gesture detectable
        AnimatedOpacity(
          opacity: animationValue,
          duration: const Duration(milliseconds: 100),
          child: GestureDetector(
            onTap: () {
              _toggle();
              context.push(item.route);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: ColorConstants.surface2,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.label,
                style: GoogleFonts.inter(
                  color: ColorConstants.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
        // Mini FAB
        SizedBox(
          width: 48,
          height: 48,
          child: FloatingActionButton(
            heroTag: 'fab_${item.label}',
            onPressed: () {
              _toggle();
              context.push(item.route);
            },
            elevation: 2,
            backgroundColor: ColorConstants.surface2,
            child: Icon(
              item.icon,
              color: ColorConstants.textPrimary,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainFab() {
    return SizedBox(
      width: 56,
      height: 56,
      child: FloatingActionButton(
        heroTag: 'main_fab',
        onPressed: _toggle,
        elevation: _isExpanded ? 8 : 4,
        backgroundColor: ColorConstants.surface3,
        child: AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: Icon(
                _isExpanded ? Icons.close : Icons.dashboard,
                color: ColorConstants.textPrimary,
                size: 28,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FabMenuItem {
  final IconData icon;
  final String label;
  final String route;

  const _FabMenuItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}