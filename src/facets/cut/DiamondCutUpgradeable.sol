// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

// interfaces
import {IDiamondCut, IDiamondCutEvents} from "./IDiamondCut.sol";
import {IDiamond} from "../../IDiamond.sol";

// libraries
import {DiamondCutUseCase} from "./DiamondCutUseCase.sol";
import {IntrospectionUseCase} from "../introspection/IntrospectionUseCase.sol";
import {OwnableUseCase} from "../ownable/OwnableUseCase.sol";

// contracts
import {Initializable} from "../../utils/Initializable.sol";

abstract contract DiamondCutUpgradeable is IDiamondCutEvents, Initializable {
  error DiamondCut_NotAllowed();

  function __DiamondCut_init() internal onlyInitializing {
    IntrospectionUseCase.addInterface(type(IDiamondCut).interfaceId);
  }

  function _diamondCut(
    IDiamond.FacetCut[] memory facetCuts,
    address init,
    bytes memory initPayload
  ) internal {
    if (!_canCutDiamonds()) revert DiamondCut_NotAllowed();

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
    return OwnableUseCase.owner() == msg.sender;
  }
}
