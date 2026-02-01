# ScalpGuru V10 - How AccountBalance Parameter Works

## Understanding the Dual System

V10 uses a **smart dual-tracking system** for funded account management:

### 1. AccountBalance Input Parameter (Baseline)
**Purpose:** The funded account challenge size you're trading
**Usage:** 
- Calculates risk percentages for lot sizing
- Sets the baseline for drawdown limits
- Defines daily loss limits as % of this value

**Example:** 
- You have a $6,000 funded challenge → Set `AccountBalance = 6000.0`
- You have a $15,000 funded challenge → Set `AccountBalance = 15000.0`

### 2. Live Balance Monitoring (Actual Tracking)
**Purpose:** Monitor your REAL account balance/equity
**Usage:**
- Tracks actual current balance
- Monitors actual equity
- Enforces limits by comparing actual equity against baseline

## How It Works Together

### Scenario: $6,000 Funded Account Challenge

```
INPUT PARAMETER:
AccountBalance = 6000.0

CALCULATED LIMITS (Based on AccountBalance):
- Max Drawdown: 6000 × 5.5% = $330
- Daily Loss Limit: 6000 × 2.5% = $150
- Lot Size Risk: 6000 × 1.0% = $60 per trade

LIVE MONITORING (Actual Account):
- Start balance: $6,000 (actual)
- Current equity: $5,700 (actual, after some trades)
- Drawdown: 6000 - 5700 = $300
- Check: $300 < $330 ✅ OK, within limits
```

### What Happens if You Misconfigure?

**Example: Set AccountBalance = 15000 but actually have $6000**

```
INPUT PARAMETER:
AccountBalance = 15000.0

CALCULATED LIMITS (Based on AccountBalance):
- Max Drawdown: 15000 × 5.5% = $825
- Daily Loss Limit: 15000 × 2.5% = $375
- Lot Size Risk: 15000 × 1.0% = $150 per trade ⚠️ HUGE!

LIVE MONITORING (Actual Account):
- Actual balance: $6,000
- Trade lot size: Calculated for $150 risk = MASSIVE position
- Result: ONE LOSS = Account blown! ⚠️

This is YOUR fault for misconfiguring!
```

## Key Rules

1. ✅ **AccountBalance parameter** = Your funded challenge size
2. ✅ **Always match your actual account** = Set AccountBalance to what you actually have
3. ✅ **System monitors live balance** = Enforces limits on actual equity
4. ✅ **User's responsibility** = If you set wrong value, risk is on you

## Code Logic

### Initialization (OnInit)
```mql
overallStartBalance = AccountBalance;              // Baseline from input parameter
dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);  // Actual starting balance
```

### Lot Size Calculation
```mql
riskAmount = AccountBalance * (RiskPerTradePercent * volMultiplier / 100.0);
// Uses AccountBalance parameter for sizing
```

### Drawdown Monitoring
```mql
currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);     // ACTUAL live equity
overallDrawdown = overallStartBalance - currentEquity; // Compare: Baseline vs Actual
maxAllowedDrawdown = overallStartBalance * (MaxDrawdownPercent / 100);
if(overallDrawdown >= maxAllowedDrawdown) {
    // STOP TRADING - Max drawdown hit!
}
```

### Daily Loss Monitoring
```mql
currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);           // ACTUAL equity now
dailyEquityChange = currentEquity - dailyStartBalance;       // ACTUAL daily change
dailyLossLimit = overallStartBalance * (DailyLossLimitPercent / 100);  // Limit from baseline
if(dailyEquityChange <= -dailyLossLimit) {
    // STOP TRADING - Daily limit hit!
}
```

## Summary

✅ **AccountBalance input** = Funded challenge size baseline (YOU control this)
✅ **Live monitoring** = Tracks ACTUAL account equity (system monitors this)
✅ **Risk calculations** = Based on AccountBalance parameter
✅ **Limit enforcement** = Based on ACTUAL equity vs AccountBalance baseline
✅ **User responsibility** = Set AccountBalance correctly or face consequences!

The system gives you full control while protecting you from hitting funded account limits! 🚀
