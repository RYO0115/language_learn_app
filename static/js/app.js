// アプリ共通 JavaScript
// HTMX フック・UI ユーティリティを定義する

// HTMX のリクエスト完了後に Alpine.js のコンポーネントを再初期化する
// （HTMX がコンテンツを入れ替えた後も Alpine のデータバインドが正常に動作するよう保証）
document.addEventListener("htmx:afterSettle", () => {
  if (window.Alpine) {
    // Alpine v3 では DOM 変更後に自動で初期化されるため、特別な処理は不要
    // ただし明示的に initTree を呼ぶことでより確実にする
    document.querySelectorAll("[x-data]").forEach((el) => {
      if (!el._x_dataStack) {
        Alpine.initTree(el);
      }
    });
  }
});

// ── 発音機能（Web Speech API） ────────────────────────────────────────────────

/**
 * 英語テキストを音声で読み上げる。
 * iOS Safari は speechSynthesis.getVoices() が非同期で読み込まれるため、
 * voices が空の場合は onvoiceschanged イベントを待って再実行する。
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

  const speak = () => {
    const utterance = new SpeechSynthesisUtterance(text);
    utterance.lang = "en-US";
    utterance.rate = rate;
    utterance.pitch = 1.0;

    // en-US の音声を優先して選択（ない場合は en-* にフォールバック）
    const voices = speechSynthesis.getVoices();
    const voice =
      voices.find((v) => v.lang === "en-US" && v.localService) ||
      voices.find((v) => v.lang === "en-US") ||
      voices.find((v) => v.lang.startsWith("en"));
    if (voice) utterance.voice = voice;

    speechSynthesis.speak(utterance);
  };

  // voices がすでに読み込まれていればすぐ再生、未読み込みなら読み込み完了を待つ
  if (speechSynthesis.getVoices().length > 0) {
    speak();
  } else {
    speechSynthesis.addEventListener("voiceschanged", speak, { once: true });
  }
}

// フォームの二重送信を防ぐ（テストの回答ボタンなど）
document.addEventListener("submit", (e) => {
  const btn = e.target.querySelector("button[type=submit]");
  if (btn) {
    btn.disabled = true;
    btn.style.opacity = "0.6";
  }
});
