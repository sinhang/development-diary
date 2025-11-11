### ansible 站点
1. [ansible文档](https://docs.ansible.com/)
2. [ansible github](https://github.com/ansible/ansible)
3. [ansible examples](https://github.com/ansible/ansible-examples)

### 安装 ansible

```shell
sudo apt install ansible -y
```

### 查看 ansible 版本
```shell
ansible --version
```

### 使用参数
- `-become-password-file` or `--become-pass-file`: `BECOME_PASSWORD_FILE` 权限提升密码文件
- `-connection-password-file` or `--conn-pass-file`: `CONNECTION_PASSWORD_FILE` 连接密码文件
- `-list-hosts`: 输出匹配的主机列表；不执行其他任何操作
- `-playbook-dir`: `BASEDIR` 由于此工具不使用剧本，将此作为替代的剧本目录。这会设置许多功能的相对路径，包括 roles/、group_vars/ 等。
- `-task-timeout`: `TASK_TIMEOUT` 设置任务超时限制（秒），必须为正整数。
- `-vault-id`: `VAULT_IDS`  要使用的加密库标识。此参数可多次指定。
- `-vault-password-file `: `VAULT_PASSWORD_FILES` 加密库密码文件
- `B` or `--background`: `SECONDS` 异步运行，在 X 秒后失败（默认=不适用）
- `C` or `--check `: 不进行任何更改；而是尝试预测可能发生的一些更改
- `D` or `--diff`: 当更改（小）文件和模板时，显示这些文件的差异；与 --check 配合使用效果很好
- `J` or `--ask-vault-password, --ask-vault-pass`: 询问加密库密码
- `K` or `--ask-become-pass `: 询问权限提升密码
- `M` or `--module-path `: `MODULE_PATH` 在模块库前添加冒号分隔的路径（默认=`{{ ANSIBLE_HOME ~ "/plugins/modules:/usr/share/ansible/plugins/modules" }}`）。此参数可多次指定。
- `P` or `--poll`: `POLL_INTERVAL` 如果使用 -B，设置轮询间隔（默认=15）
- `a` or `--args`: `MODULE_ARGS` 操作的选项，以空格分隔的 `k=v` 格式：`-a 'opt1=val1 opt2=val2'` 或 JSON 字符串：`-a '{"opt1": "val1", "opt2": "val2"}'`
- `e` or `--extra-vars`: `EXTRA_VARS` 设置附加变量为 `key=value` 或 `YAML/JSON`，如果是文件名前加 @。此参数可多次指定。
- `f` or `--forks `: `FORKS` 指定要使用的并行进程数（默认=5）
- `i` or `--inventory or --inventory-file `: `INVENTORY` 指定库存主机路径或逗号分隔的主机列表。`--inventory-file` 已弃用。此参数可多次指定。
- `k` or `--ask-pass`: 询问连接密码
- `l` or `--limit `: `SUBSET` 进一步将选定的主机限制为附加模式
- `m` or `--module-name `: `MODULE_NAME` 要执行的操作名称（默认=command）
- `o` or `--one-line`: 压缩输出
- `t` or `--tree`: 将输出记录到此目录
- `v` or `--verbose `: 使 Ansible 打印更多调试信息。添加多个 `-v` 将增加详细程度，内置插件当前最多支持 `-vvvvvv`。合理的起始级别是 `-vvv`，连接调试可能需要 `-vvvv`。此参数可多次指定。
- `-become-method `: `BECOME_METHOD` 要使用的权限提升方法（默认=sudo），使用 `ansible-doc -t become -l` 列出有效选择。
- `-become-user `: `BECOME_USER` 以此用户身份运行操作（默认=root）
- `b` or `--become`: 使用权限提升运行操作（不暗示密码提示）
- `-private-key `: `PRIVATE_KEY_FILE` 使用此文件进行连接认证
- `-scp-extra-args`: `SCP_EXTRA_ARGS` 指定仅传递给 scp 的额外参数（例如 -l）
- `-sftp-extra-args `: `SFTP_EXTRA_ARGS` 指定仅传递给 sftp 的额外参数（例如 -f, -l）
- `-ssh-common-args `: `SSH_COMMON_ARGS` 指定传递给 sftp/scp/ssh 的通用参数（例如 ProxyCommand）
- `-ssh-extra-args`: `SSH_EXTRA_ARGS` 指定仅传递给 ssh 的额外参数（例如 -R
- `T` or `--timeout `: `TIMEOUT` 覆盖连接超时时间（秒）（默认取决于连接类型）
- `c` or `--connection`: `CONNECTION` 要使用的连接类型（默认=ssh）
- `u` or `--user`: `REMOTE_USER` 以此用户身份连接（默认=无）

### 配置 ansible
```shell
sudo vi /etc/ansible/ansible.cfg
```