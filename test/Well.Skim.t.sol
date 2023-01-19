/**
 * SPDX-License-Identifier: MIT
 **/
pragma solidity ^0.8.17;

import "test/TestHelper.sol";

contract WellSkimTest is TestHelper {

    function setUp() public {
        setupWell(2);
    }

    function test_initialized() public {
        // Well should have liquidity 
        assertEq(tokens[0].balanceOf(address(well)), 1000e18);
        assertEq(tokens[1].balanceOf(address(well)), 1000e18);
    }
    
    function test_skim(uint[2] calldata amounts) prank(user) public {
        vm.assume(amounts[0] <= 800e18);
        vm.assume(amounts[1] <= 800e18);

        // Transfer from Test contract to Well
        // FIXME: which contract are these being transferred from?
        tokens[0].transfer(address(well), amounts[0]);
        tokens[1].transfer(address(well), amounts[1]);

        // Verify that the Well has received the tokens
        assertEq(tokens[0].balanceOf(address(well)), 1000e18 + amounts[0]);
        assertEq(tokens[1].balanceOf(address(well)), 1000e18 + amounts[1]);

        // Get a user with a fresh address (no ERC20 tokens)
        address _user = users.getNextUserAddress();
        uint[] memory balances = new uint[](2);
        balances[0] = tokens[0].balanceOf(_user);
        balances[1] = tokens[1].balanceOf(_user);
        assertEq(balances[0], 0);
        assertEq(balances[1], 0);

        well.skim(_user);

        // Since only 1000e18 of each token was added as liquidity, the Well's balance
        // should be reset back to this.
        assertEq(tokens[0].balanceOf(address(well)), 1000e18);
        assertEq(tokens[1].balanceOf(address(well)), 1000e18);

        // The difference has been sent to _user.
        assertEq(tokens[0].balanceOf(_user), amounts[0]);
        assertEq(tokens[1].balanceOf(_user), amounts[1]);
    }
}