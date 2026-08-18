# MoeMemos iOS 16

MoeMemos iOS 16 是基于 [MoeMemos](https://github.com/mudkipme/MoeMemos) 完整 Fork 并持续修改的第三方 Memos 客户端，主要面向仍在使用 iOS 16 的设备，同时适配 Memos 0.30 API。

本项目不是 Memos 官方客户端，也不隶属于 Memos 或原 MoeMemos 项目。

## 实机测试

当前版本已完成以下实机测试：

| 项目 | 测试结果 |
| --- | --- |
| 设备 | iPhone 13 |
| 系统 | iOS 16.0 |
| 安装方式 | TrollStore 导入 IPA |
| Memos 服务端 | Memos 0.30 |
| 登录方式 | 服务器地址 + Personal Access Token |
| 运行情况 | 用户实测运行正常 |
| 登录保持 | v0.1.1 已修复，关闭并重新打开 App 后可自动恢复登录 |

以上结果来自真实设备测试。其他 iPhone、iPad 和更高版本 iOS 原则上可以运行，但仍建议以实际设备测试结果为准。

## 下载

推荐使用最新版本：

- [下载 MoeMemos iOS 16 v0.1.1](https://github.com/lcmovie/MoeMemos/releases/tag/ios16-memos030-v0.1.1)
- [查看全部发行版](https://github.com/lcmovie/MoeMemos/releases)

发行版提供未签名 IPA，可用于 TrollStore，或由用户使用自己的签名、侧载方式安装。本项目不提供签名证书。

## 使用条件

使用前需要准备：

- 一台已经部署完成的 Memos 0.30 服务器；
- 可以从手机访问的 Memos 服务端地址；
- 在 Memos 中创建的 Personal Access Token；
- iOS 16 或更高版本的 iPhone 或 iPad。

首次打开 App 后，输入 Memos 服务器地址和 Access Token 即可登录。v0.1.1 开始会持久保存登录凭据，正常关闭或重新启动 App 后不需要再次输入。

## 主要功能

- 使用服务器地址和 Access Token 登录自建 Memos；
- 查看、创建和编辑备忘录；
- 删除、归档和恢复备忘录；
- 置顶及取消置顶；
- 支持公开、成员可见和私有可见性；
- 支持 Markdown 基础渲染；
- 支持标签提取和标签列表；
- 支持图片附件上传与显示；
- 支持资源列表、分享扩展和桌面小组件；
- 支持深色模式及系统动态字体；
- 登录状态持久保存。

## 兼容性改造

原项目的新版本依赖 iOS 18，并使用了 SwiftData、Observation 等较新的系统能力，无法直接运行在 iOS 16。本 Fork 以仍采用 SwiftUI 和 ObservableObject 架构的旧版本为基础，重新移植 Memos 0.30 网络接口。

主要修改包括：

1. 将备忘录数字 ID 改为 Memos 0.30 使用的 `memos/{id}` 资源名称；
2. 将旧版 Resource 接口改为 Attachment 接口，并支持 `attachments/{id}`；
3. 更新当前用户、实例信息、备忘录列表、创建、编辑、删除、归档和置顶接口；
4. 更新 ISO 8601 日期解析，兼容带小数秒的服务端时间；
5. 将登录方式收敛为 Memos 0.30 下更稳定的 Personal Access Token；
6. 更新小组件和分享扩展使用的新 API 与资源标识；
7. 替换无法公开获取的 Swift Package 依赖，并恢复公开环境下的完整编译；
8. 增加 GitHub Actions，在 macOS 和 Xcode 环境中自动构建未签名 IPA；
9. 修复 TrollStore 环境下原作者 Keychain Access Group 与当前签名不一致造成的登录状态丢失问题。

## 登录状态保存

v0.1.1 对 Access Token 的存储进行了专门调整：

1. 优先尝试原共享钥匙串；
2. TrollStore 或重签名环境下使用应用本地钥匙串；
3. 仅当两个钥匙串位置均无法写入时，才使用应用沙盒存储回退；
4. App 启动时自动读取服务器地址和 Access Token，并恢复用户状态；
5. 主程序、小组件和分享扩展统一使用同一套凭据读取逻辑。

Access Token 不会写入项目源码、公开仓库或构建日志。

## 当前限制

- 仅针对 Memos 0.30 进行了适配和测试，旧版或未来新版 Memos 可能需要继续调整；
- Markdown 任务清单可以显示，但当前兼容版本暂不支持直接点击复选框修改正文；
- GitHub Release 中的 IPA 未签名；
- iOS 17 及更高版本尚未逐一完成真实设备测试；
- 尚未发布的未来 iOS 版本无法提前保证完全兼容。

## 自动构建

仓库包含 GitHub Actions 构建流程。每次向兼容分支推送代码时，GitHub 的 macOS 构建环境会执行：

1. 解析 Swift Package 依赖；
2. 使用 Xcode 构建 Release 版 iOS App；
3. 关闭代码签名要求；
4. 将生成的 `MoeMemos.app` 打包为未签名 IPA；
5. 上传构建产物供后续发布。

## 版本记录

### v0.1.1

- 修复 App 关闭后登录状态丢失的问题；
- 增加 TrollStore 和重签名环境下的本地钥匙串支持；
- 增加钥匙串不可用时的应用沙盒回退；
- 同步修复小组件与分享扩展的凭据读取；
- 经用户在 iPhone 13、iOS 16.0 上实测运行正常。

### v0.1.0

- 完成 iOS 16 基础兼容；
- 完成 Memos 0.30 API 适配；
- 支持 Access Token 登录和主要备忘录功能；
- 建立公开源码与自动 IPA 构建流程。

## 上游项目

- Memos：[usememos/memos](https://github.com/usememos/memos)
- 原 MoeMemos：[mudkipme/MoeMemos](https://github.com/mudkipme/MoeMemos)
- MarkdownUI：[gonzalezreal/swift-markdown-ui](https://github.com/gonzalezreal/swift-markdown-ui)

感谢上述项目作者和贡献者提供的开源成果。

## 隐私说明

本客户端直接连接用户填写的 Memos 服务端，不包含第三方统计或广告功能。服务器地址和登录凭据仅用于连接用户自己的服务端。

## 开源许可证

本项目继承原项目的 [Mozilla Public License 2.0](LICENSE)。对源码进行再发布或修改时，请继续遵守 MPL-2.0 的相关要求，并保留必要的许可证和版权信息。
