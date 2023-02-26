// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import {Script, console} from "@forge-std/Script.sol";
import {EnumerableSet, Uint256Set} from "./lib/EnumerableSet.sol";


/// @title Foundry Register Scripts
/// @notice Scripts for setting up and keeping track of deployments
contract RegisterScripts is Script {
    using EnumerableSet for Uint256Set;

    struct ContractData {
        string key;
        address addr;
    }

    bool SCRIPTS_RESET; // re-deploys all contracts
    bool SCRIPTS_BYPASS; // deploys contracts without any checks whatsoever
    bool SCRIPTS_DRY_RUN; // doesn't actually boradcast and store transaction on chain but still simulate deployment Tx
    bool SCRIPTS_CONFIRM; // confirm saving on deployments/production when running on mainnet
    bool SCRIPTS_ATTACH_ONLY; // doesn't deploy contracts, just attaches with checks
    bool SCRIPTS_MOCK_ADDRESS; // doesn't use contracts addresses from mainnet

    // mappings chainid => ...
    mapping(uint256 => mapping(address => bool)) firstTimeDeployed; // set to true for contracts that are just deployed; useful for inits
    mapping(uint256 => mapping(address => mapping(address => bool))) isUpgradeSafe; // whether a contract => contract is deemed upgrade safe

    Uint256Set registeredChainIds; // chainids that contain registered contracts
    mapping(uint256 => ContractData[]) registeredContracts; // contracts registered through `setUpContract` or `setUpProxy`
    mapping(uint256 => mapping(address => string)) registeredContractName; // chainid => address => name mapping
    mapping(uint256 => mapping(string => address)) registeredContractAddress; // chainid => key => address mapping

    // cache for operations
    mapping(string => bool) __madeDir;
    mapping(uint256 => bool) __latestDeploymentsLoaded;
    mapping(uint256 => string) __latestDeploymentsJson;
    mapping(uint256 => bool) __savedDeploymentsLoaded;
    mapping(uint256 => string) __savedDeploymentsJson;

    string[] __decodedKeys ;
    address payable[] __decodedAddressed ;

    constructor() {
        setUpScripts(); // allows for environment variables to be set before initial load

        loadEnvVars();

        if (SCRIPTS_BYPASS) return; // bypass any checks
        if (SCRIPTS_ATTACH_ONLY) return; // bypass any further checks (doesn't require FFI)

        // enforce dry-run when ffi is disabled, as otherwise
        // deployments won't be able to be stored in `deployment/`
        if (!SCRIPTS_DRY_RUN && !isFFIEnabled()) {
            SCRIPTS_DRY_RUN = true;

            console.log("Dry-run enabled (`FFI=false`).");
        }
    }

    /* ------------- setUp ------------- */

    /// @dev allows for `SCRIPTS_*` variables to be set in override
    function setUpScripts() internal virtual {}

    /// @notice Sets-up a contract. If a previous deployment is found,
    ///         the creation-code-hash is checked against the stored contract's
    ///         hash and a new contract is deployed if it is outdated or no
    ///         previous deployment was found. Otherwise, it is simply attached.
    /// @param contractName name of the contract to be deployed (must be exact)
    /// @param constructorArgs abi-encoded constructor arguments
    /// @param key unique identifier to be used in logs
    /// @return deployment deployed or loaded contract deployment
    function setUpContract(
        string memory contractName,
        bytes memory constructorArgs,
        string memory key,
        bool attachOnly
    ) internal virtual returns (address deployment) {
        string memory keyOrContractName = bytes(key).length == 0 ? contractName : key;
        bytes memory creationCode = abi.encodePacked(getContractCode(contractName), constructorArgs);

        if (SCRIPTS_BYPASS) {
            deployment = deployCodeWrapper(creationCode);

            vm.label(deployment, keyOrContractName);

            // registerContract(keyOrContractName, contractName, deployment);

            return deployment;
        }
        if (SCRIPTS_ATTACH_ONLY) attachOnly = true;

        bool deployNew = SCRIPTS_RESET;

        if (!deployNew) {
             deployment = loadSavedDeployedAddress(keyOrContractName);

            if (deployment != address(0)) {
                if (deployment.code.length == 0) {
                    console.log("Stored %s does not contain code.", contractLabel(contractName, deployment, key));
                    console.log("Make sure '%s' contains all the latest deployments.", getDeploymentsPath("deploy-latest.json")); // prettier-ignore

                    throwError("Invalid contract address.");
                }

                if (creationCodeHashMatches(deployment, keccak256(creationCode))) {
                    console.log("Stored %s up-to-date.", contractLabel(contractName, deployment, key));
                } else {
                    console.log("deployment for %s changed.", contractLabel(contractName, deployment, key));

                    if (attachOnly) console.log("Keeping existing deployment (`attachOnly=true`).");
                    else deployNew = true;
                }
            } else {
                console.log("Existing deployment for %s not found.", contractLabel(contractName, deployment, key)); // prettier-ignore

                deployNew = true;

                if (SCRIPTS_ATTACH_ONLY) throwError("Contract deployment is missing.");
            }
        }

        if (deployNew) {
            deployment = deployCodeWrapper(creationCode);

            console.log("=> new %s.\n", contractLabel(contractName, deployment, key));

            saveCreationCodeHash(deployment, keccak256(creationCode));
        }

        registerContract(keyOrContractName, contractName, deployment);
    }

    /* ------------- overloads ------------- */

    function setUpContract(
        string memory contractName,
        bytes memory constructorArgs,
        string memory key
    ) internal virtual returns (address) {
        return setUpContract(contractName, constructorArgs, key, false);
    }

    function setUpContract(string memory contractName) internal virtual returns (address) {
        return setUpContract(contractName, "", "", false);
    }

    function setUpContract(string memory contractName, bytes memory constructorArgs)
        internal
        virtual
        returns (address)
    {
        return setUpContract(contractName, constructorArgs, "", false);
    }
    

    /* ------------- snippets ------------- */

    function loadEnvVars() internal virtual {
        // silently bypass everything if set in the scripts
        if (!SCRIPTS_BYPASS) {
            SCRIPTS_RESET = tryLoadEnvBool(SCRIPTS_RESET, "SCRIPTS_RESET", "US_RESET");
            SCRIPTS_BYPASS = tryLoadEnvBool(SCRIPTS_BYPASS, "SCRIPTS_BYPASS", "US_BYPASS");
            SCRIPTS_DRY_RUN = tryLoadEnvBool(SCRIPTS_DRY_RUN, "SCRIPTS_DRY_RUN", "US_DRY_RUN");
            SCRIPTS_CONFIRM = tryLoadEnvBool(SCRIPTS_CONFIRM, "SCRIPTS_CONFIRM", "US_CONFIRM");
            SCRIPTS_ATTACH_ONLY = tryLoadEnvBool(SCRIPTS_ATTACH_ONLY, "SCRIPTS_ATTACH_ONLY", "US_ATTACH_ONLY"); // prettier-ignore
            SCRIPTS_MOCK_ADDRESS = tryLoadEnvBool(SCRIPTS_MOCK_ADDRESS, "SCRIPTS_MOCK_ADDRESS", "US_MOCK_ADDRESS"); 

            if (
                SCRIPTS_RESET ||
                SCRIPTS_BYPASS ||
                SCRIPTS_DRY_RUN ||
                SCRIPTS_ATTACH_ONLY ||
                SCRIPTS_CONFIRM ||
                SCRIPTS_MOCK_ADDRESS
            ) console.log("");
        }
    }

    function tryLoadEnvBool(
        bool defaultVal,
        string memory varName,
        string memory varAlias
    ) internal virtual returns (bool val) {
        val = defaultVal;

        if (!val) {
            try vm.envBool(varName) returns (bool val_) {
                val = val_;
            } catch {
                try vm.envBool(varAlias) returns (bool val_) {
                    val = val_;
                } catch {}
            }
        }

        if (val) console.log("%s=true", varName);
    }

    function startBroadcastIfNotDryRun() internal {
        if (!SCRIPTS_DRY_RUN) {

            if (SCRIPTS_CONFIRM) {

                // -trezor --sender <wallet address>
                vm.startBroadcast();

            } else {
                // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
                // string memory mnemonic = vm.envString("MNEMONIC");

                // address is already funded with ETH
                string memory mnemonic ="test test test test test test test test test test test junk";
                uint256 deployerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 0);
                vm.startBroadcast(deployerPrivateKey);
            }
        } else {
            console.log("Disabling `vm.broadcast` (dry-run).\n");

            // need to start prank instead now to be consistent in "dry-run"
            vm.stopBroadcast();
            vm.startPrank(tx.origin);
        }
    }


    function loadSavedDeployedAddress(string memory key) internal virtual returns (address) {
        return loadSavedDeployedAddress(key, block.chainid);
    }

    function loadSavedDeployedAddress(string memory key, uint256 chainId) internal virtual returns (address) {
        if (!__savedDeploymentsLoaded[chainId]) {
            try vm.readFile(getDeploymentsPath("formated-register.json", chainId)) returns (string memory json) {
                __savedDeploymentsJson[chainId] = json;
            } catch {}
            __savedDeploymentsLoaded[chainId] = true;
        }

        if (bytes(__savedDeploymentsJson[chainId]).length != 0) {
            try vm.parseJson(__savedDeploymentsJson[chainId], string.concat(".", key)) returns (bytes memory data) {
                if (data.length == 32) return abi.decode(data, (address));
            } catch {}
        }

        return address(0);
    }


    function saveCreationCodeHash(address addr, bytes32 creationCodeHash) internal virtual {
        if (SCRIPTS_DRY_RUN) return;

        mkdir(getDeploymentsPath("data/"));

        string memory path = getCreationCodeHashFilePath(addr);

        vm.writeFile(path, vm.toString(creationCodeHash));
    }

    /// @dev .codehash is an improper check for contracts that use immutables
    function creationCodeHashMatches(address addr, bytes32 newCreationCodeHash) internal virtual returns (bool) {
        string memory path = getCreationCodeHashFilePath(addr);

        try vm.readFile(path) returns (string memory data) {
            bytes32 codehash = vm.parseBytes32(data);

            return codehash == newCreationCodeHash;
        } catch {}

        return false;
    }

    function getContractCode(string memory contractName) internal virtual returns (bytes memory code) {
        try vm.getCode(contractName) returns (bytes memory code_) {
            code = code_;
        } catch (bytes memory reason) {
            try vm.getCode(string.concat(contractName, ".sol")) returns (bytes memory code_) {
                code = code_;
            } catch {
                assembly {
                    revert(add(0x20, reason), mload(reason))
                }
            }
        }

        if (code.length == 0) {
            console.log("Unable to find artifact '%s'.", contractName);
            console.log("Provide either a unique contract name ('MyContract'),");
            console.log("or an artifact location ('MyContract.sol:MyContract').");

            throwError("Contract does not exist.");
        }
    }


    function deployCodeWrapper(bytes memory code) internal virtual returns (address addr) {
        addr = deployCode(code);

        firstTimeDeployed[block.chainid][addr] = true;

        require(addr.code.length != 0, "Failed to deploy code.");
    }

   
    /* ------------- utils ------------- */

    function deployCode(bytes memory code) internal virtual returns (address addr) {
        assembly {
            addr := create(0, add(code, 0x20), mload(code))
        }
    }

    function isTestnet() internal view virtual returns (bool) {
        uint256 chainId = block.chainid;

        if (chainId == 4) return true; // Rinkeby
        if (chainId == 5) return true; // Goerli
        if (chainId == 420) return true; // Optimism
        if (chainId == 1_337) return true; // Anvil
        if (chainId == 31_337) return true; // Anvil
        if (chainId == 31_338) return true; // Anvil
        if (chainId == 80_001) return true; // Mumbai
        if (chainId == 421_611) return true; // Arbitrum
        if (chainId == 11_155_111) return true; // Sepolia

        return false;
    }


    function isFFIEnabled() internal virtual returns (bool) {
        string[] memory script = new string[](1);
        script[0] = "echo";

        try vm.ffi(script) {
            return true;
        } catch {
            return false;
        }
    }

    function mkdir(string memory path) internal virtual {
        if (__madeDir[path]) return;

        string[] memory script = new string[](3);
        script[0] = "mkdir";
        script[1] = "-p";
        script[2] = path;

        vm.ffi(script);

        __madeDir[path] = true;
    }

    /// @dev throwing error like this, because sometimes foundry won't display any logs otherwise
    function throwError(string memory message) internal view {
        if (bytes(message).length != 0) console.log("\nError: %s", message);

        // Must revert if not dry run to cancel broadcasting transactions.
        if (!SCRIPTS_DRY_RUN) revert(string.concat(message, '\nEnable dry-run (`SCRIPTS_DRY_RUN=true`) if the error message did not show.')); // prettier-ignore

        // Sometimes Forge does not display the complete message then..
        // That's why we return instead.
        assembly {
            return(0, 0)
        }
    }

    /* ------------- contract registry ------------- */

    function registerContract(
        string memory key,
        string memory name,
        address addr
    ) internal virtual {
        uint256 chainId = block.chainid;

        if (registeredContractAddress[chainId][key] != address(0)) {
            console.log("Duplicate entry for key [%s] found when registering contract.", key);
            console.log("Found: %s(%s)", key, registeredContractAddress[chainId][key]);

            throwError("Duplicate key.");
        }

        registeredChainIds.add(chainId);

        registeredContractName[chainId][addr] = name;
        registeredContractAddress[chainId][key] = addr;

        registeredContracts[chainId].push(ContractData({key: key, addr: addr}));

        vm.label(addr, key);
    }

    /* ------------- filePath ------------- */

    function getDeploymentsPath(string memory path) internal virtual returns (string memory) {
        return getDeploymentsPath(path, block.chainid);
    }

    function getDeploymentsPath(string memory path, uint256 chainId) internal virtual returns (string memory) {
        return string.concat( !SCRIPTS_DRY_RUN && SCRIPTS_CONFIRM ? "deployments/production/": "deployments/test/", vm.toString(chainId), "/", path);
    }


    function getCreationCodeHashFilePath(address addr) internal virtual returns (string memory) {
        return getDeploymentsPath(string.concat("data/", vm.toString(addr), ".creation-code-hash"));
    }

    function logDeployments() internal view virtual {
        title("Registered Contracts");

        for (uint256 i; i < registeredChainIds.length(); i++) {
            uint256 chainId = registeredChainIds.at(i);

            console.log("Chain id %s:\n", chainId);
            for (uint256 j; j < registeredContracts[chainId].length; j++) {
                console.log("%s=%s", registeredContracts[chainId][j].key, registeredContracts[chainId][j].addr);
            }

            console.log("");
        }
    }

    function generateRegisteredContractsJson(uint256 chainId) internal virtual returns (string memory json) {
        if (registeredContracts[chainId].length == 0) return "";

        json = string.concat("{\n", '  "git-commit-hash": "', getGitCommitHash(), '",\n');

        for (uint256 i; i < registeredContracts[chainId].length; i++) {
            json = string.concat(
                json,
                '  "',
                registeredContracts[chainId][i].key,
                '": "',
                vm.toString(registeredContracts[chainId][i].addr),
                i + 1 == registeredContracts[chainId].length ? '"\n' : '",\n'
            );
        }
        json = string.concat(json, "}");
    }

    function generateSavedContractJson(uint256 chainId) internal virtual returns (string memory json) {

        if (registeredContracts[chainId].length == 0) return "";
        json = "{\n";

        try vm.readFile(getDeploymentsPath("raw-register.json", chainId)) returns (string memory deployments) {

            if (bytes(deployments).length != 0) {

                bytes memory keys = vm.parseJson(deployments, ".keys");
                __decodedKeys = abi.decode(keys, (string[]));

                for (uint256 i; i < registeredContracts[chainId].length; i++) {
                    __decodedKeys.push(registeredContracts[chainId][i].key);
                }

                bytes memory addresses = vm.parseJson(deployments, ".addresses");
                address[] memory decodedExistingAddresses = abi.decode(addresses, (address[]));

                for (uint256 i; i < decodedExistingAddresses.length; i++) {
                    __decodedAddressed.push(payable(decodedExistingAddresses[i] ));
                }

                for (uint256 i; i < registeredContracts[chainId].length; i++) {
                    __decodedAddressed.push(payable(registeredContracts[chainId][i].addr ));
                }

                json = string.concat(
                        json,
                        '  "keys": ['
                );

                for (uint256 i; i < __decodedKeys.length; i++) {
                    json = string.concat(
                        json,
                        '  "',
                        __decodedKeys[i],
                        i + 1 == __decodedKeys.length ? '"],\n' : '",'
                    );
                }

                json = string.concat(
                        json,
                         '  "addresses": ["'
                );

                for (uint256 i; i < __decodedAddressed.length; i++) {
                    json = string.concat(
                        json,
                        vm.toString(__decodedAddressed[i]),
                        i + 1 == __decodedAddressed.length ? '"]\n' : '", "'
                    );
                }
                json = string.concat(json, "}");
                return json;
            }

        } catch {

            json = string.concat(
                    json,
                    '  "keys": ['
            );

            for (uint256 i; i < registeredContracts[chainId].length; i++) {
                json = string.concat(
                    json,
                    '  "',
                    registeredContracts[chainId][i].key,
                    i + 1 == registeredContracts[chainId].length ? '"],\n' : '",'
                );
            }

            json = string.concat(
                    json,
                    '  "addresses": ["'
            );
                  

            for (uint256 i; i < registeredContracts[chainId].length; i++) {
                json = string.concat(
                    json,
                    vm.toString(registeredContracts[chainId][i].addr),
                    i + 1 == registeredContracts[chainId].length ? '"]\n' : '", "'
                );
            }
        }

        return json = string.concat(json, "}");
    }

    function generateFormatedContractJson(uint256 chainId) internal virtual returns (string memory json) {

        if (registeredContracts[chainId].length == 0) return "";
        json = "{\n";

        try vm.readFile(getDeploymentsPath("raw-register.json", chainId)) returns (string memory deployments) {

            if (bytes(deployments).length != 0) {

                bytes memory keys = vm.parseJson(deployments, ".keys");
                string[] memory decodedKeys = abi.decode(keys, (string[]));

                bytes memory addresses = vm.parseJson(deployments, ".addresses");
                address[] memory decodedAddresses = abi.decode(addresses, (address[]));

                for (uint256 i; i < decodedKeys.length; i++) {
                    json = string.concat(
                        json,
                        '  "',
                        decodedKeys[i],
                        '": "',
                        vm.toString(decodedAddresses[i]),
                        i + 1 == decodedKeys.length ? '"\n' : '",\n'
                    );
                }

            }

        } catch {}

        return json = string.concat(json, "}");
    }


function storeLatestDeployments() internal virtual {
        logDeployments();

        if (!SCRIPTS_DRY_RUN) {

            for (uint256 i; i < registeredChainIds.length(); i++) {
                uint256 chainId = registeredChainIds.at(i);

                string memory json = generateRegisteredContractsJson(chainId);

                if (keccak256(bytes(json)) == keccak256(bytes(__latestDeploymentsJson[chainId]))) {
                    console.log("No changes detected.", chainId);
                } else {
                    mkdir(getDeploymentsPath("", chainId));

                    vm.writeFile(getDeploymentsPath(string.concat("deploy-latest.json"), chainId), json);
                    vm.writeFile(getDeploymentsPath(string.concat("deploy-", vm.toString(block.timestamp), ".json"), chainId), json); // prettier-ignore

                    console.log("Deployments saved to %s.", getDeploymentsPath("deploy-latest.json", chainId)); // prettier-ignore
                }                
            }

        }
    }

    function savePastDeployments() internal virtual {
        if (!SCRIPTS_DRY_RUN) {

            for (uint256 i; i < registeredChainIds.length(); i++) {
                uint256 chainId = registeredChainIds.at(i);

                string memory json = generateSavedContractJson(chainId);

                mkdir(getDeploymentsPath("", chainId));
                vm.writeFile(getDeploymentsPath(string.concat("raw-register.json"), chainId), json);

                console.log("Deployments saved to %s.", getDeploymentsPath("raw-register.json", chainId)); // prettier-ignore
            }
            formatRegister();
        }
    }

    function formatRegister() internal {
        if (!SCRIPTS_DRY_RUN) {

            for (uint256 i; i < registeredChainIds.length(); i++) {
                uint256 chainId = registeredChainIds.at(i);

                string memory json = generateFormatedContractJson(chainId);

                vm.writeFile(getDeploymentsPath(string.concat("formated-register.json"), chainId), json);

                console.log("formated Deployments saved to %s.", getDeploymentsPath("formated-register.json", chainId)); // prettier-ignore
            }
        }
    }

    function getGitCommitHash() internal virtual returns (string memory) {
        string[] memory script = new string[](3);
        script[0] = "git";
        script[1] = "rev-parse";
        script[2] = "HEAD";

        bytes memory hash = vm.ffi(script);

        if (hash.length != 20) {
            console.log("Unable to get commit hash.");
            return "";
        }

        string memory hashStr = vm.toString(hash);

        // remove the "0x" prefix
        assembly {
            mstore(add(hashStr, 2), sub(mload(hashStr), 2))
            hashStr := add(hashStr, 2)
        }
        return hashStr;
    }

    /* ------------- prints ------------- */

    function title(string memory name) internal view virtual {
        console.log("\n==========================");
        console.log("%s:\n", name);
    }

    function contractLabel(
        string memory contractName,
        address addr,
        string memory key
    ) internal virtual returns (string memory) {
        return
            string.concat(
                contractName,
                addr == address(0) ? "" : string.concat("(", vm.toString(addr), ")"),
                bytes(key).length == 0 ? "" : string.concat(" [", key, "]")
            );
    }

}