#
# Be sure to run `pod lib lint ZZMakeFMDBManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZZMakeFMDBManager'
  s.version          = '0.0.1'
  s.summary          = 'FMDB数据库管理工具.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
            FMDB数据库管理工具,增删改查使用简单.
                       DESC

  s.homepage         = 'https://github.com/UserZhangXiaoZhe/ZZMakeFMDBManager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'UserZhangXiaoZhe' => 'zaihuishou223@163.com' }
  s.source           = { :git => 'https://github.com/UserZhangXiaoZhe/ZZMakeFMDBManager.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ZZMakeFMDBManager/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ZZMakeFMDBManager' => ['ZZMakeFMDBManager/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'FMDB'
end
