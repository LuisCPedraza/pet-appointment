import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

/// Wrapper sencillo para facilitar la adición de etiquetas Semantics en widgets.
class SemanticsWrapper extends StatelessWidget {
  final String? label;
  final Widget child;
  final bool hideChildren;

  const SemanticsWrapper({
    super.key,
    required this.child,
    this.label,
    this.hideChildren = false,
  });

  @override
  Widget build(BuildContext context) {
    if (label == null || label!.isEmpty) return child;
    return Semantics(
      label: label,
      container: true,
      explicitChildNodes: true,
      child: ExcludeSemantics(excluding: hideChildren, child: child),
    );
  }
}
