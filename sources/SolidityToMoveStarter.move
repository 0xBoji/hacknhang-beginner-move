module SolidityToMove::OurFungibleAsset {
    /* Errors */
    // TODO ...

    /* Constants */
    // TODO token metadata...

    /* Resources */
    // TODO Fungible Asset Permissions...

    /* Events */
    // TODO ...

    /* Initialization - Asset Creation */
    fun init_module(deployer: &signer) {
        // TODO create the fungible asset...
        // TODO generate a signer for the asset's permissions...
        // TODO store the asset's permissions...
    }

    /// Mint new assets to the specified account. 
    public entry fun mint(deployer: &signer, to: address, amount: u64) acquires Management {
        // TODO admin assertion...
        // TODO ...

        // TODO event emission...
    }

    /// Burn assets from the specified account. 
    public entry fun burn(deployer: &signer, from: address, amount: u64) acquires Management {
        // TODO admin assertion...
        // TODO ...
        // Rely on fungible_asset libraries.

        // TODO event emission...
    }

    /// Transfer assets from one account to another. 
    public entry fun transfer(from: &signer, to: address, amount: u64) acquires Management {
        // TODO ...
        // Rely on primary_fungible_store and fungible_asset libraries.
    }

    inline fun assert_admin(deployer: &signer) {
        // TODO ...
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

    // TODO tests...
    // Create a few tests for the mint, burn, and transfer functions. 
    // Use asserts the results vs the expected outcomes.
}