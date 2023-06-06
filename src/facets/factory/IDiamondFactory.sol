// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces
import {IDiamond} from "../../IDiamond.sol";
import {IFacetRegistry} from "../registry/IFacetRegistry.sol";

// libraries

// contracts
interface IDiamondFactoryStructs {
  struct BaseFacet {
    bytes32 facetId;
    bytes initArgs;
  }

  struct FacetInit {
    address facet;
    bytes data; // encoded initializer + args
  }
}

interface IDiamondFactory is IDiamondFactoryStructs {
  /**
   * @notice Emitted when a diamond is deployed via the factory.
   */
  event DiamondCreated(
    address indexed diamond,
    address indexed deployer,
    BaseFacet[] baseFacets
  );

  /**
   * @notice Creates a diamond with the given base Facets
   * @param baseFacets The base facets info which will be added to the diamond.
   * @return diamond The address of the diamond.
   */
  function createDiamond(
    BaseFacet[] calldata baseFacets
  ) external returns (address diamond);

  /**
   * @notice Creates a diamond with the given base Facets and salt.
   * @param baseFacetIds The facetIds of the base facets to be added to the diamond.
   * @param salt The salt to be used in the diamond address computation.
   * @return diamond The address of the diamond.
   */
  // TODO: function createDiamond(bytes32[] calldata baseFacetIds, uint256 salt) external returns (address diamond);

  /**
   * @notice Builds a FacetCut struct from a given facetId.
   * @param action The action to be performed.
   * @param facetId The facetId of the facet.
   */
  function makeFacetCut(
    IDiamond.FacetCutAction action,
    bytes32 facetId
  ) external view returns (IDiamond.FacetCut memory facetCut);

  /**
   * @dev To be called only via delegatecall.
   * @notice Executes a delegatecall to initialize the diamond.
   * @param diamondInitData The FacetInit data to be used in the delegatecall.
   */
  function multiDelegateCall(FacetInit[] memory diamondInitData) external;

  /**
   * @notice Returns the address of the `FacetRegistry`.
   */
  function facetRegistry() external view returns (IFacetRegistry);
}
