module MyModule::InsurancePool {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing an insurance pool.
    struct Pool has store, key {
        total_funds: u64,
        payout_amount: u64,
    }

    /// Function to create a new insurance pool.
    public fun create_pool(owner: &signer, payout_amount: u64) {
        let pool = Pool {
            total_funds: 0,
            payout_amount,
        };
        move_to(owner, pool);
    }

    /// Function for members to contribute to the pool or request a payout.
    public fun contribute_or_payout(member: &signer, owner: &signer, amount: u64, request_payout: bool) acquires Pool {
        let pool = borrow_global_mut<Pool>(signer::address_of(owner));

        if (!request_payout) {
            // Contribute to the pool
            let contribution = coin::withdraw<AptosCoin>(member, amount);
            coin::deposit<AptosCoin>(signer::address_of(owner), contribution);
            pool.total_funds = pool.total_funds + amount;
        } else {
            // Request a payout if there are enough funds
            assert!(pool.total_funds >= pool.payout_amount, 1);
            let payout = coin::withdraw<AptosCoin>(owner, pool.payout_amount);
            coin::deposit<AptosCoin>(signer::address_of(member), payout);
            pool.total_funds = pool.total_funds - pool.payout_amount;
        }
    }
}
