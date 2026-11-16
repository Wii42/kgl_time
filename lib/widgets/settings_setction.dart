import 'package:kgl_time/utils/helpers.dart';
import 'package:material_ui/material_ui.dart';

class SettingsSection extends StatelessWidget {
  final String sectionTitle;
  final List<Widget> children;
  final bool addDividerBetweenChildren;

  final Widget divider = const Divider(height: 1, indent: 56, endIndent: 16);

  const new({
    super.key,
    required this.sectionTitle,
    required this.children,
    this.addDividerBetweenChildren = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            sectionTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: addDividerBetweenChildren ? children.withWidgetBetween(divider) : children,
          ),
        ),
      ],
    );
  }
}
