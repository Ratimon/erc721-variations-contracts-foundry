<h1> erc721-variations-contracts-foundry</h1>

## 📚 What is it for ?

This illustrate the ERC721 variations

1. NFT With Bitmap Merkle Tree Presale

- An ERC721 NFT which has a function “presale” that allows a set of addresses to make a purchase at a discounted price. There a re merkle tree to create this set (from openzeppelin) and a bitmap to track if an address has already done a presale purchase [`Reference`](https://github.com/DonkeVerse/PrivateSaleBenchmark/blob/main/contracts/Benchmark.sol . It also support  ERC 2918 royalty standard.

2. NFT Staking and Rewards

-  An ERC20 token
-  An ERC721 token
-  A staking smart contract that can mint new ERC20 tokens and receive ERC721 tokens. A classic feature of NFTs is being able to receive them to stake tokens. Users can send their NFTs and withdraw 10 ERC20 tokens every 24 hours.

3. Enumerable Protocol

- a NFT collection with 20 items using ERC721Enumerable

- a smart contract that has a function which accepts an address and returns how many NFTs are owned by that address which have tokenIDs that are prime numbers. For example, if an address owns tokenIds 10, 11, 12, 13, it should return 2. In a real blockchain game, these would refer to special items

## Sections

### 1. 🏗 Installation & Quick Start 

- Everything you need to install

- Quick Guide & Tutorial to Use Template

- Read more [`here`](./docs/1_SETUP.md).