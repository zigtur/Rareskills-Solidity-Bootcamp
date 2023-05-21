// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import "./lib/YulDeployer.sol";
import "solmate/tokens/ERC1155.sol";
//import "openzeppelin/token/ERC1155/IERC1155.sol";

interface IERC1155 {
    // ERC-1155 standard functions
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);
    // must be marked back to view function
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    // custom functions
    function mint(address to, uint256 id, uint256 amount) external;
    function mint(address to, uint256 id, uint256 amount, bytes calldata) external;
}


contract ERC1155Test is Test {
    YulDeployer yulDeployer = new YulDeployer();

    IERC1155 token;
    
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event URI(string _value, uint256 indexed _id);    

    function setUp() public {
        token = IERC1155(yulDeployer.deployContract("ERC1155"));
    }

    function testMint() public {
        token.mint(address(this), 1, 1000);
        console.log("balance for token1 is : ", token.balanceOf(address(this), 1));
        assertEq(token.balanceOf(address(this), 1), 1000);
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////
    ///                                                                                             ///
    ///                                    ApprovalForAll tests                                     ///
    ///                                                                                             ///
    ///////////////////////////////////////////////////////////////////////////////////////////////////

    function testApproveAll() public {
        token.setApprovalForAll(address(0xBEEF), true);

        assertTrue(token.isApprovedForAll(address(this), address(0xBEEF)));

        token.setApprovalForAll(address(0xBEEF), false);

        assertFalse(token.isApprovedForAll(address(this), address(0xBEEF)));
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    ///                                                                                             ///
    ///                                    balanceOfBatch tests                                     ///
    ///                                                                                             ///
    ///////////////////////////////////////////////////////////////////////////////////////////////////

    function testBatchBalanceOf() public {
        address[] memory tos = new address[](5);
        tos[0] = address(0xBEEF);
        tos[1] = address(0xCAFE);
        tos[2] = address(0xFACE);
        tos[3] = address(0xDEAD);
        tos[4] = address(0xFEED);

        uint256[] memory ids = new uint256[](5);
        ids[0] = 1337;
        ids[1] = 1338;
        ids[2] = 1339;
        ids[3] = 1340;
        ids[4] = 1341;

        token.mint(address(0xBEEF), 1337, 100, "");
        token.mint(address(0xCAFE), 1338, 200, "");
        token.mint(address(0xFACE), 1339, 300, "");
        token.mint(address(0xDEAD), 1340, 400, "");
        token.mint(address(0xFEED), 1341, 500, "");

        uint256[] memory balances = token.balanceOfBatch(tos, ids);

        assertEq(balances[0], 100);
        assertEq(balances[1], 200);
        assertEq(balances[2], 300);
        assertEq(balances[3], 400);
        assertEq(balances[4], 500);
    }

    function testFailBalanceOfBatchWithArrayMismatch() public view {
        address[] memory tos = new address[](5);
        tos[0] = address(0xBEEF);
        tos[1] = address(0xCAFE);
        tos[2] = address(0xFACE);
        tos[3] = address(0xDEAD);
        tos[4] = address(0xFEED);

        uint256[] memory ids = new uint256[](4);
        ids[0] = 1337;
        ids[1] = 1338;
        ids[2] = 1339;
        ids[3] = 1340;

        token.balanceOfBatch(tos, ids);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    ///                                                                                             ///
    ///                                         mint tests                                          ///
    ///                                                                                             ///
    ///////////////////////////////////////////////////////////////////////////////////////////////////

    function testMintToEOA() public {
        token.mint(address(0xBEEF), 1337, 1, "");

        assertEq(token.balanceOf(address(0xBEEF), 1337), 1);
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////
    ///                                                                                             ///
    ///                                   safeTransferFrom tests                                    ///
    ///                                                                                             ///
    ///////////////////////////////////////////////////////////////////////////////////////////////////

    function testSafeTransferFromToEOA() public {
        address from = address(0xABCD);

        token.mint(from, 1337, 100, "");

        vm.prank(from);
        token.setApprovalForAll(address(this), true);

        token.safeTransferFrom(from, address(0xBEEF), 1337, 70, "");

        assertEq(token.balanceOf(address(0xBEEF), 1337), 70);
        assertEq(token.balanceOf(from, 1337), 30);
    }

    function testSafeTransferFromToERC1155Recipient() public {
        ERC1155Recipient to = new ERC1155Recipient();

        address from = address(0xABCD);

        token.mint(from, 1337, 100, "");

        vm.prank(from);
        token.setApprovalForAll(address(this), true);

        token.safeTransferFrom(from, address(to), 1337, 70, "testing 123");

        //// transfer hooks implementation incoming...
        //assertEq(to.operator(), address(this));
        //assertEq(to.from(), from);
        //assertEq(to.id(), 1337);
        //assertBytesEq(to.mintData(), "testing 123");

        assertEq(token.balanceOf(address(to), 1337), 70);
        assertEq(token.balanceOf(from, 1337), 30);
    }

    function testSafeTransferFromSelf() public {
        token.mint(address(this), 1337, 100, "");

        token.safeTransferFrom(address(this), address(0xBEEF), 1337, 70, "");

        assertEq(token.balanceOf(address(0xBEEF), 1337), 70);
        assertEq(token.balanceOf(address(this), 1337), 30);
    }


    function testFailSafeTransferFromInsufficientBalance() public {
        address from = address(0xABCD);

        token.mint(from, 1337, 70, "");

        vm.prank(from);
        token.setApprovalForAll(address(this), true);

        token.safeTransferFrom(from, address(0xBEEF), 1337, 100, "");
    }

    function testFailSafeTransferFromSelfInsufficientBalance() public {
        token.mint(address(this), 1337, 70, "");
        token.safeTransferFrom(address(this), address(0xBEEF), 1337, 100, "");
    }

    function testFailSafeTransferFromToZero() public {
        token.mint(address(this), 1337, 100, "");
        token.safeTransferFrom(address(this), address(0), 1337, 70, "");
    }

    // transfer hooks implementation incoming...
    /*
    function testFailSafeTransferFromToNonERC155Recipient() public {
        token.mint(address(this), 1337, 100, "");
        token.safeTransferFrom(address(this), address(new NonERC1155Recipient()), 1337, 70, "");
    }

    function testFailSafeTransferFromToRevertingERC1155Recipient() public {
        token.mint(address(this), 1337, 100, "");
        token.safeTransferFrom(address(this), address(new RevertingERC1155Recipient()), 1337, 70, "");
    }

    function testFailSafeTransferFromToWrongReturnDataERC1155Recipient() public {
        token.mint(address(this), 1337, 100, "");
        token.safeTransferFrom(address(this), address(new WrongReturnDataERC1155Recipient()), 1337, 70, "");
    }
    */


    /*function testMintToERC1155Recipient() public {
        ERC1155Recipient to = new ERC1155Recipient();

        token.mint(address(to), 1337, 1, "testing 123");

        assertEq(token.balanceOf(address(to), 1337), 1);

        assertEq(to.operator(), address(this));
        assertEq(to.from(), address(0));
        assertEq(to.id(), 1337);
        assertBytesEq(to.mintData(), "testing 123");
    }*/

    /*function testOwnership() public {
        require(ch.owner() == address(yulDeployer), "ownership check failed");
    }

    function testMinting() public {
        address owner = address(yulDeployer);
        vm.expectEmit(true, true, true, true);
        emit TransferSingle(owner, address(0), address(this), 1, 20);

        ch.mint(address(this), 1, 20);

        uint256 balance = ch.balanceOf(address(this), 1);
        require(balance == 20, "balance not as expected");
    }



    function testBalance() public {
        // uint256 balance = ch.balanceOf(address(this),1);
        // require(balance > 0, "balance was unexpected");
    }*/
}

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    ///                                                                                             ///
    ///                                         Other tools                                         ///
    ///                                                                                             ///
    ///////////////////////////////////////////////////////////////////////////////////////////////////
contract ERC1155Recipient is ERC1155TokenReceiver {
    address public operator;
    address public from;
    uint256 public id;
    uint256 public amount;
    bytes public mintData;

    function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _amount,
        bytes calldata _data
    ) public override returns (bytes4) {
        operator = _operator;
        from = _from;
        id = _id;
        amount = _amount;
        mintData = _data;

        return ERC1155TokenReceiver.onERC1155Received.selector;
    }

    address public batchOperator;
    address public batchFrom;
    uint256[] internal _batchIds;
    uint256[] internal _batchAmounts;
    bytes public batchData;

    function batchIds() external view returns (uint256[] memory) {
        return _batchIds;
    }

    function batchAmounts() external view returns (uint256[] memory) {
        return _batchAmounts;
    }

    function onERC1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _amounts,
        bytes calldata _data
    ) external override returns (bytes4) {
        batchOperator = _operator;
        batchFrom = _from;
        _batchIds = _ids;
        _batchAmounts = _amounts;
        batchData = _data;

        return ERC1155TokenReceiver.onERC1155BatchReceived.selector;
    }
}