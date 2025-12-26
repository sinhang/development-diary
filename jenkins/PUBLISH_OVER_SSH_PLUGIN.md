### publish over ssh


### 生成 ssh 密钥
```bash
# 进入 jenkins 容器
sudo docker exec -it jenkins bash
# 生成 ssh 密钥
ssh-keygen -t rsa -b 4096 -C "jenkins@domain.com"
cd /var/jenkins_home/.ssh
# 输入文件名，我这边输入的是 jenkins_rsa
# Enter file in which to save the key (/var/jenkins_home/.ssh/id_rsa): jenkins_rsa
# 输入密码，我这边直接回车
# Enter passphrase (empty for no passphrase): 我这边直接回车

# 查看公钥
cat /var/jenkins_home/.ssh/jenkins_rsa.pub
```

![ssh-keygen](../static/images/jenkins/ssh-keygen.png)

### 为密钥授权
```bash
# 进去需要授权的机器将 公钥复制到 authorized_keys 文件中
# 比如输出 jenkins 机器的公钥
cat /var/jenkins_home/.ssh/jenkins_rsa.pub
# 输出
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC0n0rRgkdS20RAgFo9AIJTWUU9vjHE6PkbxS2BTEeQw4ihhP10W170pRC7kbNehcLl6zOUrzwvxSbH37F8VVf7IFONGqLpSqk4JUFmGvhTh4mbh2q16KAaAY7rvY/sf5DHzG9ZLxG8nQ4sCrDbfeTbrgjDWM45V39ig2gJsgD51/bXO9GV0ckEQA+fAa0ELvHIdTmTrrT9OJx39vCJ8LRL6lOZqXBBpOPlOg2eMkQ0EzZp6dQEeS6vvtl+gZjNa5OIuvDg+YSu25uxQTOPC+hT1xZ44ZClS3GqIDFUszscWaspju07h5QII0qGLDIHjVzfba2n4Fv7bv9qsS+hpGhxW80zkCQucB4UGR18N6UgOmbbrgF5y+VkUQ8Fx5WeVEsZCC5HfpxlRb+JAvskOyHNFH6NLvbJBjnw9oXlLqY4vtvPw3mJcQLkz4eZ8bHUnJyySfuBNkrkeYDyVq4+SuafJlYn0Sgfg6kkCzvrH9JAP8VRnsNZaT6zM0IM63mk5juF0d88x+mcqqCsYu9xhEKKVRle0nnWF4tDmO4Qw4SHx3gi0FyslbvY0EnvUOPRAssMFc05uxJmZjtVzKb3ZjXOBZ7sNEiguE5jZPfd2Fh0a77+BRv+ubN0rhrKdrEdlc7KWFq1I2a19CPf2WMwahrpSVZAvYzX9HZK2k7DdMxWRQ== jenkins@domain.com

# 将上面的输出添加到需要授权的机器 authorized_keys 文件中
echo "AAAAB3NzaC1yc2EAAAADAQABAAACAQC0n0rRgkdS20RAgFo9AIJTWUU9vjHE6PkbxS2BTEeQw4ihhP10W170pRC7kbNehcLl6zOUrzwvxSbH37F8VVf7IFONGqLpSqk4JUFmGvhTh4mbh2q16KAaAY7rvY/sf5DHzG9ZLxG8nQ4sCrDbfeTbrgjDWM45V39ig2gJsgD51/bXO9GV0ckEQA+fAa0ELvHIdTmTrrT9OJx39vCJ8LRL6lOZqXBBpOPlOg2eMkQ0EzZp6dQEeS6vvtl+gZjNa5OIuvDg+YSu25uxQTOPC+hT1xZ44ZClS3GqIDFUszscWaspju07h5QII0qGLDIHjVzfba2n4Fv7bv9qsS+hpGhxW80zkCQucB4UGR18N6UgOmbbrgF5y+VkUQ8Fx5WeVEsZCC5HfpxlRb+JAvskOyHNFH6NLvbJBjnw9oXlLqY4vtvPw3mJcQLkz4eZ8bHUnJyySfuBNkrkeYDyVq4+SuafJlYn0Sgfg6kkCzvrH9JAP8VRnsNZaT6zM0IM63mk5juF0d88x+mcqqCsYu9xhEKKVRle0nnWF4tDmO4Qw4SHx3gi0FyslbvY0EnvUOPRAssMFc05uxJmZjtVzKb3ZjXOBZ7sNEiguE5jZPfd2Fh0a77+BRv+ubN0rhrKdrEdlc7KWFq1I2a19CPf2WMwahrpSVZAvYzX9HZK2k7DdMxWRQ== jenkins@domain.com" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### 配置 jenkins
1. setting -> system

![system](../static/images/jenkins/manage-system.png)
1. 添加 ssh 密钥
2. 测试设置

![add ssh key && test](../static/images/jenkins/publish-over-ssh-setting.png)