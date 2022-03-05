def  shared_pods
    
    # ignore all warnings from all pods
    inhibit_all_warnings!

    # Firebase
    pod 'Firebase/Core', '~> 8.6.0'
    pod 'Firebase/Analytics'
    pod 'Firebase/Auth'
    pod 'Firebase/Storage'
    pod 'Firebase/Firestore'
    pod 'Firebase/Functions', '~> 8.6.0'
    pod 'Firebase/RemoteConfig'
    pod "Firebase/Crashlytics"
    pod 'Firebase/Messaging'
    pod 'Firebase/DynamicLinks'
    
    # Facebook
    pod 'FBSDKLoginKit'
    
    # Google
    pod 'GoogleSignIn'
   # pod 'GooglePlaces', '6.0.0'
    
    # Chat
    pod 'PubNub'
    pod 'MessageKit'

    # Security
    pod 'KeychainAccess'
    # pod 'RNCryptor', '~> 5.0.3'
    
    # Caches and helpers
    pod 'SDWebImage', '~> 5.0'
    
    # Local database
    pod 'RealmSwift'
    
    # Networking
    pod 'Alamofire', '~> 4.7.3'

    # UI
    pod 'SnapKit'

    # Linter
    pod 'SwiftLint'
    
    pod 'GooglePlaces', '6.0.0'
    
    # RX
    pod 'RxCocoa', :git => 'https://github.com/ReactiveX/RxSwift', :branch => 'main'
    pod 'RxSwift'

    # Vertical Swiper
    pod 'VerticalCardSwiper'
    
    pod "Koloda"

    # Image Cropper
    pod 'TOCropViewController'
    
    # Hint
    pod 'AMPopTip'
    
    # Toast
    pod 'NotificationBannerSwift', '2.5.0'
    
    # Debugger
    pod 'FLEX', :configurations => ['Debug']
end


target 'Sparks' do
  
  platform :ios, '14.5'
  use_frameworks!
  shared_pods

end

target 'SparksNotificationExtension' do
  platform :ios, '14.5'
  use_frameworks!
  pod 'Firebase/Messaging'
end

