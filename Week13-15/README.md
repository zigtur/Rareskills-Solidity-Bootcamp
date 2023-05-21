# ERC-1155 in Yul

Here is the list of what is does:
- :white_check_mark: Mint tokens
- :white_check_mark: Get token balance for account
- :x: Transfer hooks


List of supported functions (ERC-1155 standard):
- :white_check_mark: balanceOf(address account, uint256 id)
- :white_check_mark: balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
- :white_check_mark: setApprovalForAll(address _operator, bool _approved)
- :white_check_mark: isApprovedForAll(address _owner, address _operator)
- :white_check_mark: safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data)
- :x: safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data)

List of non-standard functions:
- :white_check_mark: mint(address to, uint256 id, uint256 amount)