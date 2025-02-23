## 📌 CHC & WHC Smart Contract - TEST VERSION
<p align="center">
  <img src="assets/CHC_logo.svg" alt="CHC Logo" width="200"/>
  <img src="assets/WHC_logo.svg" alt="WHC Logo" width="200"/>
</p>

## 1️⃣ Project Overview

**ColdHouse Coin (CHC) ❄️** & **WarmHouse Coin (WHC) 🔥** are test blockchain tokens designed to explore a reward-based economy for good deeds and sustainable actions. This implementation integrates both tokens into a single smart contract with a unique **lock-up conversion mechanism**:

### ColdHouse Coin (CHC)
* Earned by performing eco-friendly actions (e.g., recycling, energy saving, animal care)
* Actions are recorded and verified by an admin before CHC tokens are minted
* Maximum supply is capped at **10,000,000 CHC**
* CHC serves as the basic utility token

### WarmHouse Coin (WHC)
* Obtained by converting (redeeming) CHC via a lock-up process (e.g., **10,000 CHC locked → 1 WHC minted**)
* Instead of burning CHC during conversion, the required CHC amount is locked
* Users can later return WHC to unlock the locked CHC
* Maximum supply is capped at **1,000 WHC**, ensuring its premium and scarce nature

💡 **This project is a test implementation of Ethereum smart contracts that record good actions, distribute rewards, and maintain a reversible conversion loop through lock-up, all under admin-controlled verification.**

🚨 **NOTE:** This project is for testing purposes only and is not intended for real-world transactions!

---

## 2️⃣ Project Structure

* **contracts/** → Solidity smart contracts (integrated CHC/WHC token & reward logic with lock-up mechanism)
* **artifacts/** → Compiled contract JSON files
* **scripts/** → Deployment scripts (`Ethers.js`, `Web3.js`)
* **tests/** → Test scripts covering contract functionality

---

## 3️⃣ Smart Contracts

### 🔹 KindActionRewardSystem.sol

* **Integrated Contract:** Manages both CHC and WHC tokens along with a reward mechanism and reversible conversion
* **Key Features:**
  * **Action Recording:** Users record good deeds with an action type (using `bytes32` for gas efficiency) and description
  * **Admin Verification:** An admin must verify recorded actions before CHC tokens are minted
  * **Reward Calculation:** Uses a mapping to determine reward amounts based on the action type, with a default reward if unregistered
  * **Lock-Up Conversion:** When converting CHC to WHC, the required CHC amount is locked (not burned). Users can later return WHC to unlock the CHC
  * **Token Redemption:** Conversion rate is set at **10,000 CHC locked → 1 WHC minted**

🚨 **Testnet Deployment Only!**

---

## 4️⃣ Deployment Instructions

### 📌 Deploying on Remix IDE

1. Open `contracts/KindActionRewardSystem.sol` in Remix
2. Compile the contract
3. Deploy using **Injected Provider (MetaMask - Testnet Only)**
4. Copy the deployed contract address

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

* ✅ Further refinement of admin roles and access control
* ✅ Integration with NFT reward systems, donation mechanisms, and additional utilities
* ✅ Exploring dynamic conversion rates or additional economic incentives based on CHC circulation

---

## 7️⃣ Contributions & Contact

* **This is a test project**, and contributions are welcome!
* For inquiries or feedback, submit issues on GitHub or contact us via the community channels.

---

## 📌 Final Notes

🔥 **CHC & WHC are currently in the test phase. Do not use them in real transactions.** 🔥

**For educational and development purposes only.**

---
