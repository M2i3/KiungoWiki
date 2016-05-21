main_image := m2i3/kiungowiki
bundle_install_image := kiungowiki-bundle-install
app_container := kiungo--kiungowiki.web.0
database_container := kiungo--kiungowiki.mongodb.0
database_container_data := kiungo--kiungowiki-mongodb_data
test_image := kiungowiki-test
importer_image := kiungowiki-importer
test_database_container := kiungo--kiungowiki-test.mongodb.0

app_network := kiungowiki--dev
test_app_network := kiungowiki--test

all: bundle.install build
	
bundle.install:
	docker build -t $(bundle_install_image) -f ./dockerfiles/bundle.dockerfile ./
	docker run --rm -v "$(shell pwd)":/usr/src/app -w /usr/src/app $(bundle_install_image) bundle install
	docker rmi $(bundle_install_image)
	
build-test: 
	docker build -t $(test_image)  -f ./dockerfiles/test.dockerfile ./
	
build:
	ruby-check recent
	docker build -t $(main_image) -f ./dockerfiles/Dockerfile ./

bash: app.up
	docker run --rm -it -v "$(shell pwd)":/usr/src/app -w /usr/src/app --env-file=./.env --net=$(app_network) $(main_image) /bin/bash
	
console: app.up
	docker run --rm -it -v "$(shell pwd)":/usr/src/app -w /usr/src/app --env-file=./.env --net=$(app_network) $(main_image) bundle exec rails c

run: build app.up
	docker rm -f $(app_container) &> /dev/null || true
	docker create --name $(app_container) --env-file=./.env -e SERVICE_NAME="kiungowiki-80" -e RAILS_ENV=development $(main_image)
	docker network connect $(app_network) $(app_container) &> /dev/null || true
	docker network connect --ip=10.254.0.2 m2i3app--router $(app_container) &> /dev/null || true
	docker start $(app_container)

t: build app.up
	docker run -it --rm --name $(app_container) --env-file=./.env -e SERVICE_NAME="kiungowiki-80" -e RAILS_ENV=development $(main_image) /bin/bash

logs:
	docker exec -it $(app_container) tail -f /usr/src/app/log/development.log || true
	
test: test.unit test.spec
	
test.unit: build-test network.up test-database.up
	docker run --rm -it -e RAILS_ENV=test --net=$(test_app_network) $(test_image)  /usr/local/bundle/bin/rake test

test.spec: build-test network.up test-database.up
	docker run --rm -it -e RAILS_ENV=test --net=$(test_app_network) $(test_image)  /usr/local/bundle/bin/rake spec
	
test.cucumber: build-test network.up test-database.up
	docker run --rm -it -e RAILS_ENV=test --net=$(test_app_network) $(test_image)  /bin/bash /usr/src/app/cucumber
	
app.up: build network.up database.up 
	
network.up:
	mappc is-network $(app_network) || docker network create $(app_network)
	mappc is-network $(test_app_network) || docker network create $(test_app_network)

network.cleanup: 
	! mappc is-network $(app_network) || docker network rm $(app_network)
	! mappc is-network $(test_app_network) || docker network rm $(test_app_network)
	
database.up: network.up
	mappc is-container $(database_container_data) || mappc mkdata $(database_container_data) --volume=/data/db
	mappc is-container $(database_container) || docker create --name $(database_container) --volumes-from=$(database_container_data) mongo:3
	docker network connect --alias=db $(app_network) $(database_container) &> /dev/null || true
	docker start $(database_container)
	

test-database.up:
	mappc is-container kiungo--kiungowiki-test.mongodb.0 || docker create  --name kiungo--kiungowiki-test.mongodb.0 mongo:3
	docker start kiungo--kiungowiki-test.mongodb.0
	
import.accessdb: database.up
	ruby-check recent
	docker build -t $(importer_image)  -f ./dockerfiles/importer.dockerfile ./
	docker run --rm -it -v "$(shell pwd)/../data":/mnt/import -v "$(shell pwd)":/usr/src/app -w /usr/src/app --env-file=./.env -e RAILS_ENV=development --net=$(app_network) $(importer_image) bundle exec rails c
	
cleanup-all: cleanup cleanup-images
	
cleanup:
	! mappc is-container $(app_container) || docker rm -f $(app_container) > /dev/null || true
	! mappc is-container $(database_container) || docker rm -f $(database_container) > /dev/null  || true
	! mappc is-container $(test_database_container) || docker rm -f $(test_database_container) > /dev/null  || true

cleanup-images:
	! mappc is-image $(main_image) || docker rmi -f $(main_image) || true
	! mappc is-image $(test_image)  || docker rmi -f $(test_image)  || true
	! mappc is-image $(bundle_install_image) || docker rmi -f $(bundle_install_image) || true