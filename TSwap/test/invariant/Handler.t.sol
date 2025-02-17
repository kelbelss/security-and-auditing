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
    int256 public startingY;
    int256 public startingX;
    int256 public expectedDeltaY;
    int256 public expectedDeltaX;
    int256 public actualDeltaY;
    int256 public actualDeltaX;

    constructor(TSwapPool _pool) {
        pool = _pool;
        weth = ERC20Mock(_pool.getWeth()); // getter function from TSWAP
        poolToken = ERC20Mock(_pool.getPoolToken()); // getter function from TSWAP
    }

    // Invaraint contract has the whole set up, Handler will act as simulate a user
    // start with deposit and swapExactOutput
    // Invariant being tested - ∆x = (β/(1-β)) * x

    function deposit(uint256 wethAmount) public {
        // make sure its a reasonable amount
        // avoid weird overflow errors
        uint256 minWeth = pool.getMinimumWethDepositAmount();
        wethAmount = bound(wethAmount, minWeth, weth.balanceOf(address(pool)));

        // startingY and startingX
        startingY = int256(poolToken.balanceOf(address(pool)));
        startingX = int256(weth.balanceOf(address(pool)));

        // below gets the ratio based on how much weth is going in - change
        expectedDeltaY = int256(pool.getPoolTokensToDepositBasedOnWeth(wethAmount));
        // the weth amount deposited will be the delta amount - change
        expectedDeltaX = int256(wethAmount);

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
        uint256 endingY = weth.balanceOf(address(pool));
        uint256 endingX = poolToken.balanceOf(address(pool));

        actualDeltaY = int256(endingX) - int256(startingY);
        actualDeltaX = int256(endingY) - int256(startingX);
    }

    function swapPoolTokenForWethBasedOnOutputWeth(uint256 outputWeth) public {
        uint256 minWeth = pool.getMinimumWethDepositAmount();

        if (weth.balanceOf(address(pool)) <= minWeth) {
            return;
        }

        outputWeth = bound(outputWeth, minWeth, weth.balanceOf(address(pool)));

        // dont want to swap out all the money in the pool
        if (outputWeth >= weth.balanceOf(address(pool))) {
            return;
        }
        // looking for delta X
        uint256 poolTokenAmount = pool.getInputAmountBasedOnOutput(
            outputWeth, poolToken.balanceOf(address(pool)), weth.balanceOf(address(pool))
        );

        // starting values updated
        startingY = int256(poolToken.balanceOf(address(pool)));
        startingX = int256(weth.balanceOf(address(pool)));

        expectedDeltaY = int256(poolTokenAmount);
        expectedDeltaX = int256(-1) * int256(outputWeth);

        if (poolToken.balanceOf(swapper) < poolTokenAmount) {
            poolToken.mint(swapper, poolTokenAmount - poolToken.balanceOf(swapper) + 1);
        }

        // do the actual swap
        vm.startPrank(swapper);
        poolToken.approve(address(pool), type(uint256).max);
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        vm.stopPrank();

        // actual values after deposit - lets see the deltas
        uint256 endingY = poolToken.balanceOf(address(pool));
        uint256 endingX = weth.balanceOf(address(pool));

        actualDeltaY = int256(endingY) - int256(startingY);
        actualDeltaX = int256(endingX) - int256(startingX);
    }
}
