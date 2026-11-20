import 'forecast.dart';
import 'occasions.dart';

/// Feeds occasion predictions into the forecast: each enabled occasion is
/// counted in the month where it starts (FR-030, REQUIREMENTS §6.2).
class ServiceOccasionPredictor implements OccasionPredictor {
  const ServiceOccasionPredictor(this.service);
  final OccasionService service;

  @override
  List<(String, int)> occasionsIn(String ym, String? memberKey) => [
        for (final key in service.enabledKeys)
          for (final d in service.dates(key))
            if (d.startsWith(ym))
              (key, service.predict(key, memberKey: memberKey).total),
      ];
}
