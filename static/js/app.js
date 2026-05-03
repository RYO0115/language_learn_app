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

// フォームの二重送信を防ぐ（テストの回答ボタンなど）
document.addEventListener("submit", (e) => {
  const btn = e.target.querySelector("button[type=submit]");
  if (btn) {
    btn.disabled = true;
    btn.style.opacity = "0.6";
  }
});
