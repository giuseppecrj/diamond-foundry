// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces

// libraries

// contracts
import {FacetHelper} from "test/diamonds/facets/Facet.t.sol";

interface IMockFacet {
  function mockFunction() external pure returns (uint256);
}

contract MockFacet is IMockFacet {
  function mockFunction() external pure override returns (uint256) {
    return 42;
  }
}

contract MockFacetHelper is FacetHelper {
  MockFacet internal mockFacet;

  constructor() {
    mockFacet = new MockFacet();
  }

  function facet() public view override returns (address) {
    return address(mockFacet);
  }

  function selectors()
    public
    pure
    override
    returns (bytes4[] memory selectors_)
  {
    selectors_ = new bytes4[](1);
    selectors_[0] = MockFacet.mockFunction.selector;
  }

  function initializer() public pure override returns (bytes4) {
    return bytes4(0);
  }

  function supportedInterfaces()
    public
    pure
    override
    returns (bytes4[] memory interfaces)
  {
    interfaces = new bytes4[](1);
    interfaces[0] = type(IMockFacet).interfaceId;
  }
}
