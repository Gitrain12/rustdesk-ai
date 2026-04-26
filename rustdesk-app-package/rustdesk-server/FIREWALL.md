# RustDesk 二次开发 - 防火墙配置指南

## 必需端口 (Linux/Ubuntu)

```bash
# 查看当前防火墙状态
sudo ufw status

# 开放必需端口
sudo ufw allow 21115/tcp comment 'RustDesk NAT Test'
sudo ufw allow 21116/tcp comment 'RustDesk ID/TCP'
sudo ufw allow 21116/udp comment 'RustDesk ID/UDP'
sudo ufw allow 21117/tcp comment 'RustDesk Relay'

# 可选端口 (Web客户端支持)
sudo ufw allow 21114/tcp comment 'RustDesk Web Console (Pro)'
sudo ufw allow 21118/tcp comment 'RustDesk Web Socket'
sudo ufw allow 21119/tcp comment 'RustDesk Web Relay'

# 重新加载防火墙
sudo ufw reload

# 验证端口
sudo ufw status verbose
```

## 云服务商安全组配置

### AWS EC2
```
入站规则:
- 类型: 自定义TCP | 端口: 21115 | 来源: 0.0.0.0/0
- 类型: 自定义TCP | 端口: 21116 | 来源: 0.0.0.0/0
- 类型: 自定义UDP | 端口: 21116 | 来源: 0.0.0.0/0
- 类型: 自定义TCP | 端口: 21117 | 来源: 0.0.0.0/0
```

### 阿里云ECS
```
授权策略: 允许
协议: TCP
端口范围: 21115/21119
授权对象: 0.0.0.0/0

协议: UDP
端口范围: 21116/21116
授权对象: 0.0.0.0/0
```

### 腾讯云CVM
```
类型: 自定义
协议: TCP
端口: 21115-21119
源: 0.0.0.0/0

协议: UDP
端口: 21116
源: 0.0.0.0/0
```

## Docker网络模式说明

推荐使用 `network_mode: "host"` 的原因：
- 容器可以直接使用主机网络
- 避免NAT导致的连接问题
- 正确获取客户端真实IP地址
- 许可证验证正常工作

如果必须使用桥接网络，请参考自定义端口配置：
```yaml
services:
  hbbs:
    ports:
      - "21115:21115"
      - "21116:21116"
      - "21116:21116/udp"
    command: hbbs -r your-server-ip:21117
```

## 验证部署

```bash
# 1. 检查容器状态
docker compose ps

# 2. 查看日志
docker logs hbbs
docker logs hbbr

# 3. 检查端口监听
sudo ss -tlnp | grep -E '211(14|15|16|17|18|19)'

# 4. 测试NAT类型
# 在客户端设置中运行NAT类型测试

# 5. 验证公钥文件
ls -la ./data/
cat ./data/id_ed25519.pub
```
