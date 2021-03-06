#! /bin/bash

#Global variables
YAML=ESL-Setting.yaml
MAX=$1
SETNAME=$2
FILE_PATH=./$YAML
OTHERSETTING_1=tomcat-0.tomcat:8080

#writting yaml file
cat > $FILE_PATH <<EOF
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
for i in `seq 0 $MAX`;do
    let x=9000+$i
    let y=37021+$i

    echo "  - port: $x" >> $FILE_PATH
    echo "    name: esl-http-$i" >> $FILE_PATH
    echo "  - port: $y" >> $FILE_PATH
    echo "    name: esl-tcp-$i" >> $FILE_PATH
done
cat >> $FILE_PATH <<EOF
  selector:
    app: nginx-$SETNAME
EOF
echo "---" >> $FILE_PATH
cat >> $FILE_PATH <<EOF
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
for i in `seq 0 $MAX`;do
    let x=9000+$i
    let y=37021+$i

    echo "        - containerPort: $x" >> $FILE_PATH
    echo "          name: esl-http-$i" >> $FILE_PATH
    echo "        - containerPort: $y" >> $FILE_PATH
    echo "          name: esl-tcp-$i" >> $FILE_PATH
done
cat >> $FILE_PATH <<EOF
        volumeMounts:
        - name: config-volume
          mountPath: /script
      volumes:
      - name: config-volume
        configMap: 
          name: nginx
EOF
cat >> $FILE_PATH <<EOF
---
apiVersion: "apps/v1beta1"
kind: StatefulSet
metadata:
  name: $SETNAME
spec:
  serviceName: $SETNAME
  replicas: $MAX
  template:
    metadata:
      labels:
        app: $SETNAME
    spec:
      imagePullSecrets:
      - name: regsecret
      containers:
      - name: $SETNAME
        image: killonexx/hanshow:esl-2.2.2-v1      
        ports:
        - containerPort: 9000
          name: http
        - containerPort: 37021
          name: tcp
        - containerPort: 37022
          name: sslk
        - containerPort: 8800
          name: g1-udp
        - containerPort: 5649
          name: g1-tcp
        - containerPort: 21
          name: g1-ftp
        resources:
          limits:
          #  cpu: "500m"
            memory: 2Gi
          requests:
          # cpu: "500m"
           memory: 2Gi
        env:
          - name: SW_URL
            value: "$OTHERSETTING_1"
          - name: APG1
            value: "false"
        volumeMounts:
        - name: data
          mountPath: /esl_data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: data
      resources:
        requests:
          storage: 2Gi
EOF