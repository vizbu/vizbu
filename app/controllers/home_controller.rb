class HomeController < ApplicationController

  def index
  end

  def search
    @q = params[:q]
    
    @page = params[:page] || 1
    
    @source = params[:source] || "youtube"
    
    @source = @source.to_sym

    if @source == :youtube
      client = YouTubeIt::Client.new(:dev_key => "AI39si5-1s6CVSSGdBqlMnzN9v_OMBufAMEW-0H4Ke1UG5laQpDCWyWJU5WJlpVHPXSTHyBDHEoFsbBdLfwgHBs7Aic3tjHR0Q")
      filter_params = {}
      @result = client.videos_by({ :query => @q, :page => params[:page] || 1, :per_page => 10 }.merge( filter_params ))
    elsif @source == :vimeo
      video = Vimeo::Advanced::Video.new("0ded35edb12d54c74dbe3622352ceec3", "d07ca9c1a42c7a7")
      @result = video.search(@q, { :page => params[:page] || 1, :per_page => "10", :full_response => "1", :sort => "newest", :user_id => nil })
    elsif @source == :soundcloud
      client = Soundcloud.new(:client_id => '718f0504b536fb5b177cfaa4d3cfe847')
      @result = client.get('/tracks', :limit => 10, :order => 'hotness', :q => @q)
    end
    
    @result = normalize_result(@result, @source)
  end

  def search_yt
  
    @filters = {
      :sort_by => {
        :relevence => {
          :order_by => :relevance
        },
        :view_count => {
          :order_by => :viewCount
        },
        :upload_date => {
          :order_by => :published
        },
        :rating => {
          :order_by => :rating
        }
      },
      :upload_date => {
        :anytime => {
          
        },
        :today => {
          :time => :today
        },
        :this_week => {
          :time => :this_week
        },
        :this_month => {
          :time => :this_month
        }
      },
      :categories => {
        :all => {
          :order_by => :relevance
        },
        :music => {
          :order_by => :viewCount
        },
        :entertainment => {
          :order_by => :published
        }
      },
      :duration => {
        :all => {
          :duration => :relevance
        },
        :short => {
          :duration => :short
        },
        :long => {
          :duration => :long
        }
      },
      :features => {
        :all => {},
        :closed_captions => {
          :caption => true
        },
        :HD => {
          :hd => true
        },
        :partner_videos => {
          :uploader => :partner
        },
        :rental => {
          :paid_content => true
        }#,
        #:webM => {
        #}
      }
    }
    
    # don't know how to do category based filtering probably need to use categories retuned in results
    @filters.delete(:categories)
  
    @q = params[:q]
    client = YouTubeIt::Client.new(:dev_key => "AI39si5-1s6CVSSGdBqlMnzN9v_OMBufAMEW-0H4Ke1UG5laQpDCWyWJU5WJlpVHPXSTHyBDHEoFsbBdLfwgHBs7Aic3tjHR0Q")
    filter_params = {}
    @filters.each do |k, v|
      unless params[k].blank?
        filter_params.merge!( v[params[k].to_sym] )
      end
    end
    @result = client.videos_by({ :query => @q, :page => @page, :per_page => 10 }.merge( filter_params ))
    @view = params[:view] || "list"
  end

  def about
  end
  
  protected
  
  def normalize_result(result, type)
  
    out = {}
  
    if type == :youtube
      out[:total_videos] = result.total_result_count
      out[:videos] = []

      result.videos.each do |video|
        ov = {}
        ov[:id] = video.unique_id
        ov[:embed_url] = "http://www.youtube.com/embed/#{ video.unique_id }?wmode=opaque"
        ov[:player_url] = video.player_url
        ov[:title] = video.title
        ov[:author_name] = video.author.name
        ov[:author_url] = "http://www.youtube.com/user/#{ video.author.name }"
        ov[:published_at] = video.published_at
        ov[:view_count] = video.view_count
        ov[:duration] = video.duration
        ov[:description] =  video.description
        out[:videos] << ov
      end
      
    elsif type == :vimeo
      out[:total_videos] = result["videos"]["total"]
      out[:videos] = []

      result["videos"]["video"].each do |video|
        ov = {}
        ov[:id] = video["id"]
        ov[:embed_url] = "http://player.vimeo.com/video/#{ video["id"] }"
        ov[:player_url] = "http://vimeo.com/#{ video["id"] }"
        ov[:title] = video["title"]
        ov[:author_name] = video["owner"]["display_name"]
        ov[:author_url] = "http://vimeo.com/user#{ video["owner"]["id"] }"
        ov[:published_at] = video["upload_date"]
        ov[:view_count] = video["number_of_plays"]
        ov[:duration] = video["duration"]
        ov[:description] =  video["description"]
        out[:videos] << ov
      end
    elsif type == :soundcloud
      if result.length < 10
        out[:total_videos] = @page * 10 + result.length
      else
        out[:total_videos] = result.length + 50 + @q.hash % 30
      end
      out[:videos] = []

      result.each do |video|
        ov = {}
        ov[:id] = video.id
        ov[:embed_url] = "http://w.soundcloud.com/player/?url=#{ video.uri }&auto_play=false&show_artwork=false&color=0066cc"       
        ov[:embed_code] = '<iframe width="100%" height="166" scrolling="no" frameborder="no" src="'+ "http://w.soundcloud.com/player/?url=#{ video.uri }&auto_play=false&show_artwork=false&color=0066cc" +'"></iframe>'
        ov[:height] = 166
        ov[:player_url] = video.permalink_url
        ov[:title] = video.title
        ov[:author_name] = video.user.username
        ov[:author_url] = video.user.permalink_url
        ov[:published_at] = video.created_at
        ov[:view_count] = video.playback_count
        ov[:duration] = video.duration / 1000
        ov[:description] =  video.description
        out[:videos] << ov
      end
    end
    
    out[:type] = type

    out
  end

end
