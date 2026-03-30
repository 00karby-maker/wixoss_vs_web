import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../model/match_record.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String format = "∀";

  final List<String> lrigList = [
// 白ルリグ
  "タマ","タウィル","サシェ","リメンバ","ドーナ",
  "アキノ","LION","ノヴァ","ゆかゆか","ガブリエラ",
  "るう子","ゆきめ","エマ","にじさんじ","リゼ",
  "アンジュ","アズサ","サオリ","ネージュ",
// 赤ルリグ
  "花代","ユヅキ","赤タマ","ララ・ルー","リル",
  "カーニバル","レイラ","LOV","ヒラナ","LOVIT",
  "エクス","アザエラ","ちより","ジール",
// 青ルリグ
  "ピルルク","エルドラ","ミルルン","ソウイ","あや",
  "青リメンバ","青タマ","青ウムル","レイ","タマゴ",
  "マドカ","みこみこ","ミカエラ","あきら","ネル",
  "ミヤコ","リップル",
// 緑ルリグ
  "緑子","アン","アイヤイ","メル","ママ",
  "緑ユヅキ","緑ピルルク","アト","WOLF","バン",
  "サンガ","緑カーニバル","ひとえ","ホシノ","シロコ",
  "ユカリ","ミーティア",
// 黒ルリグ
  "ウリス","イオナ","ウムル","ミュウ","ハナレ",
  "アルフォウ","ナナシ","グズ子","黒カーニバル","ムジカ",
  "デウス","マキナ","まほまほ","黒タマ","ヤミノ",
  "ヒナ","シュン","とこ","ヴィオラ",
// 無ルリグ
  "夢限"
];

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
  return lrigColors[name] ?? Colors.grey; // マップにない場合はグレー
}

  Color getTextColor(Color bgColor) {
  final brightness = ThemeData.estimateBrightnessForColor(bgColor);
  return brightness == Brightness.dark ? Colors.white : Colors.black;
}

  /// データ取得
  List<MatchRecord> getRecords(Box<MatchRecord> box) {
    if (format == "∀") return box.values.toList();
    return box.values.where((e) => e.format == format).toList();
  }

  /// ルリグごとの件数カウント
  Map<String, int> countBy(Box<MatchRecord> box, bool used) {
    final map = <String, int>{};
    for (var r in getRecords(box)) {
      final key = used ? r.usedLrig : r.opponentLrig;
      if (key.isEmpty) continue;
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  /// 勝率データ
  Map<String, Map<String, int>> winData(Box<MatchRecord> box) {
    final map = <String, Map<String, int>>{};
    for (var r in getRecords(box)) {
      final key = r.usedLrig;
      if (key.isEmpty) continue;
      map.putIfAbsent(key, () => {"win": 0, "total": 0});
      map[key]!["total"] = map[key]!["total"]! + 1;
      if (r.result == "勝") map[key]!["win"] = map[key]!["win"]! + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<MatchRecord>('records');

    if (box.isEmpty) {
      return const Center(child: Text("記録がありません"));
    }

    final used = countBy(box, true);
    final opp = countBy(box, false);
    final winMap = winData(box);
    final entries = winMap.entries.toList()
      ..sort((a, b) {
        final winA = a.value["win"]!;
        final totalA = a.value["total"]!;
        final rateA = totalA == 0 ? 0 : winA / totalA;

        final winB = b.value["win"]!;
        final totalB = b.value["total"]!;
        final rateB = totalB == 0 ? 0 : winB / totalB;

        // 勝率優先 → 同率なら試合数
        final cmp = rateB.compareTo(rateA);
        if (cmp != 0) return cmp;

        return totalB.compareTo(totalA);
      });

    return SingleChildScrollView(
      key: ValueKey(format),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// フィルター
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: DropdownButtonFormField<String>(
                value: format,
                decoration: const InputDecoration(
                  labelText: "フォーマット",
                  border: OutlineInputBorder(),
                ),
                items: ["∀", "A", "K", "D"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => format = v!),
              ),
            ),
          ),

          const SizedBox(height: 16),

          buildPie("使用ルリグ割合", used),
          buildPie("対戦ルリグ割合", opp),
          buildBar(entries, winMap),
        ],
      ),
    );
  }

  /// 円グラフ
  Widget buildPie(String title, Map<String, int> data) {
    final total = data.values.fold<int>(0, (a, b) => a + b);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sections: data.entries.map((e) {
                    final percent = total == 0 ? 0.0 : (e.value / total * 100);
                    final bgColor = lrigColor(e.key);
                    final showLabel = percent >= 5;
                    return PieChartSectionData(
                      value: percent.toDouble(),
                      color: lrigColor(e.key),
                      radius: 65,
                      title: showLabel
        ? "${e.key}\n${percent.toStringAsFixed(1)}%"
        : "",
                      titleStyle: TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.bold,
  color: getTextColor(bgColor),
  shadows: [
    Shadow(
      blurRadius: 3,
      color: Colors.black.withOpacity(0.7),
      offset: Offset(1, 1),
    ),
  ],
),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 棒グラフ（勝率）
  Widget buildBar(
      List<MapEntry<String, Map<String, int>>> entries,
      Map<String, Map<String, int>> winMap) {

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("使用ルリグ勝率",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: BarChart(
                BarChartData(
                  maxY: 100,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (value, meta) => Text(
                          "${value.toInt()}%",
                          style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.black87),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i >= entries.length) return const SizedBox();
                          // 下部はルリグ名
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(entries[i].key,
                                style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i >= entries.length) return const SizedBox();
                          // 上位5位はTier1〜Tier5、それ以降は数字表示
                          final label = i < 5 ? "Tier${i + 1}" : "$i";
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(label,
                                style: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold)),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.black87,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final name = entries[groupIndex].key;
                        final win = winMap[name]!["win"]!;
                        final total = winMap[name]!["total"]!;
                        final rate = total == 0 ? 0.0 : (win / total * 100);
                        return BarTooltipItem(
                          "$name\n${rate.toStringAsFixed(1)}%\n$win勝 / $total戦",
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  barGroups: List.generate(entries.length, (i) {
                    final name = entries[i].key;
                    final win = winMap[name]!["win"]!;
                    final total = winMap[name]!["total"]!;
                    final rate = total == 0 ? 0.0 : (win / total * 100);
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: rate.toDouble(),
                          color: lrigColor(name),
                          width: 18,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
