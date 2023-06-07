// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

//interfaces
import {IFacetRegistry} from "src/diamonds/facets/registry/IFacetRegistry.sol";
import {IDiamondFactoryStructs} from "src/diamonds/facets/factory/IDiamondFactory.sol";
import {IDiamondCut} from "src/diamonds/facets/cut/IDiamondCut.sol";
import {IDiamondLoupe} from "src/diamonds/facets/loupe/IDiamondLoupe.sol";

//libraries

//contracts
import {TestUtils} from "./utils/TestUtils.sol";
import {DiamondFactory} from "src/diamonds/facets/factory/DiamondFactory.sol";
import {FacetRegistry} from "src/diamonds/facets/registry/FacetRegistry.sol";
import {DiamondCut} from "src/diamonds/facets/cut/DiamondCut.sol";
import {DiamondLoupe} from "src/diamonds/facets/loupe/DiamondLoupe.sol";
import {Ownable} from "src/diamonds/facets/Ownable/Ownable.sol";

import {console} from "forge-std/console.sol";

contract DiamondFactoryTest is TestUtils {
  DiamondFactory internal diamondFactory;
  FacetRegistry internal facetRegistry;

  /// @notice Set up the facet registry and diamond factory
  function setUp() external {
    facetRegistry = new FacetRegistry();
    diamondFactory = new DiamondFactory(facetRegistry);
  }

  /// @notice Register the DiamondCut extension with the facet registry
  function registerDiamondCutExtension()
    internal
    returns (DiamondCut diamondCutExtension)
  {
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

  /// @notice Register the DiamondLoupe extension with the facet registry
  function registerDiamondLoupeExtension()
    internal
    returns (DiamondLoupe diamondLoupeExtension)
  {
    diamondLoupeExtension = new DiamondLoupe();

    bytes4[] memory diamondLoupeSelectors = new bytes4[](5);
    diamondLoupeSelectors[0] = diamondLoupeExtension.facets.selector;
    diamondLoupeSelectors[1] = diamondLoupeExtension
      .facetFunctionSelectors
      .selector;
    diamondLoupeSelectors[2] = diamondLoupeExtension.facetAddresses.selector;
    diamondLoupeSelectors[3] = diamondLoupeExtension.facetAddress.selector;
    diamondLoupeSelectors[4] = diamondLoupeExtension.supportsInterface.selector;

    IFacetRegistry.FacetInfo memory facetInfo = IFacetRegistry.FacetInfo({
      facet: address(diamondLoupeExtension),
      initializer: diamondLoupeExtension.initialize.selector,
      selectors: diamondLoupeSelectors
    });

    facetRegistry.registerFacet(facetInfo);
  }

  function registerOwnableExtension() internal returns (Ownable ownable) {
    ownable = new Ownable();

    bytes4[] memory ownableSelectors = new bytes4[](2);
    ownableSelectors[0] = ownable.owner.selector;
    ownableSelectors[1] = ownable.transferOwnership.selector;

    IFacetRegistry.FacetInfo memory facetInfo = IFacetRegistry.FacetInfo({
      facet: address(ownable),
      initializer: Ownable.initialize.selector,
      selectors: ownableSelectors
    });

    facetRegistry.registerFacet(facetInfo);
  }

  /// @notice Test that the diamond registry can register a facet
  function test_registerFacet() external {
    DiamondCut diamondCutExtension = registerDiamondCutExtension();

    bytes32 facetId = facetRegistry.computeFacetId(
      address(diamondCutExtension)
    );

    assertEq(address(diamondCutExtension), facetRegistry.facetAddress(facetId));
  }

  /// @notice Test that the diamond factory can create a diamond from a set of base facets
  function test_createDiamond() external {
    DiamondCut diamondCutExtension = registerDiamondCutExtension();
    DiamondLoupe diamondLoupe = registerDiamondLoupeExtension();
    Ownable ownable = registerOwnableExtension();

    DiamondFactory.BaseFacet[]
      memory baseFacets = new DiamondFactory.BaseFacet[](3);

    baseFacets[0] = IDiamondFactoryStructs.BaseFacet({
      facetId: facetRegistry.computeFacetId(address(diamondCutExtension)),
      initPayload: ""
    });

    baseFacets[1] = IDiamondFactoryStructs.BaseFacet({
      facetId: facetRegistry.computeFacetId(address(diamondLoupe)),
      initPayload: ""
    });

    baseFacets[2] = IDiamondFactoryStructs.BaseFacet({
      facetId: facetRegistry.computeFacetId(address(ownable)),
      initPayload: abi.encodeWithSelector(
        ownable.initialize.selector,
        makeAddr("deployer")
      )
    });

    address diamond = diamondFactory.createDiamond(baseFacets);

    assertTrue(
      DiamondLoupe(address(diamond)).supportsInterface(
        type(IDiamondCut).interfaceId
      )
    );

    assertEq(Ownable(address(diamond)).owner(), makeAddr("deployer"));
  }
}
