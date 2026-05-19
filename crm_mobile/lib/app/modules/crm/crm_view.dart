import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/models/crm_models.dart';
import '../../core/utils/ui_format.dart' show toYmd, formatSalesCardDate, pickDateIntoController, pickDateTimeIntoController;
import '../../shared/widgets/app_error_banner.dart';
import '../../shared/widgets/app_navigation_drawer.dart';
import '../../routes/app_routes.dart';
import '../auth/auth_controller.dart';
import '../../shared/widgets/role_aware_bottom_nav.dart';
import '../../showcase/showcase_widgets.dart';
import 'crm_add_lead_view.dart';
import 'crm_controller.dart';
import 'crm_edit_lead_view.dart';
import 'crm_lead_detail_view.dart';
import 'crm_quote_nav.dart';

Future<void> _openQuickFollowup(
  BuildContext context,
  CrmController controller,
  int leadId,
) async {
  final now = DateTime.now();
  final hh = now.hour.toString().padLeft(2, '0');
  final mm = now.minute.toString().padLeft(2, '0');
  final dateCtrl = TextEditingController(
    text: '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}T$hh:$mm',
  );
  final descCtrl = TextEditingController();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Set Follow-up',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: dateCtrl,
            readOnly: true,
            onTap: () => pickDateTimeIntoController(context: context, controller: dateCtrl),
            decoration: const InputDecoration(
              labelText: 'Due Date & Time',
              suffixIcon: Icon(Icons.calendar_today_rounded),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: descCtrl,
            decoration: const InputDecoration(labelText: 'Description (optional)'),
            minLines: 2,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          Obx(
            () => FilledButton(
              onPressed: controller.isSubmitting.value
                  ? null
                  : () async {
                      if (dateCtrl.text.trim().isEmpty) return;
                      await controller.addFollowup(
                        leadId: leadId,
                        dueDate: dateCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                      );
                      if (context.mounted) Navigator.of(context).pop();
                    },
              child: const Text('Save Follow-up'),
            ),
          ),
        ],
      ),
    ),
  );
}

class CrmView extends GetView<CrmController> {
  const CrmView({super.key});

  static const Color _leadsAppBarBg = Color(0xFF263238);

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      drawer: const AppNavigationDrawer(currentRoute: AppRoutes.crm),
      appBar: AppBar(
        backgroundColor: _leadsAppBarBg,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white, size: 18),
        actionsIconTheme: const IconThemeData(color: Colors.white, size: 18),
        title: Obx(
          () => Text(
            'Leads (${controller.leads.length})',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt_rounded),
            tooltip: 'Lead lists',
            onPressed: () => Get.toNamed(AppRoutes.crmLists),
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Masters',
            onPressed: () => Get.toNamed(AppRoutes.crmMasters),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Source filter',
            onPressed: () => _openSourceFilterSheet(context, controller),
          ),
          IconButton(
            onPressed: () {
              if (controller.selectedStageId.value != null ||
                  controller.selectedSourceId.value != null ||
                  controller.searchQuery.value.trim().isNotEmpty ||
                  (controller.createdFromYmd.value != null &&
                      controller.createdFromYmd.value!.trim().isNotEmpty) ||
                  (controller.createdToYmd.value != null &&
                      controller.createdToYmd.value!.trim().isNotEmpty)) {
                controller.applyFilters();
              } else {
                controller.loadInitial();
              }
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const CrmAddLeadView()),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Lead'),
      ),
      bottomNavigationBar: const RoleAwareBottomNav(currentRoute: AppRoutes.crm),
      body: Column(
        children: [
          Obx(() {
            if (!controller.isSalesManager) return const SizedBox.shrink();
            final scope = auth.crmExecutiveScopeId.value;
            final scheme = Theme.of(context).colorScheme;
            final dark = Theme.of(context).brightness == Brightness.dark;
            return Material(
              color: dark ? const Color(0xFF1B2E3B) : const Color(0xFFE3F2FD),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.groups_2_outlined, size: 20, color: scheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Pipeline',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          isExpanded: true,
                          value: scope,
                          hint: const Text('All leads'),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All leads'),
                            ),
                            ...controller.reportingExecutives.map((e) {
                              final raw = e['id'];
                              final tid = raw is int ? raw : (raw as num).toInt();
                              return DropdownMenuItem<int?>(
                                value: tid,
                                child: Text(e['name']?.toString() ?? 'Executive'),
                              );
                            }),
                          ],
                          onChanged: (v) => controller.setTeamExecutiveFilter(v),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          Obx(() {
            final id = controller.selectedSourceId.value;
            if (id == null) return const SizedBox.shrink();
            var label = 'Filtered list';
            for (final s in controller.sources) {
              if (s.id == id) {
                label = s.name;
                break;
              }
            }
            final filterDark = Theme.of(context).brightness == Brightness.dark;
            return Material(
              color: filterDark ? const Color(0xFF0D2818) : const Color(0xFFE8F5E9),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 18,
                      color: filterDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: filterDark ? const Color(0xFFC8E6C9) : const Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        controller.selectedSourceId.value = null;
                        controller.applyFilters();
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Search leads…',
                    isDense: true,
                  ),
                  onChanged: (v) => controller.searchQuery.value = v,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => controller.applyFilters(),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final from = controller.createdFromYmd.value?.trim();
                  final to = controller.createdToYmd.value?.trim();
                  final has = from != null &&
                      from.isNotEmpty &&
                      to != null &&
                      to.isNotEmpty;
                  final scheme = Theme.of(context).colorScheme;
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickLeadDateRange(context, controller),
                          icon: const Icon(Icons.date_range_rounded, size: 20),
                          label: Text(
                            has ? 'Created $from → $to' : 'Created date…',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ),
                      if (has) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Clear dates',
                          onPressed: controller.clearCreatedDateFilter,
                          icon: Icon(Icons.close_rounded, color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ],
                  );
                }),
                const SizedBox(height: 10),
                const ShowcaseSectionTitle('Stage filters'),
                Obx(() {
                  int? stageIdFor(String keyword) {
                    final k = keyword.toLowerCase();
                    for (final s in controller.stages) {
                      if (s.name.toLowerCase().contains(k)) return s.id;
                    }
                    return null;
                  }

                  int countMatching(bool Function(String st) pred) {
                    return controller.leadsAll.where((l) => pred(l.stage.toLowerCase())).length;
                  }

                  final newId = stageIdFor('new');
                  final proposalId = stageIdFor('proposal');
                  final wonId = stageIdFor('won');
                  final selected = controller.selectedStageId.value;

                  void setStage(int? id) {
                    controller.selectedStageId.value = id;
                    controller.selectedSourceId.value = null;
                    controller.applyFilters();
                  }

                  final allN = controller.leadsAll.length;
                  final newN = countMatching((s) => s.contains('new'));
                  final propN = countMatching((s) => s.contains('proposal'));
                  final wonN = countMatching((s) => s.contains('won'));

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _StagePillChip(
                          label: 'All ($allN)',
                          selected: selected == null,
                          onTap: () => setStage(null),
                        ),
                        const SizedBox(width: 8),
                        _StagePillChip(
                          label: 'New ($newN)',
                          selected: selected != null && selected == newId,
                          onTap: () {
                            if (newId != null) setStage(newId);
                          },
                        ),
                        const SizedBox(width: 8),
                        _StagePillChip(
                          label: 'Proposal ($propN)',
                          selected: selected != null && selected == proposalId,
                          onTap: () {
                            if (proposalId != null) setStage(proposalId);
                          },
                        ),
                        const SizedBox(width: 8),
                        _StagePillChip(
                          label: 'Won ($wonN)',
                          selected: selected != null && selected == wonId,
                          onTap: () {
                            if (wonId != null) setStage(wonId);
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Obx(
              () => AppErrorBanner(
                message: controller.errorMessage.value,
                onRetry: () {
                  if (controller.selectedStageId.value != null ||
                      controller.selectedSourceId.value != null ||
                      controller.searchQuery.value.trim().isNotEmpty ||
                      (controller.createdFromYmd.value != null &&
                          controller.createdFromYmd.value!.trim().isNotEmpty) ||
                      (controller.createdToYmd.value != null &&
                          controller.createdToYmd.value!.trim().isNotEmpty)) {
                    controller.applyFilters();
                  } else {
                    controller.loadInitial();
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.leads.isEmpty) {
                return const Center(child: Text('No leads found'));
              }

              return RefreshIndicator(
                onRefresh: controller.applyFilters,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.leads.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final lead = controller.leads[i];
                    return _LeadCard(
                      lead: lead,
                      onTap: () async {
                        await Get.to(() => CrmLeadDetailView(leadId: lead.id));
                        await controller.applyFilters();
                      },
                      onAfterEdit: () => controller.applyFilters(),
                      onSetFollowup: () => _openQuickFollowup(context, controller, lead.id),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

}

class _LeadCard extends StatelessWidget {
  const _LeadCard({
    required this.lead,
    required this.onTap,
    required this.onAfterEdit,
    required this.onSetFollowup,
  });

  final CrmLead lead;
  final VoidCallback onTap;
  final VoidCallback onAfterEdit;
  final VoidCallback onSetFollowup;

  @override
  Widget build(BuildContext context) {
    final display = lead.displayTitle;
    final sub = lead.displaySubtitle;
    final parts = display.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    final initials = parts.isEmpty
        ? '?'
        : (parts.length == 1
            ? (parts.first.length >= 2 ? parts.first.substring(0, 2) : parts.first.substring(0, 1))
            : (parts[0][0] + parts[1][0])).toUpperCase();
    final hues = [0xFF5C6BC0, 0xFF26A69A, 0xFFEC407A, 0xFFAB47BC, 0xFFFF7043];
    final avatarBg = Color(hues[lead.id.abs() % hues.length]);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dateText = formatSalesCardDate(lead.createdAt.toIso8601String());
    final chipBg = isDark ? const Color(0xFF0D1F2D) : const Color(0xFFE3F2FD);
    final chipFg = isDark ? const Color(0xFF93C5FD) : const Color(0xFF0C447C);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark
              ? const Color(0xFF2A3142)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 11, 8, 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: avatarBg,
                    child: Text(
                      initials,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Name + sub + date chip
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          display,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (sub.isNotEmpty && sub != display) ...[
                          const SizedBox(height: 2),
                          Text(
                            sub,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 11,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 6),
                        // Date chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: chipBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            dateText,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: chipFg),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Stage + priority + score + menu
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ShowcaseStagePill(lead.stage),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert_rounded, size: 20, color: Theme.of(context).hintColor),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            onSelected: (v) async {
                              if (v == 'detail') {
                                onTap();
                              } else if (v == 'edit') {
                                await Get.to(() => CrmEditLeadView(leadId: lead.id));
                                onAfterEdit();
                              } else if (v == 'sales') {
                                await navigateSalesFlowForLead(context, lead);
                              }
                            },
                            itemBuilder: (ctx) => [
                              PopupMenuItem(
                                value: 'detail',
                                child: Row(children: [Icon(Icons.open_in_new_rounded, size: 20, color: Theme.of(ctx).colorScheme.onSurface), const SizedBox(width: 10), const Text('View details')]),
                              ),
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(children: [Icon(Icons.edit_outlined, size: 20, color: Theme.of(ctx).colorScheme.onSurface), const SizedBox(width: 10), const Text('Edit lead')]),
                              ),
                              PopupMenuItem(
                                value: 'sales',
                                child: Row(children: [Icon(Icons.shopping_bag_outlined, size: 20, color: Theme.of(ctx).colorScheme.onSurface), const SizedBox(width: 10), const Text('Sales…')]),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: _priorityDotColor(lead.priority),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(_priorityShort(lead.priority), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              lead.leadScore.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 9),
              // Bottom row: Set follow-up button + assigned name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: onSetFollowup,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A2C3A) : const Color(0xFFEAF4FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E3F5A) : const Color(0xFFBBD8F0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_alarm_rounded, size: 12, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1565C0)),
                          const SizedBox(width: 4),
                          Text(
                            'Set follow-up',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1565C0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            lead.assignedName.isNotEmpty ? lead.assignedName : lead.source,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(Icons.person_outline_rounded, size: 14, color: Colors.blueGrey.shade400),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _pickLeadDateRange(BuildContext context, CrmController c) async {
  final now = DateTime.now();
  DateTimeRange? initial;
  final fromS = c.createdFromYmd.value?.trim();
  final toS = c.createdToYmd.value?.trim();
  if (fromS != null &&
      fromS.isNotEmpty &&
      toS != null &&
      toS.isNotEmpty) {
    try {
      final start = DateTime.parse('${fromS}T12:00:00');
      final end = DateTime.parse('${toS}T12:00:00');
      initial = DateTimeRange(start: start, end: end);
    } catch (_) {}
  }
  final picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime(now.year - 10, 1, 1),
    lastDate: DateTime(now.year + 1, 12, 31),
    initialDateRange: initial,
  );
  if (picked != null) {
    c.createdFromYmd.value = toYmd(picked.start);
    c.createdToYmd.value = toYmd(picked.end);
    await c.applyFilters();
  }
}

void _openSourceFilterSheet(BuildContext context, CrmController c) {
  final items = List<CrmLookupItem>.from(c.sources);
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.clear_all_rounded),
            title: const Text('All sources'),
            onTap: () {
              c.selectedSourceId.value = null;
              c.applyFilters();
              Navigator.pop(ctx);
            },
          ),
          const Divider(height: 1),
          ...items.map(
            (s) => ListTile(
              title: Text(s.name),
              onTap: () {
                c.selectedSourceId.value = s.id;
                c.applyFilters();
                Navigator.pop(ctx);
              },
            ),
          ),
        ],
      ),
    ),
  );
}

String _priorityShort(String p) {
  switch (p) {
    case 'hot':
      return 'HIGH';
    case 'cold':
      return 'LOW';
    default:
      return 'MED';
  }
}

Color _priorityDotColor(String p) {
  switch (p) {
    case 'hot':
      return const Color(0xFF2E7D32);
    case 'cold':
      return const Color(0xFFF9A825);
    default:
      return const Color(0xFF78909C);
  }
}

class _StagePillChip extends StatelessWidget {
  const _StagePillChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedBg = isDark ? const Color(0xFF1A3A5C) : const Color(0xFFE6F1FB);
    final selectedFg = isDark ? const Color(0xFF93C5FD) : const Color(0xFF0C447C);
    const selectedBorder = Color(0xFF185FA5);
    final unselectedBg = scheme.surfaceContainerHighest;
    final unselectedFg = scheme.onSurfaceVariant;
    final unselectedBorder = scheme.outline.withValues(alpha: 0.45);

    return Material(
      color: selected ? selectedBg : unselectedBg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? selectedBorder : unselectedBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? selectedFg : unselectedFg,
            ),
          ),
        ),
      ),
    );
  }
}
