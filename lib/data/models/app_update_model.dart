enum UpdateType {
  none,
  soft,
  force,
}

class AppUpdateConfig {
  final String minVersion;
  final String latestVersion;
  final bool isForceUpdate;
  final bool isSoftUpdate;
  final String updateUrl;
  final String title;
  final String message;

  const AppUpdateConfig({
    this.minVersion = '1.0.0',
    this.latestVersion = '1.0.0',
    this.isForceUpdate = false,
    this.isSoftUpdate = false,
    this.updateUrl = '',
    this.title = '',
    this.message = '',
  });

  factory AppUpdateConfig.fromJson(Map<String, dynamic> json) {
    return AppUpdateConfig(
      minVersion: json['min_version']?.toString() ?? '1.0.0',
      latestVersion: json['latest_version']?.toString() ?? '1.0.0',
      isForceUpdate: json['is_force_update'] as bool? ?? false,
      isSoftUpdate: json['is_soft_update'] as bool? ?? false,
      updateUrl: json['update_url']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'min_version': minVersion,
        'latest_version': latestVersion,
        'is_force_update': isForceUpdate,
        'is_soft_update': isSoftUpdate,
        'update_url': updateUrl,
        'title': title,
        'message': message,
      };
}

class AppUpdateInfo {
  final UpdateType updateType;
  final String currentVersion;
  final String minVersion;
  final String latestVersion;
  final String updateUrl;
  final String? customTitle;
  final String? customMessage;

  const AppUpdateInfo({
    required this.updateType,
    required this.currentVersion,
    required this.minVersion,
    required this.latestVersion,
    required this.updateUrl,
    this.customTitle,
    this.customMessage,
  });

  bool get isForceUpdate => updateType == UpdateType.force;
  bool get isSoftUpdate => updateType == UpdateType.soft;
  bool get hasUpdate => updateType != UpdateType.none;

  factory AppUpdateInfo.noUpdate({
    String currentVersion = '1.0.0',
    String minVersion = '1.0.0',
    String latestVersion = '1.0.0',
    String updateUrl = '',
  }) {
    return AppUpdateInfo(
      updateType: UpdateType.none,
      currentVersion: currentVersion,
      minVersion: minVersion,
      latestVersion: latestVersion,
      updateUrl: updateUrl,
    );
  }
}
