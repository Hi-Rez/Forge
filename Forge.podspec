Pod::Spec.new do |spec|
  spec.name                   = "Forge"
  spec.version                = "1.2.0"
  spec.summary                = "Get up and rendering with Metal via Metalkit without worrying about triple buffering / semaphores"
  spec.description            = <<-DESC
  Forge's Renderer class sets up triple buffering rendering so you don't have to. You also get nice Cinder / Processing / Openframeworks functions you can hook into and do stuff.
                   DESC
  spec.homepage               = "https://github.com/Hi-Rez/Forge"
  spec.license                = { :type => "MIT", :file => "LICENSE" }
  spec.author                 = { "Reza Ali" => "reza@hi-rez.io" }
  spec.social_media_url       = "https://twitter.com/rezaali"
  spec.source                 = { :git => "https://github.com/Hi-Rez/Forge.git", :tag => spec.version.to_s }
  spec.osx.deployment_target  = "10.15"
  spec.ios.deployment_target  = "13.0"
  spec.tvos.deployment_target = "13.0"

  spec.osx.source_files       = "Sources/Forge/*.swift"
  spec.ios.source_files       = "Sources/Forge/*.swift"
  spec.tvos.source_files      = "Sources/Forge/*.swift"

  spec.frameworks             = "Metal", "MetalKit", "SwiftUI"
  spec.module_name            = "Forge"
  spec.swift_version          = "5.1"
end
