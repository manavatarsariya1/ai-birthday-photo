import 'dart:async';

import 'package:flutter/widgets.dart';

/// Gates ad refreshes on real on-screen visibility so no ad is requested while
/// it cannot produce an impression (which would lower the AdMob show rate).
///
/// An ad counts as visible only when ALL of these hold:
/// - the app is in the foreground,
/// - its route is the top-most route (no screen / bottom sheet / dialog above),
/// - it is not inside an offstage / ticker-disabled subtree,
/// - at least half of it is inside the screen bounds (not scrolled away).
mixin AdVisibilityMixin<T extends StatefulWidget> on State<T> {
  static const Duration _pollInterval = Duration(milliseconds: 1500);

  Timer? _visibilityPollTimer;

  bool isAdVisibleNow() {
    if (!mounted) return false;

    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle != null && lifecycle != AppLifecycleState.resumed) {
      return false;
    }

    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return false;

    if (!TickerMode.valuesOf(context).enabled) return false;

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox ||
        !renderObject.attached ||
        !renderObject.hasSize) {
      return false;
    }
    final size = renderObject.size;
    if (size.height <= 0 || size.width <= 0) return false;

    final screen = MediaQuery.maybeSizeOf(context);
    if (screen == null) return true;

    final topLeft = renderObject.localToGlobal(Offset.zero);
    final rect = topLeft & size;
    final visible = rect.intersect(Offset.zero & screen);
    if (visible.width <= 0 || visible.height <= 0) return false;
    return visible.height >= size.height * 0.5;
  }

  /// Runs [action] now if the ad is visible, otherwise waits (polling cheaply)
  /// until it becomes visible again and runs it exactly once.
  void runWhenAdVisible(VoidCallback action) {
    cancelAdVisibilityWait();
    if (isAdVisibleNow()) {
      action();
      return;
    }
    _visibilityPollTimer = Timer.periodic(_pollInterval, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (isAdVisibleNow()) {
        timer.cancel();
        _visibilityPollTimer = null;
        action();
      }
    });
  }

  void cancelAdVisibilityWait() {
    _visibilityPollTimer?.cancel();
    _visibilityPollTimer = null;
  }

  @override
  void dispose() {
    cancelAdVisibilityWait();
    super.dispose();
  }
}
