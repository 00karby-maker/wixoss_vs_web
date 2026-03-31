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

              return Dismissible(
                key: Key(r.key.toString()),

                direction: DismissDirection.horizontal,

                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),

                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),

                /// 削除確認
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("削除確認"),
                      content: const Text("削除しますか？"),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, false),
                          child: const Text("キャンセル"),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, true),
                          child: const Text("削除"),
                        ),
                      ],
                    ),
                  );
                },

                /// 実削除
                onDismissed: (direction) {
                  r.delete();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("削除しました")),
                  );
                },

                child: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: r.result == "勝"
                          ? Colors.red
                          : Colors.blue,
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

                      if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text("大会名: ${r.eventName}"),
                              Text("${r.round}回戦"),

                              if (r.imagePath != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          vertical: 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      final bytes =
                                          base64Decode(
                                              r.imagePath!);
                                      showDialog(
                                        context: context,
                                        builder: (_) => Dialog(
                                          child:
                                              InteractiveViewer(
                                            child: Image.memory(
                                                bytes),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Image.memory(
                                      base64Decode(
                                          r.imagePath!),
                                      height: 150,
                                    ),
                                  ),
                                ),

                              if (r.memo.isNotEmpty)
                                ExpansionTile(
                                  title: const Text("メモ"),
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.all(
                                              8),
                                      child: Text(r.memo),
                                    )
                                  ],
                                ),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon:
                                        const Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              EditPage(
                                                  record: r),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.delete),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) =>
                                            AlertDialog(
                                          title: const Text(
                                              "削除確認"),
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
                                              child: const Text(
                                                  "削除"),
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
