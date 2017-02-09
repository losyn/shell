##### 各 Shell 脚本的作用及用法

* /java/build.sh 打包 java 微服务为 jar 文件， 可以提供参数直接 deploy 服务到指定的器机

1. ARTIFACT=$1
    
    第一个参数 指定需要打包的项目名（必填）
   
2. VERSION=$2
    
    第二个参数 指定打包的版本（必填）
   
3. DESC=$3
    
    第三个参数 当前打包代码的相关功能描述或打包升级的功能（必填）

4. GIT=$4
    
    第四个参数 指定打包项目的 GIT 地址（必填）
    
5. BRANCH=$5

    第五个参数 指定打包项目的 GIT 分支， 默认 master 分支 如： master, develop（选填）
    
```
    ### 进入 shell 脚本存放的目录
    cd /×××/×××/shell
    build.sh ARTIFACT VERSION DESC GIT BRANCH
    
```

* /java/deploy.sh 部署服务使用

1. ARTIFACT=$1
    
    第一个参数 指定需要部署的项目名（必填）

2. VERSION=$2

    第二个参数 指定需要部署的项目版本（必填）
3. BRANCH=$3

    第三个参数 指定需要部署的项目包是用哪个 GIT 分支打的包
4. DEPLOY_U=$4   
    
    第四个参数 部署使用的用户名， 能够无须密码 SSH 到参数四指定的机器的用户名（必填）
              
5. DEPLOY_M=$5   
    
    第五个参数 部署的器地址，传数组形式如： "192.168.1.2 192.168.1.3 192.168.1.5"（必填）

6. DEPLOY_E=$6   
    
    第六个参数 部署运行的环境，如：test, qa, prod（必填）

```
    ### 进入 shell 脚本存放的目录
    cd /×××/×××/shell
    deploy.sh ARTIFACT VERSION BRANCH DEPLOY_U "DEPLOY_M" DEPLOY_E
    
```

* /java/start.sh 在部署有项目的器机上启动服务

1. ARTIFACT=$1   
    
    第一个参数 指定需要启动的项目名（必填）

2. VERSION=$2    
    
    第二个参数 指定需要启功的项目版本（必填）

3. DEPLOY_E=$3   
    
    第三个参数 服务运行的环境，如：test, qa, prod（必填）
    
4. DEPLOY_WS=$4
    
    第四个参数 指定需要启动在哪个目录下绝对路径 如：/mnt/deploy（必填）
    
4. BRANCH=$5

    第五个参数 指定需要启动用哪个 GIT 分支打的包； 传入这个参数后会从远程拉取项目包运行，否则运行本地项目包（选填）
    
```
    ### 进入 shell 脚本存放的目录
    cd /×××/shell
    ./start.sh ARTIFACT VERSION DEPLOY_E DEPLOY_WS BRANCH
    
```

* /java/stop.sh 停止指定的项目

1. ARTIFACT=$1   
    
    第一个参数 指定需要停止的项目名（必填）

```
    ### 进入 shell 脚本存放的目录
    cd /×××/×××/shell
    stop.sh ARTIFACT

```

* /ui/xxx.sh UI 相关脚本


* /other 其他服务相关脚本