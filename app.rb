require 'bundler'

Bundler.require
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite")

class Track
  include DataMapper::Resource
  belongs_to :album
  property :id, Serial, :key => true
  property :created_at, DateTime
  property :title, String, :length => 1000
  property :soundcloud_url, String, :length => 500
  property :youtube_url, String, :length => 500
end

class Album
  include DataMapper::Resource
  has n, :tracks
  property :id, Serial, :key => true
  property :created_at, DateTime
  property :title, String, :length => 1000
  property :artist, String, :length => 255
  property :release_date, DateTime
end

DataMapper.finalize
DataMapper.auto_migrate!
DataMapper.auto_upgrade!

get '/' do
  send_file './public/index.html'
end

get '/albums' do
  content_type :json
  @albums = Album.all(:order => :created_at.desc)
  @albums.to_json
end

post '/albums' do
  content_type :json
  @album = Album.new(params)

  if @album.save
    @album.to_json
  else
    halt 500
  end
end

get '/albums/tracks' do
  content_type :json
  @tracks = Track.all(:order => :created_at.desc)
  @tracks.to_json
end

post '/albums/tracks' do
  content_type :json
  @track = Track.new(params)

  if @track.save
    @track.to_json
  else
    halt 500
  end
end

get '/albums/:id' do
  content_type :json
  @album = Album.get(params[:id])

  if @album
    @album.to_json
  else
    halt 404
  end
end

get '/albums/tracks/:id' do
  content_type :json
  @track = Track.get(params[:id])

  if @track
    @track.to_json
  else
    halt 404
  end
end

# put '/songs/:id' do
#   content_type :json

#   @song = Coupon.get(params[:id])
#   @songs.update(params)

#   if @songs.save
#     @songs.to_json
#   else
#     halt 500
#   end
# end

# delete '/coupons/:id/delete' do
#   content_type :json
#   @song = Coupon.get(params[:id])

#   if @coupon.destroy
#     {:success => "ok"}.to_json
#   else
#     halt 500
#   end
# end

if Track.count == 0 && Album.count == 0
  album = Album.create(:artist => "Emi Hinouchi", :title => "Dramatiques", :release_date => Time.now)
  album.tracks.create(:title => "Magic", :youtube_url => "http://www.youtube.com/watch?v=WmyUhgg0HBU")
  album.tracks.create(:title => "Rosy", :soundcloud_url => "https://soundcloud.com/emihinouchi/rosy-khalil-fong-cover-feat")
end