import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kgl_time/data_model/work_categories.dart';
import 'package:kgl_time/data_model/work_entries.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/format_duration.dart';
import 'package:kgl_time/pages/kgl_page.dart';
import 'package:provider/provider.dart';

class NewEntryPage extends KglPage {
  /// The existing entry to edit, or null if a new entry should be created.
  final WorkEntry? existingEntry;
  const NewEntryPage({super.key, required super.appTitle, this.existingEntry});

  @override
  Widget body(BuildContext context) => Consumer<WorkCategories>(
        /// TODO: Check if WorkEntries is needed here
        builder: (context, workCategories, _) => Consumer<WorkEntries>(
          builder: (context, workEntries, _) => _NewEntryStatefulPage(
            existingEntry: existingEntry,
            categories: List.of(workCategories.entries)
              ..addAll(existingEntry?.categories
                      .where((element) =>
                          !workCategories.entries.contains(element))
                      .map((e) => e.toWorkCategory()) ??
                  []),
            key: key,
          ),
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

  late List<bool> categorySelection;
  late DateTime selectedDate;
  late TextEditingController dateController;
  late TextEditingController durationMinuteController;
  late TextEditingController durationHourController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    categorySelection = [
      for (WorkCategory category in widget.categories)
        if (widget.existingEntry == null)
          false
        else
          widget.existingEntry!.categories
              .any((element) => element.id == category.id)
    ];

    selectedDate = widget.existingEntry?.date ?? DateTime.now();
    dateController = TextEditingController(text: formatDate(selectedDate));
    Duration? workDuration = widget.existingEntry?.workDuration;
    durationMinuteController = TextEditingController(
        text: workDuration != null ?(workDuration.inMinutes % Duration.minutesPerHour).toString() : '');
    String workHours = workDuration?.inHours.toString() ?? '';
    durationHourController = TextEditingController(
        text: workHours != '0' ? workHours : '');
    descriptionController =
        TextEditingController(text: widget.existingEntry?.description ?? '');
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Form(
      key: _formKey,
      child: KglPage.alwaysFillingScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(),
              Padding(
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
                                suffixText: 'h'),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            keyboardType: TextInputType.number,
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
                                suffixText: 'min'),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Bitte geben Sie eine Dauer ein.\nNur Ziffern erlaubt';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _buildCategoryChips(context),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Beschreibung',
                ),
                maxLines: 1,
                maxLengthEnforcement:
                    MaxLengthEnforcement.truncateAfterCompositionEnds,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'Datum',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? newDate = await showDatePicker(
                    //locale: Locale('de'),
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
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  void saveEntry(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      int hours = durationHourController.text.isNotEmpty
          ? int.parse(durationHourController.text)
          : 0;
      WorkEntry newEntry = WorkEntry(
        workDurationInSeconds:
            Duration(hours: hours, minutes: int.parse(durationMinuteController.text)).inSeconds,
        date: selectedDate,
        categories: [
          for (int i = 0; i < widget.categories.length; i++)
            if (categorySelection[i]) widget.categories[i].toEmbedded()
        ],
        description: descriptionController.text,
        startTime: widget.existingEntry?.startTime,
        endTime: widget.existingEntry?.endTime,
        lastEdit: DateTime.now(),
        tickedOff: widget.existingEntry?.tickedOff ?? false,
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

  List<Widget> _buildCategoryChips(BuildContext context) {
    return [
      for ((int index, IWorkCategory category) element
          in widget.categories.indexed)
        ChoiceChip(
          //avatar: category.icon != null? Icon(category.icon): null,
          label: Text(element.$2.displayName),
          selected: categorySelection[element.$1],
          onSelected: (selected) {
            setState(() {
              categorySelection[element.$1] = selected;
            });
          },
        ),
    ];
  }

  @override
  void dispose() {
    dateController.dispose();
    durationMinuteController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
