project 'WhatFilm.xcodeproj'

platform :ios, '9.0'

target 'WhatFilm' do

  use_frameworks!

  # Pods for WhatFilm
  pod 'Alamofire'
  pod 'SwiftyJSON', git: 'https://github.com/BaiduHiDeviOS/SwiftyJSON.git', branch: 'swift3'
  pod 'RxSwift', '~> 3.0.0.alpha.1'
  pod 'RxCocoa', '~> 3.0.0.alpha.1'
  pod 'RxDataSources', '~> 1.0.0-beta.2'
  pod 'SDWebImage'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'DateTools'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
      config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.10'
    end
  end
end
