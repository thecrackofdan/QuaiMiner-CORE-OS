# Quai Network Official References

This document contains official Quai Network resources and references used in this project.

## 📚 Official Documentation

### Main Documentation
- **Quai Network Docs**: https://docs.quai-network.org
- **Quai v2 Docs**: https://docs.v2.qu.ai
- **QuaiScan Docs**: https://docs.quaiscan.io
- **Quais SDK Docs**: https://docs.qu.ai/sdk/introduction

### Architecture & Concepts
- **Architecture Overview**: https://docs.v2.qu.ai/docs/learn/advanced-introduction/architecture
- **Merged Mining**: https://docs.v2.qu.ai/docs/learn/advanced-introduction/merged-mining
- **Interoperability**: https://docs.v2.qu.ai/docs/learn/advanced-introduction/interoperability
- **Node Setup**: https://docs.v2.qu.ai/docs/participate/node/run-a-node
- **Node Monitoring**: https://docs.v2.qu.ai/docs/participate/node/node-monitoring

## 🔗 Official Repositories

### Core Repositories
- **go-quai**: https://github.com/dominant-strategies/go-quai
  - Main Quai Network node implementation
  - Contains RPC methods, metrics, and configuration
  - Check `metrics_config/prometheus.yml` for metric names

- **quai-gpu-miner**: https://github.com/dominant-strategies/quai-gpu-miner
  - Official GPU miner for Quai Network
  - ProgPoW algorithm implementation

- **quai-docs**: https://github.com/dominant-strategies/quai-docs
  - Official documentation repository
  - Source for all documentation

## 🌐 Official APIs & Services

### QuaiScan (Block Explorer)
- **Website**: https://quaiscan.io
- **API Docs**: https://docs.quaiscan.io/developer-support/api
- **GraphQL API**: https://docs.quaiscan.io/developer-support/api/graphql
- **Mainnet API**: https://api.quaiscan.io/api (verify in docs)

### QuaiSwap (DEX)
- **Website**: https://quaiswap.io
- **API**: Verify endpoints at quaiswap.io or Discord

## 🔧 Development Tools

### Quais SDK
- **Documentation**: https://docs.qu.ai/sdk/introduction
- **Built on**: Ethers v6
- **Language**: JavaScript/TypeScript
- **Features**: Multi-chain support, cross-chain transactions

### Smart Contracts
- **Solidity**: Standard EVM-compatible contracts
- **SolidityX**: Cross-chain smart contracts
- **Reference**: https://support.qu.ai/en/articles/9483158-what-coding-languages-are-used-for-quai

## ⛏️ Mining Resources

### Mining Software
- **Quai GPU Miner**: https://github.com/dominant-strategies/quai-gpu-miner
- **Mining Guide**: https://docs.qu.ai/guides/miner/pools-software
- **Algorithm**: ProgPoW (Programmatic Proof of Work)

### Mining Pools
- **DePools**: https://docs.qu.ai/guides/client/dePool (Note: This project focuses on solo mining, not DePool operation)
- **Pool Software**: Check Quai Network Discord for latest pool information

## 🔗 Integrations

### Wormhole
- **Multichain Support**: https://qu.ai/blog/quai-network-is-going-multichain-with-wormhole
- **Native Token Transfers (NTT)**: Enables token movement across 40+ networks

### Entangle
- **Oracle Services**: https://qu.ai/blog/quai-network-announces-strategic-integration-with-entangle
- **Off-chain Data**: Secure connection to external APIs

## 📊 Network Structure

### Chain Hierarchy
- **Level 0**: Prime Chain (Main coordination chain)
- **Level 1**: Regions (Cyprus, Paxos, Hydra)
- **Level 2**: Zones (Cyprus-1, Cyprus-2, Cyprus-3, Paxos-1, Paxos-2, Paxos-3, Hydra-1, Hydra-2, Hydra-3)

### Port Configuration
- **Prime**: 30303 (TCP/UDP)
- **Cyprus**: 30304 (TCP/UDP)
- **Paxos**: 30305 (TCP/UDP)
- **Hydra**: 30306 (TCP/UDP)
- **Zones**: 30307-30315 (TCP/UDP)
- **RPC**: 8545 (TCP, typically localhost-only)

## 💡 Key Features

### SOAP Protocol
- **Solo Optimized Algorithm Protocol**
- Staking rewards with lockup periods
- Merged mining support
- Reference: Check Quai Network documentation for official SOAP details

### LMT/LMR
- **Liquid Mining Tokens (LMT)**
- **Locked Mining Rewards (LMR)**
- Staking mechanisms
- Reference: Check Quai Network documentation for official LMT/LMR details

### Qi Token
- **Energy-based stablecoin**
- Tied to energy costs
- Stable purchasing power
- Reference: https://docs.quai-network.org

## ⚠️ Important Notes

1. **API Endpoints**: Always verify actual endpoints in official documentation
2. **Metric Names**: Update Prometheus metric names from go-quai repository
3. **RPC Methods**: Verify all RPC methods against go-quai implementation
4. **Chain Names**: Use official names (Cyprus, Paxos, Hydra) not generic names
5. **Documentation**: Check official docs regularly for updates

## 🔄 Keeping Updated

1. **Monitor GitHub**: Watch go-quai and quai-docs repositories
2. **Check Discord**: Join Quai Network Discord for latest updates
3. **Review Docs**: Regularly check documentation for changes
4. **Test APIs**: Verify API endpoints are still valid

---

**Last Updated**: 2024-12-26
**Next Review**: Check official docs quarterly for updates

