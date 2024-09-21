#!/bin/bash

ARGOCD_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode)

# Run Argo CD port-forward to access localhost:8080
echo "Starting port forwarding to Argo CD server on port 8080..."
kubectl -n argocd port-forward deployment/argocd-server 8080 & > /dev/null 2>&1
PORT_FORWARD_PID=$!

# Wait a few seconds to ensure port-forward is established
sleep 5

# Log in to Argo CD using CLI
echo "Logging in to Argo CD..."
yes | argocd login localhost:8080 --username admin --password $ARGOCD_PASSWORD --insecure > /dev/null 2>&1

argocd app list
argocd app list --output name | xargs -I{} argocd app sync {}

sleep 5

echo "Stopping port forwarding..."
sleep 5
kill $PORT_FORWARD_PID

# Function to get the external IP of the microservices-1 service
get_loadbalancer_ip() {
    kubectl get svc microservice-1-svc -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
}

echo "Waiting for the microservice-1 service to receive a hostname from AWS..."

# Loop until the LoadBalancer has an external IP
while true; do
    # Get the current IP (empty if not assigned yet)
    HOSTNAME=$(get_loadbalancer_ip)
    
    # If the IP is not empty, print it and break the loop
    if [[ -n "$HOSTNAME" ]]; then
        echo "-------------------------------------------------------------------"
        echo "The LoadBalancer hostname is: $HOSTNAME"
        echo "Here is a ready cURL command to test it out!"
        echo "---"
        echo "curl -X POST http://$HOSTNAME -H 'Content-Type: application/json' -d '{\"data\":{\"email_subject\":\"Happy new year!\",\"email_sender\":\"John doe\",\"email_timestream\":\"1693561101\",\"email_content\":\"Just want to say... Happy new year!!!\"},\"token\":\"lior\"}'"
        echo "---"
        echo "NOTE! - The secret token value is set to 'lior', use it to test a valid scenario."
        echo "-------------------------------------------------------------------"
        break
    fi
    
    # Wait for 5 seconds before checking again
    sleep 5
done
