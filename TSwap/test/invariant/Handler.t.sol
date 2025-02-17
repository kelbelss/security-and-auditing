// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {TSwapPool} from "../../src/TSwapPool.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";

contract Handler is Test {
    TSwapPool pool;
    ERC20Mock weth;
    ERC20Mock poolToken;

    address liquidityProvider = makeAddr("lp");
    address swapper = makeAddr("swapper");

    // Ghost Variables - only exist in Handler
    int256 startingY;
    int256 startingX;
    int256 expectedDeltaY;
    int256 expectedDeltaX;
    int256 actualDeltaY;
    int256 actualDeltaX;

    constructor(TSwapPool _pool) {
        pool = _pool;
        weth = ERC20Mock(_pool.getWeth()); // getter function from TSWAP
        poolToken = ERC20Mock(_pool.getToken()); // getter function from TSWAP
    }

    // Invaraint contract has the whole set up, Handler will act as simulate a user
    // start with deposit and swapExactOutput
    // Invariant being tested - ∆x = (β/(1-β)) * x

    function swapPoolTokenForWethBasedOnOutputWeth(uint256 outputWeth) public {
        outputWeth = bound(outputWeth, 0, type(uint64).max);
        // dont want to swap out all the money in the pool
        if (output >= weth.balanceOf(address(pool))) {
            return;
        }
        // looking for delta X
        uint256 poolTokenAmount = pool.getInputAmountBasedOnOutput(
            outputWeth, poolToken.balanceOf(address(pool)), weth.balanceOf(address(pool))
        );
        // return if poolTokenAmount is too big
        if (poolTokenAmount > type(uint64).max) {
            return;
        }

        // starting values updated
        startingY = int256(weth.balanceOf(address(this)));
        startingX = int256(poolToken.balanceOf(address(this)));

        expectedDeltaY = int256(-1) * int256(outputWeth);
        expectedDeltaX = int256(pool.getPoolTokensToDepositBasedOnWeth(poolTokenAmount));
        if (poolToken.balanceOf(swapper) < poolTokenAmount) {
            poolToken.mint(swapper, poolTokenAmount - poolToken.balanceOf(swapper) + 1);
        }

        // do the actual swap
        vm.startPrank(swapper);
        poolToken.approve(address(pool), type(uint256).max);
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        vm.stopPrank();

        // actual values after deposit - lets see the deltas
        uint256 endingY = weth.balanceOf(address(this));
        uint256 endingX = poolToken.balanceOf(address(this));

        actualDeltaY = int256(endingY) - int256(startingY);
        actualDeltaX = int256(endingX) - int256(startingX);
    }

    function deposit(uint256 wethAmount) public {
        // make sure its a reasonable amount
        // avoid weird overflow errors
        wethAmount = bound(wethAmount, 0, type(uint64).max);
        // 18.446744073709551615

        // startingY and startingX
        startingY = int256(weth.balanceOf(address(this)));
        startingX = int256(poolToken.balanceOf(address(this)));

        // the weth amount deposited will be the delta amount - change
        expectedDeltaY = int256(wethAmount);
        // below gets the ratio based on how much weth is going in - change
        expectedDeltaX = int256(pool.getPoolTokensToDepositBasedOnWeth(wethAmount));

        // do deposit
        vm.startPrank(liquidityProvider);
        // mint the weth and pool tokens to LP address
        weth.mint(liquidityProvider, wethAmount);
        poolToken.mint(liquidityProvider, uint256(expectedDeltaX));
        // approve the pool to take the tokens
        weth.approve(address(pool), type(uint256).max);
        poolToken.approve(address(pool), type(uint256).max);
        // deposit into the pool
        pool.deposit(wethAmount, 0, uint256(expectedDeltaX), uint64(block.timestamp));
        vm.stopPrank();

        // actual values after deposit - lets see the deltas
        uint256 endingY = weth.balanceOf(address(this));
        uint256 endingX = poolToken.balanceOf(address(this));

        actualDeltaY = int256(endingY) - int256(startingY);
        actualDeltaX = int256(endingX) - int256(startingX);
    }
}
