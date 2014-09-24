%w(uri json net/http).each { |x| require x }
class Search < ActiveRecord::Base

  attr_accessor :api_call_count
  validates :query, :encoded_query, :presence => :true
  after_initialize :encode
  has_many :locations
  validates_associated :locations

  def perform
   # Location.create_all(self, locs[0..LOCS_LIMIT])
    results = []
    self.locations.each do |loc|
      results_in_loc = self.call_api(loc)
      results_in_loc.each do |item| 
        indeedItem = self.simplify(item)
        indeedItem["travelTime"] = call_walkscore_api(indeedItem["latitude"], indeedItem["longitude"])

        results << indeedItem
      end
    end
    results.ensure_uniq.sort_by_date
  end
  # sets locations 
  def locations
    Location.where(:search_id => self.id)
  end
  # compares locations with the maximum limit set
  def self.too_many?(locations)
    return locations.scan(/,/).size > LOCS_LIMIT
  end
  # creates an array of 
  def make_list(location_string)
    locs = location_string.split(/\s?,\s?/).uniq[0..LOCS_LIMIT]
    Location.create_all(self, locs)
  end
  # this keeps only the desired keys as indicated in RELEVANT_KEYS
  def simplify(hash)
    hash.keep_if {|key| RELEVANT_KEYS.index(key)} # , value
  end
  # creates encoded params to use in uri query
  def encode
    attribute = self.query
    eval <<-end_eval
    unless self.query.nil?
      self.encoded_query = URI.encode_www_form_component(self.query)
    end
    end_eval
  end
  # this uses builds the uri, sends request to uri, and parses JSON response to results
  def call_api(loc)
    uri = URI.parse("#{BASE_URI}?publisher=#{API_KEY}&q=#{self.encoded_query}&l=#{loc.encoded_name}#{END_OF_URI}")
    page = Net::HTTP.get(uri)
    @api_call_count ||= 0
    @api_call_count += 1 unless page.nil? or page.empty?
    json = JSON.parse(page)
    json["results"]
  end

  def call_walkscore_api(latitude, longitude)
    # uri_walkjscore = URI.parse("#{BASE_URI2}?wsapikey=#{WS_API_KEY2}&q=#{queryString2}&l=#{loc.encoded_name}#{END_OF_URI2}")
    uri_walkjscore = URI.parse("http://api2.walkscore.com/api/v1/traveltime/json?wsapikey=94db5d1a5e559d9e830fea3894f9d6e0&mode=walk&origin=34.013579,%20-118.495999&destination=#{latitude},#{longitude}")
    puts uri_walkjscore
    puts "*****"
    puts latitude
    puts longitude
    puts "*****"


    pagetwo = Net::HTTP.get(uri_walkjscore)
    puts pagetwo
    @api_call_count ||= 0
    @api_call_count += 1 unless pagetwo.nil? or pagetwo.empty?
    json = JSON.parse(pagetwo)
    # puts "json:::"
    # puts json["response"]["results"][0]["travel_times"]["seconds"]
    json["response"]["results"][0]["travel_times"]#["seconds"].first
  end
  
  # this is no longer needed
  def debug_crazy(loc)
    uri = "#{BASE_URI}?publisher=#{API_KEY}&q=#{self.encoded_query}&l=#{loc.encoded_name}#{END_OF_URI}"
  end
end




