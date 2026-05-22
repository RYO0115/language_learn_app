.PHONY: build setup gen test apk shell doctor clean

# Docker イメージをビルド（初回・Flutter バージョン変更時のみ）
build:
	docker compose build

# 依存パッケージを取得
setup:
	docker compose run --rm flutter flutter pub get

# drift / riverpod のコード生成
gen:
	docker compose run --rm flutter dart run build_runner build --delete-conflicting-outputs

# ユニット・ウィジェットテストを実行
test:
	docker compose run --rm flutter flutter test

# テスト（カバレッジ付き）
test-cov:
	docker compose run --rm flutter flutter test --coverage

# Android APK をビルド
apk:
	docker compose run --rm flutter flutter build apk --release

# インタラクティブなシェルを起動
shell:
	docker compose run --rm flutter bash

# Flutter の診断情報を表示
doctor:
	docker compose run --rm flutter flutter doctor -v

# Dart の静的解析
analyze:
	docker compose run --rm flutter flutter analyze

# 生成ファイルと build/ を削除
clean:
	docker compose run --rm flutter flutter clean
