import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class TradingRulesPage extends StatefulWidget {
  final VoidCallback onContinue;

  const TradingRulesPage({super.key, required this.onContinue});

  @override
  State<TradingRulesPage> createState() => _TradingRulesPageState();
}

class _TradingRulesPageState extends State<TradingRulesPage> {
  List<String> _rules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    final rules = await SettingsService.getTradingRules();
    if (!mounted) return;
    setState(() {
      _rules = rules;
      _isLoading = false;
    });
  }
 Future<void> _showRuleDialog({int? index}) async {
    final controller = TextEditingController(
      text: index == null ? '' : _rules[index],
    );

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(index == null ? 'Tambah aturan' : 'Ubah aturan'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: null,
          decoration: const InputDecoration(hintText: 'Tulis aturan...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    setState(() {
      if (index == null) {
        _rules.add(result);
      } else {
        _rules[index] = result;
      }
    });
    await SettingsService.saveTradingRules(_rules);
  }

  Future<void> _deleteRule(int index) async {
    setState(() => _rules.removeAt(index));
    await SettingsService.saveTradingRules(_rules);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 56, color: Colors.orange.shade800),
                    const SizedBox(height: 8),
                    Text(
                      'PERINGATAN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Baca aturan trading kamu sebelum mulai.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _rules.isEmpty
                          ? const Center(child: Text('Belum ada aturan.'))
                          : ListView.builder(
                              itemCount: _rules.length,
                              itemBuilder: (context, index) => Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text('${index + 1}'),
                                  ),
                                  title: Text(_rules[index]),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () =>
                                            _showRuleDialog(index: index),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => _deleteRule(index),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showRuleDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah aturan'),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: widget.onContinue,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Saya mengerti, lanjut'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
