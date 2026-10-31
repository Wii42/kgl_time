import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:clock/clock.dart';
import 'package:kgl_time/data_model/key_values.dart';
import 'package:kgl_time/data_model/work_categories.dart';
import 'package:kgl_time/data_model/work_entries.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/kgl_time_app.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/select_category_dialog.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:timer_builder/timer_builder.dart';

import 'data_model/work_category.dart';

class WorkEntryTimeTracker extends StatelessWidget {
  static const String _storageKey = 'timeTrackerStart';

  const WorkEntryTimeTracker({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime? startTime = context.select<KeyValues, DateTime?>(
      (keyValues) => keyValues.get<DateTime?>(_storageKey),
    );
    bool isTrackingTime = startTime != null;

    double height = 50;
    double borderWidth = 1.5;

    Color indicatorColor(bool isTracking) =>
        isTracking ? KglTimeApp.actionColor : KglTimeApp.primaryColor;

    AppLocalizations? loc = AppLocalizations.of(context);
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            // Bridge theme data, as animated_toggle_switch does not yet use material_ui
            child: MaterialUiCompatibilityBridge(
              child: LayoutBuilder(
                // Force the toggle switch to rebuild on width change, so that the indicator size is updated
                builder: (context, _) {
                  return AnimatedToggleSwitch<bool>.dual(
                    first: false,
                    second: true,
                    current: isTrackingTime,
                    textBuilder: (isTracking) => isTracking
                        ? TimerBuilder.periodic(
                            Duration(seconds: 10),
                            builder: (context) => Row(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton.filledTonal(
                                  onPressed: () =>
                                      SelectCategoryDialog.showSelectCategoryDialog(context),
                                  icon: Icon(
                                    Icons.category,
                                  ),
                                  tooltip: loc?.selectCategory,
                                ),
                                Text(
                                  loc?.runningForDuration(
                                        _trackTime(startTime ?? clock.now()),
                                      ) ??
                                      '<runningForDuration>',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                SizedBox(),
                              ],
                            ),
                          )
                        : Text(
                            loc?.trackTime ?? '<trackTime>',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                    iconBuilder: (isTracking) => Text(
                      (isTracking ? loc?.stop : loc?.start) ?? '<start/stop>',
                      style: Theme.of(context).textTheme.bodyLarge?.apply(color: Colors.white),
                    ),
                    onChanged: (isTracking) {
                      KeyValues keyValues = context.read<KeyValues>();
                      if (isTracking) {
                        keyValues.set<DateTime>(_storageKey, clock.now());
                      } else {
                        keyValues.remove(_storageKey);
                        String? serializedCategories = keyValues.get<String>(
                          SelectCategoryDialog.storageKey,
                        );
                        List<WorkCategory> selectedCategories = [];
                        if (serializedCategories != null) {
                          selectedCategories = SelectCategoryDialog.deserializeCategories(
                            serializedCategories,
                            context.read<WorkCategories>().entries,
                          );
                        }
                        keyValues.remove(SelectCategoryDialog.storageKey);
                        context.read<WorkEntries>().add(
                          WorkEntry.fromStartAndEndTime(
                            startTime: startTime!,
                            endTime: clock.now(),
                            categories: selectedCategories.map((e) => e.toEmbedded()).toList(),
                            createType: CreateWorkEntryType.timeTracker,
                          ),
                        );
                      }
                    },
                    height: height,
                    borderWidth: borderWidth,
                    indicatorSize: Size.fromWidth(height - 2 * borderWidth),
                    styleBuilder: (isTracking) => ToggleStyle(
                      indicatorColor: indicatorColor(isTracking),
                      borderColor: indicatorColor(isTracking),
                      indicatorBorder: Border.all(
                        width: 6,
                        strokeAlign: BorderSide.strokeAlignOutside - 0.1,
                        color: indicatorColor(isTracking),
                      ),
                    ),
                    clipBehavior: Clip.none,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _trackTime(DateTime startTime) {
    int hours = clock.now().difference(startTime).inHours;
    int minutes = clock.now().difference(startTime).inMinutes % Duration.minutesPerHour;
    return [if (hours > 0) "${hours}h", "$minutes min"].join(" ");
  }
}
