# Start from root workspace folder

param (
    [switch]$delete = $false
)

# Configuration 

if($delete) {
    kind delete cluster
}

# Create cluster k8s with kind
$kind_clusters = (kind get clusters | Out-String)
if($kind_clusters -eq ''){
    kind create cluster --config .\net\kind-config.yaml
}
else {
    Write-Host 'Found ' $kind_clusters -ForegroundColor Cyan
}

# Build image of docker
docker build -t test-worker-express:1.0.0 .\net\workers\test-worker\
if($LASTEXITCODE -ne 0){
    Write-Host 'Docker build failed' -ForegroundColor Red
    exit -1;
}

# Cleanup old docker images that have been replaced
# TODO scope the pruning to just the images that have been replaced
docker image prune --force

# Load created images in docker
kind load docker-image test-worker-express:1.0.0
if($LASTEXITCODE -ne 0){
    Write-Host 'Loading docker images in kind cluster failed' -ForegroundColor Red
    exit -1;
}

# Apply external configurations and namespaces
kubectl apply -f .\net\k8s\external\

# Rabbitmq
kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"

# Apply internal configurations 
kubectl apply -f .\net\k8s\

# Interazione con RabbitMQ
# 
# $username = kubectl get secret rabbitmq-cluster-default-user -o jsonpath='{.data.username}'
# $username = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($username))
# $username
# 
# $password = kubectl get secret rabbitmq-cluster-default-user -o jsonpath='{.data.password}'
# $password = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($password))
# $password
#
# $service = kubectl get service rabbitmq-cluster  -o jsonpath='{.spec.clusterIP}'
# $service
#
# Write-Host $username $password => default_user_TV9CNWAcxBd__Tk3zFr WBRyv_inlf8oVjUa6RNB2zmb8sAHJjn6
# kubectl port-forward "service/rabbitmq-cluster" 15672
# 
# PERF TEST
# kubectl run perf-test --image=pivotalrabbitmq/perf-test -- --uri "amqp://$($username):$($password)@$($service)"
# kubectl logs --follow perf-test
# Results: 
# - id: test-211846-048, time 10.000 s, sent: 85244 msg/s, received: 81331 msg/s, min/median/75th/95th/99th consumer latency: 362469/426001/442659/461815/468588 µs
# - id: test-211846-048, time 11.000 s, sent: 77983 msg/s, received: 80102 msg/s, min/median/75th/95th/99th consumer latency: 371835/431564/448368/464575/470368 µs
# - id: test-211846-048, time 12.000 s, sent: 78788 msg/s, received: 78178 msg/s, min/median/75th/95th/99th consumer latency: 361566/433624/452841/472158/480461 µs
# kubectl delete pod perf-tests

