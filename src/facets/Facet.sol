// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

// interfaces

// libraries

// contracts
import {Initializable} from "../utils/Initializable.sol";
import {DelegateCall} from "../utils/DelegateCall.sol";

abstract contract Facet is Initializable, DelegateCall {
  constructor() {
    _disableInitializers();
  }
}
