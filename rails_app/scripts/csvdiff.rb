# Compares first two columns of a CSV file using `meld`.
# Input file can be passed as argument or piped to stdin.

require 'csv'
require 'tempfile'

Tempfile.open('a') do |fa|
  Tempfile.open('b') do |fb|
    ARGF.each.with_index(1) do |l, i|
      a, b, _ = CSV.parse_line l
      next if a.nil? || b.nil?

      fa.puts a
      fb.puts b
    end

    fa.flush
    fb.flush

    `meld #{fa.path} #{fb.path}`
  end
end
