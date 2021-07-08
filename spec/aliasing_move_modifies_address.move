// address 0x0 {
module M{
    use 0x1::Signer;
    // Defined Roles for the equalelence to moves_to
    use 0x1::Roles;

    struct U has key { g: u64 }

    struct T has key { f: address }

    struct S has key { h: address }

    public fun foo ( account : & signer , addr1 : address , addr2 : address ) acquires U,S,T{
        // modify the U.g from addr1&2 to 1 and 2
        bar(account,addr1,addr2);
        // modify the U.g in account  to 3
        bar2(account);
    }

    // fun has_role(account: &signer, role_id: u64): bool acquires RoleId {
    //    let addr = Signer::address_of(account);
    //    exists<RoleId>(addr)
    //        && borrow_global<RoleId>(addr).role_id == role_id
    // }
    
    spec fun foo {
        // check the addr and acount and their resource exist.
        aborts_if exists <U>( Signer::spec_address_of ( account ));
        aborts_if !exists <T>( addr1 );
        aborts_if !exists <U>( global <T>( addr1 ).f) && global <T>( addr1 ).f
            != Signer::spec_address_of ( account );
        aborts_if !exists <S>( addr2 );
        aborts_if !exists <U>( global <S>( addr2 ).h) && global <S>( addr2 ).h
            != Signer::spec_address_of ( account );
        aborts_if !exists <U>( Signer::spec_address_of ( account ));

        // moves_to global <U>( Signer::spec_address_of ( account )); Here means the account has the permission to write
        requires Roles::has_diem_root_role(account);//This is ensured by its write prologue.

        // Specifies U.g is modified by the procedure of addrs respectively.
        modifies global <U>( global <T>( addr1 ).f).g;
        modifies global <U>( global <S>( addr2 ).h).g;

        // Specifies U.g is modified by the procedure of account eventually.
        modifies global <U>( Signer::spec_address_of ( account )).g;

        // Ensure the result of global state of U.g by Signer account is 3.
        ensures global <U>( Signer::spec_address_of ( account )).g == 3;
    }
    public fun bar ( account : &signer , addr1 : address , addr2 : address ) acquires U,S,T{
        move_to ( account, U { g:0 });                       // initialize the account with U.g=0
        borrow_global_mut<U>(borrow_global<T>(addr1).f).g = 1;   // borrow mut from T.f to U.g and change to 1
        borrow_global_mut<U>(borrow_global<S>(addr2).h).g = 2;   // bottow mut from S.h to U.g and change to 2
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
        requires Roles::has_diem_root_role(account);//This is ensured by its write prologue.

        // Specifies U.g is modified by the procedure of addrs respectively.
        modifies global <U>( global <T>( addr1 ).f).g;
        modifies global <U>( global <S>( addr2 ).h).g;

        // Check the signer spec address of account's g is either 0,1 or 2 
        // either runs well means the instruction ran correctly.
        ensures global <U>( Signer::spec_address_of ( account )).g == 0
            || global <U>( Signer::spec_address_of ( account )).g == 1
            || global <U>( Signer::spec_address_of ( account )).g == 2;
    }
    fun bar2 ( account : & signer ) acquires U{
        borrow_global_mut<U>( Signer::address_of ( account )).g =3;
    }
    spec fun bar2 {
        // Specifies U.g is modified by the procedure of addrs respectively.
        modifies global <U>( Signer::spec_address_of ( account ));
        aborts_if !exists <U>( Signer::spec_address_of ( account ));

        // Check the signer spec adddres of account's g is 1+2
        ensures global <U>( Signer::spec_address_of ( account )).g == 3;
    } 
}