import 'package:flutter/cupertino.dart';

import 'config_packages.dart';

class CommonSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;

  const CommonSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeTrackColor,
    this.inactiveTrackColor,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoSwitch(
      value: value,
      activeTrackColor: activeTrackColor ?? AppColors.primaryColor,
      inactiveTrackColor: inactiveTrackColor ?? const Color(0xFFCBD5E1),
      onChanged: onChanged,
    );
  }
}
