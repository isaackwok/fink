import 'package:flutter/material.dart';

/// Gives a full-screen scrollable the bottom-sheet "drag down to close"
/// gesture without owning any gestures itself: it only observes the child
/// scrollable's notifications, so it can never fight the scroll view in the
/// gesture arena or change how scrolling feels.
///
/// Dismissal fires on release after the finger has pulled down past
/// [dismissThreshold] while the scrollable was at its top edge, or after a
/// fast downward flick ([flingVelocity]) with at least a small pull. The pull
/// is measured as *raw finger travel* (from `dragDetails.delta`), not the
/// scroll position — `BouncingScrollPhysics` applies friction to overscroll
/// (much stronger when the content is shorter than the viewport), so a
/// position threshold would need a different distance depending on content
/// height and platform physics. Finger travel is the same everywhere, and it
/// also works under clamping physics where the position never leaves 0.
///
/// The wrapped scrollable should use [AlwaysScrollableScrollPhysics] —
/// otherwise content that fits the viewport can't be dragged at all and the
/// gesture is dead.
class PullDownToDismiss extends StatefulWidget {
  const PullDownToDismiss({
    super.key,
    required this.child,
    required this.onDismiss,
    this.dismissThreshold = 120,
    this.flingVelocity = 700,
  });

  final Widget child;

  /// Called exactly once when the pull qualifies as a dismissal. The caller
  /// owns what "dismiss" means (typically `Navigator.pop`).
  final VoidCallback onDismiss;

  /// Net downward finger travel past the top edge, in logical pixels, needed
  /// for a release to dismiss.
  final double dismissThreshold;

  /// Downward finger velocity (logical px/s) that dismisses on release even
  /// before [dismissThreshold] is reached — the "flick down" gesture. The
  /// flick still needs a quarter of [dismissThreshold] of overscroll travel,
  /// so a fast scroll-back-to-top that barely grazes the edge never counts.
  final double flingVelocity;

  @override
  State<PullDownToDismiss> createState() => _PullDownToDismissState();
}

class _PullDownToDismissState extends State<PullDownToDismiss> {
  bool _dismissed = false;

  /// Net finger travel (px) spent overscrolled past the top in the current
  /// pull. Pushing back up subtracts, so a pull the user walks back doesn't
  /// dismiss.
  double _pullDistance = 0;

  /// Finger velocity (px/s, positive = downward) from the most recent drag
  /// update, derived from event timestamps.
  double _dragVelocity = 0;
  Duration? _lastDragTimestamp;

  void _dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    widget.onDismiss();
  }

  void _reset() {
    _pullDistance = 0;
    _dragVelocity = 0;
    _lastDragTimestamp = null;
  }

  void _trackDrag(DragUpdateDetails details, double pulledBy) {
    _pullDistance = (_pullDistance + pulledBy).clamp(0, double.infinity);
    final timestamp = details.sourceTimeStamp;
    if (timestamp != null && _lastDragTimestamp != null) {
      final dt = (timestamp - _lastDragTimestamp!).inMicroseconds / 1e6;
      if (dt > 0) {
        _dragVelocity = details.delta.dy / dt;
      }
    }
    _lastDragTimestamp = timestamp;
  }

  /// The finger just lifted (or scrolling ended). Decide once, then forget
  /// the pull.
  void _evaluateRelease() {
    final pulledFar = _pullDistance >= widget.dismissThreshold;
    final flicked =
        _pullDistance >= widget.dismissThreshold / 4 &&
        _dragVelocity >= widget.flingVelocity;
    if (pulledFar || flicked) {
      _dismiss();
    }
    _reset();
  }

  bool _handleNotification(ScrollNotification notification) {
    // depth 0 = the nearest scrollable only; nested scrollables (page views,
    // horizontal lists) inside the content must not trigger dismissal.
    if (_dismissed || notification.depth != 0) return false;

    if (notification is ScrollUpdateNotification) {
      final drag = notification.dragDetails;
      if (drag != null) {
        if (notification.metrics.pixels < 0) {
          // Bouncing physics: overscrolled past the top with the finger down.
          _trackDrag(drag, drag.delta.dy);
        } else {
          // Finger-down scrolling inside the content cancels any pull.
          _reset();
        }
      } else if (_pullDistance > 0) {
        // First ballistic frame after a pull: the release moment.
        _evaluateRelease();
      }
    } else if (notification is OverscrollNotification) {
      // Clamping physics: the position stays pinned at 0 and the pull
      // arrives as unapplied overscroll deltas (negative = downward).
      final drag = notification.dragDetails;
      if (drag != null && notification.overscroll < 0) {
        _trackDrag(drag, -notification.overscroll);
      }
    } else if (notification is ScrollEndNotification) {
      // Clamping physics has no ballistic bounce-back, so the release is
      // only observable here. (Under bouncing physics the pull was already
      // evaluated and reset, making this a no-op.)
      if (_pullDistance > 0) {
        _evaluateRelease();
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleNotification,
      child: widget.child,
    );
  }
}
