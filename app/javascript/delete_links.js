// 削除リンクのconfirm処理（共通化）
function setupDeleteLinks() {
  const deleteLinks = document.querySelectorAll('a[data-confirm][data-method="delete"]');
  deleteLinks.forEach(function(link) {
    // 既にイベントリスナーが設定されている場合はスキップ
    if (link.hasAttribute('data-delete-link-setup')) {
      return;
    }
    link.setAttribute('data-delete-link-setup', 'true');

    link.addEventListener('click', function(e) {
      const confirmMessage = link.getAttribute('data-confirm');
      if (!confirm(confirmMessage)) {
        e.preventDefault();
        return false;
      }

      // DELETEリクエストを送信するためのフォームを作成
      const form = document.createElement('form');
      form.method = 'POST';
      form.action = link.href;

      // CSRFトークンを追加
      const csrfToken = document.querySelector('meta[name="csrf-token"]');
      if (csrfToken) {
        const csrfInput = document.createElement('input');
        csrfInput.type = 'hidden';
        csrfInput.name = 'authenticity_token';
        csrfInput.value = csrfToken.getAttribute('content');
        form.appendChild(csrfInput);
      }

      // method override
      const methodInput = document.createElement('input');
      methodInput.type = 'hidden';
      methodInput.name = '_method';
      methodInput.value = 'delete';
      form.appendChild(methodInput);

      document.body.appendChild(form);
      form.submit();

      e.preventDefault();
      return false;
    });
  });
}

// ページ読み込み時に削除リンクを設定
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', setupDeleteLinks);
} else {
  setupDeleteLinks();
}

// Turboを使っている場合のイベント
document.addEventListener('turbo:load', setupDeleteLinks);

