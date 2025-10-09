class LiturgiaHorarumLinkBuilder
  def self.call(chant)
    new.call chant
  end

  def call(chant)
    date_and_hour(chant)
      &.yield_self {|dh| link(*dh) }
  end

  def date_and_hour(chant)
    date = chant.source_file_path.match(/^sanktoral\/(\d{2})(\d{2})/) do |m|
      next nil if m[2].to_i > 90 # movable sanctorale feasts not supported for now

      sanctorale_celebration_date CalendariumRomanum::AbstractDate.new(m[1].to_i, m[2].to_i)
    end

    return nil unless date

    hour_sym =
      {
        'tercie' => :terce,
        'sexta' => :sext,
        'nona' => :none
      }[chant.chant_id] ||
      chant.hour&.system_name&.to_sym ||
      :invitatory

    [date, hour_sym]
  end

  def sanctorale_celebration_date(abstract_date)
    year = 2000 - 1
    begin
      year += 1
      date = abstract_date.concretize(year)
    end until calendar[date].celebrations.any? do |i|
      i.cycle == :sanctorale &&
        i.date == abstract_date &&
        (date.sunday? || i.rank != CalendariumRomanum::Ranks::FEAST_LORD_GENERAL)
    end

    date
  end

  def link(date, hour)
    hour_code = {
      # Hour system_names
      readings: 'mpc',
      lauds: 'mrch',
      vespers: 'mv',
      compline: 'mk',
      # hours not covered by separate Hour system names
      invitatory: 'mi',
      terce: 'mpred',
      sext: 'mna',
      none: 'mpo',
    }.fetch hour

    # TODO: investigate why Hash.to_query doesn't work -
    # is it due to changing parameter order, or something else?
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

  private

  def calendar
    @calendar ||= begin
      CalendariumRomanum::PerpetualCalendar.new(
        sanctorale: CalendariumRomanum::Data::CZECH.load
      )
    end
  end
end
