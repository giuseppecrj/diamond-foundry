// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces

// libraries
import {EnumerableSet} from "openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";

// contracts

library FacetRegistryStorage {
  using EnumerableSet for EnumerableSet.Bytes32Set;

  bytes32 public constant FACET_REGISTRY_STORAGE_POSITION =
    keccak256("facet.registry.storage");

  struct FacetInfo {
    address facet;
    bytes4 initializer;
    bytes4 interfaceId;
  }

  struct Layout {
    mapping(bytes32 => EnumerableSet.Bytes32Set) selectorByFacetId;
    mapping(bytes32 => FacetInfo) facetByFacetId;
  }

  function layout() internal pure returns (Layout storage ds) {
    bytes32 position = FACET_REGISTRY_STORAGE_POSITION;

    // solhint-disable-next-line no-inline-assembly
    assembly {
      ds.slot := position
    }
  }
}
