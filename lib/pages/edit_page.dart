import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

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

  late Box lrigBox;
  final Map<String, int> lrigCount = {};

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

    eventCtrl = TextEditingController(text: widget.record.eventName);
    memoCtrl = TextEditingController(text: widget.record.memo);

    result = widget.record.result;
    firstSecond = widget.record.firstSecond;
    selfLb = widget.record.selfLb;
    oppLb = widget.record.opponentLb;
    format = widget.record.format;
    round = widget.record.round;
    date = widget.record.date;

    imagePath = widget.record.imagePath; // URL
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

  /// 🔥 Firebase対応画像アップロード
  Future<void> pickImage() async {
  final picker = ImagePicker();
  final file = await picker.pickImage(source: ImageSource.gallery);

  if (file == null) return;

  final bytes = await file.readAsBytes();
  final name = DateTime.now().millisecondsSinceEpoch.toString();

  final ref = FirebaseStorage.instance
      .ref()
      .child('images/$name.jpg');

  await ref.putData(bytes);

  final url = await ref.getDownloadURL();

  setState(() {
    imagePath = url;
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

  Future<String?> selectLrig(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("ルリグ選択"),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView(
              children: lrigList.map((e) {
                return ListTile(
                  title: Text(e),
                  onTap: () => Navigator.pop(context, e),
                );
              }).toList(),
            ),
          ),
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

            /// 🔥 画像
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("デッキレシピ"),
            ),

            if (imagePath != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Image.network(imagePath!, height: 120),
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
