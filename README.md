## Borrow USDC from Aave (Mainnet Fork) - Foundry + Cast

### A compact demo that forks Ethereum mainnet, deposits WETH as collateral into Aave v3, and borrows USDC against it — all in a safe local testing environment. We use Foundry’s fork tools to simulate real DeFi interactions without spending real ETH.

### Key Takeaways
- Use Foundry (forge/cast) to fork the Ethereum mainnet and test DeFi protocols locally.
- WETH (Wrapped Ether) = ERC-20 version of ETH, required by Aave.
- Deposit WETH - borrow USDC - check balances & health factor.
- No real money needed: all happens in a fork.
- Secrets stay safe: .env + .gitignore.

## Prerequisites
### Install Foundry

```shell
curl -L https://foundry.paradigm.xyz | bash

foundryup
```

### foundry.toml (example)
```shell
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
optimizer = true
optimizer_runs = 200
solc_version = "0.8.24"

[rpc_endpoints]
mainnet = "${MAINNET_RPC_URL}"
```

## Contracts & Tests
### src/AaveBorrow.sol
- wrapAndApprove: wraps ETH - WETH and approves Aave pool.
- supplyWETH: deposits WETH as collateral.
- borrowUSDC: borrows USDC with variable rate (mode = 2).
- usdcBalance: helper to check USDC balance.

### src/interfaces/IERC20.sol
- Standard ERC-20 functions (balanceOf, approve, transfer, allowance).
- Lets us interact with tokens like USDC or WETH as ERC-20s.
- Example: IERC20(USDC).balanceOf(address(this)) - check our USDC balance.

### src/interfaces/IWETH9.sol

- Special interface for WETH contract.
- Provides deposit() (wrap ETH - WETH) and withdraw() (unwrap).
- Example: send 1 ETH to weth.deposit{value: 1 ether}() - get 1 WETH token.

### src/interfaces/IAaveV2LendingPool.sol

- Interface for Aave’s LendingPool (v2/v3 use same function signatures).
- Provides deposit(), borrow(), getUserAccountData().
- Example: pool.deposit(WETH, 1 ether, address(this), 0) - supply 1 WETH to Aave.

### test/AaveBorrow.t.sol

- Forks Ethereum mainnet.
- Funds contract with ETH.
- Wraps ETH → WETH, deposits to Aave v3 pool.
- Borrows 100 USDC.
- Asserts borrow success & health factor > 1.
- Includes impersonation demo.

### script/AaveBorrow.s.sol

- Scripted flow: wrap, approve, deposit, borrow.
- Runnable with forge script against fork or mainnet.

### Environment Variables (.env)

```shell
# Mainnet RPC (Infura or Alchemy)
MAINNET_RPC_URL=https://mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID
```

#### Explanation:
- MAINNET_RPC_URL - where forked state comes from (via Infura/Alchemy).
- No PRIVATE_KEY needed unless you want to broadcast real txs to mainnet.
- .gitignore ensures .env is never committed.


### Commands to Run

```shell
1) Build & Test
forge build
forge test --fork-url $MAINNET_RPC_URL -vv

2) Run Script (on fork)
forge script script/AaveBorrow.s.sol \
  --fork-url $MAINNET_RPC_URL \
  --broadcast -vvv

3) (Optional) Run Script on Real Mainnet 

Requires funding a wallet with real ETH + PRIVATE_KEY in .env:

forge script script/AaveBorrow.s.sol \
  --rpc-url $MAINNET_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast -vvv
```

### Sample Outputs

#### Tests

```shell
Ran 2 tests for test/AaveBorrow.t.sol:AaveBorrowTest
[PASS] test_DepositWETH_ThenBorrowUSDC() (gas: 455151)
[PASS] test_Impersonation_Demo() (gas: 3658)
Suite result: ok. 2 passed; 0 failed
```

#### Borrow Check

```shell
USDC Balance: >= 100e6
Health Factor: > 1e18 (safe)
```

### Handy Links 
```shell
Aave v3 Pool (Ethereum) - https://etherscan.io/address/0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2
WETH (ERC-20 wrapper) - https://etherscan.io/address/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
USDC Token - https://etherscan.io/address/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
```

### Caution
- Never commit .env, private keys, or seed phrases.
- Forking is safe; real mainnet is risky - you can lose money if collateral is liquidated.
- Gas fees apply only when you deploy on mainnet.

## End of Project.
We successfully borrowed USDC from Aave v3 on a mainnet fork using Foundry.
