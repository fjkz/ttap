Japanese in UTF-8

# TT-Runner: A Test Scripts Runner

**TT-Runner** はテストスクリプト群のディレクトリ構成のフレームワークです。テストスクリプト群はひとつのディレクトリ配下に定められた構成で配置されます。TT-Runner はファイル・ディレクトリの名前からスクリプトの実行順序を決定し、実行します。テスト結果は [TAP (Test Anything Protocol)](http://testanything.org/) で出力されます。

## 使用法

### テストの実行

以下のようなテストスクリプト群があったとします。以降、TT-Runner で実行されるテストスクリプト群のことをテストスイートと呼びます。

```
sample/test-simple
├── test_not_ok.sh
└── test_ok.sh
```

テストスイートのルートディレクトリを指定して `tt-runner` コマンドを実行すると、テストスイートが実行されます。`tt-runner` コマンドは、すべてのスクリプトの実行に成功した場合にはステータスコード `0` で終了し、失敗したスクリプトがあった場合にはステータスコード `1` で終了します。

テストの結果はコンソールに出力されます。標準出力は TAP に従います。

```
$ tt-runner sample/test-simple
1..2
not ok 1 test_not_ok.sh
ok 2 test_ok.sh
---
operations       : 2
succeeded        : 1
failed           : 1
skipped          : 0
time taken [sec] : 0

FAILURE

- 1 test_not_ok.sh

```

`--color` オプションを付与すると、コンソール出力が着色されます。

テストの結果は、`-o` オプションで指定されたディレクトリにも出力されます。`result.txt` は TAP フォーマットのテスト結果です。`*.out` はそれぞれのスクリプトの標準出力および標準エラー出力です。

```
$ tt-runner sample/test-simple -o result 1>/dev/null 2>/dev/null
$ ls result
1.test_not_ok.sh.out  2.test_ok.sh.out  result.txt
```

### テストスクリプトの書き方

テストスクリプトには、どのプログラミング言語も利用可能です。それぞれのスクリプトは以下の条件を満たす必要があります。

テストスクリプトのファイルは Unix 上で実行可能である必要があります。すなわち、読み込みと実行のパーミッションが付与されていなければなりません。パーミッションを持たないいスクリプトはスキップされます。また、Shebang（`#!` で始まるヘッダ）を忘れないでください。

テストスクリプトはテストが失敗した場合には非ゼロのステータスコードで終了しなければなりません。`tt-runner` はそれぞれのテストが成功・失敗をステータスコードから判断します。

テストスクリプトは、それぞれのスクリプトが存在するディレクトリをワーキングディレクトリとした状態で実行されることに注意してください。`tt-runner` はスクリプト実行時にワーキングディレクトリを変更します。もしワーキングディレクトリを変更されたくない場合は、`--no-change-dir` オプションを指定してください。

テストスクリプトの実行時には以下の環境変数が設定されており、スクリプトから利用できます。

- `TT_RUNNER_EXEC_DIR` 変数には、 `tt-runner` コマンドが実行されたワーキングディレクトリが含まれます。
- `TT_RUNNER_ROOT_DIR` 変数には、 `tt-runner` コマンドに指定されたテストスイートのルートディレクトリが含まれます。
- `TT_RUNNER_OUTPUT_DIR` 変数には、 `tt-runner` コマンドに `-o` オプションで指定されたテスト結果が出力されるディレクトリが含まれます。

### ディレクトリ構成

テストスイートが満たすべき命名規約およびディレクトリ構成を示します。

テストスイートに含まれるファイルおよびディレクトリは**ノード**と呼ばれます。6種のノードが定義されています：

- Test ノード、
- Run ノード、
- Before ノード、
- After ノード、
- Init ノード、
- Final ノード。

ノードの種別はファイル名で判別されます。各ノード種別のファイルはそれぞれ、`test`、`run`、`before`、`after`、`init`、`final`で始まります。これらは次のオプションで変更することができます：`--test-regex`、`--run-regex`、`--before-regex`、`--after-regex`、`--init-regex`、`--final-regex`。

ノードがディレクトリであった場合には、配下に子ノードを持つことができます。ディレクトリのノードが実行された時には、再帰的に子ノードが実行されます。

次にそれぞれのノードについて説明します。

### Test ノード

Test ノードとなっているスクリプトにテストされるべき操作が記述されます。

同じディレクトリ配下の Test ノードは順序を持ちません。各 Test ノードは独立しているべきです。「テストスイートの品質向上のために」の節を参照してください。

### Run ノード

Run ノードは他のノードの子ノードとして利用されます。Test ノードと異なり、同一ディレクトリ内の Run ノードは独立ではありません。Run ノードには順序があり、実行時には昇順に実行されます。

同一ディレクトリに Run ノードと他のノード種別を含むことは推奨しません。

### Before / After ノード

Before ノード・After ノードはそれぞれ、各 Test ノードの前処理、後処理を行います。JUnit４ の `@Before`・`@After` アノテーションが付与されたメソッドのように、各 Test ノードが実行される前後に実行されます。

前処理は昇順、後処理は降順で実行されます。

以下は実行例です。

```
$ tree sample/test-before-after
sample/test-before-after
├── after1.sh
├── after2.sh
├── before1.sh
├── before2.sh
├── test1.sh
└── test2.sh

$ tt-runner sample/test-before-after 2>/dev/null
1..10
ok 1 before1.sh
ok 2 before2.sh
ok 3 test1.sh
ok 4 after2.sh
ok 5 after1.sh
ok 6 before1.sh
ok 7 before2.sh
ok 8 test2.sh
ok 9 after2.sh
ok 10 after1.sh
```

なお、前処理が失敗した場合には、テストはスキップされます。

### Init / Final ノード


Init ノード・Final ノードは同一ディレクトリ内のすべてのテストが実行される前後に一度だけ実行されます。JUnit4 での `@BeforeClass`・`@AfterClass` アノテーションに相当します。

Before ノード・After ノードと同様に、Init ノードは昇順、Final ノードは降順に実行されます。

以下は実行例です。

```
$ tree sample/test-init-final
sample/test-init-final
├── final1.sh
├── final2.sh
├── init1.sh
├── init2.sh
├── test1.sh
└── test2.sh

$ tt-runner sample/test-init-final 2>/dev/null
1..6
ok 1 init1.sh
ok 2 init2.sh
ok 3 test1.sh
ok 4 test2.sh
ok 5 final2.sh
ok 6 final1.sh
```

### テストスイートのテスト

テストスイートのテストのために `tt-runner` では以下のコマンドラインオプションが利用できます。

- `--print-log` オプションが付与されると、実行中のスクリプトの出力がコンソールに出力されます。
- `--stop-on-failure` オプションが付与されると、ひとつの操作が失敗したときに残りの操作の実行はすべてスキップされます。この際、後処理もスキップされます。
- `--skip-all` オプションが付与されると、すべての操作はスキップされます。このオプションはスクリプトの実行計画の確認と、操作の番号を知るのに利用します。
- `--only` オプションで操作の番号が指定されると、指定された番号の操作のみが実行されます。ただし、前処理・後処理の操作は自動的に実行されないことに注意してください。
- `--skip` オプションで操作の番号が指定されると、指定された番号の操作はスキップされます。

### テストスイートの品質向上のために

各テストは独立であるべきです。テストの独立性を向上させるため、`tt-runner` コマンドは `--randomize` オプションが付与されたときには、テストの実行順序をランダムにします。同じディレクトリ配下のテストの順序がランダムに交換されます。乱数のシードは、実行時に出力されるサマリーに表示されます。再現性のため、`--randomize` オプションに乱数のシードを指定することもできます。

テストの前処理は冪当であるべきです。前処理のためのスクリプトの冪等性を守るために、`tt-runner` コマンドは `--multiply-preconditioning` オプションが指定されると、前処理の操作を連続して２回実行します。なお、後処理は冪当である必要はないことに注意してください。後処理は前処理が行われていることを期待して実行されるべきです。

## 必要環境

- Linux
- Python 2.7

## ライセンス

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a>

この作品は <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">クリエイティブ・コモンズ 表示-継承 4.0 国際ライセンス</a> の下に提供されています。