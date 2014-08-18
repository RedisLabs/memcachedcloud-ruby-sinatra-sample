require 'sinatra'
require 'dalli'

configure do
    if ENV["MEMCACHEDCLOUD_SERVERS"]
        $cache = Dalli::Client.new(ENV["MEMCACHEDCLOUD_SERVERS"].split(','), :username => ENV["MEMCACHEDCLOUD_USERNAME"], :password => ENV["MEMCACHEDCLOUD_PASSWORD"])
    end
end

get '/' do
  File.read(File.join('views', 'index.html'))
end

get '/command' do
  unless $cache.nil?
    @res= ''

    begin
      case params[:a]
        when 'set'           
          @res  = $cache.set('welcome_msg', 'Hello from Redis!').nil? ? 'False' : 'True'          
        when 'get'
          @res = $cache.get('welcome_msg') || 'N/A'
        when 'delete'
          @res = $cache.delete('welcome_msg').nil? ? 'N/A' : 'True'
        when 'stats'
          $cache.stats().each { |k, v| 
            @res += "#{k}: #{v}<br />" 
          }
      end
    
    rescue => e
      puts e.message
      @res = nil
    end
  
    $cache.close()  
  end

  @res  
end
