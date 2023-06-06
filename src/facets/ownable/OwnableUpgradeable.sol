// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces
import {IERC173, IERC173Events} from "./IERC173.sol";
import {OwnableUseCase} from "./OwnableUseCase.sol";

// libraries
import {IntrospectionUseCase} from "../introspection/IntrospectionUseCase.sol";

// contracts
import {Initializable} from "../../utils/Initializable.sol";

abstract contract OwnableUpgradeable is IERC173Events, Initializable {
  modifier onlyOwner() {
    OwnableUseCase.checkOwner(msg.sender);
    _;
  }

  function __Ownable_init(address owner) internal onlyInitializing {
    OwnableUseCase.transferOwnership(owner);
  }

  function _owner() internal view returns (address owner) {
    owner = OwnableUseCase.owner();
  }

  function _transferOwnership(address newOwner) internal {
    address oldOwner = _owner();
    OwnableUseCase.transferOwnership(newOwner);
    emit OwnershipTransferred(oldOwner, newOwner);
  }

  function _renounceOwnership() internal {
    address oldOwner = _owner();
    OwnableUseCase.renounceOwnership();
    emit OwnershipTransferred(oldOwner, address(0));
  }
}
