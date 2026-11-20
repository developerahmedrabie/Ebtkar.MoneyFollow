import 'package:flutter/widgets.dart';

import 'app_localizations.dart';
import 'l10n_lookup.dart';

export 'app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l => AppLocalizations.of(this);

  /// `ar` | `en`.
  String get lang => Localizations.localeOf(this).languageCode;
}

extension L10nKeyX on AppLocalizations {
  /// Text for a key stored in data (`name_key`, `note_key`), or the key.
  String key(String k) => lookupL10nKey(this, k) ?? k;
}
