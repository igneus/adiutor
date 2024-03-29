# Shortcuts for executing essential commands from the outside of the dockerized environment

IN_RAILS_APP=./dc.sh run -w '/var/app/rails_app' ruby
IN_PYTHON_APP=./dc.sh run -w '/var/app/python' ruby

# dependency management

install-pkgs:
	$(IN_RAILS_APP) bundle install
	$(IN_PYTHON_APP) pip install -r requirements.txt

# running tests

test-rails:
	$(IN_RAILS_APP) bundle exec rake spec

test-python:
	$(IN_PYTHON_APP) /root/.local/bin/py.test

test-editfial:
	php editfial/editfial.php test

test: test-rails test-python test-editfial

# generating computed content

volpiano:
	$(IN_PYTHON_APP) python3 bin/tasks.py volpiano --missing
