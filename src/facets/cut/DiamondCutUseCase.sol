// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

// interfaces
import {IDiamond} from "../../IDiamond.sol";

// libraries
import {DiamondCutStorage} from "./DiamondCutStorage.sol";
import {EnumerableSet} from "openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";
import {Address} from "openzeppelin-contracts/contracts/utils/Address.sol";

// contracts

error DiamondCut_InvalidSelector();
error DiamondCut_FunctionAlreadyExists(bytes4 selector);
error DiamondCut_InvalidFacetRemoval(address facet, bytes4[] selectors);
error DiamondCut_FunctionDoesNotExist(address facet);
error DiamondCut_InvalidFacetCutAction();
error DiamondCut_InvalidFacet(address facet);
error DiamondCut_InvalidFacetSelectors(address facet);
error DiamondCut_ImmutableFacet();
error DiamondCut_InvalidContract(address init);

library DiamondCutUseCase {
  using DiamondCutStorage for DiamondCutStorage.Layout;
  using EnumerableSet for EnumerableSet.AddressSet;
  using EnumerableSet for EnumerableSet.Bytes32Set;

  ///@notice Add a new facet to the diamond
  ///@param facet The facet to add
  ///@param selectors The selectors for the facet
  function addFacet(address facet, bytes4[] memory selectors) internal {
    DiamondCutStorage.Layout storage ds = DiamondCutStorage.layout();

    // add facet to diamond storage
    ds.facets.add(facet);

    // add selectors to diamond storage
    for (uint256 i; i < selectors.length; i++) {
      bytes4 selector = selectors[i];

      if (selector == bytes4(0)) {
        revert DiamondCut_InvalidSelector();
      }

      if (ds.facetBySelector[selector] != address(0)) {
        revert DiamondCut_FunctionAlreadyExists(selector);
      }

      ds.facetBySelector[selector] = facet;
      ds.selectorsByFacet[facet].add(selector);
    }
  }

  ///@notice Remove a facet from the diamond
  ///@param facet The facet to remove
  ///@param selectors The selectors for the facet
  function removeFacet(address facet, bytes4[] memory selectors) internal {
    DiamondCutStorage.Layout storage ds = DiamondCutStorage.layout();

    for (uint256 i; i < selectors.length; i++) {
      bytes4 selector = selectors[i];

      if (selector == bytes4(0)) {
        revert DiamondCut_InvalidSelector();
      }

      if (ds.facetBySelector[selector] != facet) {
        revert DiamondCut_InvalidFacetRemoval(facet, selectors);
      }

      delete ds.facetBySelector[selector];

      ds.selectorsByFacet[facet].remove(selector);

      if (ds.selectorsByFacet[facet].length() == 0) {
        ds.facets.remove(facet);
      }
    }
  }

  /// @notice Replace a facet on the diamond
  /// @param facet The facet to replace
  /// @param selectors The selectors for the facet
  function replaceFacet(address facet, bytes4[] memory selectors) internal {
    DiamondCutStorage.Layout storage ds = DiamondCutStorage.layout();

    ds.facets.add(facet);
    for (uint256 i; i < selectors.length; i++) {
      bytes4 selector = selectors[i];

      address oldFacet = ds.facetBySelector[selector];

      if (selector == bytes4(0)) {
        revert DiamondCut_InvalidSelector();
      }

      if (oldFacet == address(0)) {
        revert DiamondCut_FunctionDoesNotExist(facet);
      }

      if (oldFacet == facet) {
        revert DiamondCut_FunctionAlreadyExists(selector);
      }

      // overwrite selector to new facet
      ds.facetBySelector[selector] = facet;

      ds.selectorsByFacet[facet].add(selector);

      ds.selectorsByFacet[oldFacet].remove(selector);

      if (ds.selectorsByFacet[oldFacet].length() == 0) {
        ds.facets.remove(oldFacet);
      }
    }
  }

  /// @notice Validate a facet cut
  /// @param facetCut The facet cut to validate
  function validateFacetCut(IDiamond.FacetCut memory facetCut) internal view {
    if (uint256(facetCut.action) > 2) {
      revert DiamondCut_InvalidFacetCutAction();
    }

    if (facetCut.facet == address(0)) {
      revert DiamondCut_InvalidFacet(facetCut.facet);
    }

    if (!Address.isContract(facetCut.facet)) {
      revert DiamondCut_InvalidFacet(facetCut.facet);
    }

    if (facetCut.selectors.length == 0) {
      revert DiamondCut_InvalidFacetSelectors(facetCut.facet);
    }
  }

  ///@notice Check if immutable
  ///@param facet The facet to check
  function checkImmutable(address facet, bytes4[] memory) internal view {
    if (facet == address(this)) revert DiamondCut_ImmutableFacet();
  }

  /// @notice Initialize Diamond Cut Payload
  /// @param init The init address
  /// @param initPayload The init payload
  function initializeDiamondCut(
    IDiamond.FacetCut[] memory,
    address init,
    bytes memory initPayload
  ) internal {
    if (init == address(0)) return;

    if (!Address.isContract(init)) {
      revert DiamondCut_InvalidContract(init);
    }

    Address.functionDelegateCall(init, initPayload);
  }
}
