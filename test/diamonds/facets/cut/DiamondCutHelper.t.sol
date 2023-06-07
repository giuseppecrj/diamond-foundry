// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces
import {IDiamondCut} from "src/diamonds/facets/cut/IDiamondCut.sol";

// libraries

// contracts
import {FacetHelper} from "test/diamonds/facets/Facet.t.sol";
import {DiamondCut} from "src/diamonds/facets/cut/DiamondCut.sol";

contract DiamondCutHelper is FacetHelper {
  DiamondCut public diamondCut;

  constructor() {
    diamondCut = new DiamondCut();
  }

  function facet() public view override returns (address) {
    return address(diamondCut);
  }

  function selectors() public view override returns (bytes4[] memory) {
    bytes4[] memory selectors_ = new bytes4[](1);
    selectors_[0] = diamondCut.diamondCut.selector;
    return selectors_;
  }

  function initializer() public view override returns (bytes4) {
    return diamondCut.initialize.selector;
  }

  function supportedInterfaces()
    public
    pure
    override
    returns (bytes4[] memory interfaces)
  {
    interfaces = new bytes4[](1);
    interfaces[0] = type(IDiamondCut).interfaceId;
  }
}
