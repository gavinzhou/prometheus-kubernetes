fmt:
	@echo -e "\033[1m>> Formatting all jsonnet files\033[0m"
	find -iname '*.libsonnet' | awk '{print $1}' | xargs jsonnet fmt -i $1

generate: fmt docs
	git diff --exit-code

docs: embedmd
	@echo -e "\033[1m>> Generating docs\033[0m"
	embedmd -w README.md

embedmd:
	@echo -e "\033[1m>> Ensuring embedmd is installed\033[0m"
	go get github.com/campoy/embedmd

build: remove
	$(MAKE) compile

compile:
	jsonnet -J vendor -m manifests -J . kube-prometheus.jsonnet | xargs -I{} sh -c 'cat {} | gojsontoyaml > {}.yaml; rm -f {}' -- {}

deps:
	@echo -e "\033[1m>> Ensuring jb (jsonnet-bundler) is installed\033[0m"
	go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
	@echo -e "\033[1m>> Ensuring gojsontoyaml (jsonnet-bundler) is installed\033[0m"
	go get github.com/brancz/gojsontoyaml

init:
	rm -rvf vendor
	jb install

remove:
	rm -rf manifests && mkdir manifests

build-ci: remove
	jsonnet -J vendor -m manifests -J . minikube-prometheus.jsonnet | xargs -I{} sh -c 'cat {} | gojsontoyaml > {}.yaml; rm -f {}' -- {}