class Dailymotion
  include HTTParty

  base_uri 'api.dailymotion.com'

  # https://api.dailymotion.com/videos?fields=allow_embed,duration%2Cid&search=simple
end
