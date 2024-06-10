# Setup

1. Costruire le varie immagini che sono utilizzate 
    
    ```shell
    docker build -t <image>:<version> <path>
    ```
2. Crea cluster da kind-config.yaml
    ```shell
    kind create cluster --config <path>
    ```
3. Carica le immagini dentro kind in modo che possa usare all'interno dei pods
    ```shell
    kind load docker-image <image>:<version> [,<image>:version]+
    ```
4. Importa i namespace dei servizi esterni di nginx e metallb e applica i manifesti 
    ```shell
    # Applica nginx ingress per poterlo usare dentro un servizio
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

    # Importa namespace MetalLLB
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml

    # Applica manifesto di MetalLB
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml
    ```
5. Applica tutte le configurazioni
    ```shell
    kubectl apply -f <folder> 
    ```
