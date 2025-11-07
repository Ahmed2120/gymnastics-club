import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  const CustomDropdown({super.key});

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String? selectedValue = 'أحمد محمود';

  final List<String> items = [
    'أحمد محمود',
    'محمد علي',
    'سارة خالد',
    'خالد يوسف',
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality( // To make it RTL for Arabic
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
            isExpanded: true,
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedValue = newValue;
              });
            },
          ),
        ),
      ),
    );
  }
}