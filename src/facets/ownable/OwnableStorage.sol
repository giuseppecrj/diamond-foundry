// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces

// libraries

// contracts

library OwnableStorage {
  bytes32 internal constant STORAGE_SLOT = keccak256("diamond.ownable.storage");

  struct Layout {
    address owner;
  }

  function layout() internal pure returns (Layout storage ds) {
    bytes32 slot = STORAGE_SLOT;

    // solhint-disable-next-line no-inline-assembly
    assembly {
      ds.slot := slot
    }
  }
}
