module 0xYourAddress::simple_token_transfer_with_history {
    use sui::coin::{Self, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::TxContext;

    // Define the token struct
    public struct MY_TOKEN has drop {}

    // Define a struct to store transaction details
    struct TransactionHistory has key {
        sender: address,
        recipient: address,
        amount: u64,
        timestamp: u64,
    }

    // Define a table to store transaction histories
    struct HistoryTable has key {
        histories: vector<TransactionHistory>,
    }

    // Initialize the token and history table
    public fun init(ctx: &mut TxContext) {
        let (treasury, metadata) = coin::create_currency<MY_TOKEN>(
            6, // Decimals
            b"MY_TOKEN", // Token name
            b"MTK", // Token symbol
            b"", // Description
            option::none(), // Icon URL
            ctx
        );
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury, ctx.sender());

        // Initialize the history table
        let history_table = HistoryTable { histories: vector::empty<TransactionHistory>() };
        transfer::public_transfer(history_table, ctx.sender());
    }

    // Mint new tokens
    public fun mint(treasury: &TreasuryCap<MY_TOKEN>, amount: u64, ctx: &mut TxContext) {
        coin::mint(treasury, amount, ctx.sender(), ctx);
    }

    // Transfer tokens and record the transaction
    public fun transfer(recipient: address, amount: u64, ctx: &mut TxContext) {
        let coin = coin::withdraw<MY_TOKEN>(ctx.sender(), amount, ctx);
        transfer::public_transfer(coin, recipient);

        // Record the transaction
        let history_table = borrow_global_mut<HistoryTable>(ctx.sender());
        let transaction = TransactionHistory {
            sender: ctx.sender(),
            recipient: recipient,
            amount: amount,
            timestamp: ctx.timestamp(),
        };
        vector::push_back(&mut history_table.histories, transaction);
    }

    // Get transaction history
    public fun get_transaction_history(owner: address): vector<TransactionHistory> {
        let history_table = borrow_global<HistoryTable>(owner);
        history_table.histories
    }
}
