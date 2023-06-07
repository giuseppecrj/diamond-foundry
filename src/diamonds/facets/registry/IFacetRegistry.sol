// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces

// libraries

// contracts

/// @title IFacetRegistry
/// @notice Interface for the facet registry contract
interface IFacetRegistry {
  /// @notice FacetInfo struct containing facet address, initializer function selector, and function selectors
  /// @param facet Facet address
  /// @param initializer Initializer function selector
  /// @param selectors Function selectors of the facet
  struct FacetInfo {
    address facet;
    bytes4 initializer;
    bytes4[] selectors;
  }

  /// @notice Emitted when a facet is registered or removed
  /// @param facetId The id of the facet
  /// @param facet The address of the facet
  event FacetRegistered(bytes32 indexed facetId, address indexed facet);

  /// @notice Emitted when a facet is removed
  /// @param facetId The id of the facet
  event FacetRemoved(bytes32 indexed facetId, address indexed facet);

  /// @notice Registers a new facet
  /// @param facetInfo FacetInfo struct containing facet address, initializer function selector, and function selectors
  function registerFacet(FacetInfo calldata facetInfo) external;

  /// @notice Removes a facet
  /// @param facetId The id of the facet
  function removeFacet(bytes32 facetId) external;

  /// @notice Returns the facetId of a facet address
  /// @param facet Facet address
  /// @return facetId The id of the facet
  function computeFacetId(
    address facet
  ) external view returns (bytes32 facetId);

  /// @notice Returns the facet info of a facet id
  /// @param facetId The id of the facet
  /// @return facet The address of the facet
  function facetAddress(bytes32 facetId) external view returns (address facet);

  /// @notice Returns the initializer function selector of a facet id
  /// @param facetId The id of the facet
  /// @return selector The initializer function selector of the facet id
  function facetInitializer(
    bytes32 facetId
  ) external view returns (bytes4 selector);

  /// @notice Returns the interface id of a facet id
  /// @param facetId The id of the facet
  /// @return interfaceId The interface id of the facet id
  function facetInterface(
    bytes32 facetId
  ) external view returns (bytes4 interfaceId);

  /// @notice Returns the selectors of a given facet
  /// @param facetId The id of the facet
  /// @return selectors The selectors of the facet
  function facetSelectors(
    bytes32 facetId
  ) external view returns (bytes4[] memory selectors);
}
