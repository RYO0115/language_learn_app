// アプリ共通 JavaScript
// HTMX フック・UI ユーティリティを定義する

// HTMX のリクエスト完了後に Alpine.js のコンポーネントを再初期化する
// （HTMX がコンテンツを入れ替えた後も Alpine のデータバインドが正常に動作するよう保証）
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

// ページロード時に音声リストを事前初期化する。
// iOS Safari は初回呼び出し時に音声リストが空になるため、
// ユーザーがボタンを押す前に getVoices() をトリガーしておく。
window.addEventListener("load", () => {
  if (window.speechSynthesis) {
    speechSynthesis.getVoices();
  }
});

/**
 * 英語テキストを音声で読み上げる。
 * ボタンの data-text / data-word 属性からテキストを取得して呼び出す。
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

  // 再生中の音声があればキャンセルしてから新しく開始する
  speechSynthesis.cancel();

  const utterance = new SpeechSynthesisUtterance(text);
  utterance.lang = "en-US";
  utterance.rate = rate;
  utterance.pitch = 1.0;

  // en-US の音声を優先して選択（ない場合は en-* にフォールバック）
  // ページロード時に getVoices() を呼んでいるため、ここでは同期的に取得できる
  const voices = speechSynthesis.getVoices();
  const voice =
    voices.find((v) => v.lang === "en-US" && v.localService) ||
    voices.find((v) => v.lang === "en-US") ||
    voices.find((v) => v.lang.startsWith("en"));
  if (voice) utterance.voice = voice;

  speechSynthesis.speak(utterance);
}
