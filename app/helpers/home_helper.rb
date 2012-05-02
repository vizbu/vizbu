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
    @filters[@source.to_sym].each do |filter|
      out_params.delete(filter.to_s)
    end
    out_params = {}
    out_params
  end
end
