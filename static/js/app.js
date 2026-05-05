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

// 音声リストをモジュールレベルでキャッシュする。
// Chrome では getVoices() が初回空を返し onvoiceschanged で非同期に読み込まれる。
// iOS Safari ではページロード時の同期取得で概ね取得できる。
let _ttsVoices = [];

window.addEventListener("load", () => {
  if (!window.speechSynthesis) return;
  // 同期取得を試みる（Safari ではここで取得できる）
  _ttsVoices = speechSynthesis.getVoices();
  // Chrome 向け: 非同期読み込み完了時にキャッシュを更新する
  speechSynthesis.onvoiceschanged = () => {
    _ttsVoices = speechSynthesis.getVoices();
  };
});

/**
 * 英語テキストを音声で読み上げる。
 * ボタンの data-word / data-text 属性から取得したテキストを渡すこと。
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

  // 再生中があればキャンセルする
  speechSynthesis.cancel();

  const utterance = new SpeechSynthesisUtterance(text);
  utterance.lang = "en-US";
  utterance.rate = rate;
  utterance.pitch = 1.0;

  // キャッシュ済みの音声から en-US を選択（未取得の場合はブラウザ既定音声で再生）
  const voice =
    _ttsVoices.find((v) => v.lang === "en-US" && v.localService) ||
    _ttsVoices.find((v) => v.lang === "en-US") ||
    _ttsVoices.find((v) => v.lang.startsWith("en"));
  if (voice) utterance.voice = voice;

  // Chrome 既知バグ対策: cancel() 直後の speak() が無視される場合があるため
  // 100ms 待ってから再生する。
  // iOS Safari もこの時間内であればユーザージェスチャーの文脈が保持される。
  setTimeout(() => speechSynthesis.speak(utterance), 100);
}
