all: bundle.install build
	
bundle.install:
	docker build -t kiungowiki-bundle-install -f ./dockerfiles/bundle.dockerfile ./
	docker run --rm -v "$(shell pwd)":/usr/src/app -w /usr/src/app kiungowiki-bundle-install bundle install
	docker rmi kiungowiki-bundle-install
	
build-test: 
	docker build -t kiungowiki-test -f ./dockerfiles/test.dockerfile ./
	
build:
	docker build -t registry:5001/kiungo/kiungowiki -f ./dockerfiles/Dockerfile ./
	
console: app.up
	docker run --rm -it -v "$(shell pwd)":/usr/src/app -w /usr/src/app -e RAILS_ENV=development --link=kiungo--kiungowiki.mongodb.0:db registry:5001/kiungo/kiungowiki /bin/bash

run: build app.up
	docker run --rm -it -p 3000:3000 --name kiungo--kiungowiki.web.0 -e RAILS_ENV=development --link=kiungo--kiungowiki.mongodb.0:db registry:5001/kiungo/kiungowiki

logs:
	docker exec -it kiungo--kiungowiki.web.0 tail -f /usr/src/app/log/development.log
			
test: test.unit test.spec
	
test.unit: build-test test-database.up
	docker run --rm -it -e RAILS_ENV=test --link=kiungo--kiungowiki-test.mongodb.0:db kiungowiki-test /usr/local/bundle/bin/rake test

test.spec: build-test test-database.up
	docker run --rm -it -e RAILS_ENV=test --link=kiungo--kiungowiki-test.mongodb.0:db kiungowiki-test /usr/local/bundle/bin/rake spec
	
test.cucumber: build-test test-database.up
	docker run --rm -it -e RAILS_ENV=test --link=kiungo--kiungowiki-test.mongodb.0:db kiungowiki-test /bin/bash /usr/src/app/cucumber.sh
	
app.up: build database.up

database.console: database.up
	docker run -it --link kiungo--kiungowiki.mongodb.0:mongo --rm mongo sh -c 'mongo "$$MONGO_PORT_27017_TCP_ADDR:$$MONGO_PORT_27017_TCP_PORT/test"'
	
database.up:
	docker inspect --format='{{.Name}}' kiungo--kiungowiki-mongodb_data || mappc start-data kiungo--kiungowiki-mongodb data --volume=/data/db
	docker inspect --format='{{.Name}}' kiungo--kiungowiki.mongodb.0 || docker create  --name kiungo--kiungowiki.mongodb.0 --volumes-from=kiungo--kiungowiki-mongodb_data mongo:3
	docker start kiungo--kiungowiki.mongodb.0

test-database.up:
	docker inspect --format='{{.Name}}' kiungo--kiungowiki-test.mongodb.0 || docker create  --name kiungo--kiungowiki-test.mongodb.0 mongo:3
	docker start kiungo--kiungowiki-test.mongodb.0
