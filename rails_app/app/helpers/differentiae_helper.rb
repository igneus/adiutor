module DifferentiaeHelper
  def differentia_anchor(*elements)
    elements
      .compact
      .collect {|i| i.gsub(/[^\w\d]/, '-') }
      .join('_')
  end
end
