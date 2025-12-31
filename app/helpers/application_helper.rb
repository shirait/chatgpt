module ApplicationHelper
  # マークダウン表示に必要なgem
  require 'redcarpet'
  require 'redcarpet/render_strip'

  def need_toplevel_flash_messages?
    !not_need_toplevel_flash_messages?
  end

  def not_need_toplevel_flash_messages?
    params[:action].in?(["add_message", "show"])
  end

  # review: スコープを小さくできないか確認（chats_helper.rb に移動できないか確認）
  def message_type_class(message)
    "#{message.message_type.to_s}-message"
  end

  def message_background_color(message)
    return "has-background-primary-light" if message.user?
    return "has-background-link-light"    if message.gpt?
  end

  def markdown_to_html(text)
    render_options = {
      filter_html:         true,  # HTMLタグのフィルタリングを有効にする
      hard_wrap:           true,  # ハードラップを有効にする
      link_attributes:     { rel: 'nofollow', target: "_blank" },  # リンクの属性を設定する
      space_after_headers: true,  # ヘッダー後のスペースを有効にする
      fenced_code_blocks:  true,  # フェンス付きコードブロックを有効にする
    }

    # HTMLレンダラーを作成する
    renderer = Redcarpet::Render::HTML.new(render_options)

    # マークダウンの拡張機能を設定する
    extensions = {
      autolink:           true,  # 自動リンクを有効にする
      no_intra_emphasis:  true,  # 単語内の強調を無効にする
      fenced_code_blocks: true,  # フェンス付きコードブロックを有効にする
      lax_spacing:        true,  # 緩いスペーシングを有効にする
      strikethrough:      true,  # 取り消し線を有効にする
      superscript:        true,  # 上付き文字を有効にする
      tables:             true,  # テーブルを有効にする
      with_toc_data:      true,  # 目次を有効にする
      escape_html:        true,  # HTMLエスケープを有効にする
    }

    # マークダウンをHTMLに変換し、結果をhtml_safeにする
    Redcarpet::Markdown.new(renderer, extensions).render(text).html_safe
  end
end
