### [H-1] Storing the password on-chain makes it visible to anyone, and no longer private.

**Description:** All data stored on-chain is visible to anyone, and can be read directly from the blockchain. The `PasswordStore::s_password` variable is intended to be a private variable and only accessed through the `PasswordStore::getPassword` function, which is intended to be only called by the owner of the contract.

We show one such method of reading any data off chain below.

**Impact:** Anyone can read the private password, severely breaking the functionality of the protocol.

**Proof of Concept:** The below test case shows how anyone can read a password directly from the blockchain.

1. Create a locally running chain 
   ```bash
   anvil
   ```

2. Deploy the contract to the chain 
   ```
   make deploy
   ```

3. Run the storage tool

We use `1` because that's the storage slot of `s_password` in the contract.

   ```
   cast storage <ADDRESS_HERE> 1 --rpc-url http://127.0.0.1:8545
   ```

You'll get an output that looks like this:

`0x6d7950617373776f726400000000000000000000000000000000000000000014`

You can then parse that hex to a string with:

`run cast parse-bytes32-string 0x6d7950617373776f726400000000000000000000000000000000000000000014`

And get an output of:

`myPassword`

**Recommended Mitigation:** Due to this, the overall architecture of the contract should be rethought. One could encrypt the password off-chain, and then store the encrypted password on-chain. This would require the user to remember another password off-chain to decrypt the password. However, you'd also likely want to remove the view function as you wouldn't want the user to accidentally send a transaction with the password that decrypts your password.


### [H-2] `PasswordStore::setPassword` has no access controls, meaning a non-owner could change the password.

**Description:** The `PasswordStore::setPassword` function is set to be an `external` function. However, the NatSpec of the function and overall purpose of the smart contract is that `This function allows only the owner to set a new password`.

```javascript
    function setPassword(string memory newPassword) external {
@>  // @audit - there are no access controls
    s_password = newPassword;
    emit SetNewPassword();
    }
```

**Impact:** Anyone can change/set the password of the contract, severely breaking the contract intended functionality.

**Proof of Concept:** Add the following to the `PasswordStore.t.sol` test file.

<details>
<summary>Code</summary>

```javascript
function test_anyone_can_set_password(address randomAddress) public {
        vm.assume(randomAddress != owner);
        vm.prank(randomAddress);
        string memory expectedPassword = "myNewPassword";
        passwordStore.setPassword(expectedPassword);

        vm.prank(owner);
        string memory actualPassword = passwordStore.getPassword();
        assertEq(actualPassword, expectedPassword);
    }
```

</details>


**Recommended Mitigation:** Add an access control conditional to the `PasswordStore::setPassword` function.

```javascript
if (msg.sender != s_owner){
    revert PasswordStore__NotOwner();
}
```

### [I-1] `PasswordStore::getPassword` NatSpec indicates a parameter that doesn’t exist, causing NatSpec to be incorrect.

**Description:** 

```javascript
    /*
     * @notice This allows only the owner to retrieve the password.
     * @param newPassword The new password to set.
     */
    function getPassword() external view returns (string memory) {
```

The `PasswordStore::getPassword` function signature is `getPassword()` while the NatSpec says it should be `getPassword(string)`.

**Impact:** The NatSpec is wrong.

**Recommended Mitigation:** Remove the incorrect NatSpec line.

```diff
-   * @param newPassword The new password to set.
```