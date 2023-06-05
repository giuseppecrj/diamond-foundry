// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces
import {IDiamondCut} from "./facets/cut/IDiamondCut.sol";
import {IDiamond} from "./IDiamond.sol";

// libraries

// contracts
import {DiamondCutUpgradeable} from "./facets/cut/DiamondCutUpgradeable.sol";

contract Diamond is IDiamond, DiamondCutUpgradeable {
  struct InitParams {
    FacetCut[] baseCuts;
    address init;
    bytes initPayload;
  }

  constructor(InitParams memory params) payable {
    /// @dev If `diamondCut` facet is not provided, the diamond will be immutable
    _diamondCut(params.baseCuts, params.init, params.initPayload);
  }
}
