import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../model/match_record.dart';
import 'edit_page.dart';
import 'search_state.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Color getColor(String key, Map<String, Color> colorMap) {
    if (colorMap.containsKey(key)) return colorMap[key]!;
    final colors = [
      Colors.indigo, Colors.blue, Colors.red, Colors.green,
      Colors.orange, Colors.purple, Colors.teal, Colors.pink
    ];
    final c = colors[colorMap.length % colors.length];
    colorMap[key] = c;
    return c;
  }

  List<MatchRecord> filterRecords(Box<MatchRecord> box, SearchState searchState) {
    return box.values.where((e) {
      final matchKeyword =
          e.eventName.contains(searchState.keyword) ||
          e.usedLrig.contains(searchState.keyword) ||
          e.opponentLrig.contains(searchState.keyword);

      final matchFormat =
          searchState.formatFilter == "すべて" || e.format == searchState.formatFilter;

      final matchUsed = searchState.usedFilters.isEmpty ||
          searchState.usedFilters.any((f) => e.usedLrig.contains(f));

      final matchOpponent = searchState.opponentFilters.isEmpty ||
          searchState.opponentFilters.any((f) => e.opponentLrig.contains(f));

      final matchDate =
          (searchState.startDate == null || !e.date.isBefore(searchState.startDate!)) &&
          (searchState.endDate == null || !e.date.isAfter(searchState.endDate!));

      return matchKeyword && matchFormat && matchUsed && matchOpponent && matchDate;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    final searchState = context.watch<SearchState>();
    final box = Hive.box<MatchRecord>('records');
    final Map<String, Color> colorMap = {};

    if (box.isEmpty) {
      return const Center(child: Text("記録がありません"));
    }

    final filteredRecords = filterRecords(box, searchState);

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (_, Box<MatchRecord> box, __) {
        return ListView.builder(
          itemCount: filteredRecords.length,
          itemBuilder: (_, i) {
            final r = filteredRecords[i];
            return Card(
              child: ListTile(
                title: Text("${r.usedLrig} vs ${r.opponentLrig}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${r.eventName} / ${r.round}回戦"),
                    Text(
                      "${r.date.year}/${r.date.month}/${r.date.day} ・ ${r.format} ・ ${r.result}",
                      style: TextStyle(
                        fontSize: 12,
                        color: r.result == "勝" ? Colors.blue : Colors.red,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// 画像
                    if (r.imagePath != null)
                      IconButton(
                        icon: const Icon(Icons.image),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              child: InteractiveViewer(
                                child: Image.file(File(r.imagePath!)),
                              ),
                            ),
                          );
                        },
                      ),

                    /// 編集
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditPage(record: r)),
                        );
                      },
                    ),

                    /// 削除
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("削除確認"),
                            content: const Text("削除しますか？"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text("キャンセル")),
                              TextButton(
                                onPressed: () {
                                  r.delete();
                                  Navigator.pop(context);
                                },
                                child: const Text("削除"),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
