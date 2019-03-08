
Pod::Spec.new do |s|

  s.name         = "AMJavascriptBridge"
  s.version      = "0.1.0"
  s.summary      = "WebView、Native和JS交互的集成"

  s.description  = "基于WKWebView集成WebViewController,基于WebViewJavascriptBridge集成Native和JS交互框架"

  s.homepage     = "https://github.com/zhenhuamu/AMJavascriptBridge"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "AndyMu" => "muzh@2345.com" }

  s.platform     = :ios, "8.0"

  s.ios.deployment_target = "8.0"

  s.source       = { :git => "git@github.com:zhenhuamu/AMJavascriptBridge.git", :tag => s.version.to_s }
  
  s.subspec 'AMBridge' do |ss|
      ss.source_files = 'AMJavascriptBridge/AMBridge/*.{h,m}'
      ss.dependency 'WebViewJavascriptBridge'
  end

  s.subspec 'AMWebView' do |ss|
      ss.source_files = 'AMJavascriptBridge/AMWebView/*.{h,m}'
      ss.resource = 'AMJavascriptBridge/AMWebView/AMWebView.bundle'
  end
  
  s.subspec 'AMBridgeWebView' do |ss|
      ss.source_files = 'AMJavascriptBridge/AMBridgeWebView/*.{h,m}'
      ss.dependency 'AMJavascriptBridge/AMBridge'
      ss.dependency 'AMJavascriptBridge/AMWebView'
  end
  
  s.subspec 'AMPrivatyPolicy' do |ss|
      ss.source_files = 'AMJavascriptBridge/AMPrivatyPolicy/*.{h,m}'
      ss.dependency 'AMJavascriptBridge/AMWebView'
  end
  
  

  s.frameworks = "UIKit", "Foundation","WebKit"

end
