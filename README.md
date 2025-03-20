# Simple Ethereum Storage Vault
## George Gorzhiyev

### A simple Solidity Smart Contract Ethereum storage vault where users can:
- deposit and store Ethereum
- retrieve stored deposit back to their wallet
- check balance of stored Ethereum
- check USD value of stored Ethereum, using Chainlink price feeds

### The goal of this project is to practice:
- writing a simple and clean Smart Contract in Solidity
- implement Events when state variable change occurs
- use Chainlink pricefeeds to get value of stored Eth
- writing NatSpec to document the code
- creating a deployment script to deploy the contract along with a Helper Config to set the appropriate Chainlink pricefeed addressed based on the chain used
- create a deployment script along with a Helper Config to aid in testing and deployment of the contract
- creating a number of unit tests to check the Smart Contract for code working and behaving appropriately
- writing a clear and legible README along with basic formatting

Thank you for checking it out :).

## Requirements
[git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

[foundry](https://getfoundry.sh/)

## Quickstart
```
git clone https://github.com/ygorz/SimpleEthereumStorageVault.git
cd SimpleEthereumStorageVault
forge build
```

## Testing
Run tests with:
```
forge test
```

Check test coverage with:
```
forge coverage
```

## Usage
In one terminal, start up a local Anvil blockchain with:
```
anvil
```

In another terminal, deploy the contract through the makefile with:
```
make deploy
```

For some basic usage, in the deploying terminal, try these commands to send and withdraw Ethereum:

Note: This private key is from a default built in user on Anvil, so there is no real value here. 

(To store and withdraw Ethereum. The 0xe7f1.. is the deployed contract on Anvil, you may have to change that if your contract address is different.)
```
cast send 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "storeEthereum()" --value 0.1ether --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 
```
```
cast send 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "withdrawEthereum(uint256)" 0.1ether --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```
