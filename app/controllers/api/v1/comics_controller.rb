class Api::V1::ComicsController < ApplicationController
  def index
    @logger = Logger.new "#{Rails.root}/log/api_v1.log"
    @logger.info '------------------------'
    @logger.info "Got params #{params.inspect}"
    query = build_query params
    @logger.info "Build query #{query}"
    @comics = Comic.eager_load(:publisher).preload(:writers, :artists, :cover_artists).where(query)
    render :index
  rescue
    @logger.info "Something went wrong"
    render json: { status: 500, message: 'Something went wrong' }
  end

  private

  AVAILABLE_QUERIES = [:publisher, :title, :shipping_date,
                       :item_type, :has_variant_cover, :issue_number,
                       :creators, :writers, :artists, :cover_artists, :reprint]

  NAME_SANITIZER = /^[\s\w\d]+/
  DATE_SANITIZER = /^\d{4}-\d{2}-\d{2}/

  def sanitize_creators(unsafe_creators)
    unsafe_creators.split(',').map do |creator|
      if m = creator.match(NAME_SANITIZER)
        m.to_s
      end
    end.compact
  end

  def build_query(params)
    query = []
    present_params = params.keys.map(&:to_sym) & AVAILABLE_QUERIES
    present_params.each do |param|
      case param
      when :title
        if m = params[param].match(NAME_SANITIZER)
          query << "comics.title ILIKE '%#{m.to_s}%'"
        end
      when :publisher
        if m = params[param].match(NAME_SANITIZER)
          query << "publishers.name = '#{m.to_s.upcase}'"
        end
      when :creators
        creators = sanitize_creators params[param]
        comics_in = Comic.filtered_by_creators(creators).map(&:id).join(',')
        query << "comics.id IN (#{comics_in})"
      when :writers, :artists, :cover_artists
        creators = sanitize_creators params[param]
        creator_type = param.to_s.singularize
        comics_in = Comic.filtered_by_creators_of_type(creators,
                                                       creator_type).map(&:id).join(',')
        query << "comics.id IN (#{comics_in})"
      when :shipping_date
        if m = params[param].match(DATE_SANITIZER)
          query << "comics.shipping_date = '#{m.to_s}'"
        end
      when :issue_number
        if m = params[param].match(/^\d+/)
          query << "comics.issue_number = '#{m.to_s}'"
        end
      when :has_variant_cover
        if m = params[param].match(/(true)/i)
          query << "comics.is_variant = '#{m.to_s}'"
        end
      when :reprint
        if m = params[param].match(/(true)/i)
          query << "comics.reprint_number IS NOT NULL"
        end
      when :item_type
        if m = params[param].match(/[\w]+/)
          query << "comics.item_type = '#{m.to_s}'"
        end
      end
    end
    query.join(' AND ')
  end
end
