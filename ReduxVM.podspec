Pod::Spec.new do |s|

s.platform = :ios
s.ios.deployment_target = '11'
s.name = "ReduxVM"
s.summary = "App framework on base of RedSwift and DeclarativeTVC."
s.requires_arc = true

s.license = { :type => "MIT", :file => "LICENSE" }
s.homepage = 'https://github.com/kocherovets/ReduxVM'
s.author = { 'Dmitry Kocherovets' => 'kocherovets@gmail.com' }

s.version = "1.0.22"
s.source = { :git => 'https://github.com/kocherovets/ReduxVM.git', :tag => s.version.to_s  }
s.source_files = "Framework/Sources/**/*.{swift}"

s.swift_version = "5.0"

s.framework = "UIKit"

s.dependency 'DeclarativeTVC'
s.dependency 'RedSwift'

end
