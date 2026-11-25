import 'package:get/get.dart';

import 'languages/english.dart' as english;
import 'languages/hindi.dart' as hindi;
import 'languages/spanish.dart' as spanish;
import 'languages/french.dart' as french;
import 'languages/german.dart' as german;
import 'languages/arabic.dart' as arabic;
import 'languages/russian.dart' as russian;
import 'languages/korean.dart' as korean;
import 'languages/vietnamese.dart' as vietnamese;
import 'languages/filipino.dart' as filipino;

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': english.en,
        'hi': hindi.hi,
        'es': spanish.es,
        'fr': french.fr,
        'de': german.de,
        'ar': arabic.ar,
        'ru': russian.ru,
        'ko': korean.ko,
        'vi': vietnamese.vi,
        'fil': filipino.fil,
      };
}
