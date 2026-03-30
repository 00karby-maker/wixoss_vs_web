import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/match_record.dart';
import 'search_state.dart';
import 'edit_page.dart';

/// ひらがな⇔カタカナ変換ユーティリティ
String toHiragana(String input) {
  return input.splitMapJoin(RegExp(r'[ァ-ン]'), onMatch: (m) {
    return String.fromCharCode(m[0]!.codeUnitAt(0) - 0x60);
  }, onNonMatch: (n) => n);
}

String toKatakana(String input) {
  return input.splitMapJoin(RegExp(r'[ぁ-ん]'), onMatch: (m) {
    return String.fromCharCode(m[0]!.codeUnitAt(0) + 0x60);
  }, onNonMatch: (n) => n);
}

class HistorySearchPage extends StatelessWidget {
  const HistorySearchPage({super.key});

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

  String formatDate(DateTime? d) {
    if (d == null) return "未選択";
    return "${d.year}/${d.month}/${d.day}";
  }

  Iterable<String> fuzzyFilter(List<String> options, String input) {
    final queryH = toHiragana(input.toLowerCase());
    final queryK = toKatakana(input.toLowerCase());
    return options.where((o) {
      final optionLower = o.toLowerCase();
      final optionH = toHiragana(optionLower);
      final optionK = toKatakana(optionLower);
      return optionLower.contains(input.toLowerCase()) ||
          optionH.contains(queryH) ||
          optionK.contains(queryK);
    });
  }

  List<String> getAllSuggestions(Box<MatchRecord> box) {
    final set = <String>{};
    for (var r in box.values) {
      if (r.usedLrig.isNotEmpty) set.add(r.usedLrig);
      if (r.opponentLrig.isNotEmpty) set.add(r.opponentLrig);
      if (r.eventName.isNotEmpty) set.add(r.eventName);
    }
    return set.toList();
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

    if (box.isEmpty) return const Center(child: Text("記録がありません"));

    final allSuggestions = getAllSuggestions(box);
    final filteredRecords = filterRecords(box, searchState);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// キーワード検索
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
              return fuzzyFilter(allSuggestions, textEditingValue.text);
            },
            onSelected: (selection) => searchState.setKeyword(selection),
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  hintText: "検索（大会名・ルリグ）",
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (v) => searchState.setKeyword(v),
              );
            },
          ),
          const SizedBox(height: 8),

          /// フォーマット選択
          Wrap(
            spacing: 6,
            children: ["すべて", "A", "K", "D"].map((e) {
              return ChoiceChip(
                label: Text(e),
                selected: searchState.formatFilter == e,
                onSelected: (_) => searchState.setFormatFilter(e),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          /// 日付選択
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: searchState.startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) searchState.setStartDate(picked);
                  },
                  child: Text("開始: ${formatDate(searchState.startDate)}"),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: searchState.endDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) searchState.setEndDate(picked);
                  },
                  child: Text("終了: ${formatDate(searchState.endDate)}"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          /// 使用ルリグ入力
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
              return fuzzyFilter(allSuggestions, textEditingValue.text);
            },
            onSelected: (selection) => searchState.addUsedFilter(selection),
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: "使用ルリグ追加",
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (v) {
                  if (v.isEmpty) return;
                  searchState.addUsedFilter(v);
                  controller.clear();
                },
              );
            },
          ),
          Wrap(
            spacing: 6,
            children: searchState.usedFilters.map((e) {
              return Chip(
                label: Text(e),
                backgroundColor: getColor(e, colorMap).withOpacity(0.2),
                onDeleted: () => searchState.removeUsedFilter(e),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          /// 対戦ルリグ入力
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
              return fuzzyFilter(allSuggestions, textEditingValue.text);
            },
            onSelected: (selection) => searchState.addOpponentFilter(selection),
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: "対戦ルリグ追加",
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (v) {
                  if (v.isEmpty) return;
                  searchState.addOpponentFilter(v);
                  controller.clear();
                },
              );
            },
          ),
          Wrap(
            spacing: 6,
            children: searchState.opponentFilters.map((e) {
              return Chip(
                label: Text(e),
                backgroundColor: getColor(e, colorMap).withOpacity(0.2),
                onDeleted: () => searchState.removeOpponentFilter(e),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          /// リセット
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: searchState.reset,
              child: const Text("リセット"),
            ),
          ),
          const Divider(),

          /// 🔹 絞り込みプレビュー（スクロール対応・件数制限なし）
          Text(
            "一致件数: ${filteredRecords.length}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),

          SizedBox(
            height: 400,
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                itemCount: filteredRecords.length,
                itemBuilder: (_, i) {
                  final r = filteredRecords[i];
                  return ListTile(
                    title: Text("${r.usedLrig} vs ${r.opponentLrig}"),
                    subtitle: Text("${r.eventName} / ${r.round}回戦 ・ ${r.date.year}/${r.date.month}/${r.date.day}"),
                    trailing: Text(r.result),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EditPage(record: r)),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
