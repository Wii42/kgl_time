import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kgl_time/data_model/work_categories.dart';
import 'package:kgl_time/data_model/work_entries.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/format_duration.dart';
import 'package:kgl_time/pages/kgl_page.dart';
import 'package:kgl_time/popup_dialog.dart';
import 'package:provider/provider.dart';

import '../kgl_time_app.dart';

class NewEntryPage extends KglPage {
  /// The existing entry to edit, or null if a new entry should be created.
  final WorkEntry? existingEntry;
  const NewEntryPage({super.key, required super.appTitle, this.existingEntry});

  @override
  Widget body(BuildContext context) => Consumer<WorkCategories>(
        builder: (context, workCategories, _) => _NewEntryStatefulPage(
          existingEntry: existingEntry,
          categories: List.of(workCategories.entries)
            ..addAll(existingEntry?.categories
                    .where((element) =>
                        workCategories.entries.every((e) => e.id != element.id))
                    .map((e) => e.toWorkCategory()) ??
                []),
          key: key,
        ),
      );

  @override
  String get pageTitle =>
      existingEntry == null ? 'Neuer Eintrag' : 'Eintrag bearbeiten';
}

class _NewEntryStatefulPage extends StatefulWidget {
  final WorkEntry? existingEntry;
  final List<WorkCategory> categories;
  const _NewEntryStatefulPage(
      {super.key, required this.existingEntry, required this.categories});

  @override
  _NewEntryStatefulPageState createState() => _NewEntryStatefulPageState();
}

class _NewEntryStatefulPageState extends State<_NewEntryStatefulPage> {
  final _formKey = GlobalKey<FormState>();

  late Map<WorkCategory, bool> categorySelection;
  late DateTime selectedDate;
  late TextEditingController dateController;
  late TextEditingController durationMinuteController;
  late TextEditingController durationHourController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    categorySelection = Map.fromIterable(widget.categories, value: (category) {
      if (widget.existingEntry == null) {
        return false;
      } else {
        return widget.existingEntry!.categories
            .any((element) => element.id == category.id);
      }
    });

    selectedDate = widget.existingEntry?.date ?? DateTime.now();
    dateController = TextEditingController(text: formatDate(selectedDate));
    Duration? workDuration = widget.existingEntry?.workDuration;
    durationMinuteController = TextEditingController(
        text: workDuration != null
            ? (workDuration.inMinutes % Duration.minutesPerHour).toString()
            : '');
    String workHours = workDuration?.inHours.toString() ?? '';
    durationHourController =
        TextEditingController(text: workHours != '0' ? workHours : '');
    descriptionController =
        TextEditingController(text: widget.existingEntry?.description ?? '');
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Form(
      key: _formKey,
      child: KglPage.alwaysFillingScrollView(
        maxWidth: KglTimeApp.maxPageWidth,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(),
              workDurationField(textTheme),
              SizedBox(height: 16),
              SelectCategoriesWidget(
                  categories: categorySelection,
                  onSelectedCategoriesChanged: (selected) {
                    setState(() {
                      categorySelection = selected;
                    });
                  }),
              SizedBox(height: 16),
              descriptionField(),
              SizedBox(height: 16),
              selectDateWidget(context),
              SizedBox(height: 16),
              bottomButtons(),
              SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  Widget workDurationField(TextTheme textTheme) {
    int errorMaxLines = 5;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Text('Arbeitsdauer', style: textTheme.bodyLarge),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 2,
                child: TextFormField(
                  controller: durationHourController,
                  style: textTheme.displaySmall,
                  decoration: InputDecoration(
                      labelText: 'Stunden',
                      suffixText: 'h',
                      errorMaxLines: errorMaxLines),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  validator: (value) => _intValidator(value,
                      factor: Duration.secondsPerHour,
                      otherValue: durationMinuteController.text),
                ),
              ),
              SizedBox(width: 8),
              Flexible(
                flex: 4,
                child: TextFormField(
                  controller: durationMinuteController,
                  style: textTheme.displaySmall,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: 'Minuten',
                      suffixText: 'min',
                      errorMaxLines: errorMaxLines),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte geben Sie eine Dauer ein.\nNur Ziffern erlaubt';
                    }

                    return _intValidator(value,
                        factor: Duration.secondsPerMinute,
                        otherValue: durationHourController.text);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget descriptionField() {
    return TextFormField(
      controller: descriptionController,
      decoration: InputDecoration(
        labelText: 'Beschreibung',
      ),
      maxLines: 1,
      maxLengthEnforcement: MaxLengthEnforcement.truncateAfterCompositionEnds,
    );
  }

  Widget selectDateWidget(BuildContext context) {
    return TextFormField(
      controller: dateController,
      decoration: InputDecoration(
        labelText: 'Datum',
        prefixIcon: Icon(Icons.calendar_today),
      ),
      readOnly: true,
      onTap: () async {
        DateTime? newDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (newDate != null) {
          setState(() {
            selectedDate = newDate;
            dateController.text = formatDate(selectedDate);
          });
        }
      },
    );
  }

  Widget bottomButtons() {
    return LayoutBuilder(builder: (context, constraints) {
      return ConstrainedBox(
        constraints: BoxConstraints(minWidth: constraints.maxWidth),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 8,
          spacing: 8,
          runAlignment: WrapAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  context.pop();
                },
                child: Text('Abbrechen')),
            FilledButton(
                onPressed: () {
                  saveEntry(context);
                },
                child: Text('Speichern'))
          ],
        ),
      );
    });
  }

  void saveEntry(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      int hours = durationHourController.text.isNotEmpty
          ? int.parse(durationHourController.text)
          : 0;
      WorkEntry newEntry = WorkEntry(
        workDurationInSeconds: Duration(
                hours: hours, minutes: int.parse(durationMinuteController.text))
            .inSeconds,
        date: selectedDate,
        categories: categorySelection.entries
            .where((element) => element.value)
            .map((e) => e.key.toEmbedded())
            .toList(),
        description: descriptionController.text,
        startTime: widget.existingEntry?.startTime,
        endTime: widget.existingEntry?.endTime,
        lastEdit: DateTime.now(),
        tickedOff: widget.existingEntry?.tickedOff ?? false,
        createType: widget.existingEntry != null
            ? widget.existingEntry!.createType
            : CreateWorkEntryType.manualDuration,
        wasEdited: widget.existingEntry != null,
      );
      WorkEntries workEntries = context.read<WorkEntries>();
      if (widget.existingEntry != null) {
        workEntries.updateEntry(
            widget.existingEntry!,
            newEntry
              ..startTime = widget.existingEntry!.startTime
              ..id = widget.existingEntry!.id);
      } else {
        workEntries.add(newEntry);
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Eintrag gespeichert'),
      ));
      context.pop();
    }
  }

  @override
  void dispose() {
    dateController.dispose();
    durationMinuteController.dispose();
    descriptionController.dispose();
    durationHourController.dispose();
    super.dispose();
  }

  String? _intValidator(String? value, {int factor = 1, String? otherValue}) {
    const int maxSaveValue = 4294967296; // 2^32

    if (value == null || value.isEmpty) {
      return null;
    }
    int parsedValue;
    try {
      parsedValue = int.parse(value);
      //print('Parsed number: $result');
    } catch (e) {
      if (e is FormatException) {
        return 'Eingegebener Wert ist zu gross oder keine ganze Zahl';
      } else {
        return 'Unerwarteter Fehler: $e';
      }
    }

    //print('number of binary digits: ${log(parsedValue) / log(2)}');
    if (parsedValue > (maxSaveValue / factor)) {
      return 'Eingegebener Wert ist zu gross';
    }

    if (otherValue != null) {
      int? otherInt = int.tryParse(otherValue);
      if (otherInt != null) {
        if (parsedValue > ((maxSaveValue / factor) - otherInt)) {
          return 'Summe der beiden Werte ist zu gross';
        }
      }
    }
    if (parsedValue * factor < 0) {
      return 'Eingegebener Wert ist ungültig';
    }

    return null;
  }
}
