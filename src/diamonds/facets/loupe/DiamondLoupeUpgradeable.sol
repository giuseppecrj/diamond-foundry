// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces
import {IDiamondLoupeStructs, IDiamondLoupe} from "./IDiamondLoupe.sol";

// libraries
import {IntrospectionUseCase} from "../introspection/IntrospectionUseCase.sol";
import {DiamondLoupeUseCase} from "./DiamondLoupeUseCase.sol";

// contracts
import {Initializable} from "../../utils/Initializable.sol";

abstract contract DiamondLoupeUpgradeable is
  IDiamondLoupeStructs,
  Initializable
{
  function __DiamondLoupe_init() internal onlyInitializing {
    IntrospectionUseCase.addInterface(type(IDiamondLoupe).interfaceId);
  }

  function _facetSelectors(
    address facet
  ) internal view returns (bytes4[] memory) {
    return DiamondLoupeUseCase.facetSelectors(facet);
  }

  function _facetAddresses() internal view returns (address[] memory) {
    return DiamondLoupeUseCase.facetAddresses();
  }

  function _facetAddress(
    bytes4 selector
  ) internal view returns (address facetAddress) {
    return DiamondLoupeUseCase.facetAddress(selector);
  }

  function _facets() internal view returns (Facet[] memory facets) {
    address[] memory facetAddresses = DiamondLoupeUseCase.facetAddresses();
    uint256 facetCount = facetAddresses.length;
    facets = new Facet[](facetCount);

    for (uint256 i; i < facetCount; i++) {
      address facetAddress = facetAddresses[i];
      bytes4[] memory selectors = _facetSelectors(facetAddress);
      facets[i] = Facet({facet: facetAddress, selectors: selectors});
    }
  }
}
