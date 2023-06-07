// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

// interfaces
import {IDiamondCut} from "./IDiamondCut.sol";
import {IDiamond} from "../../IDiamond.sol";

// libraries
import {DiamondCutUseCase} from "./DiamondCutUseCase.sol";

// contracts
import {DiamondCutUpgradeable} from "./DiamondCutUpgradeable.sol";
import {Facet} from "../Facet.sol";

contract DiamondCut is DiamondCutUpgradeable, Facet {
  function initialize() external initializer {
    __DiamondCut_init();
  }

  function diamondCut(
    IDiamond.FacetCut[] memory facetCuts,
    address init,
    bytes memory initPayload
  ) external {
    _diamondCut(facetCuts, init, initPayload);
  }
}
