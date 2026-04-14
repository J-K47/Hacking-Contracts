// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FrontRunBot is Ownable {
    IUniswapV2Router02 public immutable uniswapRouter;
    address public immutable WETH;

    event FrontRunExecuted(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint amountOut
    );
    event Withdrawn(address token, uint amount);

    constructor(address _router) Ownable(msg.sender) {
        uniswapRouter = IUniswapV2Router02(_router);
        WETH = uniswapRouter.WETH();
    }

    // Core Functions

    /*
     * @notice Execute a front-run swap on Uniswap V2
     * @param tokenIn  Token to sell (use WETH address for ETH path)
     * @param tokenOut Token to buy
     * @param amountIn Exact amount of tokenIn to spend
     * @param minAmountOut Minimum tokens to receive (slippage guard)
     * @param deadline Unix timestamp deadline
     */
    function frontRunSwap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 deadline
    ) external onlyOwner returns (uint256 amountOut) {
        IERC20(tokenIn).approve(address(uniswapRouter), amountIn);

        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        uint256[] memory amounts = uniswapRouter.swapExactTokensForTokens(
            amountIn,
            minAmountOut,
            path,
            address(this),
            deadline
        );

        amountOut = amounts[amounts.length - 1];
        emit FrontRunExecuted(tokenIn, tokenOut, amountIn, amountOut);
    }

    /*
     * @notice Simulate expected output BEFORE executing (read-only check)
     */
    function getExpectedOut(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        uint256[] memory amounts = uniswapRouter.getAmountsOut(amountIn, path);
        return amounts[amounts.length - 1];
    }

    /*
     * @notice Calculate minimum profitable gas price to beat a target tx
     * @param targetGasPrice  The victim tx's gas price (in wei)
     * @param gasBump         Extra wei to add on top (e.g. 1-10 gwei)
     */
    function calcFrontRunGasPrice(
        uint256 targetGasPrice,
        uint256 gasBump
    ) external pure returns (uint256) {
        return targetGasPrice + gasBump;
    }

    /*
     * @notice Check if an opportunity is profitable after gas costs
     * @param expectedProfit  Wei profit from the swap
     * @param gasUsed         Estimated gas units
     * @param gasPrice        Gas price you'll pay
     */
    function isProfitable(
        uint256 expectedProfit,
        uint256 gasUsed,
        uint256 gasPrice
    ) external pure returns (bool) {
        uint256 gasCost = gasUsed * gasPrice;
        return expectedProfit > gasCost;
    }

    // Fund Management

    // @notice Deposit ETH into the contract
    receive() external payable {}

    // @notice Withdraw ETH to owner
    function withdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        (bool ok, ) = owner().call{value: balance}("");
        require(ok, "ETH withdrawal failed");
        emit Withdrawn(address(0), balance);
    }

    // @notice Withdraw any ERC20 token to owner
    function withdrawToken(address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(owner(), balance);
        emit Withdrawn(token, balance);
    }
}
