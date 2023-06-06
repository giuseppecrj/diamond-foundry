// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces
import {IERC165, IIntrospectionEvents} from "./IERC165.sol";

// libraries
import {IntrospectionUseCase} from "./IntrospectionUseCase.sol";

// contracts
import {Initializable} from "../../utils/Initializable.sol";

abstract contract IntrospectionUpgradeable is
  IIntrospectionEvents,
  Initializable
{
  function __Introspection_init() internal onlyInitializing {
    _addInterface(type(IERC165).interfaceId);
  }

  function _addInterface(bytes4 interfaceId) internal {
    IntrospectionUseCase.addInterface(interfaceId);
    emit InterfaceAdded(interfaceId);
  }

  function _removeInterface(bytes4 interfaceId) internal {
    IntrospectionUseCase.removeInterface(interfaceId);
    emit InterfaceRemoved(interfaceId);
  }

  function _supportsInterface(bytes4 interfaceId) internal view returns (bool) {
    return IntrospectionUseCase.supportsInterface(interfaceId);
  }
}
