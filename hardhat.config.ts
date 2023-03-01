import fs from "fs";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-preprocessor";
import "hardhat-storage-layout";

import tasks from './tasks'
for (const tsk of tasks) { tsk() }

const config: HardhatUserConfig = {
  solidity: {

    compilers: 
  [
    {
      version: "0.8.19",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        },
        outputSelection: {
          "*": {
              "*": ["storageLayout"],
          },
        },
      }
    }
  ]
  },

  preprocess: {
    eachLine: (hre) => ({
      transform: (line: string) => {
        if (line.match(/^\s*import /i)) {
          for (const [from, to] of getRemappings()) {
            if (line.includes(from)) {
              line = line.replace(from, to);
              break;
            }
          }
        }
        return line;
      }
    }),
  },
  paths: {
    sources: "./src",
    cache: "./cache_hardhat",
  }
};

function getRemappings() {
  return fs
    .readFileSync("remappings.txt", "utf8")
    .split("\n")
    .filter(Boolean) // remove empty lines
    .map((line) => line.trim().split("="));
}

export default config;
