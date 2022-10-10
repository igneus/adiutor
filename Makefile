# Shortcuts for executing all tests from the outside of the dockerized environment

IN_RAILS_APP=cd docker && docker-compose run -w '/var/app/rails_app' ruby
IN_PYTHON_APP=cd docker && docker-compose run -w '/var/app/python' ruby

install-pkgs:
	$(IN_RAILS_APP) bundle install
	$(IN_PYTHON_APP) pip install -r requirements.txt

test-rails:
	$(IN_RAILS_APP) bundle exec rake spec

test-python:
	$(IN_PYTHON_APP) /root/.local/bin/py.test

test-editfial:
	php editfial/editfial.php test

test: test-rails test-python test-editfial
