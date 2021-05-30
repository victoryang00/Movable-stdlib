module M{
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

    public fun foo ( account : & signer , addr1 : address , addr2 : address )
        acquires S, T, U {
        bar ( account , addr1 , addr2 ) ;
        bar2 ( account );
    }

    spec fun foo {
        aborts_if exists <U >( Signer :: spec_address_of ( account ));
        aborts_if ! exists <T >( addr1 ) ;
        aborts_if ! exists <U >( global <T >( addr1 ).f) && global <T >( addr1 ).f
            != Signer :: spec_address_of ( account );
        aborts_if ! exists <S >( addr2 ) ;
        aborts_if ! exists <U >( global <S >( addr2 ).h) && global <S >( addr2 ).h
            != Signer :: spec_address_of ( account );
        aborts_if ! exists <U >( Signer :: spec_address_of ( account ));
        moves_to global <U >( Signer :: spec_address_of ( account ));
        modifies global <U >( global <T >( addr1 ).f).g;
        modifies global <U >( global <S >( addr2 ).h).g;
        modifies global <U >( Signer :: spec_address_of ( account )).g;
        ensures global <U >( Signer :: spec_address_of ( account )).g == 3;
    }
    public fun bar ( account : & signer , addr1 : address , addr2 : address )
        acquires S, T, U {
        move_to <U >( account , U { g: 0 }) ;
        borrow_global_mut <U >( borrow_global <T >( addr1 ).f).g = 1;
        borrow_global_mut <U >( borrow_global <S >( addr2 ).h).g = 2;
    }
    spec fun bar {
        aborts_if exists <U >( Signer :: spec_address_of ( account ));
        aborts_if ! exists <T >( addr1 ) ;
        aborts_if ! exists <U >( global <T >( addr1 ).f) && global <T >( addr1 ).f
            != Signer :: spec_address_of ( account );
        aborts_if ! exists <S >( addr2 ) ;
        aborts_if ! exists <U >( global <S >( addr2 ).h) && global <S >( addr2 ).h
            != Signer :: spec_address_of ( account );
        moves_to global <U >( Signer :: spec_address_of ( account ));
        modifies global <U >( global <T >( addr1 ).f).g;
        modifies global <U >( global <S >( addr2 ).h).g;
        ensures global <U >( Signer :: spec_address_of ( account )).g == 0
            || global <U >( Signer :: spec_address_of ( account )).g == 1
            || global <U >( Signer :: spec_address_of ( account )).g == 2;
    }
    fun bar2 ( account : & signer ) acquires U {
        borrow_global_mut <U >( Signer :: address_of ( account )).g = 3;
    }
    spec fun bar2 {
        modifies global <U >( Signer :: spec_address_of ( account ));
        aborts_if ! exists <U >( Signer :: spec_address_of ( account ));
        ensures global <U >( Signer :: spec_address_of ( account )).g == 3;
    } 
}