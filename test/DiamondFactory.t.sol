// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

//interfaces
import {IFacetRegistry} from "../src/facets/registry/IFacetRegistry.sol";
import {IDiamondFactoryStructs} from "../src/facets/factory/IDiamondFactory.sol";

//libraries

//contracts
import {TestUtils} from "./utils/TestUtils.sol";
import {DiamondFactory} from "../src/facets/factory/DiamondFactory.sol";
import {FacetRegistry} from "../src/facets/registry/FacetRegistry.sol";
import {DiamondCut} from "../src/facets/cut/DiamondCut.sol";

// debugging
import {console} from "forge-std/console.sol";

contract DiamondFactoryTest is TestUtils {
  DiamondFactory internal diamondFactory;
  FacetRegistry internal facetRegistry;

  function setUp() external {
    facetRegistry = new FacetRegistry();
    diamondFactory = new DiamondFactory(facetRegistry);
  }

  function setUpCutFacet() internal returns (DiamondCut diamondCutExtension) {
    diamondCutExtension = new DiamondCut();

    bytes4[] memory diamondCutSelectors = new bytes4[](1);
    diamondCutSelectors[0] = diamondCutExtension.diamondCut.selector;

    IFacetRegistry.FacetInfo memory facetInfo = IFacetRegistry.FacetInfo({
      facet: address(diamondCutExtension),
      initializer: diamondCutExtension.initialize.selector,
      selectors: diamondCutSelectors
    });

    facetRegistry.registerFacet(facetInfo);
  }

  function test_registerFacet() external {
    DiamondCut diamondCutExtension = setUpCutFacet();

    bytes32 facetId = facetRegistry.computeFacetId(
      address(diamondCutExtension)
    );

    assertEq(address(diamondCutExtension), facetRegistry.facetAddress(facetId));
  }

  function test_createDiamond() external {
    DiamondCut diamondCutExtension = setUpCutFacet();

    DiamondFactory.BaseFacet[]
      memory baseFacets = new DiamondFactory.BaseFacet[](1);

    baseFacets[0] = IDiamondFactoryStructs.BaseFacet({
      facetId: facetRegistry.computeFacetId(address(diamondCutExtension)),
      initArgs: ""
    });

    address diamond = diamondFactory.createDiamond(baseFacets);

    console.log(diamond);
  }
}
