# Loop through a users twitter lists and generate a markdown file with each one

require 'twitter'

class TwitterRecommendations

  def download
    twitter_id = "orta"

    client = get_twitter_client

    lists = client.lists twitter_id
    lists.each do |list|
      next if list.mode != "public"

      p "Looking at: " + list.name

      file_path = Dir.pwd + '/twitter-users-' + list.slug + '.md'
      File.unlink file_path if File.exists? file_path

      file_string = "## " + list.name
      file_string += "\n\n| Person | Description | Site | \n|--------|-------------|------|\n"

      listmembers = get_lists_results_for_user_and_list client, twitter_id, list.slug
      listmembers.each do |list_member|
          user_name = list_member[:name]
          user_description = list_member[:description].gsub("\n", " ").gsub("|", "-")
          user_id = list_member[:screen_name]
          user_url = ""
          begin
            description = list_member[:entities][:url][:urls][0][:display_url]
            url = list[:url]
            user_url = "[#{description}](#{url})"
          rescue
          end

          file_string += "|[#{user_name}](http://twitter.com/#{user_id})|#{user_description}|#{user_url}|\n"
      end

      File.open(file_path, 'w+') { |f| f.write file_string }
    end
  end

  private

  def get_twitter_client
    Twitter::REST::Client.new do |config|
      config.consumer_key        = "1QaLPhCqKhOeji8WW7Rgrg"
      config.consumer_secret     = "dvnLGIP7rOMlM4FkLYECY08VPT0L6afsZTjhEfcw"
      config.access_token        = "2232249636-4bqvbKfGwBsEsU78vSvnpk1JA6Zs8RKRtP466CF"
      config.access_token_secret = "jcjML9tG93Nh76IyxzesejOXIostnbfri7iyDPlk6hCU5"
    end
  end

  def get_lists_results_for_user_and_list(client, name, list_name)
    result = []
    next_cursor = -1
    until next_cursor == 0
        t = client.list_members name, list_name, {:cursor => next_cursor }
        result = result + t.attrs[:users]
        next_cursor = t.next_cursor
    end
    return result
  end

end
