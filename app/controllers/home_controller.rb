class HomeController < ApplicationController

  def index
  end

  def search

    @filters = {
      :youtube => {
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
          }
        }
      },
      :vimeo => {
        :sort_by => {
          :relevant => {},
          :newest => {
            :sort => :newest
          },
          :oldest => {
            :sort => :oldest
          },
          :most_played => {
            :sort => :most_played
          },
          :most_commented => {
            :sort => :most_commented
          },
          :most_liked => {
            :sort => :most_liked
          }
        }
      },
      :soundcloud => {
        :sort_by => {
          :hotness => {
            
          },
          :upload_date => {
            :order => :created_at
          }
        },
        :duration => {
          :all => {
            
          },
          :small => {
            "duration[to]" => 1000 * 60 * 4
          },
          :medium => {
            "duration[from]" => 1000 * 60 * 4,
            "duration[to]" => 1000 * 60 * 8
          },
          :long => {
            "duration[from]" => 1000 * 60 * 8
          }
        }
      },
      :dailymotion => {
      },
      :metacafe => {
      }
    }

    @q = params[:q]
    
    if @q.blank?
      redirect_to root_path
      return
    end

    @page = params[:page] || 1

    @source = params[:source] || "youtube"

    @source = @source.to_sym

    @view = params[:view] || "list"

    filter_params = {}
    @filters[@source.to_sym].each do |k, v|
      if !params[k].blank? && !v[params[k].to_sym].blank?
        filter_params.merge!( v[params[k].to_sym] )
      end
    end

    if @source == :youtube
      client = YouTubeIt::Client.new(:dev_key => "AI39si5-1s6CVSSGdBqlMnzN9v_OMBufAMEW-0H4Ke1UG5laQpDCWyWJU5WJlpVHPXSTHyBDHEoFsbBdLfwgHBs7Aic3tjHR0Q")
      @result = client.videos_by({ :query => @q, :page => params[:page] || 1, :per_page => 10 }.merge( filter_params ))
    elsif @source == :vimeo
      video = Vimeo::Advanced::Video.new("0ded35edb12d54c74dbe3622352ceec3", "d07ca9c1a42c7a7")
      @result = video.search(@q, { :page => params[:page] || 1, :per_page => "10", :full_response => "1", :sort => "relevant", :user_id => nil }.merge( filter_params ))
    elsif @source == :soundcloud
      client = Soundcloud.new(:client_id => '718f0504b536fb5b177cfaa4d3cfe847')
      @result = client.get('/tracks', { :offset => @page.to_i * 10, :limit => 10, :order => 'hotness', :q => @q }.merge( filter_params ) )
    elsif @source == :dailymotion
      @result = Dailymotion.get("https://api.dailymotion.com/videos", :query => { :fields => [ :id, :embed_url, :url, :title, :owner, :"owner.username", :"owner.url", :allow_embed, :created_time, :views_total, :duration, :description ], :search => @q, :page => @page, :limit => 10 } )
    elsif @source == :metacafe
      xml_resp = Metacafe.get("http://www.metacafe.com/api/videos/", :query => { :vq => @q, :"start-index" =>  (@page.to_i - 1) * 10, :"max-results" => 10 } )
      @result = Nokogiri::XML(xml_resp)
    end
    
    @orig_result = @result

    @result = normalize_result(@result, @source)

    respond_to do |format|
      format.html {
        if request.headers['X-PJAX']
          render :layout => false #add this option to save the time of layout rendering
        end
      }
      format.js
    end

    #if request.xhr?
    #  render :partial => "full_result", :layout => nil
    #end
  end

  def search_yt

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
  
  def feedback
  end
  
  def send_feedback
    # send email
    @feedback = Feedback.new(params)
    @message = Message.new(params[:feedback])
    if @message.valid?
      # TODO send message here
      flash[:notice] = "Message sent! Thank you for contacting us."
      redirect_to root_url
    else
      render :action => 'new'
    end
  end
  
  def comments
    @source = params[:source].to_sym
    @video_id = params[:id]
    if params[:page].blank?
      @page = 1 
    else
      @page = params[:page].to_i
    end

    if @source == :youtube
      @comments = []

      client = YouTubeIt::Client.new(:username => "ytuservizbuvs", :password =>  "vizbu_ytuser", :dev_key => "AI39si5-1s6CVSSGdBqlMnzN9v_OMBufAMEW-0H4Ke1UG5laQpDCWyWJU5WJlpVHPXSTHyBDHEoFsbBdLfwgHBs7Aic3tjHR0Q")

      yt_comments = client.comments(@video_id, :'max-results' => 10, :'start-index' => (@page - 1) * 10 + 1)

      yt_comments.each do |yt_comment|
        comment = {}
        comment[:content] = yt_comment.content
        comment[:author] = { :name => yt_comment.author.name, :url => "http://www.youtube.com/user/#{yt_comment.author.name}"}
        comment[:published_at] = yt_comment.published
        @comments << comment
      end
    else
      not_found
    end
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
        ov[:embed_url] = "http://www.youtube.com/embed/#{ video.unique_id }?wmode=opaque&autoplay=1"
        ov[:player_url] = video.player_url
        ov[:thumb_url] = "http://img.youtube.com/vi/#{ video.unique_id }/0.jpg"
        ov[:title] = video.title
        ov[:author_name] = video.author.name
        ov[:author_url] = "http://www.youtube.com/user/#{ video.author.name }"
        ov[:published_at] = video.published_at
        ov[:view_count] = video.view_count
        #ov[:comment_count] = video.comment_count
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
        ov[:embed_url] = "http://player.vimeo.com/video/#{ video["id"] }?autoplay=1"
        ov[:player_url] = "http://vimeo.com/#{ video["id"] }"

        ov[:thumb_url] = "/assets/vimeo_default_thumb.jpg"

        thumb_node = video["thumbnails"]["thumbnail"].inject(nil) do |thumb_node, node|
          if !thumb_node || node["width"] != "640"
            thumb_node = node
          end
          thumb_node
        end

        ov[:thumb_url] = thumb_node["_content"] if thumb_node

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
        out[:total_videos] = ((@page.to_i - 1 ) * 10) + result.length
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
    
    elsif type == :dailymotion  

      out[:total_videos] = result["total"]
      out[:videos] = []
      
      # @result = Dailymotion.get("https://api.dailymotion.com/videos", :query => { :fields => [ :id, :embed_url, :url, :title, :owner, :"owner.username", :"owner.url", :allow_embed, :created_time, :views_total, :duration, :description ], :search => "dil" } )

      result["list"].each do |video|
        ov = {}
        ov[:id] = video["id"]
        ov[:embed_url] = video["embed_url"] + "?autoPlay=1"
        # <iframe frameborder="0" width="480" height="360" src="http://www.dailymotion.com/embed/video/xr6i2l?autoPlay=1"></iframe><br /><a href="http://www.dailymotion.com/video/xr6i2l_ajax-starglider-somewhere-else-illect-recordings_music" target="_blank">Ajax Starglider - &quot;Somewhere Else&quot; Illect...</a> <i>by <a href="http://www.dailymotion.com/BlankTV" target="_blank">BlankTV</a></i>
        # ov[:embed_code] = '<iframe width="100%" height="166" scrolling="no" frameborder="no" src="'+ "http://w.soundcloud.com/player/?url=#{ video.uri }&auto_play=false&show_artwork=false&color=0066cc" +'"></iframe>'
        # ov[:height] = 166
        # http://www.dailymotion.com/video/xr82sn_santa-monica-ca-90404-dealer-buy-a-pre-owned-volkswagen-jetta_auto
        ov[:player_url] = video["url"]
        ov[:thumb_url] = video["url"].sub("www.dailymotion.com/video", "www.dailymotion.com/thumbnail/video")
        ov[:title] = video["title"]
        ov[:author_name] = video["owner.username"]
        ov[:author_url] = video["owner.url"]
        ov[:published_at] = Time.at(video["created_time"])
        ov[:view_count] = video["views_total"]
        ov[:duration] = video["duration"]
        ov[:description] =  video["description"]
        out[:videos] << ov
      end
      
    elsif type == :metacafe

      out[:total_videos] = 100
      
      out[:videos] = []
      
      # @result = Dailymotion.get("https://api.dailymotion.com/videos", :query => { :fields => [ :id, :embed_url, :url, :title, :owner, :"owner.username", :"owner.url", :allow_embed, :created_time, :views_total, :duration, :description ], :search => "dil" } )
      
      result.css("item").each do |video|
        unless video.xpath("media:content")[0]["url"].blank?
          ov = {}
          ov[:id] = video.css("id")[0].content
          ov[:embed_url] = video.css("embed_url")
          # ov[:embed_code] = '<iframe width="100%" height="166" scrolling="no" frameborder="no" src="'+ "http://w.soundcloud.com/player/?url=#{ video.uri }&auto_play=false&show_artwork=false&color=0066cc" +'"></iframe>'
          # <div style="font-size:12px;"><a href="http://www.metacafe.com/watch/yt-5xcolEu_hB0/mexico_vs_chile_upskirt_batalla_cosplay_anime_dj_sasha_tnt/">Mexico Vs Chile Upskirt Batalla Cosplay Anime Dj Sasha Tnt</a>. Watch more top selected videos about: <a href="http://www.metacafe.com/topics/Dance/" title="Dance">Dance</a>, <a href="http://www.metacafe.com/topics/Dogs/" title="Dogs">Dogs</a></div>
          # "http://www.metacafe.com/fplayer/yt-5xcolEu_hB0/mexico_vs_chile_upskirt_batalla_cosplay_anime_dj_sasha_tnt"
          #ov[:embed_code] = '<embed flashVars="playerVars=autoPlay=no" src="' + video.xpath("media:content")[0]["url"] + '" width="560" height="315" wmode="transparent" allowFullScreen="true" allowScriptAccess="always" name="Metacafe_yt-5xcolEu_hB0" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash"></embed>'
          ov[:embed_code] = '<embed flashVars="playerVars=autoPlay=no" src="http://www.metacafe.com/fplayer/8469949/boner_billys_stop_on_by.swf" width="440" height="248" wmode="transparent" allowFullScreen="true" allowScriptAccess="always" name="Metacafe_8469949" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash"></embed><div style="font-size:12px;"><a href="http://www.metacafe.com/watch/8469949/boner_billys_stop_on_by/">Boner Billy\'s - Stop on by</a> - <a href="http://www.metacafe.com/">Click here for the most popular videos</a></div>'
          # ov[:height] = 166
          ov[:player_url] = video.css("link")[0].content
          ov[:title] = video.css("title")[0].content
          ov[:author_name] = video.css("author")[0].content
          ov[:author_url] = "http://www.metacafe.com/channels/#{ov[:author_name]}/"
          ov[:published_at] = Time.now
          ov[:view_count] = 12
          ov[:duration] = video.xpath("media:content")[0]["duration"]
          ov[:description] =  video
          out[:videos] << ov
        end
      end

    end

    out[:type] = type

    out
  end

end
