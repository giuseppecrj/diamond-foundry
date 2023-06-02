// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/* Libraries */
import "forge-std/Script.sol";

contract ScriptUtils is Script {
  function _readInput(
    string memory input
  ) internal view returns (string memory) {
    string memory inputDir = string.concat(vm.projectRoot(), "/script/input/");
    string memory chainDir = string.concat(vm.toString(block.chainid), "/");
    string memory file = string.concat(input, ".json");
    return vm.readFile(string.concat(inputDir, chainDir, file));
  }
}
