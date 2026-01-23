# ScalpGuru V7 Changelog - Funded Account Edition

## Overview

V7 is specifically designed for **funded account challenges** like FundedNext Stellar 1-Step. It includes built-in protection against daily loss limits and maximum drawdown, while optimizing for profitability.

## FundedNext Stellar 1-Step Compatible

| Rule | FundedNext Limit | V7 Default Setting |
|------|------------------|-------------------|
| Max Daily Loss | 3% | 2.5% (safety buffer) |
| Max Overall Drawdown | 6% | 5.5% (safety buffer) |
| Profit Target | 10% | 10% |
| Min Trading Days | 2 | No restriction |
| EAs/Bots | Allowed on CFD | ✅ |

## V7 Features

### 1. Funded Account Protection (NEW)

- **Daily Loss Limit**: Automatically stops trading when approaching 3% daily loss
- **Max Drawdown Protection**: Closes all positions and stops trading if approaching 6% drawdown
- **Profit Target Tracking**: Logs when profit target is reached
- **Safety Buffers**: Uses 2.5% daily and 5.5% overall limits (below the 3%/6% actual limits)

```mql5
input bool EnableFundedMode = true;          // Enable funded account protection
input double DailyLossLimitPercent = 2.5;    // Max daily loss % (FundedNext: 3%)
input double MaxDrawdownPercent = 5.5;       // Max overall drawdown % (FundedNext: 6%)
input double ProfitTargetPercent = 10.0;     // Profit target % (FundedNext: 10%)
```

### 2. Reduced Risk Per Trade

- Default risk reduced from 1% to **0.5%** per trade
- With 2 trades/day max, worst case daily loss = 1% (well under 3% limit)
- Preserves capital while still being profitable

### 3. Partial Profit Taking (NEW)

- Closes **50%** of position at 1:1 risk-reward
- Locks in profit early while letting the remainder run
- Reduces drawdown volatility

```mql5
input bool EnablePartialProfit = true;      // Enable partial profit at 1:1 R:R
input double PartialProfitPercent = 50.0;   // Percentage to close at 1:1
input double ExtendedTrailMultiplier = 1.5; // Trail multiplier for remaining position
```

### 4. Improved Entry Filters

- **Tighter RSI filter**: Oversold level lowered from 35 to **30** for higher quality entries
- **Candle Confirmation**: Requires bullish/bearish candle pattern before entry
- **Keltner Retest**: Optional requirement for price to retest the Keltner band

### 5. Optimized Stop Loss & Trailing

- **SL ATR Multiplier**: Reduced from 1.4 to **1.3** for better R:R ratio
- **Trailing Stop**: Tighter initial trail (0.8 ATR), extends to 1.5 ATR after partial profit
- **Breakeven Buffer**: Reduced from 0.5 to **0.3** pips for faster protection

## Parameter Changes from V6

| Parameter | V6 Value | V7 Value | Reason |
|-----------|----------|----------|--------|
| RiskPerTradePercent | 1.0% | 0.5% | Protect daily loss limit |
| SL_ATRMultiplier | 1.4 | 1.3 | Better risk-reward ratio |
| TrailingStop_ATRMultiplier | 1.0 | 0.8 | Tighter trail captures more profit |
| BreakevenBuffer | 0.5 pips | 0.3 pips | Faster breakeven protection |
| RSI_Oversold | 35 | 30 | Higher quality entries |
| RSI_Overbought | 65 | 70 | Higher quality entries |

## New Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| EnableFundedMode | true | Enable funded account protection |
| DailyLossLimitPercent | 2.5 | Max daily loss before stopping |
| MaxDrawdownPercent | 5.5 | Max overall drawdown before stopping |
| ProfitTargetPercent | 10.0 | Profit target percentage |
| EnablePartialProfit | true | Take partial profit at 1:1 |
| PartialProfitPercent | 50.0 | % of position to close at 1:1 |
| ExtendedTrailMultiplier | 1.5 | Trail multiplier after partial |
| EnableCandleConfirmation | true | Require candle pattern for entry |
| RequireKeltnerRetest | true | Require Keltner band retest |

## Expected Performance

Based on V6 backtest with adjustments:
- **Profit Target**: $600 (10% of $6,000)
- **Max Acceptable Drawdown**: $330 (5.5% of $6,000)
- **Daily Loss Limit**: $150 (2.5% of $6,000)
- **Estimated time to pass**: 2-4 months (conservative)

## Usage for FundedNext Challenge

1. Set `AccountBalance = 6000` (or your challenge size)
2. Set `EnableFundedMode = true`
3. Keep sells disabled (`AllowSellTrades = false`)
4. Run on XAUUSD M15 timeframe
5. Monitor the journal for funded account warnings

## Risk Warning

While V7 includes funded account protections, no trading system is guaranteed to pass prop firm challenges. Always:
- Backtest extensively before live trading
- Start with smallest challenge size
- Monitor your account daily
- Be prepared to lose the challenge fee
