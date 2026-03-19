import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_vocab/providers/word_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart'; 
import 'package:my_vocab/services/word_service.dart';

// Since share_plus IS in pubspec now, verify package name later
// But sharing is better.

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Data')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Data Management'),
            leading: Icon(Icons.storage),
          ),
          ListTile(
            title: const Text('Import CSV'),
            subtitle: const Text('Add words from CSV file'),
            leading: const Icon(Icons.file_upload),
            onTap: () => _importCSV(context),
          ),
          ListTile(
            title: const Text('Import CET-6 Vocabulary'),
            subtitle: const Text('Load default word list (50 words sample)'),
            leading: const Icon(Icons.library_books),
            onTap: () => _importAssetCSV(context),
          ),
          ListTile(
            title: const Text('Export Backup'),
            subtitle: const Text('Save all words to CSV'),
            leading: const Icon(Icons.file_download),
            onTap: () => _exportCSV(context),
          ),
          const Divider(),
          const ListTile(
            title: Text('Reset Progress'),
            subtitle: Text('Clear all learning history (Keep words)'),
            leading: Icon(Icons.restore),
            // TODO: Implement reset
          ),
        ],
      ),
    );
  }

  Future<void> _importCSV(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        await WordService().importCSV(file);
        // Refresh provider
        Provider.of<WordProvider>(context, listen: false).loadWords();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Import Successful!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _importAssetCSV(BuildContext context) async {
    try {
      await WordService().importAssetCSV();
      Provider.of<WordProvider>(context, listen: false).loadWords();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CET-6 Words Imported!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _exportCSV(BuildContext context) async {
    try {
      String csvData = await WordService().exportCSV();
      final directory = await getTemporaryDirectory();
      
      final path = '${directory.path}/my_vocab_backup_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      await file.writeAsString(csvData);
      
      // Share file
      await Share.shareXFiles([XFile(path)], text: 'MyVocab Backup');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export ready to share!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
