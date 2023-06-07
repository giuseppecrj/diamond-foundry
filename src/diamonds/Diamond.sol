// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces
import {IDiamondCut} from "./facets/cut/IDiamondCut.sol";
import {IDiamond} from "./IDiamond.sol";

// libraries
import {DiamondLoupeUseCase} from "./facets/loupe/DiamondLoupeUseCase.sol";
import {OwnableUseCase} from "./facets/ownable/OwnableUseCase.sol";
import {Address} from "openzeppelin-contracts/contracts/utils/Address.sol";

// contracts
import {DiamondCutUpgradeable} from "./facets/cut/DiamondCutUpgradeable.sol";

error Diamond__FunctionNotFound();

contract Diamond is IDiamond, DiamondCutUpgradeable {
  struct InitParams {
    address owner;
    FacetCut[] baseCuts;
    address init;
    bytes initPayload;
  }

  constructor(InitParams memory params) payable {
    // set owner
    OwnableUseCase.transferOwnership(params.owner);

    /// @dev If `diamondCut` facet is not provided, the diamond will be immutable
    _diamondCut(params.baseCuts, params.init, params.initPayload);
  }

  fallback() external payable {
    _fallback();
  }

  // solhint-disable-next-line no-empty-blocks
  receive() external payable {}

  function _fallback() internal {
    address facet = DiamondLoupeUseCase.facetAddress(msg.sig);

    if (facet == address(0)) revert Diamond__FunctionNotFound();

    Address.functionDelegateCall(facet, msg.data);

    // solhint-disable-next-line no-inline-assembly
    assembly {
      // get return value
      returndatacopy(0, 0, returndatasize())
      // return return value or error back to the caller
      return(0, returndatasize())
    }
  }
}
