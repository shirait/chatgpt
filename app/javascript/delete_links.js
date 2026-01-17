// data-methodリンクのフォーム送信処理（共通化・jQuery版）
function setupMethodLinks() {
  const $methodLinks = $('a[data-method]');

  $methodLinks.each(function() {
    const $link = $(this);

    // 既にイベントリスナーが設定されている場合はスキップ
    if ($link.data('method-link-setup')) {
      return;
    }
    $link.data('method-link-setup', true);

    $link.on('click', function(e) {
      const method = ($link.data('method') || '').toString().toLowerCase();
      if (!['post', 'delete', 'patch', 'put'].includes(method)) {
        return true;
      }

      const confirmMessage = $link.data('confirm');
      if (confirmMessage && !confirm(confirmMessage)) {
        e.preventDefault();
        return false;
      }

      // data-method リクエストを送信するためのフォームを作成
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

      if (method !== 'post') {
        // method override
        $('<input>', {
          type: 'hidden',
          name: '_method',
          value: method
        }).appendTo($form);
      }

      $form.appendTo('body');
      $form[0].submit();

      e.preventDefault();
      return false;
    });
  });
}

// jQueryのreadyイベントで初期化
$(function() {
  setupMethodLinks();
});

// Turboを使っている場合のイベント
$(document).on('turbo:load', function() {
  setupMethodLinks();
});

