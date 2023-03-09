# Audit Reportfor ERC20Game

-  ERC20Game.sol
-  ERC721Game.sol
-  NFTStaking.sol

## Risk Rating

To prioritize the vulnerabilities, we have adopted the scheme of five distinct levels of risk: Critical, High, Medium, Low, and Informational, based on OWASP Risk Rating Methodology. The risk level definitions as follwing

- Critical : The code implementation does not match the specification, and it could disrupt the platform.

- High : The code implementation does not match the specification, or it could result in the loss of funds for contract owners or users.

- Medium : The code implementation does not match the specification under certain conditions, or it could affect the security standard by losing access control.

- Low : The code implementation does not follow best practices or use suboptimal design patterns, which may lead to security vulnerabilities further down the line.

- Informational : Findings in this category are informational and may be further improved by following best practices and guidelines.

## Detailed Results for  ERC20Game / ERC721Game / NFTStaking

- Informational : solc-0.8.19 is not recommended for deployment
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity