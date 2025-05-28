import 'dart:io';

void main() {
  log('开始处理...');
  final postDir = '_posts';
  final dir = Directory(postDir);
  if (dir.existsSync()) {
    final files = dir.listSync();
    for (final file in files) {
      log('开始处理文件:$file');
      processFile(file.path);
    }
  } else {
    log('$postDir不存在');
  }
}

void log(String msg) {
  print(msg);
}

/// 处理文件
/// 读取文件文本内容，将文件中所有HTTP链接替换为markdown链接
/// 如果已经是markdown链接，则不替换
///
/// markdown链接格式为：[链接文本](链接地址)
void processFile(String filePath) {
  // 读取文件内容
  final file = File(filePath);
  if (!file.existsSync()) {
    log('文件不存在: $filePath');
    return;
  }

  String content = file.readAsStringSync();

  // 正则表达式匹配HTTP链接
  // 匹配格式: http://或https://开头的URL，但不匹配已经是markdown格式的链接
  // 包括链接前面有空格的情况，如 [xxx]( http://text.com)
  final httpLinkPattern = RegExp(
    r'(?<!\[)(?<!\()(?<!\s\()https?://[^\s\)]+(?!\))(?!\])',
  );

  // 计数器
  int linkCount = 0;

  // 替换所有匹配的链接
  String newContent = content.replaceAllMapped(httpLinkPattern, (match) {
    String url = match.group(0)!;
    // 直接使用URL作为链接文本
    linkCount++; // 增加计数
    return '[$url]($url)';
  });

  // 如果内容有变化，写回文件
  if (content != newContent) {
    file.writeAsStringSync(newContent);
    log('文件已更新: $filePath');
    log('总共处理了 $linkCount 个链接');
  } else {
    log('文件无需更新: $filePath');
    log('没有找到需要处理的链接');
  }
}
