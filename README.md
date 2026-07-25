# Monad Blitz Wuhan 2026 · 链上出席证明 POAP

一个部署在 **Monad 测试网** 上的出席证明（Proof of Attendance）DApp。参与者连接钱包即可领取一枚**完全上链**的出席证明 NFT（ERC-721），可选上传自己的图片嵌入证书。图片与元数据均由合约在链上生成，无外部依赖、永久有效。

## 在线演示

- 前端：GitHub Pages（见仓库 Pages 链接）
- 合约地址（Monad Testnet）：`0xd13719fC131c23C49a55b588C2b2fD9c2EDD8Dac`
- 区块浏览器：https://testnet.monadvision.com/address/0xd13719fC131c23C49a55b588C2b2fD9c2EDD8Dac

## 功能特性

- **一键领取**：连接 MetaMask，点击即可领取出席证明 NFT
- **每地址限领 1 枚**：符合出席证明语义，防重复
- **领取时间窗口**：合约内置 `claimStart` / `claimEnd`，owner 可调整
- **可选上传图片**：领取者可上传自己的图片，前端自动压缩为约 400px 并嵌入链上证书；不上传则使用默认徽章样式
- **完全上链**：证书 SVG 与元数据由合约 Solidity 代码生成，包含活动名、日期、持有人地址、编号，无外部图床依赖

## 技术栈

- 合约：Solidity `^0.8.20`，OpenZeppelin ERC-721 / Ownable / Base64
- 前端：单文件 HTML + ethers.js v6，无需构建
- 网络：Monad Testnet（Chain ID `10143`，RPC `https://testnet-rpc.monad.xyz`）

## 本地运行

```bash
# 在项目目录启动本地服务器（避免 file:// 下钱包扩展无法注入）
python -m http.server 8000
# 浏览器打开
# http://localhost:8000/index.html
```

## 合约核心接口

| 函数 | 说明 |
|------|------|
| `mint()` | 领取默认样式出席证明 |
| `mintWithImage(string imageDataURI)` | 领取并嵌入自定义图片 |
| `isClaimOpen()` | 当前是否在领取窗口 |
| `hasClaimed(address)` | 某地址是否已领取 |
| `tokenURI(uint256)` | 链上生成的证书元数据（Base64 SVG） |
| `setClaimWindow(uint256,uint256)` | owner 调整领取窗口 |

## 文件结构

```
AttendancePOAP.sol   合约源码
index.html           前端页面（含配置区）
ethers.umd.min.js    ethers.js v6 本地库
```

## 许可

MIT
