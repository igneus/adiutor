require 'pycall'

# While it would be no big deal to code another version of the Volpiano transformations,
# let's have some time-ineffective fun and call the Python code instead:

PyCall.import_module('sys').path.append(File.expand_path('../python', Rails.root))

VolpianoDerivates = PyCall.import_module('adiutor.volpiano_derivates')

def VolpianoDerivates.snippet_to_interval_series(volpiano)
  interval_series(
    volpiano.start_with?('1') ? volpiano : '1---' + volpiano
  )
end
