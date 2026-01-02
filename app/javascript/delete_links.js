// 削除リンクのconfirm処理（共通化・jQuery版）
function setupDeleteLinks() {
  const $deleteLinks = $('a[data-confirm][data-method="delete"]');

  $deleteLinks.each(function() {
    const $link = $(this);

    // 既にイベントリスナーが設定されている場合はスキップ
    if ($link.data('delete-link-setup')) {
      return;
    }
    $link.data('delete-link-setup', true);

    $link.on('click', function(e) {
      const confirmMessage = $link.data('confirm');
      if (!confirm(confirmMessage)) {
        e.preventDefault();
        return false;
      }

      // DELETEリクエストを送信するためのフォームを作成
      const $form = $('<form>', {
        method: 'POST',
        action: $link.attr('href')
      });

      // CSRFトークンを追加
      const $csrfToken = $('meta[name="csrf-token"]');
      if ($csrfToken.length > 0) {
        $('<input>', {
          type: 'hidden',
          name: 'authenticity_token',
          value: $csrfToken.attr('content')
        }).appendTo($form);
      }

      // method override
      $('<input>', {
        type: 'hidden',
        name: '_method',
        value: 'delete'
      }).appendTo($form);

      $form.appendTo('body');
      $form[0].submit();

      e.preventDefault();
      return false;
    });
  });
}

// jQueryのreadyイベントで初期化
$(function() {
  setupDeleteLinks();
});

// Turboを使っている場合のイベント
$(document).on('turbo:load', function() {
  setupDeleteLinks();
});

