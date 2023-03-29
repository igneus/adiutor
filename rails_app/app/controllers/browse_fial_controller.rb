class BrowseFialController < ApplicationController
  # we need the POST endpoint to be callable from the outside
  skip_forgery_protection

  # accepts single FIAL as named path segment, redirects to the chant's detail
  def detail
    fial = params[:fial]
    parsed = FIAL.parse fial
    chant = Chant.find_by(source_file_path: parsed.path, chant_id: parsed.id)

    if chant
      redirect_to chant_path(chant)
      return
    end

    raise "FIAL #{fial.inspect} not found"
  end

  # accepts a list FIALs, one per line, as POST body,
  # redirects to a listing of the specified chants
  def list
    ids = request.body.read.lines.collect do |fial|
      parsed = FIAL.parse fial.strip
      Chant
        .find_by(source_file_path: parsed.path, chant_id: parsed.id)
        .tap {|x| raise "#{fial.inspect} not found" if x.nil? }
        .id
    end

    redirect_to chants_path(ids: ids.collect(&:to_s).join(','))
  end
end
