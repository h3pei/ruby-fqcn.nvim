# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

RubyファイルのクラスやモジュールからFQCN（完全修飾クラス名）を取得するNeovimプラグイン。nvim-treesitterを使用してASTベースで正確な名前解決を行う。`:CopyRubyFQCN`コマンドによるクリップボードへのコピーと、他プラグインから利用可能な`get_fqcn()` APIを提供。

## 開発環境

- Neovim 0.10+
- nvim-treesitter（Rubyパーサー必須）

## アーキテクチャ

### ファイル構成

- `plugin/ruby-fqcn.lua` - プラグインエントリーポイント、`:CopyRubyFQCN`コマンド登録
- `lua/ruby-fqcn/init.lua` - 公開API（`get_fqcn()`, `copy_fqcn()`）
- `lua/ruby-fqcn/fqcn.lua` - コアロジック
- `lua/ruby-fqcn/utils.lua` - 通知ユーティリティ

### 主要な処理フロー

1. `copy_fqcn()` - FQCNを取得してクリップボードにコピー
2. `get_fqcn()` - filetypeチェック後、namespace chainを取得して`::`で連結（公開API）
3. `get_namespace_chain()` - カーソル位置からtree-sitterで親ノードを辿り、class/module/定数代入を収集

### Tree-sitter ノードタイプ

- `class` / `module` - クラス・モジュール定義
- `assignment` - 定数代入（`Foo = Struct.new`、`Bar = Class.new` 等）
- `constant` - 定数名
- `scope_resolution` - `::`による名前空間解決（例: `Foo::Bar`）

### エラーハンドリング方針

- 全ての関数は失敗時に `utils.notify_warn()` で通知し、`nil` を返す
- 複数返り値（`value, err`）パターンは使用しない
