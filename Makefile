VENV_DIR ?= .venv
VENV_RUN = . $(VENV_DIR)/bin/activate
PIP_CMD ?= pip
TEST_PATH ?= tests

usage:        ## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

install-opentofu:
	sudo apt-get update
	sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
	sudo install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://get.opentofu.org/opentofu.gpg | sudo tee /etc/apt/keyrings/opentofu.gpg >/dev/null
	curl -fsSL https://packages.opentofu.org/opentofu/tofu/gpgkey | sudo gpg --no-tty --batch --dearmor -o /etc/apt/keyrings/opentofu-repo.gpg >/dev/null
	sudo chmod a+r /etc/apt/keyrings/opentofu.gpg
	echo "deb [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" | sudo tee /etc/apt/sources.list.d/opentofu.list > /dev/null
	sudo apt-get update
	sudo apt-get install -y tofu

install:      ## Install dependencies in local virtualenv folder
	(test `which virtualenv` || $(PIP_CMD) install --user virtualenv) && \
		(test -e $(VENV_DIR) || virtualenv $(VENV_OPTS) $(VENV_DIR)) && \
		($(VENV_RUN); $(PIP_CMD) install -e .[test])

lint:         ## Run code linter
	$(VENV_RUN); flake8 --ignore=E501,W503 bin/tflocal tests

test:         ## Run unit/integration tests
	$(VENV_RUN); pytest $(PYTEST_ARGS) -sv $(TEST_PATH)

publish:      ## Publish the library to the central PyPi repository
	# build and upload archive
	($(VENV_RUN) && pip install setuptools twine && ./setup.py sdist && twine upload dist/*)

clean:        ## Clean up
	rm -rf $(VENV_DIR)
	rm -rf dist/*

.PHONY: clean publish install usage lint test
