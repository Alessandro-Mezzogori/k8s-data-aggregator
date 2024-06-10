# Start from root workspace folder

# Create cluster k8s with kind
$kind_clusters = (kind get clusters | Out-String)
Write-Host $kind_clusters
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

# Load created images in docker
kind load docker-image test-worker-express:1.0.0
if($LASTEXITCODE -ne 0){
    Write-Host 'Loading docker images in kind cluster failed' -ForegroundColor Red
    exit -1;
}

# Apply external configurations and namespaces
# Potrebbero fallire in caso di mancato internet, possibile scaricarle e tenere un copia locale ( fare script )
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml 
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml

# Apply internal configurations 
kubectl apply -f .\net\k8s\