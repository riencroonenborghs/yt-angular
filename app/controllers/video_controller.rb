class VideoController < ApplicationController
  def info
    puts params
    valid_params  = params.permit(:video_id)
    url           = "http://www.youtube.com/get_video_info?video_id=" + valid_params[:video_id]
    response      = ::HTTParty.get url
    render text: response
  end
end