// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

//interfaces

//libraries

//contracts
import "./utils/TestUtils.sol";
import {Hello} from "src/Hello.sol";

contract HelloTest is TestUtils {
  Hello internal hello;

  function setUp() external {
    hello = new Hello();
  }

  function test_sayHello() external {
    assertEq(hello.sayHello(), "Hello, Forge!");
  }
}
