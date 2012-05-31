module HomeHelper
  def video_duration(sec)
    sec = sec.to_i
    mins = sec / 60
    sec = sec % 60
    if mins > 60
      hours = mins / 60
      mins = mins % 60
      hours.to_s.rjust(2,'0') + ":" + mins.to_s.rjust(2,'0') + ":" + sec.to_s.rjust(2,'0')
    else
      mins.to_s.rjust(2,'0') + ":" + sec.to_s.rjust(2,'0')
    end
  end
  
  def remove_filters(params)
    out_params = params.dup
    @filters[@source.to_sym].each do |k, v|
      out_params.delete(k.to_sym)
    end
    out_params
  end
  
  def video_embed_code(video)
    if video[:embed_code]
      video[:embed_code].html_safe
    else
      '<iframe width="560" height="315" src="' + video[:embed_url] + '" frameborder="0" allowfullscreen></iframe>'.html_safe
    end
  end

end
