## 📌 CHC & WHC Smart Contract - TEST VERSION

<p align="center">
  <img src="assets/CHC_logo.svg" alt="CHC Logo" width="150"/>
  <img src="assets/WHC_logo.svg" alt="WHC Logo" width="150"/>
</p>

### 1️⃣ Project Overview

**ColdHouse Coin (CHC) ❄️** & **WarmHouse Coin (WHC) 🔥** are test blockchain tokens designed to explore a reward-based economy for good deeds and sustainable actions. In this implementation, the smart contract integrates both tokens with a unique reward system:

- **CHC (ColdHouse Coin):**
  - Earned by performing eco-friendly actions (e.g., recycling, energy saving, animal care).
  - Actions are recorded and then verified by an admin before CHC tokens are minted.
  - Maximum supply is capped at **1,000,000 CHC**.

- **WHC (WarmHouse Coin):**
  - Rewarded when users convert a specified amount of accumulated CHC (e.g., 1000 CHC → 1 WHC).
  - Acts as a premium token with a maximum supply of **1,000 WHC**, emphasizing its scarcity.

💡 **This project is a test implementation of Ethereum smart contracts that record actions, distribute rewards in a decentralized way, and incorporate admin-controlled verification.**

🚨 **NOTE:** This project is for testing purposes only and is not intended for real-world transactions!

---

## 2️⃣ Project Structure

- **contracts/** → Solidity smart contracts (integrated CHC/WHC token & reward logic in one contract)
- **artifacts/** → Compiled contract JSON files
- **scripts/** → Deployment scripts (`Ethers.js`, `Web3.js`)
- **tests/** → Test scripts covering contract functionality

---

## 3️⃣ Smart Contracts

### 🔹 KindActionRewardSystem.sol
- **Integrated Contract:** Manages both CHC and WHC tokens along with the reward mechanism.
- **Features:**
  - **Action Recording:** Users record good deeds, specifying the action type (using `bytes32` for gas efficiency) and description.
  - **Admin Verification:** An admin must verify recorded actions before CHC tokens are minted.
  - **Reward Calculation:** Uses a mapping to determine reward amounts based on the action type, with a default reward if unregistered.
  - **Token Redemption:** Enables conversion of accumulated CHC into WHC tokens at a fixed conversion rate.

🚨 **Testnet Deployment Only!**

---

## 4️⃣ Deployment Instructions

### 📌 Deploying on Remix IDE
1. Open `contracts/KindActionRewardSystem.sol` in Remix.
2. Compile the contract.
3. Deploy using **Injected Provider (MetaMask - Testnet Only)**.
4. Copy the deployed contract address.

### 📌 Deploying on Hardhat (Testnet)
1. **Install dependencies**
   ```bash
   npm install
   ```
2. **Deploy to Goerli Testnet**
   ```bash
   npx hardhat run scripts/deploy_with_ethers.ts --network goerli
   ```

🚨 **WARNING:** Do not deploy this to the mainnet. This is a test version!

---

## 5️⃣ Running Tests

1. Run all smart contract tests using Hardhat:
   ```bash
   npx hardhat test
   ```
2. Alternatively, execute individual test scripts in Remix IDE.

---

## 6️⃣ Future Development 🚀

- ✅ Refining admin roles and access control.
- ✅ Integration with NFT reward systems and donation mechanisms.
- ✅ Enhanced verification (e.g., integration with external oracles for accurate timestamps).

---

## 7️⃣ Contributions & Contact

- **This is a test project.**
- For inquiries or feedback, submit issues on GitHub or contact us via the community channels.

---

## 📌 Final Notes

🔥 **CHC & WHC are currently in the test phase. Do not use them in real transactions.**  
🔥 **For educational and development purposes only.**
