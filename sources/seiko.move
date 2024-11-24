module mytoken::mycoin {
    use sui::coin::{Self, TreasuryCap, Coin};
    use sui::transfer;
    use sui::tx_context::TxContext;
    use sui::event::emit;
    use sui::balance::{Self, Balance};

    // Define the token struct
    public struct MYCOIN has drop {}

     const FLOAT_SCALING: u64 = 1_000_000_000;

    // Define the transfer event struct

       public struct LendingPool has key, store {
        id: UID,
        coin_supply: Balance<MYCOIN>,
        treasury_cap: TreasuryCap<MYCOIN>,
    }

    public struct TransferEvent has copy, drop {
        from: address,
        to: address,
        amount: u64,
    }

    // Initialize the token
     fun init(witness: MYCOIN, ctx: &mut TxContext) {
      let (treasury_cap, metadata) = coin::create_currency<MYCOIN>(
            witness, 
            9, 
            b"MY_TOKEN",
            b"Coin", 
            b"Native Coin", 
            option::none(), 
            ctx
        );

      transfer::public_transfer(treasury_cap, tx_context::sender(ctx));
      transfer::public_share_object(metadata);
  }

    // Mint new tokens
     public fun mint_token(cap: &mut TreasuryCap<MYCOIN>, ctx: &mut TxContext, amount: u64): Coin<MYCOIN>{
    let minted_coin = coin::mint(cap, amount * FLOAT_SCALING, ctx);
   // transfer::public_transfer(minted_coin, tx_context::sender(ctx));
    minted_coin
}
    
  // Mint new tokens
    public fun send(sender_balance: &mut LendingPool, recipient: address, amount: u64, ctx: &mut TxContext) {
        let coin_send = coin::take(&mut sender_balance.coin_supply, amount, ctx);
        transfer::public_transfer(coin_send, recipient);

        // Emit transfer event
        emit(TransferEvent {
            from: ctx.sender(),
            to: recipient,
            amount,
        });
    }
}
