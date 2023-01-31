class PostsList
  attr_accessor :feed_url

  def initialize(init_hash)
    @feed_url = init_hash["feed_url"]
  end

  def posts(force_refresh = false)
    if @feed_url.blank?
      items = [
          {title: 'Article 1', url: '#', image: '/logo_apidae_h.png', content_text: 'Contenu article 1'},
          {title: 'Article 2', url: '#', image: '/logo_apidae_h.png', content_text: 'Contenu article 2'},
          {title: 'Article 3', url: '#', image: '/logo_apidae_h.png', content_text: 'Contenu article 3'}
      ]
    else
      cache_key = @feed_url.split('/')[-3..-1].join('_')
      items = Rails.cache.read(cache_key)
      if items.nil? || force_refresh
        begin
          response = ''
          open(@feed_url) { |f|
            f.each_line {|line| response += line unless line.nil?}
          }
          items = JSON.parse(response)
          Rails.cache.write(cache_key, items)
        rescue Exception => ex
          Rails.logger.error "Could not retrieve posts list: #{ex.message}"
          items = []
        end
      end
    end
    items
  end
end