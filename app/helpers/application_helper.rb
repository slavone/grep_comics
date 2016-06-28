module ApplicationHelper
  def comic_link(comic)
    link_to comic.humanized_title, comic_path(comic)
  end

  def creator_links(creators)
    creators.each_with_index.collect do |creator, i|
      concat content_tag(:span) { link_to creator.name, creator_path(creator) }
      concat content_tag(:span, ', ') unless i == creators.size-1
    end
    nil
  end
end
