import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../routes/app_routes.dart';
import '../../shared/widgets/app_navigation_drawer.dart';
import 'reminders_controller.dart';

const _bucketOrder = [
  ReminderBucket.overdue,
  ReminderBucket.today,
  ReminderBucket.tomorrow,
  ReminderBucket.week,
  ReminderBucket.later,
];

Color _bucketColor(ReminderBucket b, bool isDark) {
  switch (b) {
    case ReminderBucket.overdue:  return isDark ? const Color(0xFFE57373) : const Color(0xFFD32F2F);
    case ReminderBucket.today:    return isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100);
    case ReminderBucket.tomorrow: return isDark ? const Color(0xFF64B5F6) : const Color(0xFF1565C0);
    case ReminderBucket.week:     return isDark ? const Color(0xFFB0BEC5) : const Color(0xFF546E7A);
    case ReminderBucket.later:    return isDark ? const Color(0xFF78909C) : const Color(0xFF78909C);
  }
}

Color _bucketBg(ReminderBucket b, bool isDark) {
  switch (b) {
    case ReminderBucket.overdue:  return isDark ? const Color(0xFF2D1515) : const Color(0xFFFFF0F0);
    case ReminderBucket.today:    return isDark ? const Color(0xFF2D2010) : const Color(0xFFFFF8F0);
    case ReminderBucket.tomorrow: return isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF0F5FF);
    case ReminderBucket.week:
    case ReminderBucket.later:    return isDark ? const Color(0xFF1A1D2E) : Colors.white;
  }
}

class RemindersView extends GetView<RemindersController> {
  const RemindersView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const AppNavigationDrawer(currentRoute: AppRoutes.reminders),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              title: const Text('Reminders', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              iconTheme: const IconThemeData(color: Colors.white, size: 18),
              actionsIconTheme: const IconThemeData(color: Colors.white, size: 18),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: controller.load,
                  tooltip: 'Refresh',
                ),
              ],
            ),
            Obx(() {
              if (controller.isLoading.value) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (controller.errorMessage.value.isNotEmpty) {
                return SliverFillRemaining(
                  child: Center(child: Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red))),
                );
              }
              final grouped = controller.grouped;
              final hasAny = _bucketOrder.any((b) => (grouped[b] ?? []).isNotEmpty);
              if (!hasAny) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text('No upcoming reminders', style: TextStyle(color: Colors.grey)),
                  ),
                );
              }

              final sliversContent = <Widget>[];
              for (final bucket in _bucketOrder) {
                final bucketItems = grouped[bucket] ?? [];
                if (bucketItems.isEmpty) continue;
                sliversContent.add(_SectionHeader(
                  label: '${bucket.label} · ${bucketItems.length}',
                  color: _bucketColor(bucket, isDark),
                ));
                for (final item in bucketItems) {
                  sliversContent.add(_ReminderCard(
                    item: item,
                    bucket: bucket,
                    isDark: isDark,
                    bgColor: _bucketBg(bucket, isDark),
                    labelColor: _bucketColor(bucket, isDark),
                    onDone: () => controller.markDone(item),
                  ));
                }
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(sliversContent),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionHeader({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color, letterSpacing: 1.2),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final ReminderItem item;
  final ReminderBucket bucket;
  final bool isDark;
  final Color bgColor;
  final Color labelColor;
  final VoidCallback onDone;

  const _ReminderCard({
    required this.item,
    required this.bucket,
    required this.isDark,
    required this.bgColor,
    required this.labelColor,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final dueFmt = item.dueDate != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(item.dueDate!)
        : '—';

    return GestureDetector(
      onTap: () => Get.toNamed('/lead/${item.leadId}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: bucket == ReminderBucket.overdue
                ? labelColor.withValues(alpha: 0.4)
                : isDark ? const Color(0xFF2D3350) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.leadName + (item.leadCompany != null ? ' · ${item.leadCompany}' : ''),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.description,
                      style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 12, color: labelColor),
                        const SizedBox(width: 4),
                        Text(dueFmt, style: TextStyle(fontSize: 11, color: labelColor, fontWeight: FontWeight.w500)),
                        if (item.assignedName != null) ...[
                          const SizedBox(width: 10),
                          Icon(Icons.person_outline_rounded, size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 3),
                          Text(item.assignedName!, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        ],
                      ],
                    ),
                    if (item.leadStage != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2D3350) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(item.leadStage!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onDone,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
