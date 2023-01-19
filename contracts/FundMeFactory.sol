// SPDX-License-Identifier: MIT

/**@title A sample Funding Contract
 * @author @voyotex
 * @notice This contract is for creating a sample funding contract
 * @dev This implements price feeds as our library
 */
pragma solidity ^0.8.17;

import "./Clones.sol";
import "./Fund.sol";

error FundMe__NotOwner();
error FundMe__NotEnoughFunds();
error FundMe__TransferFailed();

contract FundMeFactory {
    uint256 public fundsIndexCounter;
    uint256 public immutable i_minFundUSD;
    address public immutable i_owner;
    address[] public funds;
    address public masterContract;

    constructor(address _masterContract) {
        masterContract = _masterContract;
        fundsIndexCounter = 0;
        i_minFundUSD = 10;
        i_owner = msg.sender;
    }

    event FundCreated(uint256 index, address fundAddress);

    receive() external payable {}

    fallback() external payable {}

    function createFund(
        string memory _fundName,
        uint256 _fundDuration,
        uint256 _targetFunding
    ) external returns (address fund) {
        fund = Clones.clone(masterContract);
        fund.initialize(
            fundsIndexCounter,
            _fundName,
            msg.sender,
            _targetFunding,
            _fundDuration,
            address(this)
        );
        funds.push(address(fund));
        emit FundCreated(fundsIndexCounter, fund);
        fundsIndexCounter++;
    }

    function withdraw() public payable {
        uint256 balance = address(this).balance;
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        if (balance == 0) {
            revert FundMe__NotEnoughFunds();
        }
        (bool callResult, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        if (!callResult) revert FundMe__TransferFailed();
    }

    function getMasterContract() public view returns (address) {
        return masterContract;
    }

    function getFunds() public view returns (address[] memory) {
        return funds;
    }
}
