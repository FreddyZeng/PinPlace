platform :ios, '10.0'

target 'PinPlace' do
  use_frameworks!
  pod 'Alamofire', :git => 'https://github.com/Alamofire/Alamofire'
  pod 'JASON', :git => 'https://github.com/delba/JASON'
  pod 'ObjectMapper', :git => 'https://github.com/Hearst-DD/ObjectMapper'
  pod 'PKHUD', :git => 'https://github.com/pkluz/PKHUD'
  pod 'JSQCoreDataKit', :git => 'https://github.com/jessesquires/JSQCoreDataKit'
  pod 'RxSwift', :git => 'https://github.com/ReactiveX/RxSwift'
  # pod 'RxCocoa'
  # pod 'RxBlocking'
  pod 'RxAlamofire', :git => 'https://github.com/RxSwiftCommunity/RxAlamofire'
  pod 'RxCoreData', :git => 'https://github.com/RxSwiftCommunity/RxCoreData'
  pod 'RxGesture', :git => 'https://github.com/RxSwiftCommunity/RxGesture'
  pod 'RxMKMapView', :git => 'https://github.com/RxSwiftCommunity/RxMKMapView'
  pod 'RxDataSources', :git => 'https://github.com/RxSwiftCommunity/RxDataSources'
    
  target 'PinPlaceTests' do
    inherit! :search_paths
  end

  target 'PinPlaceUITests' do
    inherit! :search_paths
  end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.0'
        end
    end
  end
