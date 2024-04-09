module SearchUtils
  extend self

  def like_search_string(str, search_type)
    case search_type
    when 'beginning'
      "#{str}%"
    when 'end'
      "%#{str}"
    else
      "%#{str}%"
    end
  end
end
