// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {StdInvariant} from "forge-std/StdInvariant.sol";
import {Test} from "forge-std/Test.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {PoolFactory} from "../../src/PoolFactory.sol";
import {TSwapPool} from "../../src/TSwapPool.sol";
import {Handler} from "./Handler.t.sol";

contract Invariant is StdInvariant, Test {
    // these pools have 2 assets
    ERC20Mock poolToken;
    ERC20Mock weth;

    // need the contracts
    PoolFactory factory; // this factory could make mulitple pools - we use one
    TSwapPool pool; // poolToken/WETH
    Handler handler;

    // int to set X and Y value
    int256 constant STARTING_X = 100e18; // starting ERC20 / poolToken
    int256 constant STARTING_Y = 50e18; // starting ERC20 / WETH

    function setUp() public {
        // deploy the WETH and pool tokens
        weth = new ERC20Mock();
        poolToken = new ERC20Mock();

        // deploy the factory contract
        factory = new PoolFactory(address(weth));

        // created a pool using the factory
        pool = TSwapPool(factory.createPool(address(poolToken)));

        // liquidity provides put money in to jumpstart the pool (x and y)
        poolToken.mint(address(this), uint256(STARTING_X));
        weth.mint(address(this), uint256(STARTING_Y));

        // approve the pool to take the tokens (max to not do it again)
        poolToken.approve(address(pool), type(uint256).max);
        weth.approve(address(pool), type(uint256).max);

        // deposit into the pool
        pool.deposit(uint256(STARTING_Y), uint256(STARTING_Y), uint256(STARTING_X), uint64(block.timestamp));

        // set up handler
        handler = new Handler(pool);
        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = handler.deposit.selector;
        selectors[1] = handler.swapPoolTokenForWethBasedOnOutputWeth.selector;

        targetSelector(FuzzSelector({addr: address(handler), selectors: selectors}));
        targetContract(address(handler));
    }

    function statefulFuzz_constantProductFormulaStaysTheSame() public {
        assertEq(handler.actualDeltaX(), handler.expectedDeltaX());
    }
}
