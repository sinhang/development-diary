### q
```
0/1 nodes are available: 1 node(s) had untolerated taint {node-role.kubernetes.io/control-plane: }. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling.
```
### a
```bash
kubectl taint nodes <master-node-name> node-role.kubernetes.io/control-plane-
```

### q
```
Back-off pulling image "192.168.1.100:5000/dev/account-service:latest": ErrImagePull: failed to pull and unpack image "192.168.1.100:5000/dev/account-service:latest": failed to resolve image: failed to do request: Head "https://192.168.1.100:5000/v2/dev/account-service/manifests/latest": http: server gave HTTP response to HTTPS client
```
### a
[SECRET](./SECRET.md)
```bash
```