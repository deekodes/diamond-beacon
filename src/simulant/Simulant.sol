// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { DiamondBeacon } from "../beacon/DiamondBeacon.sol";
import { IDiamondLoupe } from "../interfaces/IDiamondLoupe.sol";

contract Simulant {
	address public immutable diamondBeacon;

	constructor(address _diamondBeacon) {
		diamondBeacon = _diamondBeacon;
	}

	fallback() external payable {
		address facet = IDiamondLoupe(diamondBeacon).facetAddress(msg.sig);
		require(facet != address(0), "Simulant: Function does not exist");
        // Execute external function from facet using delegatecall and return any value.
        assembly {
            // copy function selector and any arguments
            calldatacopy(0, 0, calldatasize())
            // execute function call using the facet
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            // get any return value
            returndatacopy(0, 0, returndatasize())
            // return any return value or error back to the caller
            switch result
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
	}
	
	receive() external payable {}
}