// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces
import {IFacetRegistry} from "./IFacetRegistry.sol";

// libraries
import {EnumerableSet} from "openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";
import {Address} from "openzeppelin-contracts/contracts/utils/Address.sol";
import {FacetRegistryStorage} from "./FacetRegistryStorage.sol";

// contracts

error FacetRegistry_validateFacetInfo_FacetAlreadyRegistered();
error FacetRegistry_validateFacetInfo_FacetAddressZero();
error FacetRegistry_validateFacetInfo_FacetMustHaveSelectors();
error FacetRegistry_validateFacetInfo_FacetNotContract();

library FacetRegistryUseCase {
  using FacetRegistryStorage for FacetRegistryStorage.Layout;
  using EnumerableSet for EnumerableSet.Bytes32Set;

  function addFacet(
    IFacetRegistry.FacetInfo memory facetInfo,
    bytes32 facetId
  ) internal {
    FacetRegistryStorage.Layout storage ds = FacetRegistryStorage.layout();

    ds.facetByFacetId[facetId].facet = facetInfo.facet;
    ds.facetByFacetId[facetId].initializer = facetInfo.initializer;

    bytes4 interfaceId;

    for (uint256 i; i < facetInfo.selectors.length; i++) {
      bytes4 selector = facetInfo.selectors[i];

      if (selector == bytes4(0)) continue;

      ds.selectorByFacetId[facetId].add(selector);

      i == 0 ? interfaceId = selector : interfaceId ^= selector;
    }

    ds.facetByFacetId[facetId].interfaceId = interfaceId;
  }

  function removeFacet(bytes32 facetId) internal {
    FacetRegistryStorage.Layout storage ds = FacetRegistryStorage.layout();

    delete ds.facetByFacetId[facetId].facet;
    delete ds.facetByFacetId[facetId].initializer;
    delete ds.facetByFacetId[facetId].interfaceId;

    uint256 selectorCount = ds.selectorByFacetId[facetId].length();

    for (uint256 i; i < selectorCount; i++) {
      bytes4 selector = bytes4(ds.selectorByFacetId[facetId].at(i));
      ds.selectorByFacetId[facetId].remove(selector);
    }
  }

  function facetAddress(bytes32 facetId) internal view returns (address) {
    FacetRegistryStorage.Layout storage ds = FacetRegistryStorage.layout();
    return ds.facetByFacetId[facetId].facet;
  }

  function computeFacetId(address facet) internal view returns (bytes32) {
    return facet.codehash;
  }

  function validateFacetAddress(address facet) internal view {
    if (facet == address(0))
      revert FacetRegistry_validateFacetInfo_FacetAddressZero();
    if (!Address.isContract(facet))
      revert FacetRegistry_validateFacetInfo_FacetNotContract();
  }

  function validateFacetInfo(
    IFacetRegistry.FacetInfo memory facetInfo
  ) internal view {
    if (facetInfo.facet == address(0))
      revert FacetRegistry_validateFacetInfo_FacetAddressZero();
    if (facetInfo.selectors.length == 0)
      revert FacetRegistry_validateFacetInfo_FacetMustHaveSelectors();
    if (!Address.isContract(facetInfo.facet))
      revert FacetRegistry_validateFacetInfo_FacetNotContract();
    if (facetAddress(computeFacetId(facetInfo.facet)) != address(0)) {
      revert FacetRegistry_validateFacetInfo_FacetAlreadyRegistered();
    }
  }
}
