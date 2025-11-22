### INSTALL jenkins

1. [jenkins官网](https://jenkins.io/)
2. [docker compose](../docker/compose/jenkins-compose.yml)

### 查看默认密码
```bash
sudo docker logs jenkins

# cd6fc15029974285bf1af791dfc256d7 is the password
```

```
jenkins  | *************************************************************
jenkins  | *************************************************************
jenkins  | *************************************************************
jenkins  | 
jenkins  | Jenkins initial setup is required. An admin user has been created and a password generated.
jenkins  | Please use the following password to proceed to installation:
jenkins  | 
jenkins  | cd6fc15029974285bf1af791dfc256d7
jenkins  | 
jenkins  | This may also be found at: /var/jenkins_home/secrets/initialAdminPassword
jenkins  | 
jenkins  | *************************************************************
jenkins  | *************************************************************
jenkins  | *************************************************************
```