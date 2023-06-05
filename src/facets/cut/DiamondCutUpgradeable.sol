// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

// interfaces
import {IDiamondCut, IDiamondCutEvents} from "./IDiamondCut.sol";
import {IDiamond} from "../../IDiamond.sol";

// libraries
import {DiamondCutUseCase} from "./DiamondCutUseCase.sol";

// contracts
import {Facet} from "../Facet.sol";

abstract contract DiamondCutUpgradeable is IDiamondCutEvents, Facet {
  function __DiamondCut_init() internal onlyInitializing {
    // todo add interface
  }

  function _diamondCut(
    IDiamond.FacetCut[] memory facetCuts,
    address init,
    bytes memory initPayload
  ) internal {
    if (!_canCutDiamonds()) revert("DiamondCut: Can't cut");

    for (uint256 i; i < facetCuts.length; i++) {
      IDiamond.FacetCut memory facetCut = facetCuts[i];

      DiamondCutUseCase.validateFacetCut(facetCut);

      if (facetCut.action == IDiamond.FacetCutAction.Add) {
        DiamondCutUseCase.addFacet(facetCut.facet, facetCut.selectors);
      } else if (facetCut.action == IDiamond.FacetCutAction.Replace) {
        _checkImmutable(facetCut.facet, facetCut.selectors);
        DiamondCutUseCase.replaceFacet(facetCut.facet, facetCut.selectors);
      } else if (facetCut.action == IDiamond.FacetCutAction.Remove) {
        _checkImmutable(facetCut.facet, facetCut.selectors);
        DiamondCutUseCase.removeFacet(facetCut.facet, facetCut.selectors);
      }
    }

    emit DiamondCut(facetCuts, init, initPayload);

    DiamondCutUseCase.initializeDiamondCut(facetCuts, init, initPayload);
  }

  function _checkImmutable(
    address facet,
    bytes4[] memory selectors
  ) internal view {
    DiamondCutUseCase.checkImmutable(facet, selectors);
  }

  function _canCutDiamonds() internal view virtual returns (bool) {
    return true;
  }
}
