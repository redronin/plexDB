class PlexModel
  attr_reader :title, :year, :ext, :type, :filename, :path, :season, :episode,
              :width, :height, :audio_codec, :video_codec,
              :media_part,
              :metadata


  def initialize(params)
    params = ActiveSupport::HashWithIndifferentAccess.new(params)
    @title      = params.fetch(:title)
    @year       = params.fetch(:year, nil)
    @height     = params.fetch(:height, nil)
    @width      = params.fetch(:width, nil)
    @ext        = params.fetch(:ext, nil)
    @type       = params.fetch(:type, nil)
    @filename   = params.fetch(:filename, nil)
    @path       = params.fetch(:path, nil)

    @season  = params.fetch(:season, nil)
    @episode = params.fetch(:episode, nil)

    @media_part = params.fetch(:media_part, nil)
    @metadata   = params.fetch(:metadata, nil)
    @audio_codec = params.fetch(:audio_codec, nil)    
    @video_codec = params.fetch(:video_codec, nil)
  end

  # we can have lots of versions...
  def self.create_from_metadata(metadata)
  end

  def self.create_from_media_part(media_part)
    metadata = media_part.media_item.metadata_item
    params = {
      title: media_part.title,
      year:  media_part.year,
      ext:   media_part.ext,
      type:  media_part.type,
      video_codec:media_part.media_item.video_codec,
      audio_codec:media_part.media_item.audio_codec,
      filename: media_part.filename,
      path: media_part.path,
      height: media_part.height.to_i,
      width: media_part.width.to_i,
      media_part: media_part,
      metadata: metadata
    }
    if media_part.type.upcase == 'TV'
      params.merge!({season: metadata.season_number, episode: metadata.episode_number})
    end

    PlexModel.new(params)
  end

  # type    width     height
  # -------------------------
  # HQ      >= 3860   >= 2160
  # 1080p   >= 1920   >= 1080
  # 720p    >= 1280   >= 720
  # SD      the rest
  def resolution
    if width >= 3800 || height >= 2100        # close to 3860 x 2160
      "HQ"
    elsif width >= 1900 || height >= 1000 # close to 1920 x 1080
      "1080p"
    elsif width >= 1200 || height >= 700     # close to 1280 x 720
      "720p"
    else
      "SD"
    end
  end

  def to_liquid
    {
      title: title.gsub(/\//, "_"),
      year: year,
      resolution: resolution,
      ext: ext,
      filename: filename,
      path: path,
      audio_codec: audio_codec,
      video_codec: video_codec,
      season: "%02d" % season.to_i,
      episode: "%02d" % episode.to_i     
    }.stringify_keys
  end

end