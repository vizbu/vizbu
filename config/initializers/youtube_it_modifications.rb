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
end
