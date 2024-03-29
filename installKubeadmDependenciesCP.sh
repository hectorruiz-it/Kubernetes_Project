# ubuntu 20.04
# k8s 1.23 (with kubeadm)
# cri: Docker
# install required dependencies for earch k8s server/node.
## enable some kernel modules and make them available now.
sudo apt update && sudo apt upgrade && sudo apt autoremove

# Create needed folders
mkdir /home/zeus/roles
mkdir /home/zeus/templates
mkdir /home/zeus/certs
mkdir /home/zeus/bin
sudo ln -s /bin/sed /home/zeus/bin/
sudo ln -s /bin/rm /home/zeus/bin/
sudo ln -s /bin/kubectl /home/zeus/bin/
sudo ln -s /bin/ls /home/zeus/bin/
mkdir /home/zeus/scripts
mv ./sshScript.sh /home/zeus/scripts
mv ./userDeploy.sh /home/zeus/scripts

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
## create system network settings required for k8s to work properly and load them immediately.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.brige.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system
## install containerd and docker
sudo apt-get update

sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo apt install openssh-server -y
## install k8s required packages (first disable swap usage! check also /etc/fstab for swap usage)
sudo swapoff -a
sudo apt-get update
sudo apt-get install -y apt-transport-https curl
## install gpg key from k8s repo and enable the official k8s repo.
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
## install k8s 1.23 (kubeadm + kubectl) and prevent k8s to be updated when running 'sudo apt-get update'
sudo apt-get update
sudo apt-get install -y kubelet=1.23.0-00 kubeadm=1.23.0-00 kubectl=1.23.0-00
sudo apt-mark hold kubelet kubeadm kubectl

# initialize the cluster
## only on the control plane server/node!
sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --kubernetes-version 1.23.0
## set up kubeconfig to interact with the control plane node and get nodes
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl get nodes

# create the networking on the cluster (calico) and check control plane node status
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
kubectl get nodes

# join worker nodes to cluster
## copy the result from the command above and paste it onto the worker servers/nodes (example below) as sudo
kubeadm token create --print-join-command 
## after a few minutes nodes should show up as read:
kubectl get nodes

# Install prometheus
sudo snap install helm --classic
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
sudo snap install yq
#kubectl create namespace prometheus
#helm install prometheus prometheus-community/kube-prometheus-stack --namespace=prometheus

#Install lens
wget https://api.k8slens.dev/binaries/Lens-5.4.6-latest.20220428.1.amd64.deb
sudo dpkg -i Lens-5.4.6-latest.20220428.1.amd64.deb

# Instalación k9s
wget https://github.com/derailed/k9s/releases/download/v0.25.18/k9s_Linux_x86_64.tar.gz
tar -xvf k9s_Linux_x86_64.tar.gz
sudo mv k9s /usr/bin

sudo cp /etc/kubernetes/pki/ca* /home/zeus/certs
sudo chown zeus:zeus /home/zeus/certs/* 
# Rol creation
cat <<EOF > /home/zeus/roles/noprv.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: application
  name: noPRV-role
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create"]
EOF

cat <<EOF > /home/zeus/roles/creator.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: application
  name: creator
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
- apiGroups: [""]
  resources: ["rolebindings"]
  verbs: ["create"]
EOF

# Creación PODS mediante deploy garantizando una replica
cat <<EOF > /home/zeus/templates/nginx-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-deployment
  namespace: application
spec:
  selector:
    matchLabels:
      app: user
  replicas: 2 # indica al controlador que ejecute 2 pods
  template:
    metadata:
      labels:
        app: user
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
EOF

cat <<EOF > /home/zeus/templates/alpine-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-deployment
  namespace: application
spec:
  selector:
    matchLabels:
      app: user
  replicas: 2 # indica al controlador que ejecute 2 pods
  template:
    metadata:
      labels:
        app: user
    spec:
      containers:
      - name: alpine
        image: alpine:latest
EOF

cat <<EOF > /home/zeus/templates/mariadb-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-deployment
  namespace: application
spec:
  selector:
    matchLabels:
      app: user
  replicas: 2 # indica al controlador que ejecute 2 pods
  template:
    metadata:
      labels:
        app: user
    spec:
      containers:
      - name: mariadb 
        image: mariadb:latest
        ports:
        - containerPort: 3306

EOF

kubectl create namespace application
kubectl apply -f /home/zeus/roles/noprv.yaml

# Install xfce desktop and vncserver
sudo apt install xfce4 xfce4-goodies tightvncserver -y
vncserver
vncserver -kill :1
echo "startxfce4" >> ~/.vnc/xstartup
vncserver



