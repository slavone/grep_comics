module ApplicationHelper
  def comic_link(comic)
    link_to comic.humanized_title, comic_path(comic)
  end
end
