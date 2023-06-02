// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {Hello} from "src/Hello.sol";
import {console} from "forge-std/console.sol";

contract DeployHello is Script {
  function setUp() public {}

  function run() public {
    vm.startBroadcast();
    Hello hello = new Hello();
    vm.stopBroadcast();

    console.log("Hello deployed at: ", address(hello));

    vm.writeJson(
      vm.toString(address(hello)),
      "client/addresses/Hello.json",
      ".address"
    );
  }
}
