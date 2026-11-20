import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// A new time-ordered UUID v7 (data-model "Conventions").
String newId() => _uuid.v7();
