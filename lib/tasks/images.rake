desc 'generate images for Chants'
task images: [:environment] do
  generator = LilypondImageGenerator.new
  Chant.find_each {|c| generator.(c) }
end
