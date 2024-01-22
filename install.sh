# swapoff -a
apt-get update
apt-get install -y vim curl wget git
snap install microk8s --classic
microk8s status --wait-ready
microk8s enable registry storage dns ingress
snap install kubectl --classic
mkdir -p /root/.kube
microk8s config > /root/.kube/config
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
ARGO_CLI_VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$ARGO_CLI_VERSION/argocd-linux-amd64
chmod +x /usr/local/bin/argocd
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
sleep 60
echo "Password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"
IP_ADDRESS=$(ip -f inet addr show enp0s8 | sed -En -e 's/.*inet ([0-9.]+).*/\1/p')
echo "IP de Argocd: "$IP_ADDRESS
fuser -k 8081/tcp
kubectl port-forward --address $IP_ADDRESS svc/argocd-server -n argocd 8081:443