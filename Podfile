target 'MoviePulse' do
  use_frameworks!

  # Pods for MoviePulse
  # Networks
  pod 'Alamofire'
  
  # Encrypt
  pod 'CryptoSwift', '~> 1.4.1'
  
  # Save local
  pod 'CodableFiles', '1.0.2'
  
  # Load Image
  pod 'Kingfisher', '~> 8.0'
  
  # Animation
  pod 'lottie-ios'
  
  pod 'RxSwift', '6.8.0'
  pod 'RxCocoa', '6.8.0'
  pod 'RxGesture'
  
  # Analytics
  pod 'FirebaseCore', :git => 'https://github.com/firebase/firebase-ios-sdk.git',
  :tag => 'CocoaPods-10.24.0'
  pod 'FirebaseCrashlytics', :git => 'https://github.com/firebase/firebase-ios-sdk.git',
  :tag => 'CocoaPods-10.24.0'
  pod 'FirebaseAnalyticsSwift', :git => 'https://github.com/firebase/firebase-ios-sdk.git',
  :tag => 'CocoaPods-10.24.0'
  pod 'FirebaseRemoteConfig', :git => 'https://github.com/firebase/firebase-ios-sdk.git',
  :tag => 'CocoaPods-10.24.0'
  pod 'FirebaseFirestore', :git => 'https://github.com/firebase/firebase-ios-sdk.git',
  :tag => 'CocoaPods-10.24.0'
  pod 'FirebaseMessaging', :git => 'https://github.com/firebase/firebase-ios-sdk.git',
  :tag => 'CocoaPods-10.24.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        if file.settings && file.settings['COMPILER_FLAGS']
          flags = file.settings['COMPILER_FLAGS'].split
          flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
          file.settings['COMPILER_FLAGS'] = flags.join(' ')
        end
      end
    end
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
  end
end
