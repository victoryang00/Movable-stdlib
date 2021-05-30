<a name="module_Transaction"></a>

# Module `Transaction` from Vyper

This module do the aliasing move and modifies addresses.

-  [Function `main1`](#Function_main1)
    -  [Summary](#)
    -  [Spec](#)

```rust
use 0x1::Signer ;
use 0x789::Coin ;
use 0x789::Game ;
```

<a name="@Function_main1"></a>

## Function `main1`

### Summary
Init the coin in the account and join the game.
```rust
Coin::init ( account );
Game::join_game ( account );
```
### Specification
```rust
moves_to global < Coin::T >(Signer::spec_address_of ( account ));
moves_to global < Game::PlayerState >(Signer::spec_address_of (
account ));
modifies global < Coin::T >( Game::owner () );
aborts_if true ; 
```

# Module `Game` from Vyper

-  [Function `join_game`](#Function_join_game)
    -  [Summary](#)
    -  [Spec](#)
-  [Function `donate_strength`](#Function_donate_strength)
    -  [Summary](#)
    -  [Spec](#)
```rust
use 0x1::Signer ;
use 0x789::Coin ;
resource struct PlayerState {
    alive : bool ,
    strength : u64
}
```
## Module Specification
```rust
define owner () : address { 0x12345 }
define sender ( account : signer ): address{Signer::spec_address_of ( account ) } 
```
<a name="@Function_join_game"></a>

## Function `join_game`
### Summary
Move the withdrawned coin to the Player. Change the player state.
```rust
 // Without this check , the postconditions are incorrect
 if ( Signer::address_of ( account ) == 0x12345 ) {
     abort 100
 };
 ```
### Specification
```rust
aborts_if Signer::spec_address_of ( account ) == owner () ;
moves_to global < PlayerState >( sender ( account )) ;
modifies global < Coin::T >( sender ( account ) );
modifies global < Coin::T >( owner () );
aborts_if ! exists < Coin::T >( sender ( account ));
aborts_if Coin::value ( global < Coin::T >( sender (account ))) < 50;
aborts_if ! exists < Coin::T >( owner () );
aborts_if Coin::value ( global < Coin::T >( owner () ) )> max_u64 () - 50;
aborts_if exists < PlayerState >( sender ( account )) ;
ensures exists < Coin::T >( sender ( account ));
ensures exists < Coin::T >( owner () );
ensures exists < PlayerState >( sender ( account ));
ensures Coin::value (global < Coin::T >( owner () )) ==old ( Coin::value ( global < Coin::T >( owner () )) ) + 50;
ensures Coin::value (global < Coin::T >( sender ( account)) ) == old (Coin::value ( global < Coin::T >( sender ( account )) )) - 50;
ensures global < PlayerState >( sender ( account )).alive;
ensures global < PlayerState >( sender ( account ))strength == 100;
```
<a name="@Function_donate_strength"></a>

## Function `donate_strength`
### Summary
Change the state of the donating player and update the state fort the donated player.
```rust
// Without this check , the postconditions are incorrect
if ( Signer::address_of ( account ) == beneficiary ) {
    abort 100
};
```
### Spec
```
aborts_if Signer::spec_address_of ( account ) ==beneficiary ;
modifies global < PlayerState >(Signer::spec_address_of ( account )).
    strength ;
modifies global < PlayerState >( beneficiary )strength ;
    aborts_if ! exists < PlayerState >( Signer::spec_address_of ( account ))
    ;
aborts_if ! exists < PlayerState >( beneficiary );
aborts_if global < PlayerState >(Signer::spec_address_of ( account )).
strength + global < PlayerState >( beneficiary )strength >
    max_u64 () ;
ensures exists < PlayerState >(Signer::spec_address_of ( account )) ;
ensures exists < PlayerState >( beneficiary );
ensures global < PlayerState >(Signer::spec_address_of ( account )).
    strength == 0;
ensures global < PlayerState >( beneficiary ).strength
    == old ( global < PlayerState >( beneficiary ).strength ) + old( global < PlayerState >( Signer::spec_address_of ( account )).
    strength ) ;
```
# Module `Coin` from Vyper

-  [Function `zero`](#Function_zero)
    -  [Summary](#)
    -  [Spec](#)
-  [Function `init`](#Function_init)
    -  [Summary](#)
    -  [Spec](#)
-  [Function `withdraw`](#Function_withdraw)
    -  [Summary](#)
    -  [Spec](#)
-  [Function `deposit`](#Function_deposit)
    -  [Summary](#)
    -  [Spec](#)
```
use 0x1::Signer ;
resource struct T {
    amount : u64
}
```

<a name="@Function_zero"></a>

## Function `zero`
### Summary
Init with zero.
### Specification
```rust
aborts_if false ;
ensures value ( result ) == 0;
```
<a name="@Function_init"></a>

## Function `init`
### Summary

```rust
aborts_if exists <T >( Signer::spec_address_of ( account );
moves_to global <T >( Signer::spec_address_of ( account );
ensures global <T >( Signer::spec_address_of ( account ))amount == 0;
```

<a name="@Function_withdraw"></a>

## Function `withdraw`
### Summary
Update the resource of the passed address.
### Specification

```rust
modifies global <T >( Signer::spec_address_of ( account )).amount ;
aborts_if ! exists <T >( Signer::spec_address_of ( account ));
aborts_if value ( global <T >( Signer::spec_address_of ( account )) ) <
    amount ;
ensures exists <T >( Signer::spec_address_of ( account ));
ensures value ( global <T >( Signer::spec_address_of ( account ) )) ==
    old ( value ( global <T >( Signer::spec_address_of ( account ) ))) -
    amount ;
ensures value ( result ) == amount ; 
```

<a name="@Function_deposit"></a>

## Function `deposit`
### Summary
Update the resource of the passed address.
### Specification
```
modifies global <T >( receiver ).amount ;
aborts_if ! exists <T >( receiver );
aborts_if value ( global <T >( receiver )) + value ( coin ) >max_u64 () ;
ensures value ( global <T >( receiver ) ) == old ( value (global <T >(receiver ) )) + value ( coin ) ;
```