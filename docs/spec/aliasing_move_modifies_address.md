<a name="module_M"></a>

# Module `M` from Vyper

This module do the aliasing move and modifies addresses.

-  [Function `foo`](#Function_foo)
    -  [Summary](#)
    -  [Spec](#)
-  [Function `bar`](#Function_bar)
    -  [Summary](#)
    -  [Spec](#)
-  [Function `bar2`](#Function_bar2)
    -  [Summary](#)
    -  [Spec](#)

```rust
use 0x1::Signer;
resource struct T{
    f: address
}
resource struct S{
    h: address
}
resource struct U {
    g: u64
}
```

<a name="@Function_foo"></a>

## Function `foo`

### Summary
aquires three resources S, T, U call bar for transactions.
### Specification
```rust
aborts_if exists <U >( Signer :: spec_address_of (account ));
aborts_if ! exists <T >( addr1 ) ;
aborts_if ! exists <U >( global <T >( addr1 ).f) && global <T >( addr1 ).f!= Signer :: spec_address_of ( account );
aborts_if ! exists <S >( addr2 ) ;
aborts_if ! exists <U >( global <S >( addr2 ).h) && global <S >( addr2 ).h != Signer :: spec_address_of ( account );
aborts_if ! exists <U >( Signer :: spec_address_of ( account ));
moves_to global <U >( Signer :: spec_address_of ( account ));
modifies global <U >( global <T >( addr1 ).f).g;
modifies global <U >( global <S >( addr2 ).h).g;
modifies global <U >( Signer :: spec_address_of (account )).g;
ensures global <U >( Signer :: spec_address_of ( account )).g == 3;
```
<a name="@Function_bar"></a>

## Function `bar`

### Summary
acquires S, T, U, move_to account , U { g: 0 }.and modify the borrow of resource T and S to U and value.


### Specification
```rust
aborts_if exists <U >( Signer :: pec_address_of ( account ));
aborts_if ! exists <T >( addr1 ) ;
aborts_if ! exists <U >( global <T >( addr1 ).) && global <T >( addr1 ).f
    != Signer :: spec_address_of ( account );
aborts_if ! exists <S >( addr2 ) ;
aborts_if ! exists <U >( global <S >( addr2 ).) && global <S >( addr2 ).h
    != Signer :: spec_address_of ( account );
moves_to global <U >( Signer :: spec_address_of  account ));
modifies global <U >( global <T >( addr1 ).f).g;
modifies global <U >( global <S >( addr2 ).h).g;
ensures global <U >( Signer :: spec_address_of  account )).g == 0
    || global <U >( Signer :: spec_address_of ( account )).g == 1
    || global <U >( Signer :: spec_address_of ( account )).g == 2;
```

<a name="@Function_bar"></a>

## Function `bar2`
### Summary
Get the signer address and modify the U to the address.

### Specification
```rust
modifies global <U >( Signer :: spec_address_of( account ));
aborts_if ! exists <U >( Signer ::spec_address_of ( account ));
ensures global <U >( Signer :: spec_address_of ( account )).g == 3;
```