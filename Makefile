NODE=14
UNIT_TEST := "tests/**/*.test.ts"
INTEGRATION_TEST := "tests/**/*.int-test.ts"

clean:
	./bin/clean.sh

install:
	docker run -i --rm --name install-apollo-api -u "node" -v `pwd`:/usr/src/app -w /usr/src/app node:${NODE} npm install ${PCKG}

lint:
	docker run -i --rm --name lint-apollo-api -u "node" -v `pwd`:/usr/src/app -w /usr/src/app node:${NODE} npm run lint

lint-fix:
	docker run -i --rm --name lint-fix-apollo-api -u "node" -v `pwd`:/usr/src/app -w /usr/src/app node:${NODE} npm run lint:fix

test: install unit_test integration-test-run lint

unit_test:
	docker run -i --rm -p "9199:9200" \
	-v `pwd`:/usr/src/app \
	-w /usr/src/app node:${NODE} \
	node_modules/.bin/nyc \
	node_modules/.bin/mocha \
	--require ts-node/register \
	$(UNIT_TEST) -R spec --color --verbose

integration-test-run:
	docker run -i --rm -p "9198:1337" \
	-e NODE_ENV=test \
	-e ENV="local" \
	-e JWT_PRIVATE="Test-private-key" \
	-v `pwd`:/usr/src/app -w /usr/src/app node:${NODE} \
	node_modules/.bin/nyc --reporter=cobertura --report-dir=./coverage-integration \
	node_modules/.bin/mocha \
	--require ts-node/register \
	$(INTEGRATION_TEST) -R spec --color --verbose --exit

package:
	/bin/sh ./bin/package.sh

compile:
	docker run -i --rm --name compile-apollo-api -e NODE_ENV=production -u "node" -v `pwd`:/usr/src/app -w /usr/src/app node:${NODE} npm run build

publish: test
	npm publish --access=public
