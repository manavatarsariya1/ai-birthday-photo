import 'package:get/get.dart';

import 'languages/english.dart' as english;
import 'languages/hindi.dart' as hindi;
import 'languages/bengali.dart' as bengali;
import 'languages/gujarati.dart' as gujarati;
import 'languages/marathi.dart' as marathi;
import 'languages/tamil.dart' as tamil;
import 'languages/telugu.dart' as telugu;
import 'languages/kannada.dart' as kannada;
import 'languages/malayalam.dart' as malayalam;
import 'languages/punjabi.dart' as punjabi;
import 'languages/french.dart' as french;
import 'languages/spanish.dart' as spanish;
import 'languages/chinese.dart' as chinese;
import 'languages/portuguese_portugal.dart' as portuguese_portugal;
import 'languages/russian.dart' as russian;
import 'languages/indonesian.dart' as indonesian;
import 'languages/filipino.dart' as filipino;
import 'languages/portuguese_brazil.dart' as portuguese_brazil;
import 'languages/afrikaans.dart' as afrikaans;
import 'languages/german.dart' as german;
import 'languages/korean.dart' as korean;
import 'languages/dutch.dart' as dutch;
import 'languages/arabic.dart' as arabic;
import 'languages/japanese.dart' as japanese;
import 'languages/uzbek.dart' as uzbek;
import 'languages/malay.dart' as malay;
import 'languages/turkish.dart' as turkish;
import 'languages/kazakh.dart' as kazakh;
import 'languages/polish.dart' as polish;
import 'languages/thai.dart' as thai;
import 'languages/bulgarian.dart' as bulgarian;
import 'languages/italian.dart' as italian;
import 'languages/ukrainian.dart' as ukrainian;
import 'languages/nepali.dart' as nepali;
import 'languages/vietnamese.dart' as vietnamese;

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': english.en,
        'hi': hindi.hi,
        'bn': bengali.bn,
        'gu': gujarati.gu,
        'mr': marathi.mr,
        'ta': tamil.ta,
        'te': telugu.te,
        'kn': kannada.kn,
        'ml': malayalam.ml,
        'pa': punjabi.pa,
        'fr': french.fr,
        'es': spanish.es,
        'zh': chinese.zh,
        'pt_PT': portuguese_portugal.ptPT,
        'ru': russian.ru,
        'id': indonesian.id,
        'fil': filipino.fil,
        'pt_BR': portuguese_brazil.ptBR,
        'af': afrikaans.af,
        'de': german.de,
        'ko': korean.ko,
        'nl': dutch.nl,
        'ar': arabic.ar,
        'ja': japanese.ja,
        'uz': uzbek.uz,
        'ms': malay.ms,
        'tr': turkish.tr,
        'kk': kazakh.kk,
        'pl': polish.pl,
        'th': thai.th,
        'bg': bulgarian.bg,
        'it': italian.it,
        'uk': ukrainian.uk,
        'ne': nepali.ne,
        'vi': vietnamese.vi,
      };
}
