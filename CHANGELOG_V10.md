# ScalpGuru V10 - Ultimate Funded Account Edition

## Overview

V10 combines the best aspects of V8's profitability with V9's survivability, adding new smart risk management features designed specifically for funded account challenges. **V10 uses 20+ years of XAUUSD historical data** to derive optimal parameters.

**Key Goals:**
- ✅ High win rate (target: 75%+)
- ✅ Best profitability with controlled drawdown
- ✅ Ability to pass funded accounts quickly (target: 2-3 months)
- ✅ Maximum drawdown always under 6%
- ✅ Data-driven parameters from 122,000+ hourly candles (2004-2025)

## Data-Driven Approach

V10 uses historical XAUUSD data (2004-present, 122,000+ hourly candles) to determine:

### Volatility Thresholds
Based on 20-period ATR percentiles from recent 5 years (2020-2025):
- **Low volatility**: ATR < $3.86 (25th percentile) → Increase risk by 20%
- **Normal volatility**: $3.86 - $6.24 → Standard risk
- **High volatility**: ATR > $6.24 (75th percentile) → Reduce risk by 20%

### Optimal Trading Hours
Analyzed by average hourly range:
- **Top 5 (strict mode)**: 15, 16, 17, 18, 14 (London/NY overlap)
- **Top 8 (standard mode)**: 15, 16, 17, 18, 14, 19, 10, 0

### Auto-Update System
GitHub Actions workflow (`update-xauusd-data.yml`) provides:
- Weekly data fetch from Kaggle dataset
- Automatic constant regeneration on PRs
- Validation of data-driven parameters

To update data manually:
```bash
cd data/xauusd
python update_xauusd_data.py --all
```

## Backtest Comparison

| Metric | V8 (1 year) | V9 (3 years) | V10 Target |
|--------|-------------|--------------|------------|
| Net Profit | $2,356 | $2,239 | $3,000+/year |
| Max Drawdown | 8.82% ❌ | 8.25% ❌ | <5% ✅ |
| Profit Factor | 1.68 | ~1.34 | 2.0+ |
| Win Rate | ~70% | ~64% | 75%+ |
| Trades | 221 | 347 | ~200 |

## New V10 Features

### 1. Smart Drawdown Control (Critical for Funded Accounts)
- **Conservative base limits**: 
  - Daily loss limit: 2.0% (vs V9's 2.5%)
  - Max drawdown: 4.5% (vs V9's 5.5%)
- **Adaptive risk reduction**: Progressively reduces position size as drawdown increases
  - At 50% of drawdown limit: Risk reduced to 60%
  - At 75% of drawdown limit: Risk reduced to 40%
- **Daily profit target**: Stops trading after hitting 1.5% daily profit to protect gains

### 2. Multi-Level Partial Profits
- **First partial**: 50% at 1:1 R:R (same as V8/V9)
- **Second partial**: 50% of remaining at 2:1 R:R (NEW in V10)
- **Final portion**: Trails with extended multiplier for maximum profit capture

### 3. Equity Curve Risk Management
- **Win streak boost**: After 3 consecutive wins, risk increases by 10%
- **Loss streak protection**: After 2 consecutive losses, risk decreases to 70%
- Helps preserve capital during losing periods and maximize during winning streaks

### 4. Higher Timeframe Trend Confirmation
- Uses H1 EMA (50 period) to confirm trend direction
- For buys: Price must be above H1 EMA (trading with the trend)
- Significantly improves win rate by filtering out counter-trend trades

### 5. Enhanced Entry Filters
- **Stricter RSI levels**: 28/72 (vs V9's 30/70)
- **Keltner retest enabled**: Requires price to retest channel for higher quality entries
- **Wider Keltner channel**: 2.8x ATR (vs 2.5x) for better reversal identification

### 6. Optimized Risk/Reward
- **Wider stop loss**: 1.5x ATR (vs 1.3x) for higher win rate
- **Conservative base risk**: 0.8% per trade (vs 1.0%) for safety buffer
- **Combined multipliers**: Volatility + Adaptive + Streak for optimal position sizing

## Parameter Changes from V9

| Parameter | V9 Value | V10 Value | Reason |
|-----------|----------|-----------|--------|
| `MagicNumber` | 15139 | 15140 | New version |
| `RiskPerTradePercent` | 1.0 | 0.8 | More conservative base |
| `MaxTradesPerDay` | 4 | 3 | Quality over quantity |
| `DailyLossLimitPercent` | 2.5 | 2.0 | Extra safety margin |
| `MaxDrawdownPercent` | 5.5 | 4.5 | Well under 6% limit |
| `DailyProfitTarget` | N/A | 1.5 | NEW: Lock in daily gains |
| `KeltnerMultiplier` | 2.5 | 2.8 | Wider channel for better entries |
| `SL_ATRMultiplier` | 1.3 | 1.5 | Wider SL for higher win rate |
| `TrailingStop_ATRMultiplier` | 0.8 | 0.9 | Slightly wider trail |
| `ExtendedTrailMultiplier` | 1.5 | 1.2 | Tighter trail after partials |
| `RSI_Oversold` | 30 | 28 | Stricter filter |
| `RSI_Overbought` | 70 | 72 | Stricter filter |
| `RequireKeltnerRetest` | false | true | Higher quality entries |

## New Input Parameters

### Smart Risk Management
```
EnableAdaptiveRisk = true        // Reduce risk progressively approaching limits
DrawdownRiskReduction = 0.6      // Risk multiplier at 50%+ drawdown
EnableWinStreakBoost = true      // Increase risk after winning streak
WinStreakThreshold = 3           // Wins needed to trigger boost
WinStreakBoostMultiplier = 1.1   // 10% risk boost after streak
EnableLossReduction = true       // Reduce risk after consecutive losses
LossStreakThreshold = 2          // Losses needed to trigger reduction
LossReductionMultiplier = 0.7    // 30% risk reduction after losses
```

### HTF Trend Confirmation
```
EnableHTFTrendFilter = true      // Use H1 trend for entry confirmation
HTF_EMAPeriod = 50               // H1 EMA period for trend
RequirePriceAboveHTF_EMA = true  // For buys, price must be above H1 EMA
```

### Daily Profit Target
```
DailyProfitTarget = 1.5          // Daily profit target %
EnableDailyProfitTarget = true   // Enable daily profit target limit
```

### Second Partial Profit
```
EnableSecondPartial = true       // Enable second partial at 2:1 R:R
SecondPartialPercent = 50.0      // % of remaining position to close at 2:1
```

## Expected Results

With these optimizations, V10 should achieve:
- **Monthly profit**: ~$150-200 (2.5-3.3% on $6000)
- **Time to 10% target**: ~2-3 months
- **Maximum drawdown**: <4.5% (well within 6% limit)
- **Daily drawdown**: <2% (well within 3% limit)
- **Win rate**: ~75% or higher

## Usage Notes

1. **Funded Account Settings**: The default settings are optimized for FundedNext and similar prop firms with 3% daily / 6% overall drawdown limits.

2. **Live Trading**: Start with paper trading to verify performance matches backtests before going live.

3. **Timeframe**: Designed for M15 timeframe on XAUUSD (Gold).

4. **Session**: Best performance during London/NY overlap (13:00-16:00 server time).

## Change Log

### V10.00 (2026-01-24)
- Combined best features of V8 profitability and V9 survivability
- Added adaptive drawdown risk management
- Added equity curve-based risk adjustment (win/loss streaks)
- Added H1 trend filter for entry confirmation  
- Added second partial profit at 2:1 R:R
- Added daily profit target feature
- Optimized parameters for funded account safety
- Reduced base risk and drawdown limits
- Stricter entry filters for higher win rate
- Enhanced info panel with streak display
