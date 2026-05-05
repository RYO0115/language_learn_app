// アプリ共通 JavaScript
// HTMX フック・UI ユーティリティを定義する

// HTMX のリクエスト完了後に Alpine.js のコンポーネントを再初期化する
document.addEventListener("htmx:afterSettle", () => {
  if (window.Alpine) {
    document.querySelectorAll("[x-data]").forEach((el) => {
      if (!el._x_dataStack) {
        Alpine.initTree(el);
      }
    });
  }
});

// フォームの二重送信を防ぐ（テストの回答ボタンなど）
document.addEventListener("submit", (e) => {
  const btn = e.target.querySelector("button[type=submit]");
  if (btn) {
    btn.disabled = true;
    btn.style.opacity = "0.6";
  }
});

// ── 発音機能（Web Speech API） ────────────────────────────────────────────────

// 音声リストをキャッシュする変数。
// Chrome は getVoices() が初回空のため onvoiceschanged で非同期に更新する。
// Safari はページロード時の同期取得で取得できる。
let _ttsVoices = [];

window.addEventListener("load", () => {
  if (!window.speechSynthesis) return;
  _ttsVoices = speechSynthesis.getVoices();
  speechSynthesis.onvoiceschanged = () => {
    _ttsVoices = speechSynthesis.getVoices();
  };
});

/**
 * 実際に発話を実行する内部関数。
 * utterance の作成と speak() 呼び出しをまとめる。
 */
function _doSpeak(text, rate) {
  const utterance = new SpeechSynthesisUtterance(text);
  utterance.lang = "en-US";
  utterance.rate = rate;
  utterance.pitch = 1.0;

  // キャッシュから en-US 音声を選択。取得できない場合はブラウザの既定音声で再生する。
  const voices = _ttsVoices.length > 0 ? _ttsVoices : speechSynthesis.getVoices();
  const voice =
    voices.find((v) => v.lang === "en-US" && v.localService) ||
    voices.find((v) => v.lang === "en-US") ||
    voices.find((v) => v.lang.startsWith("en"));
  if (voice) utterance.voice = voice;

  speechSynthesis.speak(utterance);
}

/**
 * 英語テキストを音声で読み上げる。
 * ボタンの data-word / data-text 属性から取得したテキストを渡すこと。
 *
 * Chrome 既知バグ対策:
 *   cancel() を常に呼ぶと直後の speak() が無視されることがある。
 *   「再生中のときのみキャンセルして 200ms 待機、それ以外は即座に再生」する方式を採用。
 *
 * @param {string} text  読み上げるテキスト
 * @param {number} rate  再生速度（1.0 = 通常、0.6 = ゆっくり）
 */
function pronounce(text, rate) {
  rate = rate || 1.0;

  if (!window.speechSynthesis) {
    alert("お使いのブラウザは音声読み上げに対応していません。");
    return;
  }

  if (speechSynthesis.speaking) {
    // 再生中の場合: キャンセルしてから 200ms 待って再生
    // （Chrome は cancel() 直後の speak() を無視するバグがある）
    speechSynthesis.cancel();
    setTimeout(() => _doSpeak(text, rate), 200);
  } else {
    // 再生中でない場合: 即座に再生（Chrome でも確実に動作する）
    _doSpeak(text, rate);
  }
}
