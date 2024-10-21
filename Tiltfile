load('ext://helm_resource', 'helm_resource')

docker_build('rancher-webhook', context='.')

# helm_resource(
#   'rancher-config',
#   './hack/rancher-config',
#   release_name='rancher',
#   namespace='cattle-system',
#   deps=['./hack/rancher-config'],
#   image_deps=['rancher-webhook'],
#   image_keys=[('repository', 'tag')],
# )

_apply_path = os.path.abspath('apply.sh')
_delete_path = os.path.abspath('noop.sh')

k8s_custom_deploy(
  'patch', 
  _apply_path,
  _delete_path,
  [],
  image_deps=['rancher-webhook'],
)

k8s_resource('patch')
