<a name="module_M"></a>

# Module `Referendum` from Vyper

Every account may either vote in favour or against using the vote procedure.
This procedure sends a VoteToken resource to the transaction signer, preventing them from voting again6
.The number of votes in favour and against are counted in a Counter resource at a special address (0x12345678).Before voting begins, the account with this address will need to call the init procedure, which aborts if the account address is unexpected and initialises and
moves to the account a Counter resource otherwise.

## Module Specification
There are three global properties we would like to specify:
- The 0x12345678 address should be special in that it contains the only
vote Counter.For this property we introduce a forall specification that
allows us to reason over the space of all account addresses.
- It is important that accounts are not allowed to vote before the Counter
is initialised.
- To make sure that double voting is prevented, we can compare the
number of VoteToken resources to the votes counted.VoteToken resources are necessarily unique at each address.
In this way we can use the linearity of resources to establish strong guarantees about the behaviour of Move programs which exploit the semantics of
resource types.

```rust
invariant forall a: address : a != 0x12345678 == > ! exists <
    Counter >(a);
invariant count < VoteToken >() > 0 == > exists < Counter >(0x12345678 ) ;
invariant count < VoteToken >() == 0 == > ! exists < Counter >(0x12345678 ) ||
    ( global < Counter >(0x12345678 ).in_favour == 0 && global <
    Counter >(0x12345678 ).against == 0) ;
invariant count < VoteToken >() > 0 == >
    count < VoteToken >() ==
    global < Counter >(0x12345678 ).in_favour +
    global < Counter >(0x12345678 ).against ; 
```

-  [Function `init`](#Function_init)
    -  [Summary](#)
    -  [Spec](#)
-  [Function `vote`](#Function_vote)
    -  [Summary](#)
    -  [Spec](#)

```rust
use 0x1::Signer;
resource struct Counter {
    in_favour : u64 ,
    against : u64
}
resource struct VoteToken {}
```

<a name="@Function_init"></a>

## Function `init`

### Summary
Init the counter and the transaction address.
### Specification
```
moves_to global < Counter >(0x12345678 ) ;
aborts_if Signer :: spec_address_of ( account ) != 0x12345678 ;
aborts_if exists < Counter >(0x12345678 ) ;
ensures exists < Counter >(0x12345678 );
ensures global < Counter >(0x12345678 ).in_favour == 0;
ensures global < Counter >(0x12345678 ).against == 0;
```

<a name="@Function_vote"></a>

## Function `vote`
### Summary
The function to implement vote.
### Specification
```rust
moves_to global < VoteToken >( Signer :: spec_address_of ( account ) );
modifies global < Counter >(0x12345678 ) ;
aborts_if ! exists < Counter >(0x12345678 );
aborts_if exists < VoteToken >( Signer :: spec_address_of ( account ));
aborts_if in_favour && global < Counter >(0x12345678 ).in_favour ==
    max_u64 () ;
aborts_if ! in_favour && global < Counter >(0x12345678 ).against ==
    max_u64 () ;
ensures exists < Counter >(0x12345678 );
ensures in_favour == >
    global < Counter >(0x12345678 ).in_favour ==
    old ( global < Counter >(0x12345678 ).in_favour ) + 1;
ensures in_favour == >
    global < Counter >(0x12345678 ).against ==
    old ( global < Counter >(0x12345678 ).against );
ensures ! in_favour == >
    global < Counter >(0x12345678 ).against ==
    old ( global < Counter >(0x12345678 ).against ) + 1;
ensures ! in_favour == >
    global < Counter >(0x12345678 ).in_favour ==
    old ( global < Counter >(0x12345678 ).in_favour );
```