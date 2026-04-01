import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  /// セクション全体
  Widget section(
    BuildContext context,
    String title,
    List<Widget> contents,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...contents,
        ],
      ),
    );
  }

  /// 説明テキスト
  Widget helpText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  /// タップで拡大できる画像
  Widget helpImage(BuildContext context, String path) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: InteractiveViewer(
                  child: Image.asset(path),
                ),
              ),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Image.asset(path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('使い方')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// データ入力
            section(
              context,
              'データ入力タブ',
              [
                helpText('対戦データを記録できます'),
                helpImage(context, 'assets/help/input_1.png'),
                helpText('①タブ名を選択すると移動します。\n動作は全画面共通です。'),
                helpText('②デッキレシピ画像を登録できます。\nダイヤログが開かれ、画像選択するとサムネイルが表示されます。'),
                helpText('③大会名を入力できます。'),
                helpText('④カレンダーから日付を選択できます。\nデフォルトは当日です。'),
                helpText('⑤使用ルリグを選択できます。\n選択するとルリグ選択画面が表示されます。'),
                helpText('⑥フォーマットを選択できます。\nA(オール)K(キー)D(ディーヴァ)から選択できます。'),
                helpImage(context, 'assets/help/input_3.png'),
                helpText('①対戦ルリグを選択できます。\n選択するとルリグ選択画面が表示されます。'),
                helpText('②先手後手を選択できます。'),
                helpText('③勝敗を選択できます。'),
                helpText('④自分と相手のライフバースト数を記録できます。'),
                helpText('⑤メモを記録できます。右端で折り返されます。'),
                helpText('⑥対戦追加ボタンで対戦数を追加、保存ボタンで対戦結果を保存できます。\n保存すると入力項目はリセットされます。'),
                helpText('▼ルリグ選択画面'),
                helpImage(context, 'assets/help/input_4.png'),
                helpText('ルリグ名で検索できます。\nひらがなにも対応し、右端には使用回数が表示され、最も使用回数が多いルリグは最上段に表示されます。'),
              ],
            ),

            /// 履歴検索
            section(
              context,
              '履歴検索タブ',
              [
                helpText('保存した対戦履歴を検索できます。\n検索結果は履歴タブで詳細を見ることができます。'),
                helpImage(context, 'assets/help/search_1.png'),
                helpText('①絞り込み条件に履歴を追加することができます。'),
                helpText('②絞り込み条件にフォーマットを追加することができます。'),
                helpText('③絞り込み条件に日付を追加できます。\n開始と終了を設定することで一定期間で絞ることもできます。'),
                helpText('④絞り込み条件に使用ルリグや対戦ルリグを追加できます。\nひらがなにも対応しています。'),
                helpText('⑤全ての絞り込み条件を解除します。'),
                helpText('⑥簡易的に検索結果を表示します。\nスクロールで移動でき、対戦を選択すると履歴編集画面に移行します。'),
                helpText('▼履歴編集画面'),
                helpText('入力画面とほぼ同じ操作です'),
                helpImage(context, 'assets/help/edit_1.png'),
                helpText('①大会名を編集できます。'),
                helpText('②日付を編集できます。'),
                helpText('③使用ルリグや対戦ルリグを編集できます。'),
                helpText('④フォーマットを編集できます。'),
                helpText('⑤対戦した回戦を編集できます。'),
                helpText('⑥先手後手、勝敗、ライフバースト数を編集できます。'),
                helpImage(context, 'assets/help/edit_2.png'),
                helpText('①メモを編集できます。'),
                helpText('②デッキレシピ画像を編集できます。'),
                helpText('③保存して遷移前の画面に戻ります。'),
              ],
            ),

            /// 履歴
            section(
              context,
              '履歴タブ',
              [
                helpText('対戦履歴が表示されます'),
                helpImage(context, 'assets/help/history_1.png'),
                helpText('①対戦結果が１戦ごとに表示されます。'),
                helpText('②押すと対戦結果の詳細を表示します。'),
                helpImage(context, 'assets/help/history_2.png'),
                helpText('①大会名とデッキレシピを表示します。\nサムネイルを選択すると拡大します。'),
                helpText('メモ欄を表示します。\n鉛筆マークを選択すると履歴編集画面に遷移し、ゴミ箱マークを選択するとその履歴を削除します。'),
              ],
            ),

            /// 統計
            section(
              context,
              '統計タブ',
              [
                helpText('履歴から集計したグラフデータが表示されます。'),
                helpImage(context, 'assets/help/stats_1.png'),
                helpText('①表示するフォーマットを選択できます。デフォルトは∀(全て)です。'),
                helpText('②使用ルリグの割合円グラフです。\nタップ・ホバーすると色が強調され、対象ルリグの名前が光ります。'),
                helpText('③使用ルリグ割合です。\n高い順になっており、数が多い場合はスクロール可能です。'),
                helpImage(context, 'assets/help/stats_2.png'),
                helpText('　'),
                helpImage(context, 'assets/help/stats_3.png'),
                helpText('①対戦ルリグの割合円グラフです。\nタップ・ホバーすると色が強調され、対象ルリグの名前が光ります。'),
                helpText('②使用ルリグ割合です。\n高い順になっており、数が多い場合はスクロール可能です。'),
                helpImage(context, 'assets/help/stats_4.png'),
                helpText('　'),
                helpImage(context, 'assets/help/stats_5.png'),
                helpText('使用したルリグの勝率棒グラフです。\n上位5ルリグはTier表示されます。タップ・ホバーするとルリグ名・勝率・勝敗数が表示されます。'),
                helpImage(context, 'assets/help/stats_6.png'),
              ],
            ),

            /// 最後
            section(
              context,
              '謝謝茄子',
              [
                helpText('最後になりますが当アプリを試していただきありがとうございます！'),
                helpText('ご要望・エラー報告・感想などあれば以下にお願いします。'),
                helpText('フォローは推奨いたしません！！！！！！'),
                helpText('https://x.com/armada_strike'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}