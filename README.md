MYCOIN Module Documentation

Overview

The mytoken::mycoin module defines the basic functionalities of the custom token MYCOIN in the Sui blockchain ecosystem. This documentation will cover the core components, token initialization, minting process, and transfer mechanism, as well as additional structs for supporting token management.

Module Contents

1. Structs

1.1 MYCOIN

The main token structure representing MYCOIN. This token has the drop capability, meaning it can be discarded after use.

public struct MYCOIN has drop {}

1.2 LendingPool

A structure that defines the lending pool where the token supply is held and managed. It contains:

	•	id: A unique identifier for the lending pool.
	•	coin_supply: The balance of MYCOIN tokens.
	•	treasury_cap: The treasury cap to control minting of the MYCOIN tokens.

public struct LendingPool has key, store {
    id: UID,
    coin_supply: Balance<MYCOIN>,
    treasury_cap: TreasuryCap<MYCOIN>,
}

1.3 TransferEvent

Defines the structure for tracking transfer events of MYCOIN. Each transfer includes:

	•	from: The address of the sender.
	•	to: The address of the recipient.
	•	amount: The number of tokens transferred.

public struct TransferEvent has copy, drop {
    from: address,
    to: address,
    amount: u64,
}

2. Constants

2.1 FLOAT_SCALING

Defines the scaling factor for decimal precision. All token amounts are multiplied by this scaling factor to support decimal places.

const FLOAT_SCALING: u64 = 1_000_000_000;

3. Functions

3.1 init

Initializes the MYCOIN token by creating its treasury cap and registering the token’s metadata. The following parameters are used:

	•	witness: An instance of the MYCOIN token to act as proof.
	•	ctx: The transaction context, which is used to register the token and handle transfers.

Process:

	•	A new token is created using the coin::create_currency function.
	•	Metadata is shared publicly to allow tracking and interaction with the token.
	•	The treasury_cap is created and stored for future minting operations.

public fun init(witness: MYCOIN, ctx: &mut TxContext) {
    let (treasury_cap, metadata) = coin::create_currency<MYCOIN>(
        witness, 
        9, // Decimal places
        b"MY_TOKEN",
        b"Coin", 
        b"Native Coin", 
        option::none(), 
        ctx
    );

    transfer::public_transfer(treasury_cap, tx_context::sender(ctx));
    transfer::public_share_object(metadata);
}

3.2 mint_token

Mints new MYCOIN tokens by interacting with the TreasuryCap. The following parameters are used:

	•	cap: A mutable reference to the treasury cap, controlling the token supply.
	•	ctx: The transaction context used for minting.
	•	amount: The number of tokens to mint.

Process:

	•	The amount is multiplied by the FLOAT_SCALING to account for decimal precision.
	•	The coin::mint function is used to mint the tokens, and the resulting coin is returned.

public fun mint_token(cap: &mut TreasuryCap<MYCOIN>, ctx: &mut TxContext, amount: u64): Coin<MYCOIN> {
    let minted_coin = coin::mint(cap, amount * FLOAT_SCALING, ctx);
    minted_coin
}

3.3 send

Transfers a specified amount of MYCOIN tokens from one address (LendingPool) to another. The following parameters are used:

	•	sender_balance: A mutable reference to the LendingPool, containing the sender’s balance of MYCOIN.
	•	recipient: The address of the token recipient.
	•	amount: The number of tokens to send.
	•	ctx: The transaction context.

Process:

	•	The coin::take function is used to reduce the sender’s balance by the specified amount.
	•	The tokens are transferred to the recipient using the transfer::public_transfer function.
	•	A TransferEvent is emitted to track the transfer, recording the sender, recipient, and amount.

public fun send(sender_balance: &mut LendingPool, recipient: address, amount: u64, ctx: &mut TxContext) {
    let coin_send = coin::take(&mut sender_balance.coin_supply, amount, ctx);
    transfer::public_transfer(coin_send, recipient);

    emit(TransferEvent {
        from: ctx.sender(),
        to: recipient,
        amount,
    });
}

Usage

1. Initializing the Token

To initialize the MYCOIN token, call the init function. This will create the token’s treasury cap and share the metadata.

mytoken::mycoin::init(witness, &mut ctx);

2. Minting Tokens

To mint new MYCOIN tokens, call the mint_token function with the treasury cap and the amount of tokens to mint.

let new_coins = mytoken::mycoin::mint_token(&mut treasury_cap, &mut ctx, 1000);

3. Transferring Tokens

To transfer tokens from the lending pool to a recipient, call the send function with the sender’s balance, recipient address, and the amount to transfer.

mytoken::mycoin::send(&mut sender_balance, recipient, 500, &mut ctx);

Events

The module emits TransferEvent to record each token transfer. This event captures the from address, the to address, and the amount of tokens transferred.

emit(TransferEvent {
    from: ctx.sender(),
    to: recipient,
    amount,
});
