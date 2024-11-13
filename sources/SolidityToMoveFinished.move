module SolidityToMove::OurFungibleToken {
    use aptos_framework::object::{Self, Object, ExtendRef};
    use aptos_framework::fungible_asset::{Self, MintRef, TransferRef, BurnRef, Metadata, FungibleAsset, FungibleStore };
    use aptos_framework::primary_fungible_store;
    use std::signer;
    use std::option;
    use std::event;
    use std::string::{Self, utf8};


    /* Errors */
    /// The caller is unauthorized.
    const EUNAUTHORIZED: u64 = 1;

    /* Constants */
    const ASSET_NAME: vector<u8> = b"Our Fungible Token";
    const ASSET_SYMBOL: vector<u8> = b"OFT";

    /* Resources */
    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct Management has key {
        mint_ref: MintRef,
        burn_ref: BurnRef,
        transfer_ref: TransferRef,
    }

    /* Events */
    #[event]
    struct Mint has drop, store {
        minter: address,
        to: address,
        amount: u64,
    }

    #[event]
    struct Burn has drop, store {
        minter: address,
        from: address,
        amount: u64,
    }


    /* Initialization - Asset Creation, Register Dispatch Functions */
    fun init_module(deployer: &signer) {
        // Create the fungible asset metadata object. 
        let constructor_ref = &object::create_named_object(deployer, ASSET_SYMBOL);
        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            constructor_ref,
            option::none(),
            utf8(ASSET_NAME), 
            utf8(ASSET_SYMBOL), 
            8, 
            utf8(b"http://example.com/favicon.ico"), 
            utf8(b"http://example.com"), 
        );

        // Generate a signer for the asset metadata object. 
        let metadata_object_signer = &object::generate_signer(constructor_ref);

        // Generate asset management refs and move to the metadata object.
        move_to(metadata_object_signer, Management {
            mint_ref: fungible_asset::generate_mint_ref(constructor_ref),
            burn_ref: fungible_asset::generate_burn_ref(constructor_ref),
            transfer_ref: fungible_asset::generate_transfer_ref(constructor_ref),
        });
    }

    /* Minting and Burning */
    /// Mint new assets to the specified account. 
    public entry fun mint(deployer: &signer, to: address, amount: u64) acquires Management {
        assert_admin(deployer);
        let management = borrow_global<Management>(metadata_address());
        let assets = fungible_asset::mint(&management.mint_ref, amount);
        fungible_asset::deposit_with_ref(&management.transfer_ref, primary_fungible_store::ensure_primary_store_exists(to, metadata()), assets);

        event::emit(Mint {
            minter: signer::address_of(deployer),
            to,
            amount,
        });
    }

    /// Burn assets from the specified account. 
    public entry fun burn(deployer: &signer, from: address, amount: u64) acquires Management {
        assert_admin(deployer);
        // Withdraw the assets from the account and burn them.
        let management = borrow_global<Management>(metadata_address());
        let assets = fungible_asset::withdraw_with_ref(&management.transfer_ref, primary_fungible_store::ensure_primary_store_exists(from, metadata()), amount);
        fungible_asset::burn(&management.burn_ref, assets);

        event::emit(Burn {
            minter: signer::address_of(deployer),
            from,
            amount,
        });
    }

    /* Transfer */
    /// Transfer assets from one account to another. 
    public entry fun transfer(from: &signer, to: address, amount: u64) acquires Management {
        // Withdraw the assets from the sender's store and deposit them to the recipient's store.
        let management = borrow_global<Management>(metadata_address());
        let from_store = primary_fungible_store::ensure_primary_store_exists(signer::address_of(from), metadata());
        let to_store = primary_fungible_store::ensure_primary_store_exists(to, metadata());
        let assets = fungible_asset::withdraw_with_ref(&management.transfer_ref, from_store, amount);

        fungible_asset::deposit_with_ref(&management.transfer_ref, to_store, assets);
    }

    inline fun assert_admin(deployer: &signer) {
        assert!(signer::address_of(deployer) == @SolidityToMove, EUNAUTHORIZED);
    }

    /* View Functions */
    #[view]
    public fun metadata_address(): address {
        object::create_object_address(&@SolidityToMove, ASSET_SYMBOL)
    }

    #[view]
    public fun metadata(): Object<Metadata> {
        object::address_to_object(metadata_address())
    }

    #[view]
    public fun deployer_store(): Object<FungibleStore> {
        primary_fungible_store::ensure_primary_store_exists(@SolidityToMove, metadata())
    }
    
    #[test_only]
    public fun init_for_test(deployer: &signer) {
        init_module(deployer);
    }
}