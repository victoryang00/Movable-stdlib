<a name="module_Game"></a>

# Module `Game` from Vyper

This module do the aliasing move and modifies addresses.

-  [Function `donate`](#Function_donate)
    -  [Summary](#)
    -  [Spec](#)
-  [Function `get_strength`](#Function_get_strength)
    -  [Summary](#)
    -  [Spec](#)

```rust
use 0x1::Signer;
resource struct Player {
    strength : u64 ,
    alive : bool
}
```

<a name="@Function_donate"></a>

## Function `donate`
### Summary
donates the donor 's strength to the beneficiary
### Specification
```rust
modifies global < Player >(Signer::spec_address_of ( donor ) ).strength
    ;
modifies global < Player >( beneficiary )strength ;
aborts_if ! exists < Player >(Signer::spec_address_of ( donor ));
aborts_if ! exists < Player >( beneficiary );
aborts_if global < Player >(Signer::spec_address_of ( donor ) ).
    strength + global < Player >( beneficiary ).strength > max_u64 () ;

ensures Signer::spec_address_of ( donor ) !=beneficiary == >
    ( global < Player >( Signer::spec_address_of ( donor )).strength ==
        0 &&
    global <Player >( beneficiary ).strength == old ( global <Player >(
        beneficiary ).strength ) 
       + old( global < Player >( Signer::spec_address_of ( donor )).
            strength ) );
ensures Signer::spec_address_of ( donor ) ==beneficiary == >
    ( global < Player >( Signer::spec_address_of ( donor )).strength ==
           0) ;
    ensures sum < Player >().strength <= old (sum < Player >().strength );
```
<a name="@Function_get_strength"></a>

## Function `get_strength`
### Summary
Get the strength from member function of player
### Specification
```rust
ensures result == player.strength; 
```