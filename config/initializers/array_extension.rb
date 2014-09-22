class ArrayExtension

  Array.class_eval do  # this converts the results date to datetime and sorts them by date

    def sort_by_date
      self.sort! {|x,y| y["date"].to_datetime <=> x["date"].to_datetime}
    end
  end

  Array.class_eval do  # this returns an array of results excluding the ones with same urls
                       # can also be used to remove key/value pairs from a hash (empty or nil strings)
    def ensure_uniq # sometimes duplicate postings have different URLs...go figure
     # without_url = self.inject([]){|a,i| a << i.reject{|k,v| k == :url}}
      # i.reject returns an array excluding all key/values except urls
      # group_by returns an array of urls by url (results with the same url get grouped together)
      grouped = self.group_by {|i| i.reject{|k,v| k == :url}}
      ary = []
      # this builds an array of the urls, only including the first url in each group
      grouped.each do |group| ary << group.first end
      ary
    end
  end



end
