import 'package:flutter/material.dart';

class CustomNumberInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String helperText;

  const CustomNumberInput({
    super.key,
    required this.label,
    required this.controller,
    this.helperText = "",
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                if (helperText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(helperText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  )
              ],
            ),
          ),
          SizedBox(
            width: 110,
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E1E2C),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade800, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.tealAccent, width: 2),
                ),
              ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.tealAccent),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomDropdownInput extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const CustomDropdownInput({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              border: Border.all(color: Colors.grey.shade800, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                dropdownColor: const Color(0xFF262636),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.tealAccent),
                style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 16),
                items: options.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
                onChanged: onChanged,
              ),
            ),
          )
        ],
      ),
    );
  }
}
