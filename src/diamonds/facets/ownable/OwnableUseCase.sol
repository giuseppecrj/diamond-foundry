// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces

// libraries
import {OwnableStorage} from "./OwnableStorage.sol";

// contracts

error Ownable_ZeroAddress();
error Ownable_NotOwner(address account);

library OwnableUseCase {
  function owner() internal view returns (address) {
    return OwnableStorage.layout().owner;
  }

  function checkOwner(address account) internal view {
    if (account != owner()) revert Ownable_NotOwner(account);
  }

  function transferOwnership(address newOwner) internal {
    if (newOwner == address(0)) revert Ownable_ZeroAddress();

    OwnableStorage.layout().owner = newOwner;
  }

  function renounceOwnership() internal {
    OwnableStorage.layout().owner = address(0);
  }
}
