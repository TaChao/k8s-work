# Pull an Image from a Private Registry

> Original Link : [Pull an Image from a Private Registry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)

## Log in to Docker
``docker login``

When prompted, enter your Docker username and password.
The login process creates or updates a config.json file that holds an authorization token.
View the config.json file:

``cat ~/.docker/config.json`` 

The output contains a section similar to this:  
```
{
    "auths": {
        "https://index.docker.io/v1/": {
            "auth": "c3R...zE2"
        }
    }
}
```
## Create a Secret that holds your authorization token
```
kubectl create secret docker-registry regsecret \
--docker-server=<your-registry-server> \
--docker-username=<your-name> \
--docker-password=<your-pword> \
--docker-email=<your-email>
```

where:
- ``<your-registry-server>`` is your Private Docker Registry FQDN.
- ``<your-name>`` is your Docker username.
- ``<your-pword>`` is your Docker password.
- ``<your-email>`` is your Docker email.

eg:
```
kubectl create secret docker-registry regsecret \
--docker-server=https://index.docker.io/v1/ \
--docker-username=username \
--docker-password=userpassword \
--docker-email=user@mail.com
```

## Create a Pod that uses your Secret

Here is a configuration file for a Pod that needs access to your secret data:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: private-reg
spec:
  containers:
  - name: private-reg-container
    image: <your-private-image>
  imagePullSecrets:
  - name: regsecret
```