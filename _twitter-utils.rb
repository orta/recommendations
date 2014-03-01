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
