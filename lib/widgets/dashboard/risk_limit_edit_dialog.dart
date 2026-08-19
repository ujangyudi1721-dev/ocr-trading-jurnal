import 'package:flutter/material.dart';

class RiskLimitEditDialog extends StatefulWidget {
  final double maxLossPercent;
  final double profitTargetPercent;

  const RiskLimitEditDialog({
    super.key,
    required this.maxLossPercent,
    required this.profitTargetPercent,
  });

  @override
  State<RiskLimitEditDialog> createState() => _RiskLimitEditDialogState();
}

class _RiskLimitEditDialogState extends State<RiskLimitEditDialog> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController maxLossController;
  late final TextEditingController profitTargetController;

  @override
  void initState() {
    super.initState();

    maxLossController = TextEditingController(
      text: widget.maxLossPercent.toStringAsFixed(0),
    );

    profitTargetController = TextEditingController(
      text: widget.profitTargetPercent.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    maxLossController.dispose();
    profitTargetController.dispose();
    super.dispose();
  }

  String? validatePercent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Wajib diisi";
    }

    final parsed = double.tryParse(value);

    if (parsed == null || parsed <= 0) {
      return "Harus angka > 0";
    }

    return null;
  }

  void submit() {
    if (!formKey.currentState!.validate()) return;

    Navigator.pop(context, {
      "maxLoss": double.parse(maxLossController.text),
      "profitTarget": double.parse(profitTargetController.text),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Atur Risk Limit"),

      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: maxLossController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Max Loss (%)",
                suffixText: "%",
              ),
              validator: validatePercent,
            ),

            const SizedBox(height: 15),

            TextFormField(
              controller: profitTargetController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Profit Target (%)",
                suffixText: "%",
              ),
              validator: validatePercent,
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),

        ElevatedButton(
          onPressed: submit,
          child: const Text("Simpan"),
        ),
      ],
    );
  }
}
