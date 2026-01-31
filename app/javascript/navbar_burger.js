// Bulmaのハンバーガーメニューを制御するJavaScript（jQuery版）
// イベント委譲で document に1つだけリスナーを置く。
// Turbo で 422 などにより body が差し替わっても、document は残るためクリックが動く。
$(document).on('click', '.navbar-burger', function() {
  const $burger = $(this);
  const target = $burger.data('target');
  const $menu = target ? $('#' + target) : $();

  $burger.toggleClass('is-active');
  if ($menu.length > 0) {
    $menu.toggleClass('is-active');
  }
});

