<a name="@Function_pay_from_sender"></a>

## Function `pay_from_sender`
### Summary
Pay the money from the sender
### Spec
```rust
aborts_if amount == 0;
aborts_if global<T>(sender()).balance.value < amount;
ensures exists<T>(payee);
ensures global<T>(sender()).balance.value
    == old(global<T>(sender()).balance.value) - amount;
```