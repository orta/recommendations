class AppRecommendations

  def mac_app_store_apps_desc
    "These are my installed Mac App Store Apps"
  end

  def cask_apps_desc
    "These are my `brew cask` Apps"
  end

  def brew_apps_desc
    "These are my `brew` Apps"
  end

  def recommend
    @cask_apps = get_installed_casks
    @store_apps = get_mac_app_store_apps
    @brew_apps = get_brew_apps
    
    generate_markdown
  end
  
  def generate_markdown
    
    file_path = Dir.pwd + '/mac-apps.md'
    File.unlink file_path if File.exists? file_path
    
    file_string = "\n\n## Mac App Store Apps"
    file_string += "\n\n" + mac_app_store_apps_desc
    
    file_string += "\n\n| App Name  | Site | \n|-----------|------|\n"
    @store_apps.each do |app|
        file_string += "|[#{app}]|#{ website_for_app(app) }|\n"
    end

    file_string += "\n\n## Homebrew Casks Apps"
    file_string += "\n\n" + cask_apps_desc
    
    file_string += "\n\n| App Name | Site | Install | \n|----------|------|---------|\n"
    @cask_apps.each do |app|
        file_string += "|[#{app}]|#{ website_for_app(app) }|#{ install_for_brew(app) }|\n"
    end
    
    file_string += "\nTo install all:"
    file_string += "\n\n```\n brew cask install " + brew_install_all_command + "\n\n```\n"

    file_string += "\n\n## Homebrew Apps"
    file_string += "\n\n" + brew_apps_desc
    file_string += "\n\n```\n brew install " + @brew_apps.join(" ") + "\n\n```\n"

    File.open(file_path, 'w') { |f| f.write file_string }
  end
  
  
  def get_brew_apps
     `brew list `.split "\n"
  end
  
  def get_mac_app_store_apps
    store_apps = []
    Dir["/Applications/*.app"].each do |app|
      
      next unless Dir.exists? app + "/Contents/_MASReceipt"
      
      app_name = app[14..-5]
      next unless is_apple_app? app_name
      
      store_apps << app_name
    end
    store_apps
  end
  
  def is_apple_app? app
    bundle_id = bundle_id_for_app app
    return bundle_id.include?("com.apple") == false
  end
  
  def bundle_id_for_app app_name
    `/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" '/Applications/#{app_name}.app/Contents/Info.plist'`.strip
  end
  
  def website_for_app app_name
    casks_path = "/usr/local/Library/Taps/phinze-cask/Casks/"
    if File.exists? casks_path + app_name.downcase + ".rb"
      brew_name = app_name.downcase.gsub(" ", "")
      address = `brew cask info #{brew_name}`.split("\n")[1]
      "[#{address}](#{address})"
    
    else
      bundle_id = bundle_id_for_app app_name
      address = bundle_id.split(".").reverse[1..-1].join(".")
      "[#{address}](http://#{address})"
    end
  end
  
  def install_for_brew app_name
    "`brew cask info #{app_name.downcase.gsub(" ", "")}`"
  end
  
  def brew_install_all_command
    @cask_apps.map{|name|name.downcase.gsub(" ", "")}.join(" ")
  end
  
  def get_installed_casks
    casks_path = "/usr/local/Library/Taps/phinze-cask/Casks"
    casks_names = []
    
    Dir[casks_path + "/*.rb"].each do |file| 
      cask_text = File.open(file).read
      name = ""
      if cask_text.include? "link '"
        name = cask_text.split("link '")[-1].split("'")[0].split("/")[-1]
      else
        name = file.split("/")[-1].gsub(".rb", ".app")
      end
      name.gsub!(".app", "")
  
      # installed
      if File.exists? "/Applications/" + name + ".app"
    
        # not mac app store
        unless Dir.exists? "/Applications/" + name + ".app/Contents/_MASReceipt"
          casks_names << name      
        end
      end
    end
    
    casks_names
  end
end