module closest_match::game_randomness{
    use aptos_framework::randomness;
    use std::vector;
    friend closest_match::game;

    
    public(friend) fun get_random_value(end_limit: u64):u64 {
        randomness::u64_range(0, end_limit)
    } 


    public(friend) fun draw_cards(deck: &mut vector<u8>, count: u8):vector<u8>{

        let drawn_cards=vector::empty();
        for (i in 0..count){
            let size= vector::length(deck) ;
            let card=get_random_value(size);
            //let card=0;
            vector::push_back(&mut drawn_cards, vector::remove(deck,card));
        };

        drawn_cards
    }

    #[test_only]
    friend closest_match::game_tests;

    #[test_only]
    public fun init_randomness(fx: &signer){
         randomness::initialize_for_testing(fx);
    }

    // #[test]
    // public fun random_test(){
    //     let v=get_random_value(10);
    //     assert!( v < 10 , 1);
    // }
}