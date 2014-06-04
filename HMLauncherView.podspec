Pod::Spec.new do |s|
  s.name             = "HMLauncherView"
  s.version          = "1.0.0"
  s.summary          = "HMLauncherView is an UI component which mimics the iOS homescreen (a.k.a SpringBoard) behaviour"
  s.description      = <<-DESC
                        HMLauncherView is an UI component which mimics the iOS homescreen (a.k.a SpringBoard) behaviour. 
                        Added icons can be reordered and removed. In addition the HMLauncherView supports drag&drop of icons between several HMLauncherView instances.
                        Checkout the demo video: http://www.youtube.com/watch?v=Mqv1usdM6fA 
                       DESC
  s.homepage         = "https://github.com/heikomaass/HMLauncherView"
  s.license          = 'Apache 2.0'
  s.author           = { "Heiko Maaß" => "mail@heikomaass.de" }
  s.source           = { :git => "git@github.com:heikomaass/HMLauncherView.git", :tag => s.version.to_s }

  s.platform     = :ios, '6.1'
  s.requires_arc = true
  s.source_files = 'Classes/*.{h,m}'

end
