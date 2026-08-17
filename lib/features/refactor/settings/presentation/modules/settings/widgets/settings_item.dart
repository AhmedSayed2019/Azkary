import 'package:azkark/core/res/resources.dart';
import 'package:azkark/util/colors.dart';
import 'package:flutter/material.dart';

/// Replaces the legacy `SettingsItem` widget. It is now a pure, stateless
/// row driven entirely by the parent's `value`/`onChanged` — the previous
/// version kept its own local `switchValue` in a `State`, which could drift
/// from the persisted value if the underlying write failed silently. The
/// new `SettingsViewModel` already reverts optimistic updates on failure and
/// notifies listeners, so this widget only ever renders the source of
/// truth.
class SettingsItem extends StatelessWidget {
  const SettingsItem({
    super.key,
    required this.activeTitle,
    required this.inactiveTitle,
    required this.value,
    required this.onChanged,
    this.borderRadius,
  });

  final String activeTitle;
  final String inactiveTitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: teal[200],
      onTap: () => onChanged(!value),
      borderRadius: borderRadius,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                value ? activeTitle : inactiveTitle,
                style: const TextStyle().semiBoldStyle().primaryTextColor(),
              ),
            ),
            Switch(
              onChanged: onChanged,
              value: value,
              activeThumbColor: teal[700],
              activeTrackColor: teal[500],
              inactiveThumbColor: teal[200],
              inactiveTrackColor: Theme.of(context).cardColor,
            ),
          ],
        ),
      ),
    );
  }
}
