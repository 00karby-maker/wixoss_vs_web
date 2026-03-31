import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  final List<String> lrigList = [
    "タマ","タウィル","サシェ","リメンバ","ドーナ",
    "アキノ","LION","ノヴァ","ゆかゆか","ガブリエラ",
    "るう子","ゆきめ","エマ","にじさんじ","リゼ",
    "アンジュ","アズサ","サオリ","ネージュ",
    "花代","ユヅキ","赤タマ","ララ・ルー","リル",
    "カーニバル","レイラ","LOV","ヒラナ","LOVIT",
    "エクス","アザエラ","ちより","ジール",
    "ピルルク","エルドラ","ミルルン","ソウイ","あや",
    "青リメンバ","青タマ","青ウムル","レイ","タマゴ",
    "マドカ","みこみこ","ミカエラ","あきら","ネル",
    "ミヤコ","リップル","緑子","アン","アイヤイ","メル","ママ",
    "緑ユヅキ","緑ピルルク","アト","WOLF","バン",
    "サンガ","緑カーニバル","ひとえ","ホシノ","シロコ",
    "ユカリ","ミーティア","ウリス","イオナ","ウムル","ミュウ","ハナレ",
    "アルフォウ","ナナシ","グズ子","黒カーニバル","ムジカ",
    "デウス","マキナ","まほまほ","黒タマ","ヤミノ",
    "ヒナ","シュン","とこ","ヴィオラ","夢限"
  ];

  @override
  void initState() {
    super.initState();
    eventCtrl = TextEditingController(text: widget.record.eventName);
    memoCtrl = TextEditingController(text: widget.record.memo);

    format = ['A','K','D'].contains(widget.record.format) ? widget.record.format : 'A';
    round = widget.record.round > 0 && widget.record.round <= 10 ? widget.record.round : 1;
    firstSecond = ['先手','後手'].contains(widget.record.firstSecond) ? widget.record.firstSecond : '先手';
    result = ['勝','負'].contains(widget.record.result) ? widget.record.result : '勝';
    selfLb = widget.record.selfLb;
    oppLb = widget.record.opponentLb;
    date = widget.record.date;

    imagePath = widget.record.imagePath;
    usedLrig = widget.record.usedLrig;
    opponentLrig = widget.record.opponentLrig;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800, imageQuality: 70);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => imagePath = base64Encode(bytes));
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

  String normalize(String input) => input.split('').map((c) {
    final code = c.codeUnitAt(0);
    if (code >= 0x3041 && code <= 0x3096) return String.fromCharCode(code + 0x60);
    return c;
  }).join();

  Widget label(String t) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Align(alignment: Alignment.centerLeft, child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold))),
  );

  Future<String?> selectLrig(BuildContext context) async {
    String search = "";
    return showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          final filtered = lrigList.where((e) => normalize(e).contains(normalize(search))).toList();
          return AlertDialog(
            title: const Text("ルリグ選択"),
            content: SizedBox(
              width: double.maxFinite,
              height: 350,
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(hintText: "検索（ひらがなOK）", prefixIcon: Icon(Icons.search)),
                    onChanged: (v) => setState(() => search = v),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(filtered[index]),
                        onTap: () => Navigator.pop(context, filtered[index]),
                      ),
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

            label("フォーマット"),
            DropdownButton<String>(
              value: format,
              isExpanded: true,
              items: ['A','K','D'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => format = v!),
            ),

            label("●回戦"),
            DropdownButton<int>(
              value: round,
              isExpanded: true,
              items: List.generate(10, (i) => DropdownMenuItem(value: i+1, child: Text("${i+1}回戦"))),
              onChanged: (v) => setState(() => round = v!),
            ),

            label("先後・勝敗・LB数"),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: firstSecond,
                    isExpanded: true,
                    items: ["先手","後手"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => firstSecond = v!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: result,
                    isExpanded: true,
                    items: ["勝","負"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => result = v!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<int>(
                    value: selfLb,
                    isExpanded: true,
                    items: List.generate(10, (i) => DropdownMenuItem(value: i, child: Text("$i"))),
                    onChanged: (v) => setState(() => selfLb = v!),
                  ),
                ),
                const Text(" - "),
                Expanded(
                  child: DropdownButton<int>(
                    value: oppLb,
                    isExpanded: true,
                    items: List.generate(10, (i) => DropdownMenuItem(value: i, child: Text("$i"))),
                    onChanged: (v) => setState(() => oppLb = v!),
                  ),
                ),
              ],
            ),

            label("メモ"),
            TextField(controller: memoCtrl, maxLines: null),

            const SizedBox(height: 10),
            ElevatedButton(onPressed: pickImage, child: const Text("デッキレシピ")),
            if (imagePath != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Image.memory(base64Decode(imagePath!), height: 120),
              ),

            const SizedBox(height: 20),
            ElevatedButton(onPressed: save, child: const Text("保存")),
          ],
        ),
      ),
    );
  }
}
