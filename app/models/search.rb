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
        results << self.simplify(item)
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
  
  # this is no longer needed
  def debug_crazy(loc)
    uri = "#{BASE_URI}?publisher=#{API_KEY}&q=#{self.encoded_query}&l=#{loc.encoded_name}#{END_OF_URI}"
  end
end
