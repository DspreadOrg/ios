
import Foundation

public struct POSTradeData {
    
    public let paymentAmount: Decimal
    public let currencyCode: String
    public let transactionType: TransactionType
    public let tradeMode: CardTradeMode
    
    public init(
        paymentAmount: Decimal,
        currencyCode: String,
        transactionType: TransactionType,
        tradeMode: CardTradeMode
    ) {
        self.paymentAmount = paymentAmount
        self.currencyCode = currencyCode
        self.transactionType = transactionType
        self.tradeMode = tradeMode
    }
}
