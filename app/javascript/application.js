// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
// 全ページで読み込みたいjsを指定する。（ページごとに読み込みたいjsは、 importmap.rb で指定する。）
import "@hotwired/turbo-rails"
import "navbar_burger"

// フラッシュトーストの自動非表示（chat showページ用）
const FLASH_TOAST_DURATION_MS = 4000

function initFlashToast() {
  document.querySelectorAll("[data-flash-toast]").forEach((el) => {
    setTimeout(() => {
      el.style.opacity = "0"
      el.style.transition = "opacity 0.3s ease-out"
      setTimeout(() => {
        el.remove()
        const container = document.getElementById("flash-toast-container")
        if (container && container.children.length === 0) {
          container.remove()
        }
      }, 300)
    }, FLASH_TOAST_DURATION_MS)
  })
}

document.addEventListener("turbo:load", initFlashToast)
document.addEventListener("DOMContentLoaded", initFlashToast)
