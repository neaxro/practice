# Tiltfile

# Apply Flux controllers and CRDs first
# k8s_yaml('infra/flux/flux-manifests.yaml')

# Apply MetalLB manifests via kustomize
k8s_yaml(kustomize('infra/metallb'), allow_duplicates=True)

# Apply cluster overlay (which may include metallb or other infra)
k8s_yaml(kustomize('clusters/kind-local'), allow_duplicates=True)

# Optional: name resources for Tilt UI visibility and control
# k8s_resource('flux-system', yaml='infra/flux/flux-manifests.yaml')
# k8s_resource('metallb', kustomize='infra/metallb')
# k8s_resource('kind-local', kustomize='clusters/kind-local')

# Tilt auto-watches all referenced files by default
# but you can explicitly watch directories to be sure
# watch_dir('infra/flux')
# watch_dir('infra/metallb')
# watch_dir('clusters/kind-local')
