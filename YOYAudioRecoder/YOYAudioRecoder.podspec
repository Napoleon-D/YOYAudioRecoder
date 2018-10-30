

Pod::Spec.new do |s|

s.name        = "YOYAudioRecoder"

s.version     = "0.0.7"

s.platform = :ios, "8.0"

s.summary     = "~~iOS~~录音器~~"

s.homepage    = "https://github.com/ox-man"

s.author     = { "ox-man" => "wangtao199205@qq.com" }

s.source      = { :git => "https://github.com/ox-man/YOYAudioRecoder.git",:tag => s.version.to_s}

s.source_files = "YOYAudioRecoder/YOYAudioRecoder/YOYAudioRecoder/*.{h,m}"

s.license     = { :type => "MIT", :file => "LICENSE" }

s.requires_arc = true

end
