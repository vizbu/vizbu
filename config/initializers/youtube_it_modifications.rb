class YouTubeIt
  module Request #:nodoc:
    VideoSearch.class_eval do

      attr_reader :duration
      attr_reader :time
      attr_reader :hd
      attr_reader :caption
      attr_reader :uploader
      attr_reader :region
      attr_reader :paid_content

      def initialize_with_extra(params={})
        @uploader, @caption, @hd, @time, @duration = nil
        initialize_without_extra(params)
      end

      alias_method :initialize_without_extra, :initialize
      alias_method :initialize, :initialize_with_extra
      
      def to_youtube_params_with_extra        
        to_youtube_params_without_extra.merge({
          'duration' => @duration,
          'time' => @time,
          'hd' => @hd,
          'caption' => @caption,
          'region' => @region,
          'paid-content' => @paid_content
        })        
      end
      
      alias_method :to_youtube_params_without_extra, :to_youtube_params
      alias_method :to_youtube_params, :to_youtube_params_with_extra

    end
  end

  module Parser

    class VideosFeedParser

      def parse_entry_with_extra(entry)
        puts entry
        puts method(:parse_entry_without_extra).source_location
        #comment_feed = entry.at_xpath('comments/feedLink[@rel="http://gdata.youtube.com/schemas/2007#comments"]')
        #comment_count = comment_feed ? comment_feed['countHint'].to_i : 0
        video = parse_entry_without_extra(entry)
        #video.comment_count = comment_count
        video
      end

      alias_method :parse_entry_without_extra, :parse_entry
      alias_method :parse_entry, :parse_entry_with_extra

    end

  end

end
