# Monad Blitz Wuhan 2026 · 链上出席证明 POAP

一个部署在 **Monad 测试网** 上的出席证明（Proof of Attendance）DApp。参与者连接钱包即可领取一枚**完全上链**的出席证明 NFT（ERC-721），可选上传自己的图片嵌入证书。图片与元数据均由合约在链上生成，无外部依赖、永久有效。

## 项目定位

POAP（Proof of Attendance Protocol）是区块链上"出席证明"的通用标准，用于记录某人参加了某场活动——不可篡改、可公开验证、永久保存。本 Demo 将 POAP 落地到 Monad Blitz Wuhan 黑客松，展示：
- 链上证书的完整生成逻辑（SVG + Base64 均在合约内）
- 用户可自定义图片的领取交互（前端压缩后嵌入链上）
- 领取时间窗口、防重复等真实 POAP 合约设计

## 使用场景

- 黑客松/技术大会的出席打卡
- 线下活动（漫展、演唱会、见面会）的纪念凭证
- 课程/培训的结业证书
- 社区贡献徽章

## 在线演示

- 前端 GitHub Pages：https://wangqiao258.github.io/monad-blitz-wuhan-poap/
- 合约地址（Monad Testnet）：`0xd13719fC131c23C49a55b588C2b2fD9c2EDD8Dac`
- 区块浏览器：https://testnet.monadvision.com/address/0xd13719fC131c23C49a55b588C2b2fD9c2EDD8Dac
- 演示账户：需要 MetaMask + Monad Testnet（Chain ID 10143），测试币可从水龙头领取

## 主要亮点

1. **完全上链**：证书 SVG 与元数据均由合约 Solidity 代码生成，无外部图床/IPFS 依赖，永久有效不失效
2. **可选上传图片**：用户可上传自己的图片，前端自动压缩至约 400px 后嵌入链上证书；不上传则使用默认紫色徽章风格
3. **领取时效**：合约内置 `claimStart` / `claimEnd` 时间窗口，owner 可调整，体现 POAP 核心语义
4. **防重复**：每地址限领 1 枚，不可批量铸造
5. **零构建**：前端为单文件 HTML + ethers.js，双击即可运行

## 技术栈

- 合约：Solidity `^0.8.20`，OpenZeppelin ERC-721 / Ownable / Base64
- 前端：单文件 HTML + ethers.js v6，无需构建工具
- 网络：Monad Testnet（Chain ID `10143`，RPC `https://testnet-rpc.monad.xyz`）

## 部署方式

1. 合约部署：使用 Remix 或 solc 编译后部署到 Monad Testnet（Chain ID 10143）
2. 前端部署：将 `index.html` + `ethers.umd.min.js` 放到任意静态托管（GitHub Pages / Vercel / Netlify），修改 `CONFIG.contractAddress` 为你的合约地址

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
README.md            项目说明
```

## 许可

MIT
