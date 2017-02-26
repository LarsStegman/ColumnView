Pod::Spec.new do |s|
    s.name         = "ColumnView"
    s.version      = "0.2.2"
    s.summary      = "View Controllers in columns"
    s.description  = <<-DESC
    A container view controller which can contain multiple child view controllers and displays them as columns.
    DESC
    s.homepage     = "https://github.com/LarsStegman/ColumnView"
    s.license      = "MIT"
    s.author       = "Lars Stegman"
    s.social_media_url   = "http://twitter.com/LarsSteg"
    s.source       = { :git => "https://github.com/LarsStegman/ColumnView.git", :branch => "master", :tag => "v#{s.version.to_s}" }
    s.ios.deployment_target = '10.0'
    s.source_files  = "Sources/*.swift"
end
