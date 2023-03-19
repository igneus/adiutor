class SourceFilesController < ApplicationController
  def index
    quality_notices =
      Chant
        .select('COUNT(*)')
        .from('chants c')
        .where('c.source_file_path = chants.source_file_path')
        .where.not('c.placet' => nil)

    @source_files =
      Corpus
        .find_by_system_name!('in_adiutorium')
        .chants
        .select(
          :source_file_path,
          'COUNT(*) AS chants_count',
          "(#{quality_notices.to_sql}) AS quality_notice_count"
        )
        .group(:source_file_path)
        .order(:source_file_path)
        .page(params[:page] || 1)
  end
end
