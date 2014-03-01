def add_markdown_files_to template
  mdfiles = []
  Dir.foreach('.') do |item|
    next if item == '.' or item == '..'
    next if item[-2..-1] != "md"
    next if item == "README.md"

    mdfiles << item
  end

  mdfiles.each do |mdfile|
    title = mdfile[0..-4].sub("_", " ").gsub(/\w+/) { |word| word.capitalize }.gsub("Ios", "iOS")
    last_updated = File.ctime(mdfile).strftime("%d %b")

    template += "|[#{title}](#{mdfile})|#{last_updated}|\n"
  end

  template
end


def add_twitter_lists
  require 'twitter'
  require Dir.pwd + "/_twitter-utils.rb"
  twitter_id = "orta"

  client = get_twitter_client

  lists = client.lists twitter_id
  lists.each do |list|
    next if list.mode != "public"

    file_path = Dir.pwd + '/twitter-users-' + list.slug + '.md'
    File.unlink file_path if File.exists? file_path

    file_string = "## " + list.name
    file_string += "\n\n| Person | Description | Site | \n|--------|-------------|------|\n"

    listmembers = get_lists_results_for_user_and_list client, twitter_id, list.slug
    listmembers.each do |list_member|
        user_name = list_member[:name]
        user_description = list_member[:description].gsub "\n", " "
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

    File.open(file_path, 'w') { |f| f.write file_string }
  end

end

add_twitter_lists

readme = File.open("README.md", 'rb') { |f| f.read }

start_split = "##### Summary"
end_split = "##### Reasoning"

start = readme.split(start_split)[0]
rest = readme.split(start_split)[1]
finale = rest.split(end_split)[1]

template = start_split + "\n\n| Topics | Last Updated |\n| -------|--------------|\n"

template = add_markdown_files_to template

new_file = start + template + "\n" + end_split + finale
File.open("README.md", 'w') { |f| f.write new_file }

puts "Doned"
