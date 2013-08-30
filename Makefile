# Licensed under the Apache License. See footer for details.

.PHONY: static

COFFEE  = node_modules/.bin/coffee
COFFEEC = $(COFFEE) --bare --compile

#-------------------------------------------------------------------------------
help:
	@echo "available targets:"
	@echo "   watch         - watch for changes, then build, then test"
	@echo "   build         - build the code"
	@echo "   test          - run the tests"
	@echo "   help          - print this help"
	@echo ""
	@echo "You will need to run 'make vendor' before duing anything useful."

#-------------------------------------------------------------------------------
watch: build-n-test
	@node_modules/.bin/wr "make build-n-test" *.coffee

#-------------------------------------------------------------------------------
build-n-test: build test

#-------------------------------------------------------------------------------
build:
	@$(COFFEEC) --output . *.coffee

#-------------------------------------------------------------------------------
test:
	@mkdir -p tmp
	@rm -rf   tmp/*

	@node node-doc-bs node-src tmp

#-------------------------------------------------------------------------------
static:
	@mkdir -p static
	@rm -rf   static/*

	cd static; wget http://netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css
	cd static; wget http://netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap-theme.min.css
	cd static; wget http://netdna.bootstrapcdn.com/bootstrap/3.0.0/js/bootstrap.min.js
	cd static; wget http://nodejs.org/images/logos/node-favicon.png
	cd static; wget http://code.jquery.com/jquery-2.0.3.min.js
	cd static; wget https://raw.github.com/isagalaev/highlight.js/master/src/styles/default.css

	mv static/jquery-2.0.3.min.js static/jquery.min.js
	mv static/default.css         static/highlight-default.css

	@echo "see ../Makefile for where these files were downloaded from" > static/README.md


#-------------------------------------------------------------------------------
# Copyright 2013 Patrick Mueller
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#-------------------------------------------------------------------------------

