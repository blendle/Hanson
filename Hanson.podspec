Pod::Spec.new do |spec|
    spec.name                      = "Hanson"
    spec.version                   = "1.1"
    spec.summary                   = "Lightweight observations and bindings in Swift"
    spec.homepage                  = "https://github.com/blendle/Hanson"
    spec.license                   = { :type => "ISC", :file => "LICENSE" }
    spec.authors                   = { "Joost van Dijk" => "joost@blendle.com" }
    spec.ios.deployment_target     = "8.0"
    spec.osx.deployment_target     = "10.9"
    spec.watchos.deployment_target = '2.0'
    spec.tvos.deployment_target    = '9.0'
    spec.source                    = { :git => "https://github.com/blendle/Hanson.git", :tag => spec.version.to_s }
    spec.source_files              = "Hanson/*.swift", "Hanson/**/*.swift"
end
