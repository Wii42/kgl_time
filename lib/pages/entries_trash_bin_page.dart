import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:kgl_time/pages/kgl_page.dart';
import 'package:kgl_time/width_constrained_list_view.dart';
import 'package:kgl_time/work_entry_widgets/trashed_work_entry.dart';
import 'package:provider/provider.dart';

import '../data_model/work_entries.dart';
import '../data_model/work_entry.dart';
import '../l10n/generated/app_localizations.dart';

class EntriesTrashBinPage extends KglPage {
  const EntriesTrashBinPage({super.key, required super.appTitle});

  @override
  Widget body(BuildContext context) {
    List<WorkEntry> trashedEntries =
        context.select<WorkEntries, List<WorkEntry>>(
      (workEntries) => workEntries.entriesInTrash,
    );
    return AnimatedWidthConstrainedListView<WorkEntry>(
      items: trashedEntries,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemBuilder: (context, animation, entry, index) => SizeFadeTransition(
          animation: animation,
          axis: Axis.vertical,
          child: TrashedWorkEntry(workEntry: entry)),
      areItemsTheSame: (WorkEntry oldItem, WorkEntry newItem) {
        return oldItem.id == newItem.id;
      },
      removeItemBuilder: (context, animation, entry) => SizeFadeTransition(
          animation: animation,
          axis: Axis.vertical,
          child: TrashedWorkEntry(workEntry: entry)),
    );
  }

  @override
  String? pageTitle(AppLocalizations? loc) {
    return loc?.trashBin;
  }
}
