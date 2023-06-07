// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces

// libraries

// contracts
interface IDiamond {
  /// @notice Add/replace/remove any number of functions and optionally execute
  /// @param Add Facets to add functions to.
  /// @param Replace Facets to replace functions in.
  /// @param Remove Facets to remove functions from.
  enum FacetCutAction {
    Add,
    Replace,
    Remove
  }

  /// @notice Execute a diamond cut
  /// @param facet Facet to cut.
  /// @param action Enum of type FacetCutAction.
  /// @param selectors Array of function selectors.
  struct FacetCut {
    address facet;
    FacetCutAction action;
    bytes4[] selectors;
  }
}
