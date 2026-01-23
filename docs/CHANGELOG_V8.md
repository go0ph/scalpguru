# ScalpGuru V8 Changelog - Aggressive 3-Month Funded Pass Edition

## Overview

V8 is designed to **pass funded account challenges in approximately 3 months** while maintaining a high win rate. It builds on V7's foundation with aggressive default settings and enhanced sell logic using Stochastic oscillator and trend filtering.

## Target Performance

| Metric | V7 Default | V8 Target |
|--------|------------|-----------|
| Monthly Profit | ~$119 | **$200+** |
| Time to $600 | ~5 months | **~3 months** |
| Win Rate | 73.74% | 70%+ |
| Max Daily Risk | 1% | 3% |

## Key Changes from V7

### 1. Aggressive Default Settings

| Parameter | V7 | V8 | Reason |
|-----------|----|----|--------|
| RiskPerTradePercent | 0.5% | **1.0%** | Double profit potential |
| MaxTradesPerDay | 2 | **3** | More opportunities |
| DailyLossLimitPercent | 2.5% | **2.9%** | Closer to 3% limit |
| MaxDrawdownPercent | 5.5% | **5.8%** | Closer to 6% limit |
| RSI_Oversold | 30 | **32** | More buy entries |
| RSI_Overbought | 70 | **68** | More sell entries |
| RequireKeltnerRetest | true | **false** | More trade opportunities |

### 2. Enhanced Sell Logic (NEW)

V8 introduces two new filters specifically for improving sell trade quality:

#### Stochastic Filter
```mql5
input bool EnableStochasticFilter = true;   // Use Stochastic for sell confirmation
input int StochKPeriod = 14;                // Stochastic %K Period
input int StochDPeriod = 3;                 // Stochastic %D Period
input int StochSlowing = 3;                 // Stochastic Slowing
input int Stoch_Overbought = 80;            // Stochastic Overbought for sells
input int Stoch_Oversold = 20;              // Stochastic Oversold for buys
```

For sells, requires:
- Stochastic %K >= 80 (overbought), AND
- %K crossing below %D (momentum shift), OR
- Stochastic %K >= 85 (deeply overbought)

#### Trend Filter
```mql5
input bool EnableTrendFilter = true;        // Trend filter to avoid counter-trend sells
input int TrendEMAPeriod = 50;              // EMA period for trend detection (H1)
input double TrendExtensionATR = 3.0;       // ATR extension above trend EMA to allow sells
```

For sells, allows entry only when:
- Price is BELOW the H1 50-period EMA (downtrend), OR
- Price is 3+ ATR ABOVE the H1 EMA (extended, likely to revert)

This prevents shorting during normal uptrends, which historically underperform.

### 3. Preset Configurations

#### Aggressive (Default) - 3 Month Pass
```ini
RiskPerTradePercent=1.0
MaxTradesPerDay=3
DailyLossLimitPercent=2.9
RSI_Oversold=32
RequireKeltnerRetest=false
AllowSellTrades=false  ; Start with buys only until sell logic is verified
```

#### Conservative - Safer with Lower Returns
```ini
RiskPerTradePercent=0.75
MaxTradesPerDay=2
DailyLossLimitPercent=2.25
RSI_Oversold=30
RequireKeltnerRetest=true
AllowSellTrades=false
```

#### Experimental - With Enhanced Sells
```ini
RiskPerTradePercent=1.0
MaxTradesPerDay=3
AllowSellTrades=true
EnableStochasticFilter=true
EnableTrendFilter=true
Stoch_Overbought=80
TrendEMAPeriod=50
TrendExtensionATR=3.0
```

## New Parameters Reference

| Parameter | Default | Description |
|-----------|---------|-------------|
| EnableStochasticFilter | true | Use Stochastic for sell entries |
| StochKPeriod | 14 | Stochastic %K calculation period |
| StochDPeriod | 3 | Stochastic %D (signal) period |
| StochSlowing | 3 | Stochastic slowing value |
| Stoch_Overbought | 80 | Stochastic level for sell signals |
| Stoch_Oversold | 20 | Stochastic level for buy signals |
| EnableTrendFilter | true | Filter sells by H1 trend |
| TrendEMAPeriod | 50 | H1 EMA period for trend detection |
| TrendExtensionATR | 3.0 | ATR multiplier for "extended" definition |

## Risk Analysis

### Daily Risk Scenarios ($6,000 Account)

| Scenario | Trades | P/L | Notes |
|----------|--------|-----|-------|
| Best day | 3 wins | +$180 | +3% |
| Good day | 2 wins, 1 loss | +$60 | +1% |
| Break even | 1 win, 1 loss, 1 skip | $0 | 0% |
| Bad day | 1 win, 2 losses | -$60 | -1% |
| Worst day | 3 losses | -$180 | -3% (daily limit) |

### Monthly Projections

Assuming 60-70% win rate over 20 trading days:
- **Conservative estimate**: $150-180/month
- **Expected**: $200-220/month
- **Optimistic**: $250+/month

## Testing Recommendations

### Before Live Trading

1. **Backtest with V8 settings** (minimum 6 months historical data)
2. **Compare results to V7** - expect similar or better win rate
3. **Demo trade for 2-4 weeks** - verify behavior matches backtest
4. **Start with buys only** (`AllowSellTrades = false`)

### If Testing Enhanced Sells

1. Enable `AllowSellTrades = true`
2. Keep `EnableStochasticFilter = true` and `EnableTrendFilter = true`
3. Monitor sell entries in journal for filter confirmations
4. Compare sell win rate vs buy win rate
5. Only enable sells in live trading if backtest shows improvement

## Migration from V7

To migrate from V7 to V8:

1. Update `MagicNumber` if running both simultaneously (V8 default: 15138)
2. Review new parameter defaults - V8 is more aggressive
3. Consider starting with V8's conservative preset first
4. Monitor funded account limits more closely (V8 runs closer to limits)

## Expected Results

Based on V7 performance extrapolated with aggressive settings:

| Metric | V7 Actual | V8 Expected |
|--------|-----------|-------------|
| Annual Profit | $1,430 | **$2,000-2,500** |
| Monthly Average | $119 | **$166-208** |
| Win Rate | 73.74% | 68-72% |
| Trades per Year | 99 | 120-150 |
| Time to Pass $600 | 5 months | **3-3.5 months** |

## Changelog

### V8.00 (Initial Release)
- Aggressive default settings for 3-month funded pass
- Added Stochastic oscillator filter for enhanced sell entries
- Added H1 trend EMA filter to avoid counter-trend sells
- Relaxed RSI oversold from 30 to 32
- Increased risk per trade from 0.5% to 1.0%
- Increased max trades per day from 2 to 3
- Updated funded account limits to 2.9% daily / 5.8% overall
- Disabled RequireKeltnerRetest by default for more opportunities

## Disclaimer

V8's aggressive settings mean higher potential returns but also higher risk. The strategy runs closer to funded account limits, leaving less margin for error.

**Always backtest thoroughly before live trading.**

---

*V8 Release Date: January 2026*
