module closest_match::utils{
    // public(friend) fun get_global_resource_address();
    // public(friend) fun get_pool_resource_address();
    // public(friend) fun get_match_state_resource_address();
    // public(friend) fun get_player_state_resource_address();
    friend closest_match::game;
    use aptos_std::math64;
    use std::vector;

    //In group of 13s
    public(friend) fun get_card_difference(v1: u8, v2: u8): u8{
        let v1mod=v1%13;
        let v2mod=v2%13;
        if (v1mod > v2mod){
            return v1mod-v2mod
        };
        v2mod-v1mod
    }

    public(friend) fun get_u64_from_vec_le(vec: &vector<u8>, l: u64 ): u64 {
        let multiplier=256;
        let total=0;
        for (i in 0..math64::min(vector::length(vec),l)) {
            let val=vector::borrow(vec, i);
            let increment=math64::pow(multiplier,i);
            total=total+increment*(*val as u64);
        };
        total
    }
     
}