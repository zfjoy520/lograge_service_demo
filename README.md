# lograge_service_demo

# 基于 lograge + kids + taojay315的一篇文章

[Rails Log Process](https://ruby-china.org/topics/27523)

写的一个即可以让Rails保持原生本机文件LOG不变,
又可以将 request / sql / exception 等日志发往kids的一个demo.

## 原作者在这里: [https://ruby-china.org/taojay315](https://ruby-china.org/taojay315)

其中，对Rails原生的丑日志的重新格式化部分抄自:
concise_logging: [https://github.com/gshaw/concise_logging](https://github.com/gshaw/concise_logging)

并有所修改.


## 相关事项

* Ruby 2.3.0
* Rails 4.2.5
* Kids: [https://github.com/zhihu/kids](https://github.com/zhihu/kids)
* Kids安装及使用方式见: [https://github.com/zhihu/kids/blob/master/README.zh_CN.md](https://github.com/zhihu/kids/blob/master/README.zh_CN.md)
* Kids启动所需配置文件在: config/conf/kids_server.conf
* Kids连接配置文件在: config/settings/kids.yml
* 配置文件加载用到了: [hashie](https://github.com/intridea/hashie) 中的 Hashie::Mash
  不太喜欢将一大堆配置文件都放在 config 目录下, 所以在 config 目录下新建了一个 settings 目录(config/settings)
  里面的 *.yml 都将加载到 ::Settings::Xxx 中
  相关的 initializer 文件在: config/initializers/settings.rb


## 开始吧

### 安装Kids

下载 [Kids源码发布包](https://github.com/zhihu/kids/releases)（文件名为 kids-VERSION.tar.gz），运行：
	
	tar xzf kids-VERSION.tar.gz
	cd kids-VERSION
    ./configure
    make && make install

### Kids 编译好后，运行：

	kids -c lograge_service_demo/config/conf/kids_server.conf

### kids 使用 redis 协议，打开一个rails console：

	2.3.0 :xxx > r = Redis.new(port: 3388)
    2.3.0 :xxx > r.psubscribe('*') do |on|
    2.3.0 :xxx >   on.pmessage do |pattern, channel, message|
    2.3.0 :xxx >     puts "pattern: #{pattern}, channel: #{channel}, message: #{message}"
    2.3.0 :xxx >   end
    2.3.0 :xxx > end

可以观察日志的收集情况

### 启动web server

因为在 lib/lograge_service/railtie.rb 中指定了 development 环境不生效, 所以需要以 production 来跑

    $ puma -p 3000 -e production -t 32:32 -w 1

### 额外的代码
只需要在 config/application.rb 中引入 lib/lograge_service 即可:

    ...

    require File.expand_path('../../lib/lograge_service', __FILE__)
    
    # Require the gems listed in Gemfile, including any gems
    # you've limited to :test, :development, or :production.
    Bundler.require(*Rails.groups)
    
    module LogrageServiceDemo
      class Application < Rails::Application
         ...

### 代码写得不好, 轻拍
