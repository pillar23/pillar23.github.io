+++
title = 'Frp实现隧道穿透远程桌面'
date = 2023-10-16T14:10:06+08:00
draft = false
+++

# 导语

果壳的校园网不给直接内网连远程桌面，感觉是因为划的子网之间不能互相通信，不知道是深澜故意的还是不小心的。todesk自然是可以，但是感觉免费的todesk画质略输一筹的同时延迟也有点小高。于是想到用frp的内网穿透来搞p2p的远程桌面。


# 操作

实际上还是挺简单的，为数不多的坑是网上的教程都还是ini格式，但是在现在的版本里已经转为了toml、yaml等，而且参数好像也有些变化。

去[github](https://github.com/fatedier/frp/releases/)下载frp的releas

## 服务端

在你的服务器上装frps，并且配置toml文件，下载的frps.toml已经基本上写好了，基本啥也不用改，只要把最后的插件注释掉（或者你也可以把插件装了用）

```toml
#[[httpPlugins]]
#name = "user-manager"
#addr = "127.0.0.1:9000"
#path = "/handler"
#ops = ["Login"]

#[[httpPlugins]]
#name = "port-manager"
#addr = "127.0.0.1:9001"
#path = "/handler"
#ops = ["NewProxy"]
```

再改一下auth.token，这个token是你的frpc也要配置成一样的，相当于server对client的认证。

```toml
auth.token = "hsijdfhsjdhf" # 这个感觉可以随便写，多复杂都行，反正你能连上你的服务器就能查
```

然后再改一改web界面的用户名密码端口啥的或者直接把web也注释了

```toml
webServer.addr = "0.0.0.0"
webServer.port = 7500
webServer.user = "dgsdgfsdfs"
webServer.password = "dweqweas"
```

然后启动时一定要用-c指定toml配置文件，否则我也不知道他默认找的哪里的配置文件

![1697438389080](/images/1697438389080.png)

## 客户端

这里使用了xtcp的代理协议来进行p2p的内网穿透，如果想用其他方法可以参考[官方文档](https://gofrp.org/zh-cn/docs/reference/proxy/)（？是吗）

在被控端和控制端都装上对应平台的frpc，并且配置frpc.toml

配置frps的地址端口和token

```toml
serverAddr = "1.1.1.1"
serverPort = 7000
auth.token = "asfggsaddasd" # 这里要和服务端配的一样
```

把下面哪些示例配置全都注释掉，然后写上下面的内容

```toml
[[proxies]]
name = "rdesk"
type = "xtcp"
localIP = "127.0.0.1" # 本机
localPort = 3389 # 远程桌面连接
role = "server"
secretKey = "akjndsghnkjadsfjh"
```

如果你的被控端的frpc设置开了web，那你应该可以再web界面看到你的xtcp的连接

![1697439827539](/images/1697439827539.png)

对了你还可以再你的frps和frpc里都指定一个user，这样你的proxy的name就会变成user.name的形式，这也就使你可以在server端配置多用户（指直接管name叫做aaa.xxx而不配置frps的user）

同时在控制的机器那边也装上frpc，配置frps的地址端口和token

```toml
serverAddr = "1.1.1.1"
serverPort = 7000
auth.token = "asfggsaddasd" # 这里要和服务端配的一样
```

然后再加上

```toml
[[visitors]]
name = "rdesk_visitor"
type = "xtcp"
serverName = "rdesk" # 这里要和上面的name一致
secretKey = "akjndsghnkjadsfjh" # 这里要和上面的secretkey一致
bindAddr = "127.0.0.1" # 本机的ip地址
bindPort = 8000
```

然后使用frpc的同时也要用-c来指定配置文件

`./frpc.exe -c ./frpc.toml`

visitors是在web里看不见的，看不到不要觉得奇怪。

如果在server上可以看到都连上了，直接mstsc连就行了，连127.0.0.1:8000（也就是你在visitor里设置的地址端口）（这里是把log指向了console，所以可以直接看）

![1697440033017](/images/1697440033017.png)

windwos防火墙会弹，同意了就完事了

## 使用systemd让frps挂在后台

直接参考https://gofrp.org/zh-cn/docs/setup/systemd/
