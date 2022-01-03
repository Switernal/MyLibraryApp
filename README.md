# 一千零一夜 | MyLibrary

## 项目官网(之前网站服务器数据库被黑了暂时无法访问)

[一千零一夜 | MyLibrary - 你的个人图书馆](https://mylibrary.switernal.com/) 

## 版本

外部版本：0.1.0 (Build 2)

内部版本：0.1.0 (1B102)

## 下载构建版本

[一千零一夜 | MyLibrary - 下载](https://mylibrary.switernal.com/download.html)

暂时仅支持Android端下载安装，iOS后续将会通过Testflight发布测试版

项目进一步完善后，将会登陆App Store及各大Android商店


## 更新记录

[一千零一夜 | MyLibrary - 更新记录](https://mylibrary.switernal.com/update.html)

## 仓库说明

这是一千零一夜项目的完整备份代码，仅移除了私有Api和一些相关隐私信息

该App需配合Server进行使用，如需Server部分代码请至仓库：[codpluto/mylibrary](https://github.com/codpluto/mylibrary)

#### 移除的相关私有接口：

ISBN查询接口私有Key：lib/MyBook/Function/SearchBookByISBN_Bamboo.dart

图床接口和token：lib/Functions/Network/UploadImage.dart

项目服务器列表：assets/NetworkConfig.yaml

## 项目简介

一千零一夜旨在提供方便的个人藏书管理，并打造了二手书店可供用户自由交易二手图书

该项目App部分由Switernal（0048）开发，Server部分由Pluto（0041）开发

App端使用 Flutter 1.22.6（本仓库）

Server端使用 Springboot（[codpluto/mylibrary](https://github.com/codpluto/mylibrary)）

了解更多信息请访问：[一千零一夜 | MyLibrary - 关于](https://mylibrary.switernal.com/about.html)

## Contributors

感谢以下参与本项目的测试人员提供的建议和反馈

- 叉叉
- 江湖骗子
- GJ
- 和宋
- sbw
- 三三
- Fair

