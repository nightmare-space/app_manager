import 'package:flutter/material.dart';

class NiIconButton extends StatelessWidget {
  const NiIconButton({Key key, this.child, this.onTap}) : super(key: key);
  final Widget child;
  final GestureTapCallback onTap;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        onTapDown: (_) {
          Feedback.forLongPress(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: child,
        ),
      ),
    );
  }
}
