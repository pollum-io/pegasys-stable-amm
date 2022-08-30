// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.9.0;

import "forge-std/Script.sol";
import {SwapDeployer} from "../src/SwapDeployer.sol";
import {Swap} from "../src/Swap.sol";
import {LPToken} from "../src/LPToken.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";

contract deploySwap is Script {
    
    SwapDeployer public swapDeployer;
    Swap public swap;
    Swap public swapClone;
    IERC20 public USDC;
    IERC20 public DAI;
    LPToken public lpToken;

    function run() external {

        
        vm.startBroadcast();
        
        swap = new Swap();
        //foundry can access environment variables, make sure to set these exact keys and source from .env
        USDC = IERC20(vm.envAddress("USDC_ADDRESS"));
        DAI = IERC20(vm.envAddress("DAI_ADDRESS"));
        lpToken = new LPToken();
        swapDeployer = SwapDeployer(vm.envAddress("SWAP_DEPLOYER_ADDRESS"));
        address swapAddress = address(swap);
        IERC20[] memory pooledTokens = new IERC20[](2);
        address token0Address = address(USDC);
        address token1Address = address(DAI);
        pooledTokens[0] = IERC20(token0Address);
        pooledTokens[1] = IERC20(token1Address);

        uint8[] memory decimals = new uint8[](2);
        decimals[0] = 18;
        decimals[1] = 18;
        string memory lpTokenName = "USDCDAISTABLEPOOL";
        string memory lpTokenSymbol = "USDCDAILP";
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

        vm.stopBroadcast();

    }
}