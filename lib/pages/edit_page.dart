import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:typed_data';
import 'dart:convert';
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
    // 無色ルリグ
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
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    setState(() {
      imagePath = base64Encode(bytes);
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

  String normalize(String input) {
    return input.split('').map((c) {
      final code = c.codeUnitAt(0);
      if (code >= 0x3041 && code <= 0x3096) {
        return String.fromCharCode(code + 0x60);
      }
      return c;
    }).join();
  }

  Widget label(String t) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      );

  Future<String?> selectLrig(BuildContext context) async {
    String search = "";

    return showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ValueListenableBuilder(
              valueListenable: Hive.box<MatchRecord>('records').listenable(),
              builder: (context, _, __) {
                // Box更新時に使用回数を計算
                final lrigCount = <String, int>{};
                for (var r in Hive.box<MatchRecord>('records').values) {
                  if (r.usedLrig.isEmpty) continue;
                  lrigCount[r.usedLrig] = (lrigCount[r.usedLrig] ?? 0) + 1;
                }

                final normalizedSearch = normalize(search);
                final frequent = lrigList
                    .where((e) => (lrigCount[e] ?? 0) > 0)
                    .toList()
                  ..sort((a, b) =>
                      (lrigCount[b] ?? 0).compareTo(lrigCount[a] ?? 0));

                final others = lrigList
                    .where((e) => (lrigCount[e] ?? 0) == 0)
                    .toList();

                final merged = [...frequent, ...others];
                final filtered = merged
                    .where((e) => normalize(e).contains(normalizedSearch))
                    .toList();

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
                            setState(() => search = v);
                          },
                        ),
                        const SizedBox(height: 10),
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
                                trailing: (lrigCount[item] ?? 0) > 0
                                    ? Text("★${lrigCount[item]}")
                                    : null,
                                onTap: () => Navigator.pop(context, item),
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
      },
    );
  }

  @override
  void dispose() {
    eventCtrl.dispose();
    memoCtrl.dispose();
    super.dispose();
  }

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
                if (selected != null) setState(() => usedLrig = selected);
              },
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

            label("メモ"),
            TextField(controller: memoCtrl, maxLines: null),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: pickImage,
              child: const Text("デッキレシピ"),
            ),
            if (imagePath != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Image.memory(
                  base64Decode(imagePath!),
                  height: 120,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: save,
              child: const Text("保存"),
            ),
          ],
        ),
      ),
    );
  }
}
