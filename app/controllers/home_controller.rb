class HomeController < ApplicationController

  def index
  end

  def search
  
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
    @result = client.videos_by({ :query => @q, :page => params[:page] || 1, :per_page => 10 }.merge( filter_params ))
    @view = params[:view] || "list"
  end

  def about
  end

end
