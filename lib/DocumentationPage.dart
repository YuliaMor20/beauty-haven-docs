import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart' show rootBundle;

class DocumentationPage extends StatelessWidget {
  const DocumentationPage({Key? key}) : super(key: key);

  Future<String> _loadMarkdown() async {
    return await rootBundle.loadString('assets/README.md');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Документация'),
        backgroundColor: const Color(0xFFF1BFBE),
      ),
      body: FutureBuilder<String>(
        future: _loadMarkdown(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки документации: ${snapshot.error}'));
          } else {
            return Markdown(data: snapshot.data ?? '');
          }
        },
      ),
    );
  }
}
