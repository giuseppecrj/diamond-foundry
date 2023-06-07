// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

//interfaces
import {IDiamond} from "src/diamonds/IDiamond.sol";
import {IDiamondFactoryStructs} from "src/diamonds/facets/factory/IDiamondFactory.sol";
import {IFacetRegistry} from "src/diamonds/facets/registry/IFacetRegistry.sol";

//libraries
import {Address} from "openzeppelin-contracts/contracts/utils/Address.sol";

//contracts
import {TestUtils} from "../../utils/TestUtils.sol";
import {Diamond} from "src/diamonds/Diamond.sol";

abstract contract FacetTest is TestUtils {
  address public diamond;

  function setUp() public virtual {
    vm.startPrank(makeAddr("deployer"));
    diamond = address(new Diamond(diamondInitParams()));
  }

  function diamondInitParams()
    internal
    virtual
    returns (Diamond.InitParams memory);
}

abstract contract FacetHelper {
  function facet() public view virtual returns (address);

  function selectors() public view virtual returns (bytes4[] memory);

  function initializer() public view virtual returns (bytes4);

  function facetId() public view virtual returns (bytes32) {
    return facet().codehash;
  }

  function supportedInterfaces() public pure virtual returns (bytes4[] memory);

  function facetInfo()
    public
    view
    returns (IFacetRegistry.FacetInfo memory info)
  {
    info = IFacetRegistry.FacetInfo({
      facet: facet(),
      initializer: initializer(),
      selectors: selectors()
    });
  }

  function makeFacetCut(
    IDiamond.FacetCutAction
  ) public view returns (IDiamond.FacetCut memory) {
    return
      IDiamond.FacetCut({
        facet: facet(),
        action: IDiamond.FacetCutAction.Add,
        selectors: selectors()
      });
  }

  /// @dev Initializers accepting arguments can override this function
  //       and decode the arguments here.
  function makeInitData(
    bytes memory
  ) public view virtual returns (IDiamondFactoryStructs.FacetInit memory) {
    return
      IDiamondFactoryStructs.FacetInit({
        facet: facet(),
        data: abi.encodeWithSelector(initializer())
      });
  }
}
