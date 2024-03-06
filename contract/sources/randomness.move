module closest_match::randomness{
    use aptos_framework::randomness;

    public(friend) fun get_random_value(end_limit: u8):u8 {
        randomness::u8_range(0, end_limit)
    }
}