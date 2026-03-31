import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../model/match_record.dart';
import 'edit_page.dart';
import 'search_state.dart';

/// ===== ルリグ色設定 =====
final Map<String, Color> lrigColors = {
  "タマ": Color(0xFFffffff),"タウィル": Color(0xFFf8fbf8),"サシェ": Color(0xFFf3f3f2),
  "花代": Color(0xFFe60033),"ユヅキ": Color(0xFFb15237),
  "ピルルク": Color(0xFF0095d9),"エルドラ": Color(0xFF674598),
  "緑子": Color(0xFF3eb370),"アン": Color(0xFF028760),
  "ウリス": Color(0xFF2b2b2b),"イオナ": Color(0xFF583822),
  "夢限": Color(0xFFccffe5),
};

Color lrigColor(String name) {
  return lrigColors[name] ?? Colors.grey;
}

/// 文字色自動調整
Color getTextColor(Color bgColor) {
  final brightness = ThemeData.estimateBrightnessForColor(bgColor);
  return brightness == Brightness.dark ? Colors.white : Colors.black;
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

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

            final leftColor = lrigColor(r.usedLrig);
            final rightColor = lrigColor(r.opponentLrig);

            final textColorLeft = getTextColor(leftColor);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Stack(
                children: [
                  /// ===== 背景2色 =====
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: leftColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: rightColor,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  /// ===== 内容 =====
                  ListTile(
                    title: Text(
                      "${r.usedLrig} vs ${r.opponentLrig}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColorLeft,
                        shadows: const [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${r.eventName} / ${r.round}回戦",
                          style: TextStyle(color: textColorLeft),
                        ),
                        Text(
                          "${r.date.year}/${r.date.month}/${r.date.day} ・ ${r.format} ・ ${r.result}",
                          style: TextStyle(
                            fontSize: 12,
                            color: r.result == "勝" ? Colors.blue : Colors.red,
                            shadows: const [
                              Shadow(
                                blurRadius: 3,
                                color: Colors.black,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    /// ===== 右側ボタン =====
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        /// 画像（軽量化済）
                        if (r.imagePath != null)
                          IconButton(
                            icon: Icon(Icons.image, color: textColorLeft),
                            onPressed: () {
                              final bytes = base64Decode(r.imagePath!);

                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  child: InteractiveViewer(
                                    child: Image.memory(
                                      bytes,
                                      filterQuality: FilterQuality.low,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                        /// 編集
                        IconButton(
                          icon: Icon(Icons.edit, color: textColorLeft),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditPage(record: r),
                              ),
                            );
                          },
                        ),

                        /// 削除
                        IconButton(
                          icon: Icon(Icons.delete, color: textColorLeft),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("削除確認"),
                                content: const Text("削除しますか？"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("キャンセル"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      r.delete();
                                      Navigator.pop(context);
                                    },
                                    child: const Text("削除"),
                                  ),
                                ],
                              ),
                            );
                          },
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
    );
  }
}
