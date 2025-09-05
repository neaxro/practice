# Apply Flux controllers and CRDs first
k8s_yaml('infra/flux/flux-manifests.yaml')

# Apply infra components
k8s_yaml(kustomize('clusters/kind-local'), allow_duplicates=True)
