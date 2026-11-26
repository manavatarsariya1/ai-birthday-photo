// ============================================================
// config_packages.dart — Central Barrel Export
// ============================================================
// Single import for all files:  import 'config_packages.dart';
// ============================================================

// --- Dart Core ---
export 'dart:async';
export 'dart:convert';
export 'dart:io' hide HeaderValue;

// --- Flutter ---
export 'package:flutter/foundation.dart';
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';

// --- State Management ---
export 'package:get/get.dart';

// --- Storage ---
export 'package:shared_preferences/shared_preferences.dart';

// --- UI / Design ---
export 'package:flutter_svg/svg.dart';
export 'package:shimmer/shimmer.dart';
export 'package:cached_network_image/cached_network_image.dart';
export 'package:dropdown_button2/dropdown_button2.dart';
export 'package:flutter_screenutil/flutter_screenutil.dart';

// --- Media ---
export 'package:image_picker/image_picker.dart';

// --- Network ---
export 'package:connectivity_plus/connectivity_plus.dart';
export 'package:internet_connection_checker/internet_connection_checker.dart';

// --- Permissions / Device ---
export 'package:permission_handler/permission_handler.dart';
export 'package:device_info_plus/device_info_plus.dart';

// --- Sharing / Reviews ---
export 'package:share_plus/share_plus.dart';
export 'package:in_app_review/in_app_review.dart';

// --- Firebase (uncomment when adding Firebase to a project) ---
// export 'package:firebase_core/firebase_core.dart';
// export 'package:firebase_crashlytics/firebase_crashlytics.dart';
// export 'package:firebase_analytics/firebase_analytics.dart';
// export 'package:firebase_messaging/firebase_messaging.dart';

// ============================================================
// App — Theme & Constants
// ============================================================
export '../theme/app_colors.dart';
export '../theme/text_styles.dart';
export '../constant/app_assets.dart';
export '../constant/app_strings.dart';
export '../constant/app_constant.dart';
export '../constant/font_sizes.dart';

// ============================================================
// App — Utils / Common Widgets
// ============================================================
export '../utils/pref_service.dart';
export '../utils/app_functions.dart';
export '../utils/app_validators.dart';
export '../utils/app_toast.dart';

export '../utils/common_text.dart';
export '../utils/common_image.dart';
export '../utils/common_svg_image.dart';
export '../utils/common_circular_svg.dart';
export '../utils/common_switch.dart';
export '../utils/common_textfield.dart';
export '../utils/common_dropdown.dart';
export '../utils/common_loader.dart';
export '../utils/common_no_data.dart';
export '../utils/common_appbar.dart';
export '../utils/common_widgets.dart';
export '../utils/common_button.dart';
export '../utils/exit_bottom_sheet.dart';
export '../utils/status_bar_wrapper.dart';
export '../utils/loading_overlay.dart';
export '../utils/common_autoplay_video.dart';

// ============================================================
// App — Services
// ============================================================
export '../services/log_event_manager.dart';
