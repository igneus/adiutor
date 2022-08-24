require 'pycall'

# While it would be no big deal to code another version of the Volpiano transformations,
# let's have some time-ineffective fun and call the Python code instead:

PyCall.import_module('sys').path.append(File.expand_path('../python', Rails.root))

VolpianoDerivates = PyCall.import_module('adiutor.volpiano_derivates')
