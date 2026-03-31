import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/match_record.dart';
import 'edit_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final Map<int, bool> _expanded = {};

  Color getTextColor(Color bgColor) {
    return bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<MatchRecord>('records');

    return Scaffold(
      appBar: AppBar(title: const Text('対戦履歴')),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<MatchRecord> box, _) {
          final list = box.values.toList();

          list.sort((a, b) => b.date.compareTo(a.date));

          if (list.isEmpty) {
            return const Center(child: Text('データがありません'));
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final r = list[index];
              final isExpanded = _expanded[index] ?? false;

              return Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

                /// ★ 枠だけ勝敗で色変更
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        r.result == "勝" ? Colors.red : Colors.blue,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        "${r.usedLrig} vs ${r.opponentLrig}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "${r.date.year}/${r.date.month}/${r.date.day} ・ ${r.format} ・ ${r.result}",
                        style: TextStyle(
                          fontSize: 12,
                          color: r.result == "勝"
                              ? Colors.red
                              : Colors.blue,
                        ),
                      ),

                      /// ▼ 展開ボタン
                      trailing: IconButton(
                        icon: Icon(
                          isExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                        ),
                        onPressed: () {
                          setState(() {
                            _expanded[index] = !isExpanded;
                          });
                        },
                      ),
                    ),

                    /// ▼ 展開部分
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text("大会名: ${r.eventName}"),
                            Text("回戦: ${r.round}"),

                            /// 画像表示
                            if (r.imagePath != null)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                        vertical: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    final bytes =
                                        base64Decode(r.imagePath!);
                                    showDialog(
                                      context: context,
                                      builder: (_) => Dialog(
                                        child: InteractiveViewer(
                                          child:
                                              Image.memory(bytes),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Image.memory(
                                    base64Decode(r.imagePath!),
                                    height: 150,
                                  ),
                                ),
                              ),

                            /// メモ（折りたたみ）
                            if (r.memo.isNotEmpty)
                              ExpansionTile(
                                title: const Text("メモ"),
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.all(8),
                                    child: Text(r.memo),
                                  )
                                ],
                              ),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.end,
                              children: [
                                /// 編集
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EditPage(record: r),
                                      ),
                                    );
                                  },
                                ),

                                /// 削除
                                IconButton(
                                  icon:
                                      const Icon(Icons.delete),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) =>
                                          AlertDialog(
                                        title:
                                            const Text("削除確認"),
                                        content: const Text(
                                            "削除しますか？"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(
                                                    context),
                                            child: const Text(
                                                "キャンセル"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              r.delete();
                                              Navigator.pop(
                                                  context);
                                            },
                                            child:
                                                const Text("削除"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
