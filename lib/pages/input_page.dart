import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../model/match_record.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class MatchInput {
  String opponentLrig = "";
  String firstSecond = "先手";
  String result = "勝";
  int selfLb = 0;
  int opponentLb = 0;
  String memo = "";

  late TextEditingController memoCtrl;

  MatchInput() {
    memoCtrl = TextEditingController(text: memo);
  }

  void dispose() {
    memoCtrl.dispose();
  }
}

class _InputPageState extends State<InputPage> {
  final eventCtrl = TextEditingController();

  String usedLrig = "";

  DateTime date = DateTime.now();
  String format = "A";

  List<MatchInput> matches = [MatchInput()];

  String? imagePath;

  /// Hiveボックス
  late Box lrigBox;

  /// 使用回数カウント（メモリ）
  final Map<String, int> lrigCount = {};

  /// ルリグ一覧
    final List<String> lrigList = [
//白ルリグ
  "タマ","タウィル","サシェ","リメンバ","ドーナ",
  "アキノ","LION","ノヴァ","ゆかゆか","ガブリエラ",
  "るう子","ゆきめ","エマ","にじさんじ","リゼ",
  "アンジュ","アズサ","サオリ","ネージュ",
//赤ルリグ
  "花代","ユヅキ","赤タマ","ララ・ルー","リル",
  "カーニバル","レイラ","LOV","ヒラナ","LOVIT",
  "エクス","アザエラ","ちより","ジール",
//青ルリグ
  "ピルルク","エルドラ","ミルルン","ソウイ","あや",
  "青リメンバ","青タマ","青ウムル","レイ","タマゴ",
  "マドカ","みこみこ","ミカエラ","あきら","ネル",
  "ミヤコ","リップル",
//緑ルリグ
  "緑子","アン","アイヤイ","メル","ママ",
  "緑ユヅキ","緑ピルルク","アト","WOLF","バン",
  "サンガ","緑カーニバル","ひとえ","ホシノ","シロコ",
  "ユカリ","ミーティア",
//黒ルリグ
  "ウリス","イオナ","ウムル","ミュウ","ハナレ",
  "アルフォウ","ナナシ","グズ子","黒カーニバル","ムジカ",
  "デウス","マキナ","まほまほ","黒タマ","ヤミノ",
  "ヒナ","シュン","とこ","ヴィオラ",
//無色ルリグ
  "夢限"
];

  @override
  void initState() {
    super.initState();
    initLrigBox();
  }

  /// Hive初期化＆読み込み
  Future<void> initLrigBox() async {
    lrigBox = await Hive.openBox('lrigUsage');

    for (var key in lrigBox.keys) {
      lrigCount[key] = lrigBox.get(key);
    }

    setState(() {});
  }

  /// ひらがな→カタカナ変換
  String normalize(String input) {
    return input.split('').map((c) {
      final code = c.codeUnitAt(0);
      if (code >= 0x3041 && code <= 0x3096) {
        return String.fromCharCode(code + 0x60);
      }
      return c;
    }).join();
  }

  /// ラベル
  Widget label(String t) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      );

  /// 検索付き選択ダイアログ
Future<String?> selectLrig(BuildContext context) async {
  String search = "";

  return showDialog<String>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {

          /// ★ 毎回Hiveから最新を読み込み
          lrigCount.clear();
          for (var key in lrigBox.keys) {
            lrigCount[key] = lrigBox.get(key);
          }

          final normalizedSearch = normalize(search);

          /// =========================
          /// ★ ここが今回のメイン処理
          /// =========================

          // よく使うルリグ（使用回数 > 0）
          final frequent = lrigList
              .where((e) => (lrigCount[e] ?? 0) > 0)
              .toList()
            ..sort((a, b) =>
                (lrigCount[b] ?? 0).compareTo(lrigCount[a] ?? 0));

          // 未使用ルリグ（元の順番そのまま）
          final others = lrigList
              .where((e) => (lrigCount[e] ?? 0) == 0)
              .toList();

          // 合体（上に頻出、下に通常順）
          final merged = [...frequent, ...others];

          // 検索フィルタ
          final filtered = merged.where((e) {
            return normalize(e).contains(normalizedSearch);
          }).toList();

          /// ★ 最多使用ルリグ（ヘッダー用）
          final mostUsed = frequent.isNotEmpty ? frequent.first : "";

          return AlertDialog(
            title: const Text("ルリグ選択"),
            content: SizedBox(
              width: double.maxFinite,
              height: 350,
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: "検索（ひらがなOK）",
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) {
                      setState(() {
                        search = v;
                      });
                    },
                  ),
                  const SizedBox(height: 10),

                  /// ★ よく使うルリグ（検索してない時だけ表示）
                  if (search.isEmpty && mostUsed.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "よく使うルリグ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 5),
                    ListTile(
                      tileColor: Colors.amber.withOpacity(0.3),
                      title: Text(mostUsed),
                      trailing: Text("★${lrigCount[mostUsed]}"),
                      onTap: () {
                        Navigator.pop(context, mostUsed);
                      },
                    ),
                    const Divider(),
                  ],

                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return ListTile(
                          title: Text(item),
                          trailing: (lrigCount[item] ?? 0) > 0
                              ? Text("★${lrigCount[item]}")
                              : null,
                          onTap: () {
                            Navigator.pop(context, item);
                          },
                        );
                      },
                    ),
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

  /// 画像選択
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final name = DateTime.now().millisecondsSinceEpoch.toString();

    final saved = await File(file.path).copy('${dir.path}/$name.jpg');

    setState(() {
      imagePath = saved.path;
    });
  }

  /// 保存
  void save() {
    final box = Hive.box<MatchRecord>('records');

    for (int i = 0; i < matches.length; i++) {
      final m = matches[i];

      box.add(
        MatchRecord(
          eventName: eventCtrl.text,
          date: date,
          format: format,
          usedLrig: usedLrig,
          round: i + 1,
          opponentLrig: m.opponentLrig,
          firstSecond: m.firstSecond,
          result: m.result,
          selfLb: m.selfLb,
          opponentLb: m.opponentLb,
          memo: m.memoCtrl.text,
          imagePath: imagePath,
        ),
      );
    }

    // ★ 試合数分カウント
if (usedLrig.isNotEmpty) {
  final addCount = matches.length;
  final newCount = (lrigCount[usedLrig] ?? 0) + addCount;

  lrigCount[usedLrig] = newCount;
  lrigBox.put(usedLrig, newCount);
}
    setState(() {
      eventCtrl.clear();
      usedLrig = "";
      imagePath = null;
      date = DateTime.now();
      format = "A";

      for (var m in matches) {
        m.dispose();
      }
      matches = [MatchInput()];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("保存しました")),
    );
  }

  @override
  void dispose() {
    eventCtrl.dispose();
    for (var m in matches) {
      m.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          label("デッキレシピ"),
          ElevatedButton(
            onPressed: pickImage,
            child: const Text("画像を選択"),
          ),
          if (imagePath != null && File(imagePath!).existsSync())
            Image.file(File(imagePath!), height: 120),

          label("大会名"),
          TextField(controller: eventCtrl),

          label("日付"),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => date = picked);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border.all()),
              child: Text("${date.year}/${date.month}/${date.day}"),
            ),
          ),

          label("使用ルリグ"),
          ListTile(
            title: Text(usedLrig.isEmpty ? "選択してください" : usedLrig),
            trailing: const Icon(Icons.arrow_drop_down),
            onTap: () async {
              final selected = await selectLrig(context);
              if (selected != null) {
                setState(() {
                  usedLrig = selected;
                });
              }
            },
          ),

          label("フォーマット"),
          DropdownButton(
            value: format,
            isExpanded: true,
            items: ['A', 'K', 'D']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => format = v!),
          ),

          const SizedBox(height: 10),

          ...List.generate(matches.length, (i) {
            final m = matches[i];

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    label("対戦 ${i + 1}"),

                    label("対面ルリグ"),
                    ListTile(
                      title: Text(m.opponentLrig.isEmpty
                          ? "選択してください"
                          : m.opponentLrig),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: () async {
                        final selected = await selectLrig(context);
                        if (selected != null) {
                          setState(() {
                            m.opponentLrig = selected;
                          });
                        }
                      },
                    ),

                    label("先後"),
                    DropdownButton(
                      value: m.firstSecond,
                      isExpanded: true,
                      items: ["先手", "後手"]
                          .map((e) => DropdownMenuItem(
                              value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => m.firstSecond = v!),
                    ),

                    label("勝敗"),
                    DropdownButton(
                      value: m.result,
                      isExpanded: true,
                      items: ["勝", "負"]
                          .map((e) => DropdownMenuItem(
                              value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => m.result = v!),
                    ),

                    label("LB数:自/被"),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton(
                            value: m.selfLb,
                            isExpanded: true,
                            items: List.generate(
                                10,
                                (i) => DropdownMenuItem(
                                    value: i, child: Text("$i"))),
                            onChanged: (v) => setState(() => m.selfLb = v!),
                          ),
                        ),
                        const Text("-"),
                        Expanded(
                          child: DropdownButton(
                            value: m.opponentLb,
                            isExpanded: true,
                            items: List.generate(
                                10,
                                (i) => DropdownMenuItem(
                                    value: i, child: Text("$i"))),
                            onChanged:
                                (v) => setState(() => m.opponentLb = v!),
                          ),
                        ),
                      ],
                    ),

                    label("メモ"),
                    TextField(
                      controller: m.memoCtrl,
                      maxLines: null,
                    ),

                    const SizedBox(height: 10),
                    if (matches.length > 1)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            m.dispose();
                            matches.removeAt(i);
                          });
                        },
                        child: const Text("削除"),
                      ),
                  ],
                ),
              ),
            );
          }),

          ElevatedButton(
            onPressed: () {
              setState(() => matches.add(MatchInput()));
            },
            child: const Text("+ 対戦追加"),
          ),

          ElevatedButton(
            onPressed: save,
            child: const Text("保存"),
          ),
        ],
      ),
    );
  }
}
