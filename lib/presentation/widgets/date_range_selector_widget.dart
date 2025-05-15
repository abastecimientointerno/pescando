import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import '../../core/services/date_formatter_service.dart'; // Asegúrate que la ruta sea correcta

class DateRangeSelector extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(DateTime, DateTime) onDateRangeSelected;

  const DateRangeSelector({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    required this.onDateRangeSelected,
  });

  @override
  State<DateRangeSelector> createState() => _DateRangeSelectorState();
}

class _DateRangeSelectorState extends State<DateRangeSelector> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = widget.initialStartDate ?? DateTime(now.year, now.month, 1);
    _endDate = widget.initialEndDate ?? now;
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.range,
        firstDate: DateTime(2000),
        lastDate: DateTime.now().add(
          const Duration(days: 365),
        ), // Permite seleccionar hasta un año en el futuro
        currentDate: DateTime.now(),
        selectedDayHighlightColor: Theme.of(context).primaryColor,
        dayTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.normal,
        ),
        selectedDayTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        weekdayLabelTextStyle: TextStyle(
          color: Colors.grey[700],
          fontWeight: FontWeight.bold,
        ),
      ),
      dialogSize: const Size(325, 400),
      value: [_startDate, _endDate],
      borderRadius: BorderRadius.circular(15),
    );

    if (results != null &&
        results.length == 2 &&
        results[0] != null &&
        results[1] != null) {
      setState(() {
        _startDate = results[0]!;
        _endDate = results[1]!;
      });
      widget.onDateRangeSelected(_startDate, _endDate);
    } else if (results != null && results.length == 1 && results[0] != null) {
      // Si solo se selecciona una fecha en modo rango, algunos pickers devuelven una lista de 1
      // Asumimos que es el inicio y fin
      setState(() {
        _startDate = results[0]!;
        _endDate = results[0]!;
      });
      widget.onDateRangeSelected(_startDate, _endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _selectDateRange(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${DateFormatterService.toDisplayFormat(_startDate)} - ${DateFormatterService.toDisplayFormat(_endDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
