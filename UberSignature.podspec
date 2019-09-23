Pod::Spec.new do |spec|
  spec.name             = 'UberSignature'
  spec.version          = '1.0.3'
  spec.license          = { :type => 'BSD' }
  spec.homepage         = 'https://github.com/uber/UberSignature'
  spec.author           = 'Uber'
  spec.summary          = 'Draw signatures in Swift and Objective-C.'
  spec.source           = { :git => 'https://github.com/uber/UberSignature.git', :tag => spec.version.to_s }
  spec.source_files 	= 'UberSignature/**/*.swift'
  spec.default_subspecs = 'Swift'
  spec.framework        = 'CoreGraphics', 'Foundation', 'UIKit'
  spec.requires_arc     = true
  spec.ios.deployment_target = '10.0'
  spec.swift_version = '4.1'
end
