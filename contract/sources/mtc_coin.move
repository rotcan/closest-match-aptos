module closest_match::mtc_coin {
    use std::signer;
    use aptos_framework::object;
    use aptos_framework::primary_fungible_store;
    use aptos_framework::fungible_asset::{Self};
    use std::option;
    use std::error;
    use aptos_framework::account;
    use std::string::{Self};

    const ERROR_ACCOUNT_DOES_NOT_EXIST: u64=1;
    const COIN_TITLE: vector<u8> = b"Mtc";
    const MAX_SUPPLY: u128 = 1_000_000_000*1_000_000_000;
    const COIN_NAME: vector<u8> = b"Mtc";
    const COIN_SYMBOL: vector<u8> = b"Mtc";
    const COIN_DECIMALS: u8 = 9;
    const COIN_URI: vector<u8> = b"https://ipfs.io/ipfs/QmUHhBAnafJmywjSxFsZWobTC636vZfVTMsw6kzNHg7PVA";
    const PROJECT_URI: vector<u8> = b"https://rotcan.github.io/";
    
    const E_ADMIN_ADDRESS_MISMATCH: u64=1;
    const E_AIRDROP_NOT_ALLOWED: u64=2;
 
    struct MtcRef has key{
        mint_ref: option::Option<fungible_asset::MintRef>,
        burn_ref: option::Option<fungible_asset::BurnRef>,
        transfer_ref: option::Option<fungible_asset::TransferRef>
    }

    struct MtcToken has key {}

    struct AdminAccount has key{
        resource_address: address,
        signer_cap: account::SignerCapability,
        allow_airdrop: bool,
    }

    fun init_module(admin: &signer){
        let admin_address=signer::address_of(admin);
        assert!(@admin_addr==admin_address, error::permission_denied(E_ADMIN_ADDRESS_MISMATCH));

        let creator_ref = object::create_named_object(admin, COIN_TITLE);
        let object_signer = object::generate_signer(&creator_ref);

        move_to(&object_signer, MtcToken{});

        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            &creator_ref,
            option::some(MAX_SUPPLY),
            string::utf8(COIN_NAME),
            string::utf8(COIN_SYMBOL),
            COIN_DECIMALS,
            string::utf8(COIN_URI),
            string::utf8(PROJECT_URI),
        );   

        let (resource_signer, signer_cap) = account::create_resource_account(admin,COIN_NAME);
        let resource_signer_from_cap=account::create_signer_with_capability(&signer_cap);
        
        move_to(admin, AdminAccount{
            resource_address : signer::address_of(&resource_signer),
            signer_cap: signer_cap,
            allow_airdrop: true,
        });

        move_to(&resource_signer_from_cap, MtcRef{
            mint_ref: option::some(fungible_asset::generate_mint_ref(&creator_ref)),
            burn_ref: option::some(fungible_asset::generate_burn_ref(&creator_ref)),
            transfer_ref:  option::some(fungible_asset::generate_transfer_ref(&creator_ref))
        });

    }

    public entry fun mint_to(admin: &signer, to_address: address, amount: u64 ) acquires MtcRef{
        let admin_address=signer::address_of(admin);
        let mtc_ref=borrow_global<MtcRef>(admin_address);
        // let coin_address=object::create_object_address(&admin_address,COIN_TITLE);
        // let mtc_obj=object::address_to_object<MtcToken>(coin_address);
        assert!(account::exists_at(to_address),error::permission_denied(ERROR_ACCOUNT_DOES_NOT_EXIST));
        primary_fungible_store::mint(option::borrow(&mtc_ref.mint_ref), to_address,amount)
    }

    public entry fun airdrop(to_address: address, amount: u64) acquires MtcRef, AdminAccount{
        let admin_account=borrow_global<AdminAccount>(@admin_addr);
        assert!(admin_account.allow_airdrop, E_AIRDROP_NOT_ALLOWED);
        let mtc_ref=borrow_global<MtcRef>(admin_account.resource_address);
        assert!(account::exists_at(to_address),error::permission_denied(ERROR_ACCOUNT_DOES_NOT_EXIST));
        primary_fungible_store::mint(option::borrow(&mtc_ref.mint_ref), to_address,amount)
    }

    public entry fun transfer_to(from: &signer, coin_address: address, to: address, amount: u64) {
        // std::debug::print<u8>(&62);
        // std::debug::print<address>(&coin_address);
        let mtc_obj = object::address_to_object<MtcToken>(coin_address);

        primary_fungible_store::transfer(from, mtc_obj, to, amount);
    }

    public fun balance(wallet: address, coin_address: address): u64 {
        let mtc_obj = object::address_to_object<MtcToken>(coin_address);

        primary_fungible_store::balance(wallet, mtc_obj)
    }

    #[view]
    public fun get_coin_address(): address{
        object::create_object_address(&@admin_addr, COIN_TITLE)
    }

    #[test_only]
    use aptos_framework::account::create_account_for_test;
    #[test_only]
    public fun setup_test(admin: &signer){
        init_module(admin);
    }

    #[test_only]
    public fun mint_coins( to_addr: address, val: u64) acquires MtcRef,AdminAccount{
        //let coin_address=object::create_object_address(&signer::address_of(admin),COIN_TITLE);
        //std::debug::print<address>(&coin_address);
        //mint_to(admin, to_addr, val);
        airdrop( to_addr, val);
    }

    #[test_only]
    public fun get_balance(admin_address: address, to_addr: address): u64{
        let coin_address = object::create_object_address(&admin_address, COIN_TITLE);
        let mtc_obj = object::address_to_object<MtcToken>(coin_address);
        primary_fungible_store::balance(to_addr,mtc_obj)
    }

    #[test(admin=@0x123,bob=@0x345, alice=@0x234)]
    public fun test_transfer(admin: &signer, bob: &signer, alice: &signer) acquires MtcRef,AdminAccount{
        create_account_for_test(signer::address_of(admin));
        create_account_for_test(signer::address_of(bob));
        create_account_for_test(signer::address_of(alice));
        setup_test(admin);
        let admin_address = signer::address_of(admin);
        let coin_address = object::create_object_address(&admin_address, COIN_TITLE);
        // std::debug::print<address>(&coin_address);
        //let mtc_ref=borrow_global<MtcRef>(admin_address);
        let mtc_obj = object::address_to_object<MtcToken>(coin_address);
        //primary_fungible_store::mint(option::borrow(&mtc_ref.mint_ref),admin_address,100);
        airdrop( admin_address, 100);
        assert!(primary_fungible_store::balance(admin_address,mtc_obj) == 100, 1);
        primary_fungible_store::transfer(admin, mtc_obj, signer::address_of(bob), 25);
        assert!(primary_fungible_store::balance(admin_address,mtc_obj) == 75, 2);
        assert!(primary_fungible_store::balance(signer::address_of(bob),mtc_obj) == 25, 3);
        airdrop( signer::address_of(alice), 120);
        assert!(primary_fungible_store::balance(signer::address_of(alice),mtc_obj) == 120, 4);
    }
}