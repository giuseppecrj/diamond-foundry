// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces
import {IERC165} from "../introspection/IERC165.sol";
import {IDiamondLoupe} from "./IDiamondLoupe.sol";

// libraries

// contracts
import {IntrospectionUpgradeable} from "../introspection/IntrospectionUpgradeable.sol";
import {DiamondLoupeUpgradeable} from "./DiamondLoupeUpgradeable.sol";
import {Facet} from "../Facet.sol";

contract DiamondLoupe is
  IDiamondLoupe,
  IERC165,
  DiamondLoupeUpgradeable,
  IntrospectionUpgradeable,
  Facet
{
  function initialize() external initializer {
    __DiamondLoupe_init();
    __Introspection_init();
  }

  function facets() external view override returns (Facet[] memory) {
    return _facets();
  }

  function facetFunctionSelectors(
    address facet
  ) external view override returns (bytes4[] memory) {
    return _facetSelectors(facet);
  }

  function facetAddresses() external view override returns (address[] memory) {
    return _facetAddresses();
  }

  function facetAddress(
    bytes4 selector
  ) external view override returns (address) {
    return _facetAddress(selector);
  }

  function supportsInterface(
    bytes4 interfaceId
  ) public view virtual override returns (bool) {
    return _supportsInterface(interfaceId);
  }
}
