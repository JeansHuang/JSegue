Pod::Spec.new do |s|

  s.name         = "JSegue"
  s.version      = "1.0.0"
  s.summary      = "极其简单易用的ViewController push 传参 封装类别；UIViewController push pop modal simple category."

  s.description  = <<-DESC
  极其简单易用的ViewController push 传参 封装类别；
  UIViewController push pop modal simple category.
  方便的页面跳转，只需一行代码。
  支持Storyboard，xib，无view。
                   DESC

  s.homepage     = "http://my.oschina.net/jeans/blog"
  
  s.license      = "MIT"
  
  s.author             = { "Jeans" => "19023006@qq.com" }
  
  s.platform     = :ios, "5.0"

  s.source       = { :git => "https://github.com/JeansHuang/JSegue.git", :tag => "#{s.version}" }

  s.source_files  = 'JSegue/**/*.{h,m}'

  s.requires_arc = true

end
