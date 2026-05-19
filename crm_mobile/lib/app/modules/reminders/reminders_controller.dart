import 'package:get/get.dart';

import '../auth/auth_controller.dart';
import '../../core/network/error_utils.dart';

class ReminderItem {
  final int id;
  final int leadId;
  final String leadName;
  final String? leadCompany;
  final String? leadStage;
  final String description;
  final DateTime? dueDate;
  final String? assignedName;

  ReminderItem({
    required this.id,
    required this.leadId,
    required this.leadName,
    this.leadCompany,
    this.leadStage,
    required this.description,
    this.dueDate,
    this.assignedName,
  });

  factory ReminderItem.fromJson(Map<String, dynamic> j) {
    DateTime? due;
    final raw = j['due_date'];
    if (raw != null) due = DateTime.tryParse(raw.toString())?.toLocal();
    return ReminderItem(
      id: int.tryParse(j['id'].toString()) ?? 0,
      leadId: int.tryParse(j['lead_id'].toString()) ?? 0,
      leadName: j['lead_name']?.toString() ?? 'Lead',
      leadCompany: j['lead_company']?.toString(),
      leadStage: j['lead_stage']?.toString(),
      description: j['description']?.toString() ?? 'Follow up',
      dueDate: due,
      assignedName: j['assigned_name']?.toString(),
    );
  }
}

enum ReminderBucket { overdue, today, tomorrow, week, later }

extension ReminderBucketExt on ReminderBucket {
  String get label {
    switch (this) {
      case ReminderBucket.overdue:  return 'Overdue';
      case ReminderBucket.today:    return 'Today';
      case ReminderBucket.tomorrow: return 'Tomorrow';
      case ReminderBucket.week:     return 'This Week';
      case ReminderBucket.later:    return 'Later';
    }
  }
}

ReminderBucket _bucket(DateTime? due) {
  if (due == null) return ReminderBucket.later;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final dayAfter = tomorrow.add(const Duration(days: 1));
  final weekEnd = today.add(const Duration(days: 7));
  if (due.isBefore(today)) return ReminderBucket.overdue;
  if (due.isBefore(tomorrow)) return ReminderBucket.today;
  if (due.isBefore(dayAfter)) return ReminderBucket.tomorrow;
  if (due.isBefore(weekEnd)) return ReminderBucket.week;
  return ReminderBucket.later;
}

class RemindersController extends GetxController {
  final AuthController _auth = Get.find<AuthController>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final items = <ReminderItem>[].obs;

  Map<ReminderBucket, List<ReminderItem>> get grouped {
    final map = <ReminderBucket, List<ReminderItem>>{};
    for (final b in ReminderBucket.values) {
      map[b] = items.where((i) => _bucket(i.dueDate) == b).toList();
    }
    return map;
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await _auth.authorizedRequest(method: 'GET', path: '/crm/leads/followups');
      items.assignAll(
        (res as List).map((e) => ReminderItem.fromJson(Map<String, dynamic>.from(e as Map))),
      );
    } catch (e) {
      errorMessage.value = userFriendlyError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markDone(ReminderItem item) async {
    try {
      await _auth.authorizedRequest(
        method: 'PATCH',
        path: '/crm/leads/${item.leadId}/followups/${item.id}/done',
      );
      items.remove(item);
    } catch (e) {
      errorMessage.value = userFriendlyError(e);
    }
  }
}
