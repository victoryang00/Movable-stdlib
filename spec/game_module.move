module Game {
    use 0x1::Signer;
    
    resource struct Player {
        strength : u64 ,
        alive : bool
    }

    // donates the donor 's strength to the beneficiary
    public fun donate ( donor : & signer , beneficiary : address ) acquires
        Player {
        // read donor strength
        let donor_ref : & Player = borrow_global < Player >( Signer ::
            address_of ( donor ));
        let donor_strength = get_strength ( donor_ref );
        // read beneficiary strength
        let beneficiary_ref : & Player = borrow_global < Player >( beneficiary
            );
        let beneficiary_strength = get_strength ( beneficiary_ref );
        // calculate new strength
        let new_strength = donor_strength + beneficiary_strength ;
        // set beneficiary strength to new strength
        let mut_beneficiary_ref : & mut Player = borrow_global_mut < Player
            >( beneficiary );
        mut_beneficiary_ref.strength = new_strength ;
        // set donor strength to zero
        let mut_donor_ref : & mut Player = borrow_global_mut <Player >(
            Signer::address_of ( donor )) ;
        mut_donor_ref.strength = 0;
        }
    spec fun donate {
        modifies global < Player >( Signer::spec_address_of ( donor ) ).strength
            ;
        modifies global < Player >( beneficiary ).strength ;
        aborts_if ! exists < Player >( Signer::spec_address_of ( donor ));
        aborts_if ! exists < Player >( beneficiary );
        aborts_if global < Player >( Signer::spec_address_of ( donor ) ).
            strength + global < Player >( beneficiary ).strength > max_u64 () ;
        
        ensures Signer::spec_address_of ( donor ) != beneficiary == >
            ( global < Player >( Signer::spec_address_of ( donor )).strength ==
                0 &&
            global <Player >( beneficiary ).strength == old ( global <Player >(
                beneficiary ).strength ) 
               + old( global < Player >( Signer::spec_address_of ( donor )).
                    strength ) );
        ensures Signer::spec_address_of ( donor ) == beneficiary == >
            ( global < Player >( Signer::spec_address_of ( donor )).strength ==
                0) ;
        ensures sum < Player >().strength <= old (sum < Player >().strength );
    }
    fun get_strength ( player : & Player ): u64 {
        player.strength
    }
    spec fun get_strength {
        ensures result == player.strength ; 
    } 
}