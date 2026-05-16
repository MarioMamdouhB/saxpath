class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    // Mocked for Windows stability
  }

  Future<void> scheduleDailyReminder(int hour, int minute) async {
    // Mocked for Windows stability
  }
}
