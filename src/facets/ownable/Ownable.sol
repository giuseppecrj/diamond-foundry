// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces
import {IERC173} from "./IERC173.sol";

// libraries

// contracts
import {OwnableUpgradeable} from "./OwnableUpgradeable.sol";
import {Facet} from "../Facet.sol";

contract Ownable is IERC173, OwnableUpgradeable, Facet {
  function initialize(address owner_) external initializer {
    __Ownable_init(owner_);
  }

  /// @inheritdoc IERC173
  function transferOwnership(address newOwner) external override onlyOwner {
    _transferOwnership(newOwner);
  }

  /// @inheritdoc IERC173
  function owner() external view override returns (address) {
    return _owner();
  }
}
