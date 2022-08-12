// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.9.0;

import "forge-std/Script.sol";
import {SwapDeployer} from "../src/SwapDeployer.sol";
import {Swap} from "../src/Swap.sol";
import {LPToken} from "../src/LPToken.sol";
import {GenericERC20} from "../src/helpers/GenericERC20.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";

contract MyScript is Script {
    
    SwapDeployer public swapDeployer;
    Swap public swap;
    Swap public swapClone;
    GenericERC20 public token0;
    GenericERC20 public token1;
    LPToken public lpToken;

    function run() external {
        vm.startBroadcast();
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

        swapDeployer.deploy(
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
        address swapToken = address(swapClone.getLpToken());

        lpToken = LPToken(swapToken);

        vm.stopBroadcast();
    }
}