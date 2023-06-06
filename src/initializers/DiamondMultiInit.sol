// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

// interfaces

// libraries
import {DiamondCutUseCase} from "../facets/cut/DiamondCutUseCase.sol";
import {IDiamond} from "../IDiamond.sol";

// contracts

error AddressAndCalldataLengthDoNotMatch(
  uint256 _addressesLength,
  uint256 _calldataLength
);

contract DiamondMultiInit {
  // This function is provided in the third parameter of the `diamondCut` function.
  // The `diamondCut` function executes this function to execute multiple initializer functions for a single upgrade.

  function multiInit(
    address[] calldata _addresses,
    bytes[] calldata _calldata
  ) external {
    if (_addresses.length != _calldata.length) {
      revert AddressAndCalldataLengthDoNotMatch(
        _addresses.length,
        _calldata.length
      );
    }
    for (uint256 i; i < _addresses.length; i++) {
      DiamondCutUseCase.initializeDiamondCut(
        new IDiamond.FacetCut[](0),
        _addresses[i],
        _calldata[i]
      );
    }
  }
}
