/**
 * SPDX-License-Identifier: MIT
 **/

pragma solidity ^0.8.17;

import "forge-std/console2.sol";
import {ConstantProduct2} from "src/functions/ConstantProduct2.sol";
import {Well, Call, TestHelper, IERC20} from "test/TestHelper.sol";
import {RandomBytes} from "utils/RandomBytes.sol";

contract ImmutableTest is TestHelper {
    function setUp() public {
        deployMockTokens(16);
        // wellBuilder = new WellBuilder();
    }

    /// @dev immutable storage should work when any number of its slots are filled
    function testImmutable(
        uint8 numberOfPumps,
        bytes[4] memory pumpBytes,
        address[4] memory pumpTargets,
        bytes memory wellFunctionBytes,
        uint8 nTokens
    ) public {
        vm.assume(numberOfPumps < 5);
        for (uint i = 0; i < numberOfPumps; i++)
            vm.assume(pumpBytes[i].length <= 4 * 32);
        vm.assume(wellFunctionBytes.length <= 4 * 32);
        vm.assume(nTokens < 4 && nTokens > 1);

        Call[] memory pumps = new Call[](numberOfPumps);
        for (uint i = 0; i < numberOfPumps; i++) {
            pumps[i].target = pumpTargets[i];
            pumps[i].data = pumpBytes[i];
        }

        address wellFunction = address(new ConstantProduct2());

        Well _well = new Well(
            getTokens(nTokens), 
            Call(wellFunction, wellFunctionBytes), 
            pumps,
            "",
            ""
        );

        Call[] memory _pumps = _well.pumps();

        for (uint i = 0; i < numberOfPumps; i++) {
            assertEq(_pumps[i].target, pumps[i].target);
            assertEq(_pumps[i].data, pumps[i].data);
        }

        // Check well function
        assertEq(_well.wellFunction().target, wellFunction);
        assertEq(_well.wellFunction().data, wellFunctionBytes);

        // Check token addresses; 
        IERC20[] memory _tokens = _well.tokens();
        for (uint i = 0; i < nTokens; i++) {
            assertEq(address(_tokens[i]), address(tokens[i]));
        }
    }
}
