// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

//interfaces
import {IDiamond} from "src/diamonds/IDiamond.sol";
import {IDiamondLoupe} from "src/diamonds/facets/loupe/IDiamondLoupe.sol";
import {IDiamondCut} from "src/diamonds/facets/cut/IDiamondCut.sol";

//libraries

//contracts
import {TestUtils} from "./utils/TestUtils.sol";

import {Diamond} from "src/diamonds/Diamond.sol";
import {DiamondCut} from "src/diamonds/facets/cut/DiamondCut.sol";
import {DiamondLoupe} from "src/diamonds/facets/loupe/DiamondLoupe.sol";
import {Ownable} from "src/diamonds/facets/ownable/Ownable.sol";

import {DiamondMultiInit} from "src/diamonds/initializers/DiamondMultiInit.sol";

// debugging
import {console} from "forge-std/console.sol";

contract DiamondTest is TestUtils {
  Diamond internal diamond;
  DiamondCut internal diamondCutExtension;
  DiamondLoupe internal diamondLoupeExtension;
  Ownable internal ownableExtension;

  function setUp() external {
    // create diamond cut extension with selectors
    diamondCutExtension = new DiamondCut();
    bytes4[] memory diamondCutSelectors = new bytes4[](1);
    diamondCutSelectors[0] = diamondCutExtension.diamondCut.selector;

    diamondLoupeExtension = new DiamondLoupe();
    bytes4[] memory diamondLoupeSelectors = new bytes4[](5);
    diamondLoupeSelectors[0] = diamondLoupeExtension.facets.selector;
    diamondLoupeSelectors[1] = diamondLoupeExtension
      .facetFunctionSelectors
      .selector;
    diamondLoupeSelectors[2] = diamondLoupeExtension.facetAddresses.selector;
    diamondLoupeSelectors[3] = diamondLoupeExtension.facetAddress.selector;
    diamondLoupeSelectors[4] = diamondLoupeExtension.supportsInterface.selector;

    ownableExtension = new Ownable();
    bytes4[] memory ownableSelectors = new bytes4[](2);
    ownableSelectors[0] = ownableExtension.owner.selector;
    ownableSelectors[1] = ownableExtension.transferOwnership.selector;

    IDiamond.FacetCut[] memory baseCuts = new IDiamond.FacetCut[](3);

    // add diamond cut extension to diamond
    baseCuts[0] = IDiamond.FacetCut({
      facet: address(diamondCutExtension),
      action: IDiamond.FacetCutAction.Add,
      selectors: diamondCutSelectors
    });

    // add diamond loupe extension to diamond
    baseCuts[1] = IDiamond.FacetCut({
      facet: address(diamondLoupeExtension),
      action: IDiamond.FacetCutAction.Add,
      selectors: diamondLoupeSelectors
    });

    // add ownable extension to diamond
    baseCuts[2] = IDiamond.FacetCut({
      facet: address(ownableExtension),
      action: IDiamond.FacetCutAction.Add,
      selectors: ownableSelectors
    });

    // create diamond multi init
    DiamondMultiInit diamondMultiInit = new DiamondMultiInit();
    address[] memory diamondMultiInitAddresses = new address[](3);
    bytes[] memory diamondMultiInitPayloads = new bytes[](3);

    diamondMultiInitAddresses[0] = address(diamondCutExtension);
    diamondMultiInitPayloads[0] = abi.encodeWithSelector(
      DiamondCut.initialize.selector
    );

    diamondMultiInitAddresses[1] = address(diamondLoupeExtension);
    diamondMultiInitPayloads[1] = abi.encodeWithSelector(
      DiamondLoupe.initialize.selector
    );

    console.logBytes4(DiamondLoupe.initialize.selector);
    console.logBytes(
      abi.encodeWithSelector(DiamondLoupe.initialize.selector, "")
    );

    diamondMultiInitAddresses[2] = address(ownableExtension);
    diamondMultiInitPayloads[2] = abi.encodeWithSelector(
      Ownable.initialize.selector,
      address(this)
    );

    console.logBytes4(Ownable.initialize.selector);

    console.logBytes(
      abi.encodeWithSelector(Ownable.initialize.selector, address(this))
    );

    Diamond.InitParams memory params = Diamond.InitParams({
      owner: address(this),
      baseCuts: baseCuts,
      init: address(diamondMultiInit),
      initPayload: abi.encodeWithSelector(
        DiamondMultiInit.multiInit.selector,
        diamondMultiInitAddresses,
        diamondMultiInitPayloads
      )
    });

    diamond = new Diamond(params);
  }

  function test_supportsInterface() external {
    assertTrue(
      DiamondLoupe(address(diamond)).supportsInterface(
        type(IDiamondCut).interfaceId
      )
    );

    assertTrue(
      DiamondLoupe(address(diamond)).supportsInterface(
        type(IDiamondLoupe).interfaceId
      )
    );

    assertFalse(
      DiamondLoupe(address(diamond)).supportsInterface(
        type(IDiamond).interfaceId
      )
    );
  }
}
