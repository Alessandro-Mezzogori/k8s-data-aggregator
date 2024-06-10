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
# Could fail if no internet access, TODO download file offline 
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml 
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml

# Sleep to avoid timeout ( ingress-nginx has a timeout of 10 seconds from last request/download )
Start-Sleep -Seconds 15

# Apply internal configurations 
kubectl apply -f .\net\k8s\