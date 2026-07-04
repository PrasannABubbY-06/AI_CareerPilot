import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  int count = 0;
  for (var file in files) {
    String content = file.readAsStringSync();
    if (content.contains(r'\$')) {
      content = content.replaceAll(r'\$', r'$');
      file.writeAsStringSync(content);
      print('Fixed \${file.path}');
      count++;
    }
  }
  print('Total fixed: \$count');
}
