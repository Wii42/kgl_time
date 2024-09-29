import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kgl_time/kgl_page.dart';
import 'package:kgl_time/work_entries.dart';
import 'package:kgl_time/work_entry.dart';
import 'package:provider/provider.dart';

import 'format_duration.dart';

class NewEntryPage extends KglPage {
  /// The existing entry to edit, or null if a new entry should be created.
  final WorkEntry? existingEntry;
  const NewEntryPage({super.key, required super.appTitle, this.existingEntry});

  @override
  Widget body(BuildContext context) => Consumer<WorkEntries>(
        builder: (context, workEntries, _) => _NewEntryStatefulPage(
          existingEntry: existingEntry,
        ),
      );

  @override
  String get pageTitle =>
      existingEntry == null ? 'Neuer Eintrag' : 'Eintrag bearbeiten';
}

class _NewEntryStatefulPage extends StatefulWidget {
  final WorkEntry? existingEntry;
  const _NewEntryStatefulPage({super.key, required this.existingEntry});

  @override
  _NewEntryStatefulPageState createState() => _NewEntryStatefulPageState();
}

class _NewEntryStatefulPageState extends State<_NewEntryStatefulPage> {
  final _formKey = GlobalKey<FormState>();

  late List<bool> categorySelection;
  late DateTime selectedDate;
  late TextEditingController dateController;
  late TextEditingController durationController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    categorySelection = List.generate(WorkCategory.values.length, (int index) {
      if (widget.existingEntry == null) return false;
      return widget.existingEntry!.categories
          .contains(WorkCategory.values[index]);
    });
    selectedDate = widget.existingEntry?.date ?? DateTime.now();
    dateController = TextEditingController(text: formatDate(selectedDate));
    durationController = TextEditingController(
        text: widget.existingEntry?.workDuration.inMinutes.toString() ?? '');
    descriptionController =
        TextEditingController(text: widget.existingEntry?.description ?? '');
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextFormField(
              controller: durationController,
              style: textTheme.displaySmall,
              autofocus: true,
              decoration: InputDecoration(
                  labelText: 'Arbeitsdauer',
                  labelStyle: textTheme.bodyLarge,
                  suffixText: 'min'),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte geben Sie eine Dauer ein. Nur Ziffern erlaubt';
                }
                return null;
              },
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
                //locale: Locale('de', 'DE'),
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
        ],
      ),
    );
  }

  void saveEntry(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      WorkEntry newEntry = WorkEntry(
        workDuration: Duration(minutes: int.parse(durationController.text)),
        date: selectedDate,
        categories: [
          for (int i = 0; i < WorkCategory.values.length; i++)
            if (categorySelection[i]) WorkCategory.values[i]
        ],
        description: descriptionController.text,
        id: widget.existingEntry?.id ?? UniqueKey().hashCode,
        startTime: widget.existingEntry?.startTime,
        endTime: widget.existingEntry?.endTime,
      );
      WorkEntries workEntries = context.read<WorkEntries>();
      if (widget.existingEntry != null) {
        workEntries.updateEntry(widget.existingEntry!,
            newEntry..startTime = widget.existingEntry!.startTime);
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
      for (WorkCategory category in WorkCategory.values)
        ChoiceChip(
          label: Text(category.displayName),
          selected: categorySelection[category.index],
          onSelected: (selected) {
            setState(() {
              categorySelection[category.index] = selected;
            });
          },
        ),
    ];
  }

  @override
  void dispose() {
    dateController.dispose();
    durationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
