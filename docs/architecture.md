# アーキテクチャ詳細

このドキュメントでは、ruby-fqcn.nvim の内部ロジックについて詳しく説明します。

## Tree-sitter の活用

本プラグインは nvim-treesitter を使用して Ruby コードを AST（抽象構文木）として解析し、クラスやモジュールの構造を正確に把握します。

### AST の例

```ruby
module Foo
  class Bar
    def method
    end
  end
end
```

上記のコードは以下のような AST 構造になります：

```
program
└── module (name: "Foo")
    └── class (name: "Bar")
        └── method (name: "method")
```

## 主要な処理フロー

### 1. FQCN 取得の基本フロー

```
copy_fqcn()
    ↓
get_fqcn()
    ↓
get_namespace_chain()
    ↓
カーソル位置から親ノードを辿る
    ↓
class/module/定数代入 ノードを収集
    ↓
名前を :: で連結
```

### 2. カーソル位置からの探索

`get_namespace_chain()` 関数では以下の手順で FQCN を構築します：

1. **パーサー取得**: `vim.treesitter.get_parser(bufnr, 'ruby')` で Ruby パーサーを取得
2. **AST 生成**: `parser:parse()` でソースコードを AST に変換
3. **有効カラム位置の計算**: カーソルが行頭（インデント部分）にある場合、最初の非空白文字の位置を使用
4. **ノード取得**: `root:named_descendant_for_range(row, effective_col, row, effective_col)` で有効位置に対応するノードを取得
5. **親ノード探索**: `node:parent()` を繰り返し呼び出して親を辿る
6. **名前空間収集**: ノードタイプが `'class'`、`'module'`、または `'assignment'`（定数代入）の場合、名前を収集

#### 有効カラム位置について

カーソルが行頭のインデント部分にある場合、そのままの位置でノードを取得すると親の module/class の body 部分が返され、その行で定義されている class/module が含まれないことがあります。

```ruby
module Foo
  class Bar  # ← この行の先頭にカーソルがある場合
  end
end
```

この問題を解決するため、カーソルが最初の非空白文字より前にある場合は、最初の非空白文字の位置（`class` キーワードの位置）を使用してノードを取得します。

## Tree-sitter ノードタイプ

### class / module ノード

クラスやモジュールの定義を表します。`field('name')` で名前ノードを取得できます。

```ruby
module Foo      # type: 'module', name: 'Foo'
class Bar       # type: 'class', name: 'Bar'
class Baz < Qux # type: 'class', name: 'Baz'（継承は別フィールド）
```

### assignment ノード（定数代入）

定数への代入を表します。`Struct.new`、`Class.new`、`Data.define` などで定義されたクラスを検出するために使用します。

```ruby
Customer = Struct.new(:name, :address)  # type: 'assignment'
Point = Data.define(:x, :y)             # type: 'assignment'
```

`field('left')` で左辺（代入先）を取得し、それが `constant` ノードの場合のみ名前空間として扱います。

#### ブロック付き定数代入の例

```ruby
module Foo
  Customer = Struct.new(:name) do
    def greeting  # ← カーソルがここにある場合
      "Hello"
    end
  end
end
```

この場合、カーソル位置から親を辿ると：
1. `def greeting` → `do...end` ブロック → `assignment` ノード（Customer）→ `module` ノード（Foo）
2. `Customer` と `Foo` を収集
3. 結果: `Foo::Customer`

### constant ノード

定数名（クラス名、モジュール名など）を表します。

```ruby
Foo  # type: 'constant', text: 'Foo'
```

### scope_resolution ノード

`::` による名前空間解決を表します。

```ruby
Foo::Bar::Baz  # type: 'scope_resolution', text: 'Foo::Bar::Baz'
```

`scope_resolution` ノードは再帰的な構造を持ちますが、本プラグインでは `vim.treesitter.get_node_text()` でテキストをそのまま取得することで簡潔に処理しています。

## ファイル構成

```
lua/ruby-fqcn/
├── init.lua           # エントリポイント（公開 API）
├── fqcn.lua           # メインロジック
├── utils.lua          # 通知ユーティリティ
└── types/
    └── treesitter.lua # TSNode 型定義（LuaLS 用）
```

### 各ファイルの役割

#### init.lua
- 公開 API（`get_fqcn()`, `copy_fqcn()`）をエクスポート
- `fqcn.lua` への薄いラッパー

#### fqcn.lua
- Tree-sitter を使用した FQCN 取得ロジック
- 主要関数:
  - `get_node_name()` - ノードから名前を抽出（constant / scope_resolution 対応）
  - `get_class_or_module_name()` - class/module ノードから名前を取得
  - `get_constant_assignment_name()` - assignment ノードから定数名を取得
  - `get_namespace_chain()` - カーソル位置から名前空間チェーンを構築
  - `get_fqcn()` - FQCN 文字列を取得
  - `copy_fqcn()` - FQCN をクリップボードにコピー

#### utils.lua
- 通知関数（`notify_info()`, `notify_warn()`, `notify_error()`）
- `vim.notify()` のラッパー

#### types/treesitter.lua
- LuaLS 用の TSNode 型定義
- `---@meta` ディレクティブで型情報のみを提供

## エラーハンドリング

本プラグインでは、全ての関数が以下の方針でエラーを処理します：

1. エラー発生時に `utils.notify_warn()` で通知
2. `nil` を返す

複数返り値（`value, err`）パターンは使用せず、シンプルさを優先しています。

### エラーケース

- **filetype が ruby 以外**
- **Tree-sitter パーサー未検出**
- **パース不可**
- **ノード未検出**
- **名前空間未検出**

## 設計判断

### カーソル位置外の処理

カーソルが class/module の外にある場合（ファイル先頭のコメント行など）は、エラーとして扱います。以前はファイル全体を探索して唯一のクラスを返すフォールバック処理がありましたが、以下の理由で削除しました：

- **シンプルさ**: コードが大幅に短くなる
- **予測可能性**: 「カーソル位置の親を辿る」という一貫した挙動
- **意図の明確さ**: ユーザーがカーソルを置いた場所が重要

### 定数代入のサポート

`Struct.new` や `Data.define` で定義されたクラスもサポートしています。これらは厳密にはクラス定義ではありませんが、実用上クラスとして扱われるため対応しています。

## 制限事項

- `filetype` が `ruby` 以外の場合は動作しない
- Tree-sitter の Ruby パーサーが必要
- カーソルが class/module/定数代入の外にある場合は FQCN を取得できない
