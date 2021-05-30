//From move-prover

public fun pay_from_sender(payee: address, amount: u64) acquires T {
    Transaction::assert(payee != Transaction::sender(), 1); // new!
    if (!exists<T>(payee)) {
        Self::create_account(payee);
    };
    Self::deposit(payee,Self::withdraw_from_sender(amount),);
}
spec fun pay_from_sender {
    //...omitted aborts_ifs...
    aborts_if amount == 0;
    aborts_if global<T>(sender()).balance.value < amount;
    ensures exists<T>(payee);
    ensures global<T>(sender()).balance.value
        == old(global<T>(sender()).balance.value) - amount;
}