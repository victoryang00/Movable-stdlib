module Transaction {
    use 0x1::Signer ;
    use 0x789::Coin ;
    use 0x789::Game ;
    public fun main1 ( account : & signer ) {
        Coin::init ( account );
        Game::join_game ( account );
    }
    spec fun main1 {
        moves_to global < Coin::T >( Signer::spec_address_of ( account ));
        moves_to global < Game::PlayerState >( Signer::spec_address_of (
        account ));
        modifies global < Coin::T >( Game::owner () );
        aborts_if true ; 
    } 
}
module Game {
    use 0x1::Signer ;
    use 0x789::Coin ;
    spec module {
        define owner () : address { 0x12345 }
        define sender ( account : signer ): address {Signer::spec_address_of ( account ) } 
    }
    resource struct PlayerState {
            alive : bool ,
            strength : u64
    }

    public fun join_game ( account : & signer ) {
        // Without this check , the postconditions are incorrect
        if ( Signer::address_of ( account ) == 0x12345 ) {
            abort 100
        };
        let coin = Coin::withdraw ( account , 50) ;
        Coin::deposit (0x12345 , coin );
        move_to < PlayerState >( account , PlayerState {
            alive : true ,
            strength : 100
        })
    }
    spec fun join_game {
        aborts_if Signer::spec_address_of ( account ) == owner () ;
        moves_to global < PlayerState >( sender ( account )) ;
        modifies global < Coin::T >( sender ( account ) );
        modifies global < Coin::T >( owner () );
        aborts_if ! exists < Coin::T >( sender ( account ));
        aborts_if Coin::value ( global < Coin::T >( sender ( account ))) < 50;
        aborts_if ! exists < Coin::T >( owner () );
        aborts_if Coin::value ( global < Coin::T >( owner () ) ) > max_u64 () - 50;
        aborts_if exists < PlayerState >( sender ( account )) ;
        ensures exists < Coin::T >( sender ( account ));
        ensures exists < Coin::T >( owner () );
        ensures exists < PlayerState >( sender ( account ));
        ensures Coin::value (global < Coin::T >( owner () )) == old ( Coin::value
            ( global < Coin::T >( owner () )) ) + 50;
        ensures Coin::value (global < Coin::T >( sender ( account )) ) == old (
            Coin::value ( global < Coin::T >( sender ( account )) )) - 50;
        ensures global < PlayerState >( sender ( account )).alive ;
        ensures global < PlayerState >( sender ( account )).strength == 100;
    }
    public fun donate_strength ( account : &signer , beneficiary : address )
        acquires PlayerState {
            // Without this check , the postconditions are incorrect
            if ( Signer::address_of ( account ) == beneficiary ) {
                abort 100
            };
            let old_strength = borrow_global < PlayerState >( Signer::address_of
                ( account )).strength ;
            let ben_strength_ref = & mut borrow_global_mut < PlayerState >(
                beneficiary ).strength ; * ben_strength_ref = * ben_strength_ref + old_strength ;
            let sender_strength_ref = & mut borrow_global_mut < PlayerState >(
                Signer::address_of ( account )).strength ; * sender_strength_ref = 0;
        }
        spec fun donate_strength {
            aborts_if Signer::spec_address_of ( account ) == beneficiary ;
            modifies global < PlayerState >( Signer::spec_address_of ( account )).
                strength ;
            modifies global < PlayerState >( beneficiary ).strength ;
                aborts_if ! exists < PlayerState >( Signer::spec_address_of ( account ))
                ;
            aborts_if ! exists < PlayerState >( beneficiary );
            aborts_if global < PlayerState >( Signer::spec_address_of ( account )).
            strength + global < PlayerState >( beneficiary ).strength >
                max_u64 () ;
            ensures exists < PlayerState >( Signer::spec_address_of ( account )) ;
            ensures exists < PlayerState >( beneficiary );
            ensures global < PlayerState >( Signer::spec_address_of ( account )).
                strength == 0;
            ensures global < PlayerState >( beneficiary ).strength
                == old ( global < PlayerState >( beneficiary ).strength ) + old( global < PlayerState >( Signer::spec_address_of ( account )).
                strength ) ;
        } 
    }
    module Coin {
        use 0x1::Signer ;
        resource struct T {
            amount : u64
        }
        public fun zero () : T { T {
            amount : 0
        } }
        spec fun zero {
            aborts_if false ;
            ensures value ( result ) == 0;
        }
        public fun init ( account : & signer ) {
            move_to <T >( account , T {
            amount : 0
        }) ;
    }
    spec fun init {
        aborts_if exists <T >( Signer::spec_address_of ( account ));
        moves_to global <T >( Signer::spec_address_of ( account ));
        ensures global <T >( Signer::spec_address_of ( account )).amount == 0;
        }
        public fun withdraw ( account : & signer , amount : u64 ): T acquires T {
        let t_ref = borrow_global_mut <T >( Signer::address_of ( account ));
        if ( t_ref.amount < amount ) {
            abort 100
        };
        t_ref.amount = t_ref.amount - amount ; T {
            amount : amount
        } 
    }
    spec fun withdraw {
        modifies global <T >( Signer::spec_address_of ( account )).amount ;
        aborts_if ! exists <T >( Signer::spec_address_of ( account ));
        aborts_if value ( global <T >( Signer::spec_address_of ( account )) ) <
            amount ;
        ensures exists <T >( Signer::spec_address_of ( account ));
        ensures value ( global <T >( Signer::spec_address_of ( account ) )) ==
            old ( value ( global <T >( Signer::spec_address_of ( account ) ))) -
            amount ;
        ensures value ( result ) == amount ; }
        public fun deposit ( receiver : address , coin : T) acquires T {
            let T { amount } = coin ;
            let t_ref = borrow_global_mut <T >( receiver );
            t_ref.amount = t_ref.amount + amount ; 
        }
        spec fun deposit {
            modifies global <T >( receiver ).amount ;
            aborts_if ! exists <T >( receiver );
            aborts_if value ( global <T >( receiver )) + value ( coin ) > max_u64 () ;
            ensures value ( global <T >( receiver ) ) == old ( value ( global <T >(
                receiver ) )) + value ( coin ) ;
        }
    }
}