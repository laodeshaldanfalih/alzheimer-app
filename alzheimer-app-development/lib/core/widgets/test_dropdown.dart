import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class TestDropdown extends StatelessWidget {
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const TestDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButtonFormField2<String>(
        hint: const Expanded(
          child: Text(
            'Benar / Salah',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        isExpanded: true,
        value: value,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintStyle: const TextStyle(color: Color(0xFFB0B8C1), fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE0E6ED)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.4),
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF8A94A6),
          ),
        ),
        items:
            options
                .map(
                  (opt) => DropdownMenuItem<String>(
                    value: opt,
                    child: Text(
                      opt,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1F2937),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                )
                .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
