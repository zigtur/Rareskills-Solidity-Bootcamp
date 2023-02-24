# Week2 notes
## Exercise 1

### GAS FIGHT - Bitmap VS Mapping

With the bitmap, the result using foundry gas report is:

| src/MyNFT-MerkleTree-presale.sol:MyOwnNFTCollection contract |                 |       |        |       |         |
|--------------------------------------------------------------|-----------------|-------|--------|-------|---------|
| Deployment Cost                                              | Deployment Size |       |        |       |         |
| 1514451                                                      | 8108            |       |        |       |         |
| Function Name                                                | min             | avg   | median | max   | # calls |
| balanceOf                                                    | 2678            | 2678  | 2678   | 2678  | 2       |
| discountPrice                                                | 306             | 306   | 306    | 306   | 3       |
| mintPrice                                                    | 262             | 262   | 262    | 262   | 1       |
| ownerOf                                                      | 558             | 963   | 558    | 2583  | 5       |
| presaleMint                                                  | 1772            | 34138 | 54414  | 54918 | 5       |
| selfMint                                                     | 47505           | 47505 | 47505  | 47505 | 1       |
| tokenURI                                                     | 2123            | 2123  | 2123   | 2123  | 1       |



Now, using a mapping, we obtain this result:

| src/MyNFT-MerkleTreeMapping-presale.sol:MyOwnNFTCollectionMapping contract |                 |       |        |       |         |
|----------------------------------------------------------------------------|-----------------|-------|--------|-------|---------|
| Deployment Cost                                                            | Deployment Size |       |        |       |         |
| 1374272                                                                    | 7718            |       |        |       |         |
| Function Name                                                              | min             | avg   | median | max   | # calls |
| balanceOf                                                                  | 2678            | 2678  | 2678   | 2678  | 2       |
| discountPrice                                                              | 306             | 306   | 306    | 306   | 3       |
| mintPrice                                                                  | 262             | 262   | 262    | 262   | 1       |
| ownerOf                                                                    | 558             | 963   | 558    | 2583  | 5       |
| presaleMint                                                                | 1772            | 44193 | 71286  | 71790 | 5       |
| selfMint                                                                   | 47505           | 47505 | 47505  | 47505 | 1       |
| tokenURI                                                                   | 2123            | 2123  | 2123   | 2123  | 1       |


If we closely look at the presaleMint function, we have those results:
| Technique used for tickets | avg gas | median gas | max gas |
|----------------------------|---------|------------|---------|
| Bitmap                     | 34138   |  54414     | 54918   |
| Mapping                    | 44193   | 71286      | 71790   |

So, the **bitmap** technique is the **WINNER!!!**


### GAS FIGHT - Array manipulation VS assembly storage slot manipulation
We will look at the presaleMint function. Jeffrey explains that assembly storage slot manipulation will be more gas efficient than array manipulation. I trust him, but... **I NEED TO TEST IT!!!**

We obtain the following results:
| Technique used for tickets         | avg gas | median gas | max gas |
|------------------------------------|---------|------------|---------|
| Array manipulation                 | 33952   | 54155      | 54659   |
| assembly storage slot manipulation | 33449   | 52525      | 54525   |

And the winner is... **ASSEMBLY!!!**



