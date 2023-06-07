// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces
import {IFacetRegistry} from "./IFacetRegistry.sol";

// libraries
import {EnumerableSet} from "openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";
import {FacetRegistryUseCase} from "./FacetRegistryUseCase.sol";
import {FacetRegistryStorage} from "./FacetRegistryStorage.sol";

// contracts
import {Facet} from "../Facet.sol";

contract FacetRegistry is IFacetRegistry, Facet {
  using EnumerableSet for EnumerableSet.Bytes32Set;

  function registerFacet(FacetInfo memory facetInfo) external {
    FacetRegistryUseCase.validateFacetInfo(facetInfo);

    bytes32 facetId = FacetRegistryUseCase.computeFacetId(facetInfo.facet);

    FacetRegistryUseCase.addFacet(facetInfo, facetId);

    emit FacetRegistered(facetId, facetInfo.facet);
  }

  function removeFacet(bytes32 facetId) external {
    address facet = FacetRegistryStorage.layout().facetByFacetId[facetId].facet;

    FacetRegistryUseCase.validateFacetAddress(facet);
    FacetRegistryUseCase.removeFacet(facetId);

    emit FacetRemoved(facetId, facet);
  }

  function computeFacetId(address facet) external view returns (bytes32) {
    return FacetRegistryUseCase.computeFacetId(facet);
  }

  function facetAddress(bytes32 facetId) external view returns (address) {
    return FacetRegistryStorage.layout().facetByFacetId[facetId].facet;
  }

  function facetInitializer(bytes32 facetId) external view returns (bytes4) {
    return FacetRegistryStorage.layout().facetByFacetId[facetId].initializer;
  }

  function facetInterface(bytes32 facetId) external view returns (bytes4) {
    return FacetRegistryStorage.layout().facetByFacetId[facetId].interfaceId;
  }

  function facetSelectors(
    bytes32 facetId
  ) external view returns (bytes4[] memory selectors) {
    bytes32[] memory selectorBytes = FacetRegistryStorage
      .layout()
      .selectorByFacetId[facetId]
      .values();

    selectors = new bytes4[](selectorBytes.length);

    for (uint256 i; i < selectorBytes.length; i++) {
      selectors[i] = bytes4(selectorBytes[i]);
    }
  }
}
