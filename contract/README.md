# Smart Contracts
## Tooling with Foundry

## How to setup such a Foundry Project 
```shell
forge init --no-git --vscode
```

I learned from my last [project](https://github.com/yvesbou/NFT-Collection-LW3/tree/main/contract#third-party-libraries-in-foundry-project). That Foundry can be quite challenging in terms on managing the project and dependencies, if you used Hardhat before. But this short manual should help:

### DApp with Foundry
1. create project folder
2. go inside and type `git init`
3. create two folders
    - client (for frontend)
    - contract
4. go inside contract
5. type `forge init --no-git --vscode`
6. go to `.vscode/settings.json`
7. Add the following content to the file
    ```
    "editor.formatOnSave": true,
    "solidity.formatter": "prettier",
    "solidity.defaultCompiler": "remote",
    "solidity.compileUsingRemoteVersion" : "latest",
    "git.ignoreLimitWarning": true,
    "solidity.remappings": [
        "ds-test/=lib/forge-std/lib/ds-test/src/",
        "forge-std/=lib/forge-std/src/"
      ]
    ```
8. 