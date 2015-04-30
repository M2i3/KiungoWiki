all: bundle.install build
	
bundle.install:
	docker run --rm -v "$(shell pwd)":/usr/src/app -w /usr/src/app registry:5001/kiungo/kiungowiki-test  bundle install
# apt-get install -y qt4-dev-tools libqt4-dev libqt4-core libqt4-gui &&

build:
	docker build -t registry:5001/kiungo/kiungowiki ./
	
build-test:
	docker build -t registry:5001/kiungo/kiungowiki-test -f test.dockerfile ./
	
console: app.up
	docker run --rm -it -v "$(shell pwd)":/usr/src/app -w /usr/src/app -e RAILS_ENV=development --link=kiungo--kiungowiki.mongodb.0:db registry:5001/kiungo/kiungowiki /bin/bash

run: build app.up
	docker run --rm -it -p 3000:3000 --name kiungo--kiungowiki.web.0 -e RAILS_ENV=development --link=kiungo--kiungowiki.mongodb.0:db registry:5001/kiungo/kiungowiki

logs:
	docker exec -it talbott-merchandiser.web.0 tail -f /usr/src/app/log/development.log
	
	
test: test.unit test.spec
	
test.unit: build test-database.up
	docker run --rm -it -e RAILS_ENV=test --link=kiungo--kiungowiki-test.mongodb.0:testdb registry:5001/kiungo/kiungowiki /usr/local/bundle/bin/rake test

test.spec: build test-database.up
	docker run --rm -it -e RAILS_ENV=test --link=kiungo--kiungowiki-test.mongodb.0:testdb registry:5001/kiungo/kiungowiki /usr/local/bundle/bin/rake spec

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
