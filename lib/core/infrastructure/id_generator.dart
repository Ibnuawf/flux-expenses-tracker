import 'package:uuid/uuid.dart';

class IdGenerator {
  String v4() => const Uuid().v4();
}
