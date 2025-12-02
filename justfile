colima-start:
    colima start --kubernetes --kubernetes-version v1.34.1+k3s1 --runtime containerd --cpu 4 --memory 8 --disk 50 --kubernetes-disable=traefik

colima-stop:
    colima stop

colima-delete:
    colima delete --data --force

minio:
    helm repo add minio https://charts.min.io
    helm repo update
    helm install minio minio/minio \
        --create-namespace \
        --namespace minio \
        --set rootUser=minioadmin \
        --set rootPassword=minioadmin123 \
        --set mode=standalone \
        --set replicas=1 \
        --set persistence.enabled=true \
        --set persistence.size=10Gi \
        --set resources.requests.memory=512Mi \
        --set consoleService.type=NodePort \
        --set service.type=NodePort

minio-port-forward:
    #!/usr/bin/env zsh
    export POD_NAME=$(kubectl get pods --namespace minio -l "release=minio" -o jsonpath="{.items[0].metadata.name}")
    kubectl port-forward $POD_NAME 9000 --namespace minio

minio-ls-local:
    mc ls -r local

minio-local-alias:
    #!/usr/bin/env zsh
    PORT=$(kubectl get svc -n minio minio -o jsonpath="{.spec.ports[0].nodePort}")
    mc alias set local "http://localhost:$PORT" minioadmin minioadmin123

minio-tansu-bucket:
    mc mb local/tansu

pod-name namespace release:
    kubectl get pods --namespace {{namespace}} -l release={{release}} -o jsonpath="{.items[0].metadata.name}"

get-deployment namespace:
    kubectl get deployment -n {{namespace}} --show-kind

get-deployment-apps namespace:
    kubectl get deployments.apps -n {{namespace}} --show-kind

get-svc namespace:
    kubectl get svc -n {{namespace}}

logs namespace label:
    kubectl logs -n {{namespace}} -l {{label}}

apply filename:
    kubectl apply --filename {{filename}}

minio-when-ready:
    kubectl wait --for=condition=ready pod -l app=minio -n minio --timeout=300s

minio-pod-name: (pod-name "minio" "minio")

minio-svc: (get-svc "minio")

tansu: (apply "tansu.yaml")

tansu-deployment: (get-deployment "tansu")

tansu-logs:
    kubectl logs -n tansu -l app=tansu -f 2>&1 | tee broker.log

tansu-all-logs:
    kubectl logs -n tansu -l app=tansu --since=5h > tansu.log

tansu-restart-monitor-status:
    kubectl rollout restart deployment/tansu -n tansu
    kubectl rollout status deployment/tansu -n tansu

knative-operator:
    helm repo add knative-operator https://knative.github.io/operator
    helm repo update
    helm install knative-operator --create-namespace --namespace knative-operator knative-operator/knative-operator

knative-operator-deployment: (get-deployment "knative-operator")

knative-serving: (apply "serving.yaml")

knative-serving-dns:
    kubectl --namespace knative-serving get service kourier

knative-serving-controller-logs: (logs "knative-serving" "app=controller")

knative-serving-deployment: (get-deployment "knative-serving")

knative-eventing: (apply "eventing.yaml")

knative-eventing-deployment: (get-deployment "knative-eventing")

knative-eventing-controller-logs: (logs "knative-eventing" "app=eventing-controller")
knative-eventing-kafka-broker-receiver-logs: (logs "knative-eventing" "app=kafka-broker-receiver")
knative-eventing-kafka-controller-logs: (logs "knative-eventing" "app=kafka-controller")
knative-eventing-kafka-webhook-eventing-logs: (logs "knative-eventing" "app=kafka-webhook-eventing")

kafka-broker-controller: (apply "https://github.com/knative-extensions/eventing-kafka-broker/releases/download/knative-v1.20.0/eventing-kafka-broker.yaml")

kafka-broker-data-plane: (apply "https://github.com/knative-extensions/eventing-kafka-broker/releases/download/knative-v1.20.0/eventing-kafka-controller.yaml")

broker: (apply "broker.yaml")

sink: (apply "sink.yaml")

event-display-logs: (logs "ping-test" "app=event-display")

trigger: (apply "trigger.yaml")

source: (apply "source.yaml")

ping-test-deployment: (get-deployment "ping-test")
