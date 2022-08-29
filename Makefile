# Shortcuts for executing all tests from the outside of the dockerized environment

test-rails:
	cd docker && docker-compose run -w '/var/app/rails_app' ruby bundle exec rake spec

test-python:
	cd docker && docker-compose run -w '/var/app/python' ruby /root/.local/bin/py.test

test-editfial:
	php editfial/editfial.php test

test: test-rails test-python test-editfial
