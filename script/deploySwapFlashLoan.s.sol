// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.9.0;

import "forge-std/Script.sol";
import {SwapDeployer} from "../src/SwapDeployer.sol";
import {SwapFlashLoan} from "../src/SwapFlashLoan.sol";
import {LPToken} from "../src/LPToken.sol";
//import {GenericERC20} from "../src/helpers/GenericERC20.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";

contract MyScript is Script {
    
    SwapDeployer public swapDeployer;
    SwapFlashLoan public swap;
    SwapFlashLoan public swapClone;
    // GenericERC20 public token0;
    // GenericERC20 public token1;
    IERC20 public USDT;
    IERC20 public BUSD;
    LPToken public lpToken;

    function run() external {
        vm.startBroadcast();
        swap = new SwapFlashLoan();
        USDT=IERC20(vm.envAddress("USDT_ADDRESS"));
        BUSD=IERC20(vm.envAddress("BUSD_ADDRESS"));
        lpToken = new LPToken();
        swapDeployer = SwapDeployer(vm.envAddress("SWAP_DEPLOYER_ADDRESS"));
        address swapAddress = address(swap);
        address token0Address = address(USDT);
        address token1Address = address(BUSD);

        IERC20[] memory pooledTokens = new IERC20[](2);
        pooledTokens[0] = IERC20(token0Address);
        pooledTokens[1] = IERC20(token1Address);

        uint8[] memory decimals = new uint8[](2);
        decimals[0] = 18;
        decimals[1] = 18;
        string memory lpTokenName = "USDTBUSDSTABLEPOOL";
        string memory lpTokenSymbol = "USDTBUSDLP";
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
        swapClone = SwapFlashLoan(swapCloneAddress);

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