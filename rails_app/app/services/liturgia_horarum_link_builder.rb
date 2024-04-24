class LiturgiaHorarumLinkBuilder
  def self.call(chant)
    date = chant.source_file_path.match(/^sanktoral\/(\d{2})(\d{2})/) do |m|
      Date.new(Date.today.year, m[1].to_i, m[2].to_i)
    end

    return nil unless date

    hour_code =
      {
        'tercie' => 'mpred',
        'sexta' => 'mna',
        'nona' => 'mpo'
      }[chant.chant_id] ||
      {
        nil => 'mi',
        'readings' => 'mpc',
        'lauds' => 'mrch',
        'vespers' => 'mv',
        'compline' => 'mk'
      }[chant.hour&.system_name]

    query = URI.encode_www_form({
      qt: 'pdt',
      d: date.day,
      m: date.month,
      r: date.year,
      p: hour_code,
      ds: 1,
      j: 'la',
      o3: 8
    })

    URI::HTTPS.build(
      host: 'breviar.sk',
      path: '/cgi-bin/l.cgi',
      query: query
    ).to_s
  end
end
