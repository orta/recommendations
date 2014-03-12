Dir["./generators/*.rb"].each {|file| require_relative file }

# twitter = TwitterRecommendations.new
# twitter.twitter_id = "orta"
# twitter.download

AppRecommendations.new.recommend
TableOfContents.new.create

puts "Applied Auto Generatedness."
