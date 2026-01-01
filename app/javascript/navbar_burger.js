// Bulmaのハンバーガーメニューを制御するJavaScript
function setupNavbarBurger() {
  const navbarBurgers = document.querySelectorAll('.navbar-burger');

  if (navbarBurgers.length === 0) {
    return;
  }

  navbarBurgers.forEach(function(burger) {
    // 既にイベントリスナーが設定されている場合はスキップ
    if (burger.hasAttribute('data-burger-listener')) {
      return;
    }
    burger.setAttribute('data-burger-listener', 'true');

    burger.addEventListener('click', function() {
      // ターゲットメニューのIDを取得
      const target = burger.dataset.target;
      const menu = document.getElementById(target);

      // ハンバーガーアイコンとメニューのis-activeクラスをトグル
      burger.classList.toggle('is-active');
      if (menu) {
        menu.classList.toggle('is-active');
      }
    });
  });
}

// 初期読み込み時
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', setupNavbarBurger);
} else {
  setupNavbarBurger();
}

// Turboのページ遷移後にも動作するように
document.addEventListener('turbo:load', setupNavbarBurger);

