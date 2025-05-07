SHELL = bash
EE_VERSION_MAJ = 1
EE_VERSION_MIN = 5
EE_IMAGE_NAME = reseau_ee:$(EE_VERSION_MAJ).$(EE_VERSION_MIN)

#
# racoursis, tests
#
.PHONY: default test test1
default: test
test:
	ansible-navigator run playbooks/ping.yaml -l my_host_group

#
# python virtual env init
#
.PHONY: pyvenv_clean
pyvenv_clean:
	rm -rf .venv

.PHONY: pyvenv_init
pyvenv_init: pyvenv_clean
	python3 -m venv .venv
	source ./.venv/bin/activate && \
		pip3 install pip --upgrade && \
		pip3 install -r ./pyenv-pip-requirements.txt

#
# execution environement targets
#

.PHONY: eenv_clean
eenv_clean:
	rm -rf _build
	rm -f *.log
 
.PHONY: eenv_build
eenv_build: eenv_clean
	docker image inspect $(EE_IMAGE_NAME) > /dev/null 2>&1; \
	if [ "$$?" -eq 0 ]; then \
		echo "ERREUR: 'make eenv_build'"; \
		echo "ERREUR: $(EE_IMAGE_NAME) deja existant"; \
		echo "ERREUR: lancer 'docker image rm $(EE_IMAGE_NAME)' pour la supprimer,"; \
		echo "ERREUR: ou editer le Makefile pour créer une nouvelle version."; \
		false; else true; fi
	ansible-builder build \
		--file    ansible-exec-env.yaml \
		--context _build \
		--tag     $(EE_IMAGE_NAME) \
		--prune-image \
		--container-runtime docker \
		--verbosity 3


#
# clean all
#
.PHONY: clean_all
clean_all: pyvenv_clean eenv_clean
	rm -f .cache
	rm -rf .ansible
	rm -rf _logs

