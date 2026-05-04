# Raspberry Pi 4B サーバー構築手順書

iPhone からどこでもアクセスできる単語帳アプリサーバーを Raspberry Pi 4B で構築する手順書です。

## アクセス構成

```
iPhone（外出先・自宅どこでも）
    ↓  Tailscale VPN（WireGuard 暗号化）
Raspberry Pi 4B
    ↓
単語帳アプリ（FastAPI + SQLite）
```

**Tailscale を採用する理由:**
- 完全無料（デバイス無制限・6ユーザーまで）
- ルーターのポート開放が不要（外部から直接さらされない）
- WireGuard ベースのエンドツーエンド暗号化
- 自宅でも外出先でも同じ IP でアクセスできる

---

## 必要なもの

| 機材 | 備考 |
|------|------|
| Raspberry Pi 4B | RAM 2GB 以上推奨 |
| microSD カード | 32GB 以上・A2 規格推奨（SanDisk / Samsung など） |
| Mac または Windows PC | 初期設定用 |
| 自宅の Wi-Fi または有線 LAN | Pi の接続用 |

---

## ステップ 1: Raspberry Pi OS のセットアップ

### 1-1. Raspberry Pi Imager をインストール

Mac/Windows の PC で以下からダウンロードしてインストールします。

```
https://www.raspberrypi.com/software/
```

### 1-2. microSD に OS を書き込む

1. Imager を起動する
2. **Raspberry Pi Device** → `Raspberry Pi 4` を選択
3. **Operating System** → `Raspberry Pi OS (other)` → `Raspberry Pi OS Lite (64-bit)` を選択
   - ※ GUI 不要のサーバー用に Lite 版を選ぶ
4. **Storage** → microSD カードを選択
5. **歯車アイコン（詳細設定）** を開き以下を設定する

```
ホスト名:         raspberrypi（任意、例: langlearn）
ユーザー名:       pi
パスワード:       [強力なパスワード ※後で SSH 鍵に変更するが必須]
Wi-Fi SSID:     [自宅の Wi-Fi 名]
Wi-Fi パスワード: [Wi-Fi のパスワード]
ロケール:        Asia/Tokyo / ja
SSH:            有効にする → 「公開鍵認証のみ使用」を選択し Mac の公開鍵を貼り付ける
```

> **Mac の公開鍵の確認方法:**
> ```bash
> cat ~/.ssh/id_ed25519.pub
> # ファイルがない場合は先に生成する
> ssh-keygen -t ed25519
> ```

6. **Write** をクリックして書き込む（5〜10 分程度）

### 1-3. Pi に電源を入れて SSH 接続する

```bash
# Pi が起動するまで 1〜2 分待つ
ssh pi@raspberrypi.local

# ホスト名を変更した場合（例: langlearn）
ssh pi@langlearn.local
```

### 1-4. 初期アップデート

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git ufw fail2ban
sudo timedatectl set-timezone Asia/Tokyo
```

---

## ステップ 2: セキュリティ設定

### 2-1. SSH のパスワード認証を無効化

```bash
sudo nano /etc/ssh/sshd_config
```

以下の行を見つけて変更する（`#` がついている場合は外す）:

```
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
```

```bash
sudo systemctl restart sshd
```

> ⚠️ この設定は SSH 鍵でログインできることを確認してから行ってください。
> ロックアウトされると復旧が大変になります。

### 2-2. ファイアウォール（UFW）を設定する

```bash
# デフォルトポリシーを設定
sudo ufw default deny incoming
sudo ufw default allow outgoing

# SSH を許可（必ず最初に設定する）
sudo ufw allow ssh

# アプリポートを自宅ネットワーク内のみ許可
# ※ 自宅のネットワークアドレスに合わせて変更（大抵は 192.168.1.0/24 か 192.168.0.0/24）
sudo ufw allow from 192.168.1.0/24 to any port 8000

# UFW を有効化
sudo ufw enable

# 設定確認
sudo ufw status verbose
```

> **自宅のネットワークアドレスの確認方法（Mac）:**
> ```bash
> ipconfig getifaddr en0    # Wi-Fi
> ipconfig getifaddr en1    # 有線の場合もある
> # 例: 192.168.1.5 → ネットワークアドレスは 192.168.1.0/24
> ```

### 2-3. fail2ban を設定する（SSH への総当たり攻撃対策）

```bash
sudo nano /etc/fail2ban/jail.local
```

以下の内容を貼り付ける:

```ini
[DEFAULT]
bantime  = 1h
findtime = 10m
maxretry = 5

[sshd]
enabled = true
port    = ssh
```

```bash
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

---

## ステップ 3: Python と uv のインストール

```bash
# uv をインストール（公式スクリプト）
curl -LsSf https://astral.sh/uv/install.sh | sh

# パスを通す（.bashrc に追記）
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# インストール確認
uv --version
```

---

## ステップ 4: アプリをデプロイする

### 4-1. Mac からアプリを Pi にコピーする

Mac のターミナルで実行する:

```bash
# アプリディレクトリを Pi にコピー（Mac 側で実行）
rsync -av --exclude='.venv' --exclude='data/' --exclude='__pycache__' \
  /Users/ryota_amano/workspace/python_workspace/language_learn_app/ \
  pi@raspberrypi.local:~/language_learn_app/
```

> **rsync の意味:**
> - `--exclude='.venv'` : 仮想環境はコピーしない（Pi 上で再構築する）
> - `--exclude='data/'` : DB ファイルは Pi 側で新たに作成されるためコピーしない

### 4-2. Pi 上で依存関係をインストールする

Pi に SSH で接続して実行:

```bash
cd ~/language_learn_app

# 仮想環境を作成して依存関係をインストール
uv sync

# インストール確認
uv run python -c "from language_learn.main import app; print('OK')"
```

### 4-3. 環境変数ファイルを作成する

```bash
cp .env.example .env
nano .env
```

以下を設定する:

```env
# Gemini を使う場合（推奨・無料）
AI_PROVIDER=gemini
GOOGLE_API_KEY=your_google_api_key_here
GEMINI_MODEL=gemini-2.0-flash

# Claude を使う場合
# AI_PROVIDER=claude
# ANTHROPIC_API_KEY=your_anthropic_api_key_here

APP_NAME=Language Learn App
DEBUG=false
```

### 4-4. 動作確認（テスト起動）

```bash
uv run uvicorn language_learn.main:app --host 0.0.0.0 --port 8000
```

Mac のブラウザで `http://raspberrypi.local:8000` を開いてアプリが表示されることを確認する。
確認できたら `Ctrl + C` で終了する。

---

## ステップ 5: systemd サービスとして登録する（自動起動）

Pi の電源を入れるだけでアプリが自動で起動するよう設定する。

```bash
sudo nano /etc/systemd/system/language-learn.service
```

以下の内容を貼り付ける:

```ini
[Unit]
Description=Language Learn App
After=network-online.target
Wants=network-online.target

[Service]
User=pi
Group=pi
WorkingDirectory=/home/pi/language_learn_app
Environment="PATH=/home/pi/.local/bin:/usr/local/bin:/usr/bin:/bin"
ExecStart=/home/pi/language_learn_app/.venv/bin/uvicorn language_learn.main:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=5s
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

```bash
# サービスを登録・起動
sudo systemctl daemon-reload
sudo systemctl enable language-learn
sudo systemctl start language-learn

# 状態確認
sudo systemctl status language-learn

# ログを見る
sudo journalctl -u language-learn -f
```

---

## ステップ 6: Tailscale のセットアップ（どこからでもアクセス）

### 6-1. Tailscale アカウントを作成する

`https://tailscale.com` にアクセスし、Google または GitHub アカウントで無料登録する。

### 6-2. Pi に Tailscale をインストールする

```bash
# インストール（ワンライナー）
curl -fsSL https://tailscale.com/install.sh | sh

# 起動して認証する
sudo tailscale up

# 表示された URL（https://login.tailscale.com/a/...）を
# ブラウザで開いて Tailscale アカウントでログインする

# Pi の Tailscale IP を確認（100.x.x.x 形式）
tailscale ip -4
```

### 6-3. iPhone に Tailscale をインストールする

1. App Store で **「Tailscale」** を検索してインストールする
2. アプリを開いて **同じ Tailscale アカウントでログイン** する
3. VPN 接続を許可する（iOS の設定で VPN プロファイルが追加される）

### 6-4. iPhone からアクセスする

Tailscale アプリで VPN を ON にした状態で、Safari を開き以下の URL を入力する:

```
http://100.x.x.x:8000
```

> `100.x.x.x` はステップ 6-2 で確認した Pi の Tailscale IP アドレス

### 6-5. ファイアウォールに Tailscale インターフェースを追加する

```bash
# Tailscale 経由のアクセスのみポート 8000 を許可する
sudo ufw allow in on tailscale0 to any port 8000
sudo ufw reload
```

---

## ステップ 7: Safari のホーム画面に追加する（アプリっぽく使う）

iPhone の Safari でアプリを開いた状態で:

1. 画面下部の **共有ボタン（□に↑）** をタップ
2. **「ホーム画面に追加」** をタップ
3. 名前を「単語帳」などに変更して **「追加」** をタップ

ホーム画面に単語帳アプリのアイコンが追加され、アプリのように起動できるようになる。

---

## アプリのアップデート方法

Mac 側でコードを変更した後、Pi に反映する手順:

```bash
# Mac のターミナルで実行（コードのみ同期・DB は除外）
rsync -av --exclude='.venv' --exclude='data/' --exclude='__pycache__' \
  /Users/ryota_amano/workspace/python_workspace/language_learn_app/ \
  pi@raspberrypi.local:~/language_learn_app/

# Pi に SSH して依存関係を更新・サービスを再起動
ssh pi@raspberrypi.local
cd ~/language_learn_app
uv sync
sudo systemctl restart language-learn
```

---

## よくあるトラブルシューティング

### アプリが起動しない

```bash
# ログを確認する
sudo journalctl -u language-learn -n 50

# サービスを手動で再起動する
sudo systemctl restart language-learn
sudo systemctl status language-learn
```

### SSH に接続できない

```bash
# Pi の IP アドレスが変わった場合はルーターの管理画面で確認する
# mDNS で接続を試みる
ssh pi@raspberrypi.local
```

### Tailscale 経由でアクセスできない

```bash
# Pi 側で Tailscale の状態を確認する
sudo tailscale status

# 接続確認
tailscale ping <iPhone の Tailscale IP>

# Tailscale を再起動する
sudo systemctl restart tailscaled
```

### ポート 8000 に接続できない

```bash
# アプリが起動しているか確認
ss -tlnp | grep 8000

# UFW のルールを確認
sudo ufw status verbose
```

---

## 参考: Pi の IP アドレスを固定する（任意）

ルーターの管理画面（通常 `http://192.168.1.1`）で Pi の MAC アドレスに固定 IP を割り当てると安定する。

```bash
# Pi の MAC アドレス（Wi-Fi）を確認
ip link show wlan0 | grep ether
# または有線（LAN ケーブル接続時）
ip link show eth0 | grep ether
```

---

*作成日: 2026-05-04*
