ARG DOCKER_REGISTRY

FROM ${DOCKER_REGISTRY:+${DOCKER_REGISTRY}/}alpine

ENV \
	HELM_VERSION=v3.12.3 \
	HELMDIFF_VERSION=3.8.0 \
	KUBECTL_VERSION=v1.28.0 \
	KUSTOMIZE_VERSION=5.1.1 \
  HELMFILE_VERSION=v0.153.1

RUN \
	echo "Installing basic tooling" \
		&& apk add --update --no-cache \
			aws-cli \
			bash \
			curl \
			git \
			jq \
			openssl \
	&& OS_NAME=$(uname -o | tr '[:upper:]' '[:lower:]') \
    && ARCH_NAME=$(uname -m) \
      && ARCH_NAME=${ARCH_NAME/aarch64/arm64} \
      && ARCH_NAME=${ARCH_NAME/x86_64/amd64} \
	&& echo "Installing kubectl version ${KUBECTL_VERSION##v}" \
		&& curl -fL https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/${OS_NAME}/${ARCH_NAME}/kubectl \
			--output /usr/local/bin/kubectl \
			--no-progress-meter \
		&& chmod +x /usr/local/bin/kubectl \
	&& echo "Installing helm version ${HELM_VERSION##v}" \
		&& curl -fSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
			--output get_helm.sh \
			--no-progress-meter \
		&& chmod 700 get_helm.sh \
		&& ./get_helm.sh --version ${HELM_VERSION} \
	&& echo "Installing helm-diff plugin ${HELMDIFF_VERSION##v}" \
    && helm plugin install https://github.com/databus23/helm-diff \
      --version=${HELMDIFF_VERSION} \
	&& echo "Installing helmfile version ${HELMFILE_VERSION##v}" \
		&& mkdir -p helmfile \
		&& curl -fL https://github.com/helmfile/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION/v/}_${OS_NAME}_${ARCH_NAME}.tar.gz \
			--no-progress-meter \
			| tar xz -C helmfile \
		&& mv helmfile/helmfile /usr/local/bin/helmfile \
			&& chmod +x /usr/local/bin/helmfile \
			&& rm -rf helmfile \
	&& echo "Installing kustomize version ${KUSTOMIZE_VERSION##v}" \
		&& curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" \
			| bash -s - ${KUSTOMIZE_VERSION} \
		&& mv ./kustomize /usr/local/bin

WORKDIR /var/workspace
