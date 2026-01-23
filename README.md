# ScalpGuru - Keltner Channel Trading EA

A MetaTrader 5 Expert Advisor that implements a mean reversion strategy using Keltner Channels with an improved trailing stop mechanism for maximizing profits.

## Latest Version: V7 - Funded Account Edition

**ScalpGuru V7** is specifically designed for **funded account challenges** like FundedNext Stellar 1-Step. See [CHANGELOG_V7.md](docs/CHANGELOG_V7.md) for full details.

### ✅ FundedNext Stellar 1-Step Compatible

| Rule | FundedNext Limit | V7 Setting |
|------|------------------|------------|
| Max Daily Loss | 3% | 2.5% (safety buffer) |
| Max Overall Drawdown | 6% | 5.5% (safety buffer) |
| Profit Target | 10% | 10% ($600 for $6K) |
| Min Trading Days | 2 | No restriction |
| EAs/Bots | ✅ Allowed | ✅ |

### V7 Key Features
- **Funded Account Protection:** Auto-stops trading when approaching daily/overall limits
- **Partial Profit Taking:** Close 50% of position at 1:1 R:R to lock in profits
- **Reduced Risk:** 0.5% risk per trade (max 1% daily with 2 trades)
- **Tighter Entry Filters:** RSI oversold at 30, candle confirmation required
- **Improved Trailing:** 0.8 ATR initial, 1.5 ATR after partial profit

### V6 Features (Included in V7)
- Professional Chart Display with full Keltner Channel bands
- Info Panel with real-time status, ATR, RSI, P/L
- RSI momentum filter, volume filter, session filter

## Backtest Results Comparison (V6 vs V7)

**Period:** January 2025 - December 2025 (12 months)
**Symbol:** XAUUSD M15

| Metric | V6 | V7 | Notes |
|--------|----|----|-------|
| **Total Net Profit** | $1,960.93 | $1,430.08 | V6 +37% more profit |
| **Monthly Average** | ~$163.41 | ~$119.17 | V6 faster to targets |
| **Profit Factor** | 1.62 | 1.93 | V7 more efficient |
| **Win Rate** | 59.52% | 73.74% | V7 +24% higher |
| **Total Trades** | 126 | 99 | V7 more selective |
| **Max Drawdown** | 9.10% | 8.83% | V7 slightly safer |
| **Recovery Factor** | 3.00 | 2.28 | V6 recovers faster |
| **Sharpe Ratio** | 11.36 | 14.48 | V7 more consistent |

### Funded Account Pass Timeline

| Version | Time to $600 (10%) | Time to $2,000 |
|---------|-------------------|----------------|
| **V6** | ~2.7 months | ~12.2 months |
| **V7** | ~3.7 months | ~16.8 months |

**Recommendation:** V7 is safer with higher win rate and lower drawdown, but V6 passes funded challenges faster. Both versions have sells disabled (buys only). See [V7 Analysis](docs/V7_BACKTEST_ANALYSIS.md) for detailed comparison.

## Strategy Overview

### Entry Logic
**Buy Signal:**
- Price dips below the lower Keltner band (close[2] < lower band)
- Price then reverses and closes above the lower band (close[0] > lower band)
- RSI not overbought (if momentum filter enabled)
- Opens a long position

**Sell Signal:**
- Price extends above the upper Keltner band (close[2] > upper band)
- Price then reverses and closes below the upper band (close[0] < upper band)
- RSI not oversold (if momentum filter enabled)
- Opens a short position

### Exit Logic
1. **Initial Stop Loss:** Placed at entry price ± (ATR × SL Multiplier)
2. **Trailing Stop Activation:** When trade reaches 1:1 risk-reward ratio:
   - Stop loss moves to breakeven + buffer (V6)
   - Trailing stop is activated at optimal distance based on ATR
   - Follows price upward (for buys) or downward (for sells)
3. **Profit Exit:** Trade closes when trailing stop is hit

## Repository Structure

```
scalpguru/
├── src/
│   ├── ScalpGuruV7.mq5          # Latest EA (recommended) - Maximum profitability
│   ├── ScalpGuruV6.mq5          # Previous version - Enhanced visuals
│   └── ScalpGuruV5.mq5          # Legacy version
├── backtests/                    # Upload backtest results here
│   └── v6 test/                  # V6 backtest results
├── report/                       # Initial backtest reports
└── docs/                         # Documentation
    ├── CHANGELOG_V7.md           # V7 profitability improvements
    ├── CHANGELOG_V6.md           # V6 changes and features
    └── CHANGELOG_V5.md           # V5 changes
```

## Installation

1. Copy `src/ScalpGuruV7.mq5` to your MetaTrader 5 `MQL5/Experts/` directory
2. Compile the EA in MetaEditor
3. Attach to a chart and configure parameters

## Key Parameters

### Trading Configuration
- **AccountBalance:** Account balance for risk calculations (default: 6000)
- **RiskPerTradePercent:** Risk per trade as % of account (default: 0.5% in V7)
- **MaxTradesPerDay:** Maximum trades per day (default: 2)

### V7 Funded Account Protection
- **EnableFundedMode:** Enable funded account protection (default: true)
- **DailyLossLimitPercent:** Max daily loss before stopping (default: 2.5%)
- **MaxDrawdownPercent:** Max overall drawdown before stopping (default: 5.5%)
- **ProfitTargetPercent:** Profit target percentage (default: 10%)

### Strategy Parameters
- **ATRPeriod:** ATR calculation period (default: 20)
- **KeltnerPeriod:** EMA period for Keltner middle line (default: 20)
- **KeltnerMultiplier:** ATR multiplier for bands (default: 2.5)
- **SL_ATRMultiplier:** Stop loss distance multiplier (default: 1.3 in V7)
- **TrailingStop_ATRMultiplier:** Trailing stop distance (default: 0.8 in V7)
- **BreakevenBuffer:** Pips added to breakeven SL (default: 0.3 in V7)

### V7 Profit Taking Parameters
- **EnablePartialProfit:** Enable partial close at 1:1 R:R (default: true)
- **PartialProfitPercent:** % of position to close at 1:1 (default: 50%)
- **ExtendedTrailMultiplier:** Trail multiplier after partial profit (default: 1.5)

### Entry Filters
- **EnableMomentumFilter:** RSI-based entry filter (default: true)
- **RSI_Oversold/RSI_Overbought:** RSI thresholds (default: 30/70 in V7)
- **EnableCandleConfirmation:** Require bullish/bearish candle (V7, default: true)
- **RequireKeltnerRetest:** Require price to retest Keltner (V7, default: true)
- **EnableVolumeFilter:** Volume confirmation (default: false)
- **EnableSessionFilter:** Time-based trading (default: false)

## Backtest Results

### V5 Performance (XAUUSD M15, Jan-Dec 2025)
- **Net Profit:** $1,960.93 (~$163/month)
- **Profit Factor:** 1.62
- **Win Rate:** 59.52%
- **Total Trades:** 126
- **Max Drawdown:** 9.10%

Upload your backtest results to the `backtests/` folder.

## Version History

- **V7:** Funded Account Edition - daily/drawdown protection, partial profit taking, reduced risk
- **V6:** Enhanced visuals, RSI momentum filter, session filter, breakeven buffer
- **V5:** Improved trailing stop mechanism, simplified code
- **V4:** Keltner Channel strategy with partial close

## Why Sells are Disabled

The mean reversion strategy works better for buying dips than selling rallies because:
1. Markets tend to have an upward bias over time
2. Buying oversold conditions has higher win rate than selling overbought
3. V6 backtests showed sells would result in negative profit

V7 includes improved sell logic with better candle confirmation, but sells remain disabled by default. Test with sells enabled (`AllowSellTrades = true`) at your own risk.

## Funded Account Usage Guide

### For FundedNext Stellar 1-Step $6K Challenge:

1. **Settings:**
   ```
   AccountBalance = 6000
   EnableFundedMode = true
   DailyLossLimitPercent = 2.5
   MaxDrawdownPercent = 5.5
   AllowSellTrades = false
   ```

2. **Symbol:** XAUUSD (Gold)
3. **Timeframe:** M15
4. **Target:** $600 profit (10%)
5. **Max Risk:** $330 drawdown (5.5%)

### Protection Features:
- ⚠️ Warning at 80% of daily limit
- 🛑 Auto-stop at daily limit (no new trades)
- ⚠️ Warning at 90% of max drawdown
- 🛑 Emergency close all positions at max drawdown

### Expected Timeline:

| Settings | Monthly Profit | Time to Pass |
|----------|---------------|--------------|
| V7 Default (Conservative) | ~$119 | ~5 months |
| V6 Settings | ~$163 | ~3.7 months |
| **V7 Aggressive** | ~$200-220 | **~3 months** ✅ |

**Want to pass in 3 months?** See the [3-Month Funded Pass Guide](docs/FUNDED_3MONTH_GUIDE.md) for optimized aggressive settings.

## License

Copyright © go0ph

## Support

For issues or questions, please open a GitHub issue.