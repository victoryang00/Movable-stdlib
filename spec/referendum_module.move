module Referendum {
    use 0x1 :: Signer ;
    spec module {
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
    }

    resource struct Counter {
        in_favour : u64 ,
        against : u64
    }
    resource struct VoteToken {}

    public fun init ( account : & signer ) {
        if ( Signer :: address_of ( account ) != 0x12345678 ) {
            abort 100
        };
        move_to < Counter >( account , Counter {
            in_favour : 0,
            against : 0
        }) ;
    }
    spec fun init {
        moves_to global < Counter >(0x12345678 ) ;
        aborts_if Signer :: spec_address_of ( account ) != 0x12345678 ;
        aborts_if exists < Counter >(0x12345678 ) ;
        ensures exists < Counter >(0x12345678 );
        ensures global < Counter >(0x12345678 ).in_favour == 0;
        ensures global < Counter >(0x12345678 ).against == 0;
    }
    public fun vote ( account : & signer , in_favour : bool ) acquires Counter {
        let counter_ref = borrow_global_mut < Counter >(0x12345678 );
        if ( in_favour ) {
            counter_ref.in_favour = counter_ref.in_favour + 1;
        } else {
            counter_ref.against = counter_ref.against + 1;
        };
        move_to < VoteToken >( account , VoteToken { }) ;
    }
    spec fun vote {
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
    } 
}