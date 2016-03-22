# 批量定义配置文件
module Settings
  Dir.glob('config/settings/**/*.yml').each do |file|
    file_name = File.basename(file, '.yml')
    module_name = file_name.camelize
    mash = Hashie::Mash.load(file)
    const_set(module_name, mash.key?(Rails.env) ? mash[Rails.env] : mash)
  end
end
