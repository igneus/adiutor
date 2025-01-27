module GregobaseUri
  BASE_URI = "https://gregobase.selapa.net"

  def self.chant_uri(id)
    BASE_URI + "/chant.php?id=#{id}"
  end

  def self.chant_image_uri(id)
    BASE_URI + "/chant_img.php?id=#{id}"
  end
end
