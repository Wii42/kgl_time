import 'package:kgl_time/widgets/work_entries/work_entry_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../data_model/work_entries.dart';
import '../../l10n/generated/app_localizations.dart';
import 'work_entry_details_content.dart';

class TrashedWorkEntry extends WorkEntryWidget {
  const TrashedWorkEntry({super.key, required super.workEntry});

  @override
  Widget details(BuildContext context) => WorkEntryDetailsContent(workEntry: workEntry);

  @override
  Axis get rightSideButtonsAxis => Axis.vertical;

  @override
  List<Widget> rightSideButtons(BuildContext context) {
    final AppLocalizations? loc = AppLocalizations.of(context);
    return <Widget>[TextButton.icon(
      onPressed: () {
        final WorkEntries entries = context.read<WorkEntries>();
        entries.restoreFromTrashBin(workEntry);
      },
      icon: const Icon(Icons.restore_from_trash_outlined),
      label: Text(loc?.restoreEntry ?? '<Restore>'),
    )
    ];
  }
}
