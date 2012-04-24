class HomeController < ApplicationController
  def index
  end

  def search
    @q = params[:q]
    @q = params[:q]
    @q = params[:q]
    @q = params[:q]
    
    client = YouTubeIt::Client.new(:dev_key => "AI39si5-1s6CVSSGdBqlMnzN9v_OMBufAMEW-0H4Ke1UG5laQpDCWyWJU5WJlpVHPXSTHyBDHEoFsbBdLfwgHBs7Aic3tjHR0Q")

    @result = client.videos_by(:query => @q, :page => 2, :per_page => 6)

    

  end

  def about
  end

end
