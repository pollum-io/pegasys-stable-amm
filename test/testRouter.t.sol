// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;
import {SwapDeployer} from "../src/SwapDeployer.sol";
import "../../src/interfaces/ISwap.sol";
import {Swap} from "../src/Swap.sol";
import {GenericERC20} from "../src/helpers/GenericERC20.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {LPToken} from "../src/LPToken.sol";
import {Router} from "../src/Router.sol";
import {ISwap} from "../src/interfaces/ISwap.sol";

import "forge-std/Test.sol";
import "forge-std/console2.sol";

contract TestDeployer is Test {
  
    SwapDeployer public swapDeployer;
    Swap public swap0;
    Swap public swap1;
    Swap public swap2;
    ISwap public swap0Clone;
    ISwap public swap1Clone;
    ISwap public swap2Clone;
    GenericERC20 public token0;
    GenericERC20 public token1;
    GenericERC20 public token2;
    GenericERC20 public token3;
    LPToken public lpToken0;
    LPToken public lpToken1;
    LPToken public lpToken2;
    Router public router;

    function setUp() public {
        swap0 = new Swap();
        swap2 = new Swap();
        token0 = new GenericERC20("token0", "TOKEN0", 18);
        token1 = new GenericERC20("token1", "TOKEN1", 18);
        lpToken0 = new LPToken();
        lpToken2 = new LPToken();
        router = new Router();
        swapDeployer = new SwapDeployer();
        address token0Address = address(token0);
        address token1Address = address(token1);

        IERC20[] memory pooledTokens = new IERC20[](2);
        pooledTokens[0] = IERC20(token0Address);
        pooledTokens[1] = IERC20(token1Address);

        uint8[] memory decimals = new uint8[](2);
        decimals[0] = 18;
        decimals[1] = 18;
        string memory lpToken0Name = "lpToken0Name";
        string memory lpToken0Symbol = "lpToken0Symbol";
        string memory lpToken2Name = "lpToken2Name";
        string memory lpToken2Symbol = "lpToken2Symbol";
 
        uint256 _a = 1 * 10**3;
        uint256 _fee = 4;
        uint256 _adminFee = 0;
        address lpToken0TargetAddress = address(lpToken0);
        address lpToken2TargetAddress = address(lpToken2);
        address swap0CloneAddress = swapDeployer.deploy(
            address(swap0),
            pooledTokens,
            decimals,
            lpToken0Name,
            lpToken0Symbol,
            _a,
            _fee,
            _adminFee,
            lpToken0TargetAddress
        );

        address swap2CloneAddress = swapDeployer.deploy(
            address(swap2),
            pooledTokens,
            decimals,
            lpToken2Name,
            lpToken2Symbol,
            _a,
            _fee + 4,
            _adminFee,
            lpToken2TargetAddress
        );

        swap0Clone = ISwap(swap0CloneAddress);
        swap2Clone = ISwap(swap2CloneAddress);

        address swap0Token = address(swap0Clone.getLpToken());
        address swap2Token = address(swap2Clone.getLpToken());
        lpToken0 = LPToken(swap0Token);

        swap1 = new Swap();

        token3 = new GenericERC20("token3", "TOKEN3", 18);
        lpToken1 = new LPToken();
        address swap1Address = address(swap1);
        address token2Address = address(lpToken0);
        address token3Address = address(token3);
        /////swap1Clone 0 ==== lp, 1 ==== token3          swap0Clone 0 ==== token0, 1 ==== token1
        IERC20[] memory pooledTokens1 = new IERC20[](2);
        pooledTokens1[0] = IERC20(token2Address);
        pooledTokens1[1] = IERC20(token3Address);
        uint8[] memory decimals1 = new uint8[](2);
        decimals1[0] = 18;
        decimals1[1] = 18;
        uint256 _a1 = 1 * 10**3;
        uint256 _fee1 = 4;
        uint256 _adminFee1 = 0;
        string memory lpToken1Name = "lpToken1Name";
        string memory lpToken1Symbol = "lpToken1Symbol";
        address lpToken1TargetAddress = address(lpToken1);
        address swap1CloneAddress = swapDeployer.deploy(
            swap1Address,
            pooledTokens1,
            decimals1,
            lpToken1Name,
            lpToken1Symbol,
            _a1,
            _fee1,
            _adminFee1,
            lpToken1TargetAddress
        );
        swap1Clone = ISwap(swap1CloneAddress);

        swapDeployer.deploy(
            swap1Address,
            pooledTokens1,
            decimals1,
            lpToken1Name,
            lpToken1Symbol,
            _a1,
            _fee1,
            _adminFee1,
            lpToken1TargetAddress
        );
        address swap1Token = address(swap1Clone.getLpToken());
        lpToken1 = LPToken(swap1Token);
    }
    function routerAddLiquidity(address _user) public returns(uint){

        uint256 mintAmount= 10000000000000000; //hardcoded due to later calls on other tests
        token0.mint(_user, mintAmount * 10**18);
        token1.mint(_user, mintAmount * 10**18);
        token3.mint(_user, mintAmount * 10**18);
        vm.startPrank(_user);

        token0.approve(address(router), mintAmount* 10**18);
        token1.approve(address(router), mintAmount* 10**18);
        token3.approve(address(router), mintAmount* 10**18);

        uint256[] memory base_amounts = new uint256[](2);
        base_amounts[0] = mintAmount* 10**17;
        base_amounts[1] = mintAmount* 10**17;

        uint256[] memory meta_amounts = new uint256[](2);
        meta_amounts[0] = lpToken0.totalSupply() / 2;
        meta_amounts[1] = mintAmount * 10**17;

        uint256 lpAmount = router.addLiquidity(
            swap1Clone, /////META POOL
            swap0Clone, /////BASE POOL
            meta_amounts,
            base_amounts,
            0,
            block.timestamp + 100
        );
        console.logUint(lpAmount);
        vm.stopPrank();
        return lpAmount;

     } 
    function testAddLiquidity(uint mintAmount) public {

        vm.assume(mintAmount>10);
        vm.assume(mintAmount<10**18); // 10**36
        address user1 = address(1);
        // uint256 amountMint = 10000000000000000000000000;
        token0.mint(user1, mintAmount * 10**18);
        token1.mint(user1, mintAmount * 10**18);

        vm.startPrank(user1);

        token0.approve(address(swap0Clone), mintAmount * 10**18);
        token1.approve(address(swap0Clone), mintAmount * 10**18);
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = mintAmount* 10**17;
        amounts[1] = mintAmount* 10**17;
        uint256 calculatedAmount = swap0Clone.calculateTokenAmount(
            amounts,
            true
        );
        console.logString("calculatedAmount");
        console.logUint(calculatedAmount);
        assertTrue(calculatedAmount > 0);
        swap0Clone.addLiquidity(amounts, 1, block.timestamp + 100);
        console.logUint(swap0Clone.getTokenBalance(0));
        assertTrue(swap0Clone.getTokenBalance(0) >= mintAmount/10);
        assertTrue(swap0Clone.getTokenBalance(1) > mintAmount/10);
        assertTrue(lpToken0.totalSupply() > 0);
        vm.stopPrank();
    }

    function testRouterAddLiquidity() public returns (uint256) {
        uint256 mintAmount= 10000000000000000; //hardcoded due to later calls on other tests
        address user1 = address(this);
        token0.mint(user1, mintAmount * 10**18);
        token1.mint(user1, mintAmount * 10**18);
        token3.mint(user1, mintAmount * 10**18);

        token0.approve(address(router), mintAmount* 10**18);
        token1.approve(address(router), mintAmount* 10**18);
        token3.approve(address(router), mintAmount* 10**18);

        uint256[] memory base_amounts = new uint256[](2);
        base_amounts[0] = mintAmount* 10**17;
        base_amounts[1] = mintAmount* 10**17;

        uint256[] memory meta_amounts = new uint256[](2);
        meta_amounts[0] = lpToken0.totalSupply() / 2;
        meta_amounts[1] = mintAmount * 10**17;

        uint256 lpAmount = router.addLiquidity(
            swap1Clone, /////META POOL
            swap0Clone, /////BASE POOL
            meta_amounts,
            base_amounts,
            0,
            block.timestamp + 100
        );
        console.logUint(lpAmount);
        assertTrue(lpAmount > 0);
        return lpAmount;
    }

    function testRouterSwapFromBase() public {
        address user1 = address(1);
        routerAddLiquidity(user1);
        vm.startPrank(user1);
        uint256 previousAmount0 = token0.balanceOf(user1);
        uint256 previousAmount1 = token3.balanceOf(user1);
        uint256 calculateAmount = router.calculateSwapFromBase(
            swap1Clone,
            swap0Clone,
            0,
            1,
            10**18
        );
        router.swapFromBase(
            swap1Clone,
            swap0Clone,
            0,
            1,
            calculateAmount,
            1**17,
            block.timestamp + 100
        );
        uint256 currentAmount0 = token0.balanceOf(user1);
        uint256 currentAmount1 = token3.balanceOf(user1);
        vm.stopPrank();

        assertTrue(previousAmount0 > currentAmount0);
        assertTrue(previousAmount1 < currentAmount1);
    }

    function testRouterSwapToBase(uint mintAmount) public {

        vm.assume(mintAmount > 0);
        vm.assume(mintAmount < 10**18);
        address user2 = address(2);
        routerAddLiquidity(user2);
        token3.mint(user2, mintAmount * 10**17);

        vm.startPrank(user2);
        token3.approve(address(router), token3.totalSupply());

        uint256 previousAmount0 = token3.balanceOf(user2);
        uint256 previousAmount1 = token0.balanceOf(user2);
        console.logUint(previousAmount0);
        console.logUint(previousAmount1);
        uint256 calculateAmount = router.calculateSwapToBase(
            swap1Clone,
            swap0Clone,
            1,
            0,
            1 * 10**18
        );
        router.swapToBase(
            swap1Clone,
            swap0Clone,
            1,
            0,
            calculateAmount,
            1 * 10**18,
            block.timestamp + 100
        );
        uint256 currentAmount0 = token3.balanceOf(user2);
        uint256 currentAmount1 = token0.balanceOf(user2);
        console.logUint(currentAmount0);
        console.logUint(currentAmount1);
        assertTrue(previousAmount0 > currentAmount0);
        assertTrue(previousAmount1 < currentAmount1);
        vm.stopPrank();
    }

    function testRemoveLiquidityOneToken() public {
        testRouterAddLiquidity();

        uint256 lpAmount = lpToken0.totalSupply();
        uint256 amount = swap1Clone.getTokenBalance(0);
        lpToken1.approve(address(router), MAX_INT);

        uint256 amountReceived = router.removeBaseLiquidityOneToken(
            swap1Clone,
            swap0Clone,
            10 * 10**18,
            1,
            1 * 10**18,
            block.timestamp + 100
        );
        console.logUint(amountReceived);
        assertTrue(amountReceived > 0);
    }

    function testRouterRemoveLiquidity() public {

        testRouterAddLiquidity();
        uint256 totalSupply = lpToken1.totalSupply();
        console.logUint(totalSupply);

        lpToken1.approve(address(router), totalSupply * 3);

        (uint256[] memory meta_amounts, uint256[] memory base_amounts) = router
            .calculateRemoveLiquidity(swap1Clone, swap0Clone, totalSupply);

        router.removeLiquidity(
            swap1Clone,
            swap0Clone,
            totalSupply,
            meta_amounts,
            base_amounts,
            block.timestamp + 100
        );
        assertTrue(lpToken1.totalSupply() == 0);
    }

    uint256 MAX_INT = 2**256 - 1;

    function testConvert() public {
        
        uint mintAmount = 10000000;
        address user3 = address(3);
        routerAddLiquidity(user3);

        vm.assume(mintAmount > 0);
        vm.assume(mintAmount < 10**18);

        token0.mint(user3, mintAmount* 10**18);
        token1.mint(user3, mintAmount* 10**18);
        token3.mint(user3, mintAmount* 10**18);

        vm.startPrank(user3);
 
        token0.approve(address(router), mintAmount* 10**18);
        token1.approve(address(router), mintAmount* 10**18);
        token3.approve(address(router), mintAmount* 10**18);

        uint256[] memory base_amounts = new uint256[](2);
        base_amounts[0] = mintAmount * 10**17;
        base_amounts[1] = mintAmount * 10**17;

        uint256[] memory meta_amounts = new uint256[](2);
        meta_amounts[0] = lpToken0.totalSupply() / 2;
        meta_amounts[1] = mintAmount * 10**17;

        uint256 lpAmount = router.addLiquidity(
            swap1Clone, /////META POOL
            swap0Clone, /////BASE POOL
            meta_amounts,
            base_amounts,
            0,
            block.timestamp + 100
        );
        console.logUint(lpAmount);
        assertTrue(lpAmount > 0);

        token0.approve(address(swap0Clone), mintAmount * 10**18);
        token1.approve(address(swap0Clone), mintAmount * 10**18);
        swap0Clone.addLiquidity(base_amounts,10**18,block.timestamp +100);

        lpToken0.approve(address(router),10**36); 
        console.logUint(router.calculateConvert(
        swap0Clone,
        swap2Clone,
        mintAmount*10**17
      )); 
        uint lpAmountTransfered = router.convert(
        swap0Clone,
        swap2Clone,
        // 2*10**18,
        lpToken0.balanceOf(user3),
        10**18,
        block.timestamp+1000 
     ); 
     vm.stopPrank();
     assertTrue(lpAmountTransfered>0);
   }
}
