# Istio
Source: https://istio.io/latest/docs/setup/additional-setup/getting-started/

da quello che ho capito istio server per gestire la parte condivisa tra i servizi:
- monitoring
- traffico
- policies
- ecc...

tra queste cose inoltre implementa la specifica della gateway api

setup istio con kind

https://istio.io/latest/docs/setup/platform-setup/kind/


## Usage
Seguire i passagi della getting started

```bash
istioctl install -f samples/bookinfo/demo-profile-no-gateways.yaml -y # forse da avviare due volte, la prima votla mi si é piantato

kubectl label namespace default istio-injection=enabled

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml
```
