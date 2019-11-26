source 'https://github.com/CocoaPods/Specs.git'
workspace 'ReduxVM'
platform :ios, '11.0'
inhibit_all_warnings!
use_frameworks!

def shared_pods
    pod 'DeclarativeTVC'
    pod 'RedSwift', :git => 'https://github.com/kocherovets/RedSwift.git', :branch => 'master'
end

target "ReduxVM" do
    project 'ReduxVM'

    shared_pods
end


target "ReduxVMTests" do
    project 'ReduxVM'

    shared_pods
end

target "ReduxVMUITests" do
    project 'ReduxVM'

    shared_pods
end
