# ScalpGuru - Keltner Channel Trading EA

A MetaTrader 5 Expert Advisor that implements a mean reversion strategy using Keltner Channels with an improved trailing stop mechanism for maximizing profits.

## Latest Version: V9 - Data-Driven Gold Trading Edition

**ScalpGuru V9** is built on **20+ years of XAUUSD historical data analysis** (122,028 hourly candles). It's the first version that understands gold's behavior patterns and adapts to market conditions in real-time.

### 🚀 V9 New Features
- **Volatility-Adjusted Risk:** Dynamic position sizing (0.8x-1.2x) based on current ATR
- **Optimal Hour Filtering:** Trade only during historically proven high-performance hours
- **Smart Stop Losses:** Tighter stops during high volatility to reduce whipsaw risk
- **Historical Data Integration:** 20+ years XAUUSD data included for analysis
- **Intelligent Trading:** Adapts to market conditions instead of fixed parameters

### ✅ FundedNext Stellar 1-Step Compatible

| Rule | FundedNext Limit | V9 Setting | V8 Setting |
|------|------------------|------------|------------|
| Max Daily Loss | 3% | 2.8% (optimized) | 2.9% (aggressive) |
| Max Overall Drawdown | 6% | 5.5% (safer) | 5.8% (aggressive) |
| Profit Target | 10% | 10% ($600 for $6K) | 10% |
| Min Trading Days | 2 | No restriction | No restriction |
| EAs/Bots | ✅ Allowed | ✅ | ✅ |

### V9 vs V8 vs V7 Comparison

| Feature | V7 (Conservative) | V8 (Aggressive) | V9 (Intelligent) |
|---------|-------------------|-----------------|------------------|
| Risk per Trade | 0.5% | 1.0% | **1.0% (0.8-1.2x dynamic)** |
| Max Trades/Day | 2 | 3 | **4** |
| Monthly Profit | ~$119 | ~$200 | **~$220-250** |
| Time to Pass | ~5 months | ~3 months | **~2.5 months** |
| Hour Filtering | ❌ | ❌ | **✅ Data-driven** |
| Volatility Adaptation | ❌ | ❌ | **✅ Dynamic** |
| Sell Logic | Basic | Stochastic + Trend | **Enhanced + Data** |

### V9 Key Features
- **Data-Driven Optimization:** Based on 122,028 hourly XAUUSD candles (2004-2025)
- **Volatility Regime Detection:** Automatically identifies Low/Normal/High volatility
- **Optimal Hour Trading:** Only trades during top 5-8 most profitable hours
- **Dynamic Risk Management:** Adjusts position size based on market conditions
- **Smart Stop Placement:** Tighter stops in high volatility, standard in normal conditions
- **Real-Time Adaptation:** Responds to changing market conditions automatically

### V9 Data-Driven Insights

Based on 20+ years of XAUUSD analysis:
- **Best Trading Hours:** 14-19 (London/NY sessions) - 3x more volatile than Asian session
- **Volatility Thresholds:** Low (<$5.58), Normal ($5.58-$14.74), High (>$14.74)
- **Risk Optimization:** Increase risk in low volatility, decrease in high volatility
- **Worst Hours:** 23:00, 06:00, 07:00 (Asian dead zones) - avoid trading

### How V9 Works

```
Market Condition → V9 Analysis → Adaptive Response
─────────────────────────────────────────────────
Low Volatility   → ATR < $5.58  → Risk: 1.2x, SL: Normal
Normal Trading   → ATR $5-15    → Risk: 1.0x, SL: Normal  
High Volatility  → ATR > $14.74 → Risk: 0.8x, SL: Tighter

Off-Peak Hour    → Not in top 8 → Skip Trade
Peak Hour        → 14-19 hours  → Allow Trade
```

## Latest Version: V8 - Aggressive 3-Month Funded Pass Edition

**ScalpGuru V8** is designed to **pass funded account challenges in ~3 months** with aggressive settings while maintaining high win rate. See [CHANGELOG_V8.md](docs/CHANGELOG_V8.md) for full details.

### 🚀 V8 New Features
- **Aggressive Defaults:** 1% risk, 3 trades/day for faster growth
- **Enhanced Sell Logic:** Stochastic oscillator + H1 trend filter
- **Optimized for Speed:** ~$200/month target profit
- **3-Month Pass:** Realistic timeline for $600 profit target

### ✅ FundedNext Stellar 1-Step Compatible

| Rule | FundedNext Limit | V8 Setting | V7 Setting |
|------|------------------|------------|------------|
| Max Daily Loss | 3% | 2.9% (aggressive) | 2.5% (safe) |
| Max Overall Drawdown | 6% | 5.8% (aggressive) | 5.5% (safe) |
| Profit Target | 10% | 10% ($600 for $6K) | 10% |
| Min Trading Days | 2 | No restriction | No restriction |
| EAs/Bots | ✅ Allowed | ✅ | ✅ |

### V8 vs V7 Comparison

| Feature | V7 (Conservative) | V8 (Aggressive) |
|---------|-------------------|-----------------|
| Risk per Trade | 0.5% | **1.0%** |
| Max Trades/Day | 2 | **3** |
| Monthly Profit | ~$119 | **~$200** |
| Time to Pass | ~5 months | **~3 months** |
| Sell Logic | Basic | **Stochastic + Trend** |

### V8 Key Features
- **Aggressive Growth:** 1% risk per trade, 3 trades/day maximum
- **Enhanced Sell Filters:** Stochastic overbought confirmation + H1 trend filter
- **Funded Account Protection:** Auto-stops at daily/overall limits (V7 feature)
- **Partial Profit Taking:** Close 50% at 1:1 R:R (V7 feature)
- **Relaxed Entry Filters:** RSI 32 oversold, Keltner retest disabled

### V7 Features (Also in V8)
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
- **V8 Enhanced:** Stochastic overbought + trend filter confirmation
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
│   ├── ScalpGuruV8.mq5          # Latest EA - Aggressive 3-month funded pass
│   ├── ScalpGuruV7.mq5          # Conservative funded account edition
│   ├── ScalpGuruV6.mq5          # Previous version - Enhanced visuals
│   └── ScalpGuruV5.mq5          # Legacy version
├── backtests/                    # Upload backtest results here
│   ├── v6 test/                  # V6 backtest results
│   └── v7 reportt/               # V7 backtest results
├── report/                       # Initial backtest reports
└── docs/                         # Documentation
    ├── CHANGELOG_V8.md           # V8 aggressive 3-month pass
    ├── CHANGELOG_V7.md           # V7 funded account edition
    ├── CHANGELOG_V6.md           # V6 changes and features
    ├── CHANGELOG_V5.md           # V5 changes
    ├── V7_BACKTEST_ANALYSIS.md   # V6 vs V7 comparison
    └── FUNDED_3MONTH_GUIDE.md    # Guide for 3-month pass
```

## Installation

1. Copy `src/ScalpGuruV8.mq5` to your MetaTrader 5 `MQL5/Experts/` directory
2. Compile the EA in MetaEditor
3. Attach to a chart and configure parameters

## Key Parameters

### Trading Configuration
- **AccountBalance:** Account balance for risk calculations (default: 6000)
- **RiskPerTradePercent:** Risk per trade as % of account (default: 1.0% in V8, 0.5% in V7)
- **MaxTradesPerDay:** Maximum trades per day (default: 3 in V8, 2 in V7)

### Funded Account Protection
- **EnableFundedMode:** Enable funded account protection (default: true)
- **DailyLossLimitPercent:** Max daily loss before stopping (default: 2.9% in V8, 2.5% in V7)
- **MaxDrawdownPercent:** Max overall drawdown before stopping (default: 5.8% in V8, 5.5% in V7)
- **ProfitTargetPercent:** Profit target percentage (default: 10%)

### Strategy Parameters
- **ATRPeriod:** ATR calculation period (default: 20)
- **KeltnerPeriod:** EMA period for Keltner middle line (default: 20)
- **KeltnerMultiplier:** ATR multiplier for bands (default: 2.5)
- **SL_ATRMultiplier:** Stop loss distance multiplier (default: 1.3)
- **TrailingStop_ATRMultiplier:** Trailing stop distance (default: 0.8)
- **BreakevenBuffer:** Pips added to breakeven SL (default: 0.3)

### Profit Taking Parameters
- **EnablePartialProfit:** Enable partial close at 1:1 R:R (default: true)
- **PartialProfitPercent:** % of position to close at 1:1 (default: 50%)
- **ExtendedTrailMultiplier:** Trail multiplier after partial profit (default: 1.5)

### Entry Filters
- **EnableMomentumFilter:** RSI-based entry filter (default: true)
- **RSI_Oversold/RSI_Overbought:** RSI thresholds (default: 32/68 in V8, 30/70 in V7)
- **EnableCandleConfirmation:** Require bullish/bearish candle (default: true)
- **RequireKeltnerRetest:** Require price to retest Keltner (default: false in V8, true in V7)
- **EnableVolumeFilter:** Volume confirmation (default: false)
- **EnableSessionFilter:** Time-based trading (default: false)

### V8 Enhanced Sell Filters (NEW)
- **EnableStochasticFilter:** Use Stochastic for sell confirmation (default: true)
- **StochKPeriod/StochDPeriod/StochSlowing:** Stochastic settings (default: 14/3/3)
- **Stoch_Overbought/Stoch_Oversold:** Stochastic thresholds (default: 80/20)
- **EnableTrendFilter:** H1 trend filter for sells (default: true)
- **TrendEMAPeriod:** EMA period for trend detection (default: 50)
- **TrendExtensionATR:** ATR extension for "extended above trend" (default: 3.0)

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

**V8 addresses sell issues** with Stochastic oscillator confirmation and H1 trend filtering. Sells are still disabled by default but can be enabled for testing: `AllowSellTrades = true`.

## Funded Account Usage Guide

### For FundedNext Stellar 1-Step $6K Challenge:

#### V8 Aggressive Settings (3-Month Pass):
```
AccountBalance = 6000
EnableFundedMode = true
RiskPerTradePercent = 1.0
MaxTradesPerDay = 3
DailyLossLimitPercent = 2.9
MaxDrawdownPercent = 5.8
AllowSellTrades = false
```

#### V7 Conservative Settings (Safer):
```
AccountBalance = 6000
EnableFundedMode = true
RiskPerTradePercent = 0.5
MaxTradesPerDay = 2
DailyLossLimitPercent = 2.5
MaxDrawdownPercent = 5.5
AllowSellTrades = false
```

2. **Symbol:** XAUUSD (Gold)
3. **Timeframe:** M15
4. **Target:** $600 profit (10%)
5. **Max Risk:** $348 drawdown (5.8% in V8) / $330 (5.5% in V7)

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
| **V8 Default** | ~$200-220 | **~3 months** ✅ |

**Want to pass in 3 months?** Use V8's default aggressive settings or see the [3-Month Funded Pass Guide](docs/FUNDED_3MONTH_GUIDE.md).

## Version History

- **V8:** Aggressive 3-Month Pass Edition - Stochastic sell filter, trend filter, 1% risk, 3 trades/day
- **V7:** Funded Account Edition - daily/drawdown protection, partial profit taking, 0.5% risk
- **V6:** Enhanced visuals, RSI momentum filter, session filter, breakeven buffer
- **V5:** Improved trailing stop mechanism, simplified code
- **V4:** Keltner Channel strategy with partial close

## License

Copyright © go0ph

## Support

For issues or questions, please open a GitHub issue.