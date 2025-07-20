#!/bin/bash

# Step 2: Create redis pod
cat <<EOF > redis-pod.yml
apiVersion: v1
kind: Pod
metadata:
  name: redis
spec:
  containers:
  - name: redis
    image: redis
EOF

kubectl apply -f redis-pod.yml

# Step 3: Create nginx pod with invalid image
cat <<EOF > nginx-pod.yml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx123
EOF

kubectl apply -f nginx-pod.yml

# Step 4: Check nginx pod status
kubectl get pod nginx

# Step 5: Fix nginx image
kubectl delete pod nginx

cat <<EOF > nginx-pod.yml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx
EOF

kubectl apply -f nginx-pod.yml
kubectl get pod nginx

# Step 6: Count ReplicaSets
kubectl get replicaset

# Step 7: Create ReplicaSet
cat <<EOF > replicaset-definition.yml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: replica-set-1
spec:
  replicas: 3
  selector:
    matchLabels:
      app: busybox
  template:
    metadata:
      labels:
        app: busybox
    spec:
      containers:
      - name: busybox
        image: busybox
EOF

kubectl apply -f replicaset-definition.yml

# Step 8: Scale to 5 pods
kubectl scale --replicas=5 -f replicaset-definition.yml

# Step 9: Check READY pods
kubectl get pods -l app=busybox

# Step 10: Delete 1 pod and verify
POD=$(kubectl get pods -l app=busybox -o jsonpath="{.items[0].metadata.name}")
kubectl delete pod $POD
kubectl get pods -l app=busybox

# Step 11: Count Deployments and ReplicaSets
kubectl get deployments
kubectl get replicaset

# Step 12: Create Deployment with busybox
cat <<EOF > deployment-1.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-1
spec:
  replicas: 3
  selector:
    matchLabels:
      app: busybox-deploy
  template:
    metadata:
      labels:
        app: busybox-deploy
    spec:
      containers:
      - name: busybox
        image: busybox
        command: ["sleep", "3600"]
EOF

kubectl apply -f deployment-1.yml

# Step 13: Count Deployments and ReplicaSets
kubectl get deployments
kubectl get rs

# Step 14: Check ready pods in deployment-1
kubectl get pods -l app=busybox-deploy

# Step 15: Update deployment image to nginx
kubectl set image deployment/deployment-1 busybox=nginx
kubectl rollout status deployment/deployment-1
kubectl get pods -l app=busybox-deploy

# Step 16: Describe deployment and check strategy
kubectl describe deployment deployment-1 | grep Strategy -A 5

# Step 17: Rollback
kubectl rollout undo deployment deployment-1
kubectl get pods -l app=busybox-deploy

# Step 18: Create nginx-deployment like the image you shared
cat <<EOF > deployment-definition.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
  labels:
    app: myapp
    type: front-end
spec:
  replicas: 3
  selector:
    matchLabels:
      type: front-end
  template:
    metadata:
      name: myapp-pod
      labels:
        app: myapp
        type: front-end
    spec:
      containers:
      - name: nginx-container
        image: nginx:1.7.1
EOF

kubectl apply -f deployment-definition.yml
