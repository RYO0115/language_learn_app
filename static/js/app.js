// アプリ共通 JavaScript（発音機能は base.html のインラインスクリプトに定義）
// HTMX フック・フォーム二重送信防止などのユーティリティを提供する

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
