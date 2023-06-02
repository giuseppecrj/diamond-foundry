// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

contract Hello {
  event GreetingChanged(string oldGreeting, string newGreeting);

  string public greeting = "Hello, Forge!";

  function sayHello() public view returns (string memory) {
    return greeting;
  }

  function setGreeting(string memory newGreeting) public {
    string memory oldGreeting = greeting;
    greeting = newGreeting;
    emit GreetingChanged(oldGreeting, newGreeting);
  }
}
