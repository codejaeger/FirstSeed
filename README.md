### Testing live
* Since the dAPP lacks a GUI/frontend the only possible way to test it is to spin up, a truffle console via
`truffle console --network ropsten`
* The smart token contract `ERC20Token` is deployed at the address - 0x87406fEE23CfbF5f7C170Ca432547868E30df5Da
* The seed supply chain smart contract `SeedChain` is deployed at - 0xc764dC81cA232438f21205B20F2925f452b03317
* To load a smart contract
`SeedChain.deployed().then(function(instance) {return instance });`
* An example workflow is provided in `test/test.txt`

#### VS code setup
* Configure VS code solidity extension settings to use solidity compiler version 0.8.13. (Find compiler binary commit hash [here](https://github.com/ethereum/solc-bin/tree/gh-pages/bin))
* Install specific truffle version with solidity version 0.8.13.
`npm install --save-dev truffle@5.x.x`

#### Prerequisites
1. Install node and npm through nvm.
2. Install ganache, truffle, geth, metamask.

#### Steps to create project
* `cd` into project folder.
* `nvm use 14.8.0`
* `sudo npm i truffle`
* `./node_modules/.bin/truffle init`

#### Compile and deploy
* Compile `F5`
* Deploy - `./node_modules/.bin/truffle deploy --reset`

#### Deploy
* Infura - `npm install --save-dev @truffle/hdwallet-provider`
* Deployment error - `nvm install --lts; nvm use --lts;`
* 