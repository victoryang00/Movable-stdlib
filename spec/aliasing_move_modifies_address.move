address 0x0 {
module M{
    use 0x1::Signer;

    resource struct U { g: u64 }

    resource struct T{ f: address }

    resource struct S{ h: address }

    public fun foo ( account : & signer , addr1 : address , addr2 : address )
        acquires S, T, U {
        bar ( account , addr1 , addr2 );
        bar2 ( account );
    }

    spec fun foo {
        aborts_if exists <U>( Signer::spec_address_of ( account ));
        aborts_if !exists <T>( addr1 ) ;
        aborts_if !exists <U>( global <T>( addr1 ).f) && global <T>( addr1 ).f
            != Signer::spec_address_of ( account );
        aborts_if !exists <S>( addr2 ) ;
        aborts_if !exists <U>( global <S>( addr2 ).h) && global <S>( addr2 ).h
            != Signer::spec_address_of ( account );
        aborts_if !exists <U>( Signer::spec_address_of ( account ));
        // moves_to global <U>( Signer::spec_address_of ( account ));
        modifies global <U>( global <T>( addr1 ).f).g;
        modifies global <U>( global <S>( addr2 ).h).g;
        modifies global <U>( Signer::spec_address_of ( account )).g;
        ensures global <U>( Signer::spec_address_of ( account )).g == 3;
    }
    public fun bar ( account : &signer , addr1 : address , addr2 : address )
        acquires S, T, U {
        move_to <U>( account , U { g: 0 }) ;
        let g1 = borrow_global_mut<U>( borrow_global <T>( addr1 ).f).g; //acquires needed
        let g2 = borrow_global_mut<U>( borrow_global <S>( addr2 ).h).g;   //acquires needed
    }
    spec fun bar {
        /// check wither the U is in account
        aborts_if exists <U>( Signer::spec_address_of ( account ));
        /// check wither the T addr1 exists
        aborts_if !exists <T>( addr1 ) ;
        /// check After the above check
        aborts_if exists <U>( Signer::spec_address_of ( account ));
        /// check the item in addr1 global T is different from account address
        aborts_if !exists <U>( global <T>( addr1 ).f) && global <T>( addr1 ).f
            != Signer::spec_address_of ( account );
        /// check wither the S addr2 exists
        aborts_if !exists <S>( addr2 ) ;
        /// check the item in addr1 global S is different from account address
        aborts_if !exists <U>( global <S>( addr2 ).h) && global <S>( addr2 ).h
            != Signer::spec_address_of ( account );
        // moves_to global <U>( Signer::spec_address_of ( account ));
        modifies global <U>( global <T>( addr1 ).f).g;
        modifies global <U>( global <S>( addr2 ).h).g;
        ensures global <U>( Signer::spec_address_of ( account )).g == 0
            || global <U>( Signer::spec_address_of ( account )).g == 1
            || global <U>( Signer::spec_address_of ( account )).g == 2;
    }
    fun bar2 ( account : & signer ) acquires U {
        borrow_global_mut<U>( Signer :: address_of ( account )).g;
    }
    spec fun bar2 {
        modifies global <U>( Signer::spec_address_of ( account ));
        aborts_if !exists <U>( Signer::spec_address_of ( account ));
        ensures global <U>( Signer::spec_address_of ( account )).g == 3;
    } 
}
}