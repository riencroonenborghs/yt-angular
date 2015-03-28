window.exports ||= {}
window.exports.app = angular.module "yt-angular",[
  "ngAria", "ngAnimate", "ngMaterial", "ngClipboard"
]

window.exports.app.config ['ngClipProvider', (ngClipProvider) ->
  ngClipProvider.setPath("/assets/zeroclipboard/dist/ZeroClipboard.swf")
]
  


window.exports.app.controller "appController", ["$scope", "$q", "$http", ($scope, $q, $http) ->
  get_video_id = (url) ->    
    regexp = /.*(?:youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=)([^#\&\?]*).*/
    matches = url.match regexp
    return matches[1]

  get_video_info = (video_id) ->    
    url = "/video/info/" + video_id
    deferred = $q.defer()
    success = (data) ->
      deferred.resolve data
      parse_video_info data
      return
    error = (res) -> 
      deferred.reject null
      return
    $http.get(url).success(success).error(error)
    return deferred.promise

  cgi_parse = (query) ->
    params = {}
    $.each query.split(/[&;]/), (i,e) ->
      splits = e.split("=", 2)
      key = cgi_unescape splits[0]
      value = cgi_unescape splits[1]

      if key && value
        if params[key] && Object.prototype.toString.call(params[key]) == "[object Array]"
          params[key].push value
        else
          params[key] = value
      else if key
        params[key] = []
      return
    return params

  cgi_unescape = (string) ->
    return string unless string
    str = string.replace(/\+/g, ' ')
    str = str.replace(/((?:%[0-9a-fA-F]{2})+)/g, (x) -> return decodeURIComponent(x))
    return str

  itag_translate = (itag) =>
    return {
      5:  {codec: 'FLV', width: 320, height: 240},
      17: {codec: '3GP', width: 176, height: 144},
      18: {codec: 'MP4', width: 480, height: 360},
      22: {codec: 'MP4', width: 1280, height: 720},
      34: {codec: 'FLV', width: 480, height: 360},
      35: {codec: 'FLV', width: 640, height: 480},
      36: {codec: '3GP', width: 320, height: 240},
      37: {codec: 'MP4', width: 1920, height: 1080},
      38: {codec: 'MP4', width: 2048, height: 1080},
      43: {codec: 'WEB', width: 480, height: 360},
      44: {codec: 'WEB', width: 640, height: 480},
      45: {codec: 'WEB', width: 1280, height: 720},
      46: {codec: 'WEB', width: 1920, height: 1080},
      82: {codec: 'MP4', width: 480, height: 360, is3d: true},
      83: {codec: 'MP4', width: 640, height: 480, is3d: true},
      84: {codec: 'MP4', width: 1280, height: 720, is3d: true},
      85: {codec: 'MP4', width: 1920, height: 1080, is3d: true},
      100: {codec: 'WEB', width: 480, height: 360, is3d: true},
      101: {codec: 'WEB', width: 640, height: 480, is3d: true},
      102: {codec: 'WEB', width: 1280, height: 720, is3d: true},
      133: {codec: 'MP4', width: 320, height: 240, video_only: true},
      134: {codec: 'MP4', width: 480, height: 360, video_only: true},
      135: {codec: 'MP4', width: 640, height: 480, video_only: true},
      136: {codec: 'MP4', width: 1280, height: 720, video_only: true},
      137: {codec: 'MP4', width: 1920, height: 1080, video_only: true},
      139: {codec: 'MP4', bitrate: 'Low bitrate', audio_only: true},
      140: {codec: 'MP4', bitrate: 'Med bitrate', audio_only: true},
      141: {codec: 'MP4', bitrate: 'Hi bitrate', audio_only: true},
      160: {codec: 'MP4', width: 256, height: 144, video_only: true}
    }[parseInt(itag)]

  parse_video_info = (video_info) ->    
    parsed = cgi_parse video_info
    $scope.title = parsed.title
    $scope.streams = []
    $.each parsed.url_encoded_fmt_stream_map.split(/,/), (i,stream) ->
      parsed_stream = cgi_parse stream
      itag = itag_translate parsed_stream.itag
      hash = 
        codec: itag.codec        
        width: itag.width
        height: itag.height
        quality: parsed_stream.quality
        url: parsed_stream.url
      $scope.streams.push hash






  $scope.get_video_streams = ->    
    video_url   = $("#video-url").val()
    video_id    = get_video_id video_url
    get_video_info video_id    
]

# https://www.youtube.com/watch?v=_M3JdjkTZZQ