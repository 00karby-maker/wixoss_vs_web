import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/match_record.dart';

class EditPage extends StatefulWidget {
  final MatchRecord record;
  const EditPage({super.key, required this.record});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController eventCtrl;
  late TextEditingController memoCtrl;

  late String result;
  late String firstSecond;
  late int selfLb;
  late int oppLb;
  late String format;
  late int round;
  late DateTime date;

  String? imagePath;
  String usedLrig = "";
  String opponentLrig = "";

  /// Hiveボックス
  late Box lrigBox;
  final Map<String, int> lrigCount = {};

  /// ルリグ一覧
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

  @override
  void initState() {
    super.initState();
    eventCtrl = TextEditingController(text: widget.record.eventName);
    memoCtrl = TextEditingController(text: widget.record.memo);

    result = widget.record.result;
    firstSecond = widget.record.firstSecond;
    selfLb = widget.record.selfLb;
    oppLb = widget.record.opponentLb;
    format = widget.record.format;
    round = widget.record.round;
    date = widget.record.date;
    imagePath = widget.record.imagePath;
    usedLrig = widget.record.usedLrig;
    opponentLrig = widget.record.opponentLrig;

    initLrigBox();
  }

  Future<void> initLrigBox() async {
    lrigBox = await Hive.openBox('lrigUsage');
    for (var key in lrigBox.keys) {
      lrigCount[key] = lrigBox.get(key);
    }
    setState(() {});
  }

  String normalize(String input) {
    return input.split('').map((c) {
      final code = c.codeUnitAt(0);
      if (code >= 0x3041 && code <= 0x3096) {
        return String.fromCharCode(code + 0x60);
      }
      return c;
    }).join();
  }

  Future<String?> selectLrig(BuildContext context) async {
    String search = "";

    return showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          final normalizedSearch = normalize(search);
          final sorted = [...lrigList];
          sorted.sort((a, b) {
            final countA = lrigCount[a] ?? 0;
            final countB = lrigCount[b] ?? 0;
            return countB.compareTo(countA);
          });
          final filtered = sorted.where((e) => normalize(e).contains(normalizedSearch)).toList();

          final mostUsed = sorted.firstWhere(
            (e) => (lrigCount[e] ?? 0) > 0,
            orElse: () => "",
          );

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
                      setState(() => search = v);
                    },
                  ),
                  const SizedBox(height: 10),
                  if (search.isEmpty && mostUsed.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("よく使うルリグ", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 5),
                    ListTile(
                      tileColor: Colors.amber.withOpacity(0.3),
                      title: Text(mostUsed),
                      trailing: Text("★${lrigCount[mostUsed]}"),
                      onTap: () => Navigator.pop(context, mostUsed),
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
                          trailing: (lrigCount[item] ?? 0) > 0 ? Text("★${lrigCount[item]}") : null,
                          onTap: () => Navigator.pop(context, item),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

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

  void save() {
    widget.record
      ..eventName = eventCtrl.text
      ..usedLrig = usedLrig
      ..opponentLrig = opponentLrig
      ..memo = memoCtrl.text
      ..result = result
      ..firstSecond = firstSecond
      ..selfLb = selfLb
      ..opponentLb = oppLb
      ..format = format
      ..date = date
      ..round = round
      ..imagePath = imagePath;
    widget.record.save();
    Navigator.pop(context);
  }

  Widget label(String t) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("編集")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
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
                if (picked != null) setState(() => date = picked);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                child: Text("${date.year}/${date.month}/${date.day}"),
              ),
            ),

            label("使用ルリグ"),
            ListTile(
              title: Text(usedLrig.isEmpty ? "選択してください" : usedLrig),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () async {
                final selected = await selectLrig(context);
                if (selected != null) setState(() => usedLrig = selected);
              },
            ),

            label("フォーマット"),
            DropdownButton(
              value: format,
              isExpanded: true,
              items: ['A', 'K', 'D'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => format = v!),
            ),

            label("●回戦"),
            DropdownButton(
              value: round,
              isExpanded: true,
              items: List.generate(10, (i) => DropdownMenuItem(value: i + 1, child: Text("${i + 1}回戦"))),
              onChanged: (v) => setState(() => round = v!),
            ),

            label("対面ルリグ"),
            ListTile(
              title: Text(opponentLrig.isEmpty ? "選択してください" : opponentLrig),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () async {
                final selected = await selectLrig(context);
                if (selected != null) setState(() => opponentLrig = selected);
              },
            ),

            label("先後・勝敗・LB数"),
            Row(
              children: [
                Expanded(
                  child: DropdownButton(
                    value: firstSecond,
                    isExpanded: true,
                    items: ["先手", "後手"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => firstSecond = v!),
                  ),
                ),
                Expanded(
                  child: DropdownButton(
                    value: result,
                    isExpanded: true,
                    items: ["勝", "負"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => result = v!),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButton(
                          value: selfLb,
                          isExpanded: true,
                          items: List.generate(10, (i) => DropdownMenuItem(value: i, child: Text("$i"))),
                          onChanged: (v) => setState(() => selfLb = v!),
                        ),
                      ),
                      const Text("-"),
                      Expanded(
                        child: DropdownButton(
                          value: oppLb,
                          isExpanded: true,
                          items: List.generate(10, (i) => DropdownMenuItem(value: i, child: Text("$i"))),
                          onChanged: (v) => setState(() => oppLb = v!),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            label("メモ"),
            TextField(controller: memoCtrl, maxLines: null),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("デッキレシピ"),
            ),
            if (imagePath != null && File(imagePath!).existsSync()) Image.file(File(imagePath!), height: 120),

            const SizedBox(height: 20),
            ElevatedButton(onPressed: save, child: const Text("保存")),
          ],
        ),
      ),
    );
  }
}
