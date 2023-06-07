// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces

// libraries

// contracts

library IntrospectionStorage {
  bytes32 internal constant INTROSPECTION_STORAGE_POSITION =
    keccak256("diamond.introspection.storage");

  struct Layout {
    mapping(bytes4 => bool) supportedInterfaces;
  }

  function layout() internal pure returns (Layout storage ds) {
    bytes32 position = INTROSPECTION_STORAGE_POSITION;

    // solhint-disable-next-line no-inline-assembly
    assembly {
      ds.slot := position
    }
  }
}
