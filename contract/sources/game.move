module closest_match::game {
    use std::string;
    use std::option;
    use aptos_std::simple_map;
    use std::error;
    //Errors
    const E_MATCH_ALREADY_RUNNING: u64=1;

    //Play state enum
    const MATCH_SETUP: u8 = 1; //match setup
    const MATCH_PLAYER_JOIN: u8 = MATCH_SETUP+1;
    const MATCH_START: u8= MATCH_PLAYER_JOIN +1;
    const MATCH_IN_PROGRESS: u8= MATCH_START +1;
    const MATCH_END: u8= MATCH_IN_PROGRESS +1;

    const GAME_INIT: u8=MATCH_END+ 1; //draw cards
    const GAME_PLAYER_HIDDEN_MOVE: u8= GAME_INIT+1; //Player move
    const GAME_PLAYER_REVEAL: u8=GAME_PLAYER_HIDDEN_MOVE+1;
    const GAME_END: u8=GAME_PLAYER_REVEAL+1;

    const RESOURCE_ADDRESS_SEED=b"closest_match";

    const MIN_PLAYERS: u8=2;
    const MAX_PLAYERS: u8=4;

    use closest_match::mtc_coin;
    //Groth16 values

    //only one current match per player as of now
    //create resource account to store this struct using seed as sender's address
    struct Matches has key,store{
        //so current match is last in vector
        match_states: vector<MatchState>,
    }

    //Resource account, anyone can update this
    struct MatchState has store{
        player_count: u8,
        max_time_between_moves: u64, //forfeit if player leaves before match finishes
        deck_cards: vector<u8>,
        table_cards: vector<u8>,
        active_player: option::Option<address>,
        players: vector<address>,
        pot_value: u64,
        player_points: simple_map::SimpleMap<address, u8>,
        match_state: u8,
        //player_state: simple_map::SimpleMap<address, PlayerState>, //could use map
        game_state: GameState,
    }

    //Resource account, anyone can update this
    struct GameState{
        game_state: u8,
        current_player: u8,
        //player_state: vector<PlayerState>,

    }


    //Only player can update this
    struct PlayerState{
        //addr: address,
        player_moves: vector<PlayerMove>,
        player_cards: vector<u8>,
    }

    struct PlayerMove has drop, store{
        secret: string::String,
        value:  option::Option<string::String>,   
    }

    fun get_coin_address(): address{
        @closest_match
    }

    //Setup match : num of players, pot size, 
    //Use fungible asset for tokens
    //At one time only one match will be active per player
    public entry fun setup_match(sender: &signer, player_count: u8, move_time: u64, pot_value: u64){
        //Create resource account
        let sender_address=signer::address_of(sender);

        //Add new resource
        let matches_resource=get_matches_resource(sender_address);

        //Add new match
        let match_states= matches_resource.match_states;


        if (vector::is_empty(&match_states))
        {
            vector::append(&mut match_states,get_empty_state(player_count,move_time,pot_value) );
        }else{
            let size=vector::length(&match_states);
            let match_state=vector::borrow(&mut match_states, size);

            assert_eq(match_state.match_state == MATCH_END,  error::permission_denied(E_MATCH_ALREADY_RUNNING ));

            vector::append(&mut match_states,get_empty_state(player_count,move_time,pot_value) );
        }
        

        //Create game pot
        if(pot_size > 0 ){
            let coin_address=get_coin_address();
            mtc_coin::transfer_to(sender, coin_address, get_resource_address(sender), pot_value);
        }

        
    }

    inline fun get_resource_address(sender: &signer):address{
        account::create_resource_address(&sender_address, RESOURCE_ADDRESS_SEED)
    }
     
    inline fun get_empty_state( player_count: u8, move_time: u64,pot_value: u64): MatchState{
        MatchState {
            player_count,
            max_time_between_moves: move_time, //forfeit if player leaves before match finishes
            deck_cards: vector::empty(),
            table_cards: vector::empty(),
            active_player: option::none(),
            players: vector::empty(),
            player_points: simple_map::new<address,u8>(),
            match_state: MATCH_SETUP,
            pot_value,
            //player_state: simple_map::SimpleMap<address, PlayerState>, //could use map
            game_state: GameState {
                game_state: GAME_INIT,
                current_player: 0,
                // player_state: vector::empty(),
            },
        }
    }

    inline fun get_matches_resource(sender_address: address): &mut Matches  acquires Matches{
        //move to resource
        let check_resource_address= account::create_resource_address(&sender_address, RESOURCE_ADDRESS_SEED);
        if (!exists<account::Account>(check_resource_address)){
            //create resource account
            let (resource,signer_cap)=account::create_resource_account(&sender_address,RESOURCE_ADDRESS_SEED);
            let resource_address=signer::address_of(resource);
            let signer_from_cap=account::create_signer_with_capability()
            
        }
        if (!exists<Matches>(check_resource_address)){
            move_to(check_resource_address, Matches {
                match_states:: vector::empty(),
            });    
        }

        borrow_global_mut<Matches>(check_resource_address)
    }

    //Join match: all players join , change state to start match
        //On start match -> Deal cards and draw card on table
    //Player 1 plays card
    //Player 2 plays card
    //Player 1 reveals card
    //Player 2 reveals card. Round finishes
        //Update scoring
    //Finish match and distribute winnings if any


}