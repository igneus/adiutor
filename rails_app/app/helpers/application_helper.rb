module ApplicationHelper
  # title = page title to be displayed as h1
  # header_title = value for /html/header/title , if it is to be different from displayed one
  def page_title(title = nil, header_title = nil)
    title ||= capture { yield }
    content_for(:title) { header_title || title }
    tag.h1 title
  end
end
