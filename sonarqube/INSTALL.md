### INSTALL sonarqube

1. [sonarqube 官网](https://www.sonarqube.org/)
2. [sonarqube download](https://www.sonarsource.com/products/sonarqube/downloads/)

### 准备工作
```bash
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-25.11.0.114957.zip
unzip sonarqube-25.11.0.114957.zip
mv sonarqube-25.11.0.114957 sonarqube
```

### 启动 sonarqube
```bash
./sonarqube/bin/linux-x86-64/sonar.sh start
```

### 访问 sonarqube
[http://localhost:9000](http://localhost:9000)

```
默认账号: admin
默认密码: admin
```


### 安装和配置 SonarScanner
1. [SonarScanner 官网](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/)

```bash
mkdir /home/{username}/soft/sonar-scanner
cd /home/{username}/soft/sonar-scanner
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
unzip sonar-scanner-cli-5.0.1.3006-linux.zip
mv sonar-scanner-5.0.1.3006 sonar-scanner

sudo ln -s /home/{username}/soft/sonar-scanner/sonar-scanner/bin/sonar-scanner /usr/bin/sonar-scanner
sudo ln -s /home/{username}/soft/sonar-scanner/sonar-scanner/bin/sonar-scanner-debug /usr/bin/sonar-scanner-debug

# 测试
sonar-scanner -v

# 帮助
sonar-scanner -h
```

### 配置 SonarScanner
```bash
vi /home/{username}/soft/sonar-scanner/sonar-scanner/conf
```
### sonar-scanner.properties
```
#Configure here general information about the environment, such as SonarQube server connection details for example
#No information about specific project should appear here

#----- Default SonarQube server
sonar.host.url=http://127.0.0.1:9000

#----- Default source code encoding
sonar.sourceEncoding=UTF-8
```

### 测试 SonarScanner
```bash
sonar-scanner -Dsonar.projectKey=sonar-demo -Dsonar.sources=/home/{username}/soft/sonar-scanner/sonar-scanner/test -Dsonar.host.url=http://127.0.0.1:9000
```