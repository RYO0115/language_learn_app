# GitHub Actions による Raspberry Pi 自動デプロイ

PR を main ブランチへマージしたとき、自動で Raspberry Pi 4B のサーバーアプリを更新するフローの設計と実装手順書。

## 方式の選定

### 比較

| 方式 | しくみ | 長所 | 短所 |
|------|--------|------|------|
| **Self-hosted runner（推奨）** | Pi がランナーとして GitHub に接続し、ジョブを直接実行 | Pi の SSH ポートを外部に公開しなくてよい・シンプル | Pi が常時起動している必要がある（すでにそうなっている） |
| SSH デプロイ（Tailscale 経由） | GitHub Actions が Tailscale で VPN に接続してから SSH | ランナー不要 | Tailscale 認証キーと SSH 秘密鍵を Secrets に登録する必要がある・複雑 |
| Webhook リスナー | Pi が軽量 HTTP サーバーを持ち、GitHub の Webhook を受け取る | 最も軽量 | カスタム実装が必要・セキュリティ管理が煩雑 |

### 推奨: Self-hosted runner 方式

Pi が GitHub Actions のランナーエージェントとして登録される。GitHub にジョブが発生すると Pi が自分でジョブを取りに行き（アウトバウンド接続のみ）、コードを pull して再起動する。

```
[PR マージ → main]
        ↓
  GitHub Actions ジョブ発火
        ↓
  Pi 上のランナーエージェントがジョブを取得
        ↓
  git pull → uv sync → systemctl restart
```

---

## 実装手順

### Phase 1: Raspberry Pi にランナーを登録する

#### 1-1. GitHub でランナー登録トークンを取得する

1. リポジトリの **Settings → Actions → Runners** を開く
2. **「New self-hosted runner」** をクリック
3. **Linux / ARM64** を選択する
4. 表示されるコマンドをメモしておく（トークンは 1 時間有効）

#### 1-2. Pi にランナーをインストールする

Pi に SSH で接続して以下を実行する:

```bash
# ランナー用ディレクトリを作成
mkdir -p ~/actions-runner && cd ~/actions-runner

# 最新バージョンを確認して ARM64 版をダウンロード
# https://github.com/actions/runner/releases の最新バージョンに合わせること
RUNNER_VERSION="2.322.0"
curl -o actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz -L \
  https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz

tar xzf ./actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz
```

#### 1-3. ランナーを設定する

GitHub のページに表示された `./config.sh` コマンドを実行する（トークンはページから取得したものを使う）:

```bash
./config.sh --url https://github.com/<owner>/<repo> --token <TOKEN>
```

対話形式でいくつか質問される:

```
# Runner group: Enterキーでデフォルト(Default)のまま
# Runner name: pi（任意）
# Additional labels: raspberry-pi（任意。ジョブで絞り込むために使う）
# Work folder: Enterキーでデフォルト(_work)のまま
```

#### 1-4. systemd サービスとして登録する（自動起動）

```bash
# ランナー付属のスクリプトで systemd サービスを作成する
sudo ./svc.sh install pi   # "pi" はランナーを実行するユーザー名
sudo ./svc.sh start

# 起動確認
sudo ./svc.sh status
```

GitHub の **Settings → Actions → Runners** でランナーが **Idle** 状態になれば登録成功。

---

### Phase 2: Pi 側のデプロイ準備

#### 2-1. GitHub からコードを pull できるように設定する

Pi 上のアプリが現在 rsync でコピーされている場合、GitHub から直接 clone する形に切り替える。

```bash
# 既存のアプリディレクトリのバックアップ（データは別の場所に保管）
cp -r ~/language_learn_app/server_app/data ~/language_learn_data_backup

# GitHub から clone し直す
rm -rf ~/language_learn_app
git clone https://github.com/<owner>/<repo>.git ~/language_learn_app

# 依存関係をインストール
cd ~/language_learn_app/server_app
uv sync

# データディレクトリを復元
cp -r ~/language_learn_data_backup ~/language_learn_app/server_app/data

# .env ファイルは git 管理外なので手動で配置する
# ファイルがなければ以下で作成
nano ~/language_learn_app/server_app/.env
```

#### 2-2. systemd からの sudo なし再起動を許可する

デプロイスクリプトが `sudo systemctl restart language-learn` を使えるように sudoers を設定する:

```bash
sudo visudo -f /etc/sudoers.d/language-learn-deploy
```

> visudo は保存時に構文チェックを行い、エラーがあれば警告して保存をブロックしてくれる（直接 vi/nano で `/etc/sudoers.d/` を編集するのは構文チェックが走らないため非推奨）。

**vi の操作方法:**

vi には「ノーマルモード」と「インサートモード」の2つのモードがある。起動直後はノーマルモード。

| 操作 | キー |
|------|------|
| インサートモードに切り替え（文字入力を開始） | `i` |
| ノーマルモードに戻る | `Esc` |
| 保存して終了（ノーマルモードで入力） | `:wq` → `Enter` |
| 保存せず終了（ノーマルモードで入力） | `:q!` → `Enter` |

**手順:**
1. `sudo visudo -f /etc/sudoers.d/language-learn-deploy` を実行
2. `i` を押してインサートモードに入る
3. 以下の内容を入力する
4. `Esc` を押してノーマルモードに戻る
5. `:wq` と入力して `Enter` で保存・終了

以下の内容を入力して保存する:

```
pi ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart language-learn
pi ALL=(ALL) NOPASSWD: /usr/bin/systemctl status language-learn
```

> **Q: deploy.yml の中で sudo コマンドを使うとパスワードを求められないか?**
> GitHub Actions はターミナルに人間がいないため、パスワードの対話入力ができない。
> パスワードなしで実行できないと CI がハング・タイムアウトして失敗する。
> この `NOPASSWD` 設定がその対策であり、**deploy.yml を作成する前に必ず Pi 側で済ませておく必要がある。**

#### 2-3. git pull 用の SSH 鍵を設定する（プライベートリポジトリの場合）

リポジトリがプライベートの場合は Pi から GitHub へのアクセスに Deploy Key を使う。

```bash
# Pi 上で鍵を生成
ssh-keygen -t ed25519 -C "raspberry-pi-deploy" -f ~/.ssh/github_deploy -N ""
cat ~/.ssh/github_deploy.pub
```

表示された公開鍵を GitHub の **Settings → Deploy keys** に登録する（Read-only で OK）。

```bash
# ~/.ssh/config に追記
cat >> ~/.ssh/config << 'EOF'

Host github.com
  IdentityFile ~/.ssh/github_deploy
  StrictHostKeyChecking no
EOF
```

---

### Phase 3: GitHub Actions ワークフローを作成する

`.github/workflows/deploy.yml` を作成する:

```yaml
name: Deploy to Raspberry Pi

on:
  push:
    branches:
      - main
    paths:
      - "server_app/**"      # server_app に変更があった場合のみデプロイ

jobs:
  deploy:
    name: Deploy server_app
    runs-on: [self-hosted, raspberry-pi]   # Pi のランナーを指定
    timeout-minutes: 10

    steps:
      - name: Checkout latest code
        uses: actions/checkout@v4

      - name: Install / update dependencies
        working-directory: server_app
        run: uv sync --frozen

      - name: Restart service
        run: sudo systemctl restart language-learn

      - name: Verify service is running
        run: |
          sleep 3
          sudo systemctl status language-learn --no-pager
```

> **paths フィルターについて:**
> `server_app/**` を指定することで、Flutter アプリや docs の変更だけの場合はデプロイが走らない。
> `paths` を外せばすべての push でデプロイされる。

---

### Phase 4: 動作確認

1. 適当なブランチを作り `server_app/` 内のファイルを変更してコミット
2. PR を作成して main にマージ
3. GitHub の **Actions タブ**で `Deploy to Raspberry Pi` ジョブが実行されることを確認
4. ジョブが成功したら Pi 上でサービスが再起動していることを確認

```bash
# Pi 上で確認
sudo journalctl -u language-learn -n 30
sudo systemctl status language-learn
```

---

## データ・設定ファイルの保護

デプロイ時に上書きしてはいけないファイルがある。

| ファイル/ディレクトリ | 内容 | 対処 |
|----------------------|------|------|
| `server_app/data/` | SQLite DB | `.gitignore` 済み・git pull で変更されない |
| `server_app/.env` | API キーなど | `.gitignore` 済み・git pull で変更されない |

`git pull` は git 管理外のファイルを削除しないので、これらは安全。

---

## 既存ワークフローとの連携

このリポジトリには以下のワークフローがすでに存在する:

| ワークフロー | トリガー | 動作 |
|-------------|---------|------|
| `auto-tag.yml` | main へ push（pyproject.toml 変更時） | バージョンタグを自動作成 |
| `release.yml` | タグ push | GitHub Release を自動作成 |
| `deploy.yml`（今回追加） | main へ push（server_app 変更時） | Pi にデプロイ |

これらは独立して動作するため競合しない。

---

## トラブルシューティング

### ランナーが Offline になる

```bash
# Pi 上でランナーサービスを確認
sudo systemctl status actions.runner.*

# 再起動
sudo systemctl restart actions.runner.*
```

### `uv sync` が失敗する

```bash
# Pi 上で手動実行してエラーを確認
cd ~/language_learn_app/server_app
uv sync
```

### git pull でコンフリクトが起きる

デプロイワークフロー内の `actions/checkout@v4` は `git fetch + git reset --hard` 相当の動作をするため、Pi 上の変更は上書きされる。Pi 上で直接ファイルを編集しないこと。

### sudo なしで systemctl が実行できない

```bash
# sudoers の設定を確認
sudo cat /etc/sudoers.d/language-learn-deploy

# テスト
sudo systemctl restart language-learn
```

---

## 代替案: SSH デプロイ（Tailscale 経由）

Self-hosted runner を使いたくない場合の代替手順。

### 必要な GitHub Secrets

| Secret 名 | 内容 |
|-----------|------|
| `TAILSCALE_AUTH_KEY` | Tailscale の Ephemeral 認証キー |
| `PI_SSH_KEY` | Pi への SSH 秘密鍵 |
| `PI_TAILSCALE_IP` | Pi の Tailscale IP（100.x.x.x） |
| `PI_USER` | Pi のユーザー名（pi） |

### Tailscale 認証キーの取得

1. Tailscale 管理コンソール → **Settings → Keys**
2. **Generate auth key** で Ephemeral キーを生成
3. GitHub Secrets に `TAILSCALE_AUTH_KEY` として登録

### SSH デプロイワークフロー

```yaml
name: Deploy to Raspberry Pi (SSH)

on:
  push:
    branches:
      - main
    paths:
      - "server_app/**"

jobs:
  deploy:
    runs-on: ubuntu-latest
    timeout-minutes: 10

    steps:
      - name: Connect to Tailscale
        uses: tailscale/github-action@v3
        with:
          authkey: ${{ secrets.TAILSCALE_AUTH_KEY }}

      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.PI_TAILSCALE_IP }}
          username: ${{ secrets.PI_USER }}
          key: ${{ secrets.PI_SSH_KEY }}
          script: |
            cd ~/language_learn_app
            git pull origin main
            cd server_app
            uv sync --frozen
            sudo systemctl restart language-learn
            sleep 3
            sudo systemctl status language-learn --no-pager
```

---

*作成日: 2026-06-12*
