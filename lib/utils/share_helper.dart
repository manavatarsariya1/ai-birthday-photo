import 'package:share_plus/share_plus.dart';

class ShareHelper {
  ShareHelper._();

  static bool _isSharing = false;

  static Future<void> shareText(String text) async {
    if (_isSharing) return;
    _isSharing = true;
    try {
      await SharePlus.instance.share(ShareParams(text: text));
    } finally {
      _isSharing = false;
    }
  }
}
