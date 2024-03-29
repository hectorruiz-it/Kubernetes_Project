#/bin/bash

if [ $# -ne 3 ]
then
    echo 'Arguments parsing error'
    exit 1
fi

# Stores username and password received by ssh connection
godPassword=$1
username=$2
password=$3

# Create user specifying directory, group and shell
echo ${godPassword} | sudo -S useradd -d /home/${username} -s /bin/rbash -m ${username}
echo ${godPassword} | sudo -S chown -R ${username}:zeus /home/${username}
echo ${godPassword} | sudo -S chmod 770 /home/${username}
mkdir /home/${username}/certs

# Creates user certificates and context for Kubernetes
cd /home/${username}
# Generates rolebinding and certificates. Configures credentials and sets it up

kubectl create rolebinding noprv_${RANDOM} --role noprv-role --user ${username} -n application
openssl genrsa -out ${username}.key 2048
openssl req -new -key ${username}.key -out ${username}.csr -subj "/CN=${username}/O=user"
openssl x509 -req -in ${username}.csr -CA /home/zeus/certs/ca.crt -CAkey /home/zeus/certs/ca.key -CAcreateserial -out ${username}.crt -days 10000
kubectl config set-credentials ${username} --client-certificate=./${username}.crt --client-key=./${username}.key
kubectl config set-context ${username}-context --cluster=kubernetes --namespace=application --user=${username}
kubectl config use-context ${username}-context

cp -r /home/zeus/.kube /home/zeus/templates/kube
# Deletes kubernetes-admin from user file kube/config 
yq 'del(.users.[0] | select(.name == "kubernetes-admin"))' /home/zeus/templates/kube/config > /home/zeus/templates/kube/config.1
yq 'del(.contexts.[0].context | select(.user == "kubernetes-admin"))' /home/zeus/templates/kube/config.1 > /home/zeus/templates/kube/config.2
yq 'del(.contexts.[0] | select(.name == "kubernetes-admin@kubernetes"))' /home/zeus/templates/kube/config.2 > /home/zeus/templates/kube/config

rm -rf /home/zeus/templates/kube/config*
mv /home/zeus/templates/kube/ /home/${username}/.kube

# Copies all the templates to username folder
cp /home/zeus/scripts/userDeploy.sh /home/${username}
cp -r /home/zeus/bin /home/${username}/

sudo bash -c 'cat <<EOF >> /home/${username}/.bashrc
alias kubectl="kubectl --context=${username}-context"
PATH=/home/${username}/bin
export PATH
EOF'

kubectl config use-context kubernetes-admin@kubernetes
echo ${godPassword} | sudo -S chown -R ${username}:zeus /home/${username}
cat <<EOF > /home/zeus/passwd-${username}.txt
${username}:${password}
EOF

echo ${godPassword} | sudo -S chpasswd < /home/zeus/passwd-${username}.txt
rm -rf /home/zeus/passwd-${username}.txt
echo ${godPassword} | sudo -S chown -R ${username}:zeus /home/${username}

