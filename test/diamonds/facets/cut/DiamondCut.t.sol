// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

//interfaces
import {IDiamondCut, IDiamondCutEvents} from "src/diamonds/facets/cut/IDiamondCut.sol";
import {IDiamond} from "src/diamonds/IDiamond.sol";

//libraries

//contracts
import {FacetTest} from "test/diamonds/facets/Facet.t.sol";
import {Diamond} from "src/diamonds/Diamond.sol";
import {DiamondMultiInit} from "src/diamonds/initializers/DiamondMultiInit.sol";
import {DiamondCutHelper} from "./DiamondCutHelper.t.sol";
import {MockFacetHelper} from "test/diamonds/mocks/MockFacet.sol";

// errors
import {DiamondCut_InvalidSelector, DiamondCut_FunctionAlreadyExists, DiamondCut_InvalidFacetRemoval, DiamondCut_FunctionDoesNotExist, DiamondCut_InvalidFacetCutAction, DiamondCut_InvalidFacet, DiamondCut_InvalidFacetSelectors, DiamondCut_ImmutableFacet, DiamondCut_InvalidContract} from "src/diamonds/facets/cut/DiamondCutUseCase.sol";

contract DiamondCutTest is FacetTest, IDiamondCutEvents {
  // @dev helper to avoid boilerplace
  IDiamond.FacetCut[] public facetCuts;

  IDiamondCut public diamondCut;
  MockFacetHelper public mockFacetHelper;

  function setUp() public virtual override {
    super.setUp();

    diamondCut = IDiamondCut(diamond);
    mockFacetHelper = new MockFacetHelper();
  }

  function diamondInitParams()
    internal
    virtual
    override
    returns (Diamond.InitParams memory)
  {
    DiamondCutHelper diamondCutHelper = new DiamondCutHelper();

    IDiamond.FacetCut[] memory baseFacets = new IDiamond.FacetCut[](1);
    baseFacets[0] = diamondCutHelper.makeFacetCut(IDiamond.FacetCutAction.Add);

    DiamondMultiInit diamondMultiInit = new DiamondMultiInit();
    address[] memory addresses = new address[](1);
    bytes[] memory calldatas = new bytes[](1);

    addresses[0] = address(diamondCutHelper.facet());
    calldatas[0] = abi.encodeWithSelector(diamondCutHelper.initializer());

    return
      Diamond.InitParams({
        owner: makeAddr("deployer"),
        baseCuts: baseFacets,
        init: address(diamondMultiInit),
        initPayload: abi.encodeWithSelector(
          diamondMultiInit.multiInit.selector,
          addresses,
          calldatas
        )
      });
  }

  // =============================================================
  //                           Tests
  // =============================================================

  function test_revertsWhenInitIsNotContract() external {
    address init = makeAddr("deployer");

    vm.expectRevert(
      abi.encodeWithSelector(DiamondCut_InvalidContract.selector, init)
    );
    diamondCut.diamondCut(facetCuts, init, "");
  }

  function test_revertWhenFacetIsZeroAddress() external {
    facetCuts.push(
      IDiamond.FacetCut({
        facet: address(0),
        action: IDiamond.FacetCutAction.Add,
        selectors: new bytes4[](0)
      })
    );

    vm.expectRevert(
      abi.encodeWithSelector(DiamondCut_InvalidFacet.selector, address(0))
    );
    diamondCut.diamondCut(facetCuts, address(0), "");
  }

  function test_revertsWhenFacetIsNotContract() external {
    address facet = makeAddr("deployer");

    facetCuts.push(
      IDiamond.FacetCut({
        facet: facet,
        action: IDiamond.FacetCutAction.Add,
        selectors: new bytes4[](0)
      })
    );

    vm.expectRevert(
      abi.encodeWithSelector(DiamondCut_InvalidFacet.selector, facet)
    );
    diamondCut.diamondCut(facetCuts, address(0), "");
  }

  function test_revertsWhenSelectorArrayIsEmpty() external {
    facetCuts.push(
      IDiamond.FacetCut({
        facet: address(mockFacetHelper.facet()),
        action: IDiamond.FacetCutAction.Add,
        selectors: new bytes4[](0)
      })
    );

    vm.expectRevert(
      abi.encodeWithSelector(
        DiamondCut_InvalidFacetSelectors.selector,
        mockFacetHelper.facet()
      )
    );
    diamondCut.diamondCut(facetCuts, address(0), "");
  }

  function test_emitEvents() external {
    facetCuts.push(
      IDiamond.FacetCut({
        facet: address(mockFacetHelper.facet()),
        action: IDiamond.FacetCutAction.Add,
        selectors: mockFacetHelper.selectors()
      })
    );

    vm.expectEmit(true, true, true, true, diamond);
    emit DiamondCut(facetCuts, address(0), "");

    diamondCut.diamondCut(facetCuts, address(0), "");
  }
}
