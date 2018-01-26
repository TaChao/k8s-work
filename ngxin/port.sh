#! /bin/bash

#Global variables
STATEFUL_SET_YAML=ESL-StatefulSet.yaml
SERVICE_YAML=ESL-Service.yaml
MAX=$1
SETNAME=$2
STATEFUL_SET_PATH=./$STATEFUL_SET_YAML
SERVICE_PATH=./$SERVICE_YAML

#writting yaml file
cat > $STATEFUL_SET_PATH <<EOF
apiVersion: apps/v1beta1 # for versions before 1.8.0 use apps/v1beta1
kind: StatefulSet
metadata:
  name: nginx-$SETNAME
spec:
  selector:
    matchLabels:
      app: nginx-$SETNAME
  serviceName: nginx-$SETNAME
  replicas: 3 # tells deployment to run 2 pods matching the template
  template: # create pods using pod definition in this template
    metadata:
      # unlike pod-nginx.yaml, the name is not included in the meta data as a unique name is
      # generated from the deployment name
      labels:
        app: nginx-$SETNAME
    spec:
      imagePullSecrets:
      - name: regsecret
      containers:
      - name: nginx-$SETNAME
        image: killonexx/nginx:alpine
        imagePullPolicy: IfNotPresent
        env:
          - name: SET_NAME
            value: "$SETNAME"
          - name: PODS_NUM
            value: "$MAX"
          - name: NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
        lifecycle:
          postStart:
            exec:
              command: 
              - bash
              - "-c"
              - |
                set -ex
                chmod +x -R /script
                sh /script/init.sh \$SET_NAME \$PODS_NUM 9000 \$NAMESPACE
                sh /script/init.sh \$SET_NAME \$PODS_NUM 37021 \$NAMESPACE
                crond

        ports:
EOF
for i in `seq 0 $1`;do
    let x=9000+$i
    let y=37021+$i

    echo "        - containerPort: $x" >> $STATEFUL_SET_PATH
    echo "          name: esl-http-$i" >> $STATEFUL_SET_PATH
    echo "        - containerPort: $y" >> $STATEFUL_SET_PATH
    echo "          name: esl-tcp-$i" >> $STATEFUL_SET_PATH
done
cat >> $STATEFUL_SET_PATH <<EOF
        volumeMounts:
        - name: config-volume
          mountPath: /script
      volumes:
      - name: config-volume
        configMap: 
          name: nginx
EOF
cat > $SERVICE_PATH <<EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-$SETNAME
spec:
  type: LoadBalancer
  loadBalancerSourceRanges:
  - 0.0.0.0/0
  ports:
EOF
for i in `seq 0 $1`;do
    let x=9000+$i
    let y=37021+$i

    echo "  - port: $x" >> $SERVICE_PATH
    echo "    name: esl-http-$i" >> $SERVICE_PATH
    echo "  - port: $y" >> $SERVICE_PATH
    echo "    name: esl-tcp-$i" >> $SERVICE_PATH
done
cat >> $SERVICE_PATH <<EOF
  selector:
    app: nginx-$SETNAME
EOF