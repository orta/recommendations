mdfiles = []
Dir.foreach('.') do |item|
  next if item == '.' or item == '..'
  next if item[-2..-1] != "md"
  next if item == "README.md"

  mdfiles << item
end

readme = File.open("README.md", 'rb') { |f| f.read }

start_split = "##### Summary"
end_split = "##### Reasoning"

start = readme.split(start_split)[0]
rest = readme.split(start_split)[1]
finale = rest.split(end_split)[1]

template = start_split + "\n\n| Topics |\n| ---------------------------------|\n"

mdfiles.each do |mdfile|
  title = mdfile[0..-4].sub("_", " ").gsub(/\w+/) { |word| word.capitalize }
  
  template += "|[#{title}](#{mdfile})|\n"
end

new_file = start + template + "\n" + end_split + finale
File.open("README.md", 'w') { |f| f.write new_file }

puts "Doned"