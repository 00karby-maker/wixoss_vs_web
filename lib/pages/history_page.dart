import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../model/match_record.dart';
import 'edit_page.dart';
import 'search_state.dart';

// 固定の色マップ
final Map<String, Color> lrigColors = {
    // 白ルリグ
  "タマ": Color(0xFFffffff),"タウィル": Color(0xFFf8fbf8),"サシェ": Color(0xFFf3f3f2),"リメンバ": Color(0xFFc1e4e9),"ドーナ": Color(0xFFffdead),
  "アキノ": Color(0xFFfef3c9),"LION": Color(0xFFfffae6),"ノヴァ": Color(0xFFfffaf0),"ゆかゆか": Color(0xFFffebcd),"ガブリエラ": Color(0xFFfaebd7),
  "るう子": Color(0xFFe6e6e6),"ゆきめ": Color(0xFFdaf3ef),"エマ": Color(0xFFe5d2c5),"にじさんじ": Color(0xFFdcdddd),"リゼ": Color(0xFFcbb994),
  "アンジュ": Color(0xFFe8ecef),"アズサ": Color(0xFFe5e4e6),"サオリ": Color(0xFFe9e4d4),"ネージュ": Color(0xFFeaf4fc),
// 赤ルリグ
  "花代": Color(0xFFe60033),"ユヅキ": Color(0xFFb15237),"赤タマ": Color(0xFFea5506),"ララ・ルー": Color(0xFFc2302a),"リル": Color(0xFFea5506),
  "カーニバル": Color(0xFF752100),"レイラ": Color(0xFF8a3319),"LOV": Color(0xFFdb8449),"ヒラナ": Color(0xFFf6b894),"LOVIT": Color(0xFFeb6ea5),
  "エクス": Color(0xFFce5242),"アザエラ": Color(0xFF683f36),"ちより": Color(0xFF872732),"ジール": Color(0xFF583133),
// 青ルリグ
  "ピルルク": Color(0xFF0095d9),"エルドラ": Color(0xFF674598),"ミルルン": Color(0xFF4c6cb3),"ソウイ": Color(0xFF274a78),"あや": Color(0xFF192f60),
  "青リメンバ": Color(0xFF00a497),"青タマ": Color(0xFF7ebeab),"青ウムル": Color(0xFF00a381),"レイ": Color(0xFF7ebea5),"タマゴ": Color(0xFF9ba88d),
  "マドカ": Color(0xFFc0c6c9),"みこみこ": Color(0xFF5383c3),"ミカエラ": Color(0xFFada250),"あきら": Color(0xFFbed2c3),"ネル": Color(0xFF84a2d4),
  "ミヤコ": Color(0xFF5d7ea3),"リップル": Color(0xFF243d5c),
// 緑ルリグ
  "緑子": Color(0xFF3eb370),"アン": Color(0xFF028760),"アイヤイ": Color(0xFF88cb7f),"メル": Color(0xFF69b076),"ママ": Color(0xFF316745),
  "緑ユヅキ": Color(0xFF00552e),"緑ピルルク": Color(0xFFdccb18),"アト": Color(0xFF98d98e),"WOLF": Color(0xFFe6eae3),"バン": Color(0xFF019a66),
  "サンガ": Color(0xFFaab3a0),"緑カーニバル": Color(0xFF879a86),"ひとえ": Color(0xFF384e36),"ホシノ": Color(0xFFc2baab),"シロコ": Color(0xFFa2bd95),
  "ユカリ": Color(0xFF436065),"ミーティア": Color(0xFF2b5f2a),
// 黒ルリグ
  "ウリス": Color(0xFF2b2b2b),"イオナ": Color(0xFF583822),"ウムル": Color(0xFF544a47),"ミュウ": Color(0xFF2e2930),"ハナレ": Color(0xFF0d0015),
  "アルフォウ": Color(0xFF241a08),"ナナシ": Color(0xFF16160e),"グズ子": Color(0xFF250d00),"黒カーニバル": Color(0xFF302833),"ムジカ": Color(0xFF432f2f),
  "デウス": Color(0xFF262626),"マキナ": Color(0xFF3e0014),"まほまほ": Color(0xFF24140e),"黒タマ": Color(0xFF595455),"ヤミノ": Color(0xFF524748),
  "ヒナ": Color(0xFF797979),"シュン": Color(0xFFb7a49f),"とこ": Color(0xFF9fa0a0),"ヴィオラ": Color(0xFF80989b),
// 無ルリグ
  "夢限": Color(0xFFccffe5)
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
