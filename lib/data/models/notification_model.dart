import 'package:isar/isar.dart';

part 'notification_model.g.dart';

@collection
class NotificationModel {
  Id id = Isar.autoIncrement;

  late String title;
  late String message;
  late DateTime timestamp;

  @Index()
  bool isRead = false;

  late String icon; // e.g., '👋', '💰', '📉'
  bool isPinned = false;
  String actionType = 'none';
}
