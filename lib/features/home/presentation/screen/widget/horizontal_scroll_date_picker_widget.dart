import 'package:easy_date_timeline/easy_date_timeline.dart';

import 'package:flutter/material.dart';
import '../../../../../core/utils/date_utils.dart';

class CustomDate extends StatelessWidget {
  const CustomDate({
    super.key,
    required this.selectedDate,
    required this.onDateSelect,
    this.controller,
  });

  final DateTime selectedDate;
  final EasyDatePickerController? controller;

  final Function(DateTime selectedDate) onDateSelect;

  @override
  Widget build(BuildContext context) {
    return EasyDateTimeLinePicker.itemBuilder(
      controller: controller,
      firstDate: calendarFirstDate,
      lastDate: calendarLastDate,

      headerOptions: const HeaderOptions(headerType: HeaderType.none),
      focusedDate: selectedDate,
      itemExtent: 105,
      itemBuilder: (context, date, isSelected, isDisabled, isToday, onTap) {
        return InkResponse(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: (isSelected) ? Colors.white10 : Colors.transparent,
            ),
            child: Text(
              textAlign: TextAlign.center,
              "${date.day.toString()}  ",
              style: (isSelected)
                  ? Theme.of(context).textTheme.bodyLarge
                  : Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      },
      timelineOptions: TimelineOptions(height: 44),
      daySeparatorPadding: 12,
      onDateChange: onDateSelect,
    );
  }
}
