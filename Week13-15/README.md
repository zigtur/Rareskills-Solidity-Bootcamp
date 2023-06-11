# ERC-1155 in Yul


Need to:
- Add comments for revert strings (it is in hex)
- Shift one bit instead of multiply by 2
- call `iszero` instead of `eq`
- do a function with multiple emits
- remove zeros in revert messages (need to modify revert)

- :x: string encoding for URI need to be implemented

List of supported functions (ERC-1155 standard):
- :white_check_mark: balanceOf(address account, uint256 id)
- :white_check_mark: balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
- :white_check_mark: setApprovalForAll(address _operator, bool _approved)
- :white_check_mark: isApprovedForAll(address _owner, address _operator)
- :white_check_mark: safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data)
- :white_check_mark: safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data)

List of non-standard functions:
- :white_check_mark: mint(address to, uint256 id, uint256 amount)
- :white_check_mark: mint(address to, uint256 id, uint256 amount, bytes calldata data)
- :white_check_mark: batchMint(address to, uint256 id, uint256 amount)
- :white_check_mark: batchMint(address to, uint256 id, uint256 amount, bytes calldata data)

# ERC-1155 in Huff

List of supported functions (ERC-1155 standard):
- :white_check_mark: balanceOf(address account, uint256 id)
- :x: balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
- :x: setApprovalForAll(address _operator, bool _approved)
- :x: isApprovedForAll(address _owner, address _operator)
- :x: safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data)
- :x: safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data)

List of non-standard functions:
- :white_check_mark: mint(address to, uint256 id, uint256 amount)
- :white_check_mark: mint(address to, uint256 id, uint256 amount, bytes calldata data)
- :x: batchMint(address to, uint256 id, uint256 amount)
- :x: batchMint(address to, uint256 id, uint256 amount, bytes calldata data)

