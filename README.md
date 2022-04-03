
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

