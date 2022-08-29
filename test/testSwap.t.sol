// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;
import {SwapDeployer} from "../src/SwapDeployer.sol";
// import "../../src/interfaces/ISwap.sol";
import {Swap} from "../src/Swap.sol";
import {GenericERC20} from "../src/helpers/GenericERC20.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {LPToken} from "../src/LPToken.sol";

import "forge-std/Test.sol";
import "forge-std/console2.sol";

contract TestDeployer is Test {
    SwapDeployer public swapDeployer;
    Swap public swap;
    Swap public swapClone;
    GenericERC20 public token0;
    GenericERC20 public token1;
    LPToken public lpToken;

    function setUp() public {
        swap = new Swap();
        token0 = new GenericERC20("token0", "TOKEN0", 18);
        token1 = new GenericERC20("token1", "TOKEN1", 18);
        lpToken = new LPToken();
        swapDeployer = new SwapDeployer();
        address swapAddress = address(swap);
        address token0Address = address(token0);
        address token1Address = address(token1);
        IERC20[] memory pooledTokens = new IERC20[](2);
        pooledTokens[0] = IERC20(token0Address);
        pooledTokens[1] = IERC20(token1Address);
        uint8[] memory decimals = new uint8[](2);
        decimals[0] = 18;
        decimals[1] = 18;
        string memory lpTokenName = "lpTokenName";
        string memory lpTokenSymbol = "lpTokenSymbol";
        uint256 _a = 1 * 10**5;
        uint256 _fee = 4;
        uint256 _adminFee = 0;
        address lpTokenTargetAddress = address(lpToken);
        address swapCloneAddress = swapDeployer.deploy(
            swapAddress,
            pooledTokens,
            decimals,
            lpTokenName,
            lpTokenSymbol,
            _a,
            _fee,
            _adminFee,
            lpTokenTargetAddress
        );
        swapClone = Swap(swapCloneAddress);
        address swapToken = address(swapClone.getLpToken());
        lpToken = LPToken(swapToken);
        assertTrue(swapAddress != address(0));
        console.logString("getA");
        console.logUint(swapClone.getA());
        console.logUint(pooledTokens.length);
    }

    function testAddLiquidity() public {
        uint256 amountMint = 10000000000000000000000000;
        token0.mint(address(this), amountMint * 10**18);
        token0.approve(address(swapClone), amountMint * 10**18);
        token1.mint(address(this), amountMint * 10**18);
        token1.approve(address(swapClone), amountMint * 10**18);
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 100 * 10**18;
        amounts[1] = 100 * 10**18;
        uint256 calculatedAmount = swapClone.calculateTokenAmount(
            amounts,
            true
        );
        console.logString("calculatedAmount");
        console.logUint(calculatedAmount);
        assertTrue(calculatedAmount > 0);
        swapClone.addLiquidity(amounts, 1, block.timestamp + 100);
        console.logUint(swapClone.getTokenBalance(0));
        assertTrue(swapClone.getTokenBalance(0) > 10000000000000000000);
        assertTrue(swapClone.getTokenBalance(1) > 10000000000000000000);
        assertTrue(lpToken.totalSupply() > 0);
    }

    function testRemoveLiquidity() public {
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 10 * 10**18;
        amounts[1] = 10 * 10**18;
        testAddLiquidity();
        console.logUint(swapClone.getTokenBalance(0));
        assertTrue(swapClone.getTokenBalance(0) > 10000000000000000000);
        assertTrue(swapClone.getTokenBalance(1) > 10000000000000000000);
        assertTrue(lpToken.totalSupply() > 0);
        uint256 lpAmount = lpToken.totalSupply();
        lpToken.approve(address(swapClone), lpAmount);
        swapClone.removeLiquidity(lpAmount, amounts, block.timestamp + 100);
        assertTrue(swapClone.getTokenBalance(0) == 0);
        assertTrue(swapClone.getTokenBalance(1) == 0);
        assertTrue(lpToken.totalSupply() == 0);
    }

    function testSwap() public {
        testAddLiquidity();
        uint256 previousAmount0 = token0.balanceOf(address(this));
        uint256 previousAmount1 = token1.balanceOf(address(this));
        uint256 calcTokenAmount = swapClone.calculateSwap(0, 1, 10 * 10**18);
        swapClone.swap(
            0,
            1,
            10 * 10**18,
            calcTokenAmount,
            block.timestamp + 60
        );
        uint256 currentAmount0 = token0.balanceOf(address(this));
        uint256 currentAmount1 = token1.balanceOf(address(this));
        assertTrue(previousAmount0 > currentAmount0);
        assertTrue(previousAmount1 < currentAmount1);
        testRemoveLiquidity();
    }

    function testRemoveLiquidityOneToken() public {
        testAddLiquidity();
        console.logUint(swapClone.getTokenBalance(0));
        assertTrue(swapClone.getTokenBalance(0) > 10000000000000000000);
        assertTrue(swapClone.getTokenBalance(1) > 10000000000000000000);
        assertTrue(lpToken.totalSupply() > 0);
        uint256 lpAmount = lpToken.totalSupply();
        uint256 amount = swapClone.getTokenBalance(0);
        lpToken.approve(address(swapClone), lpAmount);
        token0.approve(address(swapClone), amount);

        uint256 amountReceived = swapClone.removeLiquidityOneToken(
            amount,
            0,
            10 * 10**18,
            block.timestamp + 100
        );
        assertTrue(amountReceived > 0);
    }

    function testRemoveLiquidityImbalance() public {
        testAddLiquidity();
        uint256 lpAmount = lpToken.totalSupply();
        uint256 previousAmount0 = swapClone.getTokenBalance(0);
        uint256 previousAmount1 = swapClone.getTokenBalance(1);
        lpToken.approve(address(swapClone), lpAmount);
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 1 * 10**18;
        amounts[1] = 1 * 10**18;
        swapClone.removeLiquidityImbalance(
            amounts,
            lpAmount,
            block.timestamp + 100
        );
        uint256 currentAmount0 = swapClone.getTokenBalance(0);
        uint256 currentAmount1 = swapClone.getTokenBalance(1);
        assertTrue(previousAmount0 > currentAmount0);
        assertTrue(previousAmount1 > currentAmount1);
    }
}
