// Bulmaのハンバーガーメニューを制御するJavaScript（jQuery版）
function setupNavbarBurger() {
  const $navbarBurgers = $('.navbar-burger');

  if ($navbarBurgers.length === 0) {
    return;
  }

  $navbarBurgers.each(function() {
    const $burger = $(this);

    // 既にイベントリスナーが設定されている場合はスキップ
    if ($burger.data('burger-listener')) {
      return;
    }
    $burger.data('burger-listener', true);

    $burger.on('click', function() {
      // ターゲットメニューのIDを取得
      const target = $burger.data('target');
      const $menu = $('#' + target);

      // ハンバーガーアイコンとメニューのis-activeクラスをトグル
      $burger.toggleClass('is-active');
      if ($menu.length > 0) {
        $menu.toggleClass('is-active');
      }
    });
  });
}

// jQueryのreadyイベントで初期化
$(function() {
  setupNavbarBurger();
});

// Turboのページ遷移後にも動作するように
$(document).on('turbo:load', function() {
  setupNavbarBurger();
});

