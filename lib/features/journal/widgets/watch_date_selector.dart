import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:movie_journal/l10n/app_localizations.dart';

/// The editable watch date shared by journal creation and editing.
class WatchDateSelector extends StatelessWidget {
  const WatchDateSelector({
    super.key,
    required this.date,
    required this.onChanged,
  });

  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  Future<void> _chooseDate(BuildContext context) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final selected = DateUtils.dateOnly(date);
    final picked = await showDatePicker(
      context: context,
      initialDate: selected,
      firstDate: selected.isBefore(DateTime(1888)) ? selected : DateTime(1888),
      lastDate: selected.isAfter(today) ? selected : today,
      helpText: AppLocalizations.of(context).watchDatePickerTitle,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (context.mounted && picked != null && picked != selected) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppLocalizations.of(context).watchDatePickerTitle,
      child: InkWell(
        onTap: () => _chooseDate(context),
        borderRadius: BorderRadius.circular(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Jiffy.parseFromDateTime(date).format(pattern: 'MMM do yyyy'),
              style: const TextStyle(
                fontFamily: 'AvenirNext',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 16 / 14,
                letterSpacing: 0.5,
                color: Color(0xFFDDDDDD),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
