import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class MonthPicker extends StatefulWidget{
  const MonthPicker({Key? key,required this.onChanged}) : super(key: key);

  final ValueChanged<DateTime> onChanged;
  @override
  State<MonthPicker> createState() => _MonthPickerState();
}

class _MonthPickerState extends State<MonthPicker> {
  late DateTime _dateTime;
  final DateFormat _monthFormatter = DateFormat("MMMM yyyy");
  @override
  void initState() {
    _dateTime = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            'Month',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: Theme.of(context).hintColor),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            _dateTime = DateTime(
                                _dateTime.month == 1
                                    ? _dateTime.year - 1
                                    : _dateTime.year,
                                _dateTime.month == 1
                                    ? 12
                                    : _dateTime.month - 1,
                                1);
                            widget.onChanged(_dateTime);
                          });
                        },
                        icon: const Icon(Icons.chevron_left)),
                    Expanded(
                        child: InkWell(
                          onTap: () async {
                            DateTime? newDate = await showMonthPicker(
                                context: context,
                                initialDate: _dateTime,
                                lastDate: DateTime.now());
                            if (newDate != null &&
                                newDate != _dateTime) {
                              setState(() {
                                _dateTime = newDate;

                                widget.onChanged(_dateTime);
                              });
                            }
                          },
                          child: Text(
                            _monthFormatter.format(_dateTime),
                            textAlign: TextAlign.center,
                          ),
                        )),
                    IconButton(
                        onPressed: () {
                          DateTime newDate;
                          newDate = DateTime(
                              _dateTime.month == 12
                                  ? _dateTime.year + 1
                                  : _dateTime.year,
                              _dateTime.month == 12
                                  ? 1
                                  : _dateTime.month + 1,
                              1);

                          if (newDate.isBefore(DateTime.now())) {
                            setState(() {
                              _dateTime = newDate;
                              widget.onChanged(_dateTime);
                            });
                          }
                        },
                        icon: const Icon(Icons.chevron_right)),
                  ]),
              Container(
                color: Colors.grey,
                width: double.infinity,
                height: 1,
              )
            ],
          ),
        ),
      ],
    );
  }
}