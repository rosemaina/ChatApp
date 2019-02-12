# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

use_frameworks!

def eChat_pods 
    pod 'Firebase/Database'
    pod 'Firebase/Core'
    pod 'Firebase/Auth'
    pod 'Firebase/Storage'
    pod 'Firebase/Firestore'

    pod 'MBProgressHUD' 
    pod 'ProgressHUD' 
    pod 'IQAudioRecorderController'

    pod 'JSQMessagesViewController', '7.3.3'
    pod 'IDMPhotoBrowser'

    pod 'ImagePicker'

    pod 'Quick'
    pod 'Nimble'
 
end

#PODS FOR TARGET eCHAT
  target 'eChat' do
    eChat_pods

  target 'eChatTests' do
    inherit! :search_paths
    eChat_pods 
  end

  target 'eChatUITests' do
    inherit! :search_paths
    eChat_pods 
  end

end


#PODS FOR TARGET eCHAT-DEV
#target 'MyChatApp-Dev' do
    
   #eChat_pods