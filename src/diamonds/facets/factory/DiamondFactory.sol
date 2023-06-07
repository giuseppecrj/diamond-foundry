// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

// interfaces
import {IDiamondFactory} from "./IDiamondFactory.sol";
import {IDiamond} from "../../IDiamond.sol";
import {IFacetRegistry} from "../registry/IFacetRegistry.sol";

// libraries
import {Address} from "openzeppelin-contracts/contracts/utils/Address.sol";

// contracts
import {Diamond} from "../../Diamond.sol";
import {DelegateCall} from "../../utils/DelegateCall.sol";

import {console} from "forge-std/console.sol";

contract DiamondFactory is IDiamondFactory, DelegateCall {
  IFacetRegistry public immutable facetRegistry;

  constructor(IFacetRegistry _facetRegistry) {
    facetRegistry = _facetRegistry;
  }

  function createDiamond(
    BaseFacet[] memory baseFacets
  ) external override returns (address diamond) {
    diamond = _deployDiamond(baseFacets);

    emit DiamondCreated(diamond, msg.sender, baseFacets);
  }

  function makeFacetCut(
    IDiamond.FacetCutAction action,
    bytes32 facetId
  ) external view returns (IDiamond.FacetCut memory facetCut) {
    facetCut.action = action;
    facetCut.facet = facetRegistry.facetAddress(facetId);
    facetCut.selectors = facetRegistry.facetSelectors(facetId);
  }

  /// @inheritdoc IDiamondFactory
  function multiDelegateCall(
    FacetInit[] memory diamondInitData
  ) external onlyDelegateCall {
    for (uint256 i = 0; i < diamondInitData.length; i++) {
      FacetInit memory facetInit = diamondInitData[i];
      if (facetInit.data.length == 0) continue;

      // slither-disable-next-line unused-return
      Address.functionDelegateCall(facetInit.facet, facetInit.data);
    }
  }

  function _deployDiamond(
    BaseFacet[] memory baseFacets
  ) internal returns (address diamond) {
    uint256 facetCount = baseFacets.length;

    IDiamond.FacetCut[] memory baseCuts = new IDiamond.FacetCut[](facetCount);

    FacetInit[] memory diamondInitData = new FacetInit[](facetCount);

    for (uint256 i; i < facetCount; i++) {
      BaseFacet memory facet = baseFacets[i];

      address facetAddress = facetRegistry.facetAddress(facet.facetId);

      baseCuts[i] = IDiamond.FacetCut({
        facet: facetAddress,
        action: IDiamond.FacetCutAction.Add,
        selectors: facetRegistry.facetSelectors(facet.facetId)
      });

      bytes4 initializer = facetRegistry.facetInitializer(facet.facetId);

      if (initializer != bytes4(0)) {
        // if user passes a payload, use that, otherwise use the initializer
        bytes memory data = facet.initPayload.length == 0
          ? abi.encodeWithSelector(initializer)
          : facet.initPayload;

        diamondInitData[i] = FacetInit({facet: facetAddress, data: data});
      }
    }

    Diamond.InitParams memory initParams = Diamond.InitParams({
      owner: address(this),
      baseCuts: baseCuts,
      init: address(this),
      initPayload: abi.encodeWithSelector(
        this.multiDelegateCall.selector,
        diamondInitData
      )
    });

    diamond = address(new Diamond(initParams));
  }
}
