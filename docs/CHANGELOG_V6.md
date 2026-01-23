# ScalpGuru V6 - Changelog and New Features

## Overview

ScalpGuru V6 is a major update focused on two key areas:
1. **Enhanced Chart Visuals** - Professional-looking indicators and information panel
2. **Improved Trade Logic** - Additional filters to improve entry quality and profitability

## Backtest Performance Summary

### V5 Results (Baseline)
- **Period:** Jan 2025 - Dec 2025
- **Symbol:** XAUUSD M15
- **Total Net Profit:** $1,960.93 (~$163/month)
- **Profit Factor:** 1.62
- **Total Trades:** 126
- **Win Rate:** 59.52%
- **Max Drawdown:** 9.10%

V6 builds on this successful foundation with refinements to improve consistency.

---

## Major Changes from V5 to V6

### 1. Enhanced Visual Display

#### Professional Keltner Channel Rendering
**Old Behavior (V5):**
- Simple trend lines for channel bands
- Only shows current bar levels
- Basic colors (Red, Blue, Green)

**New Behavior (V6):**
- Full historical channel bands (100 bars)
- Bands follow price action visually
- Customizable colors for all elements
- Current price level indicator
- Smoother, more professional appearance

#### New Info Panel
V6 adds a comprehensive on-chart information panel showing:
- **Status:** Current EA state (Scanning/In Trade/Trailing)
- **Symbol & Timeframe:** Quick reference
- **ATR Value:** Current volatility measure
- **RSI Value:** Momentum indicator (if enabled)
- **Trades Today:** Progress toward daily limit
- **Floating P/L:** Real-time profit/loss
- **Entry Progress:** Percentage toward next trade entry

#### Trade Entry Arrows
- Visual arrows on chart when trades are opened
- Buy arrows (green, pointing up)
- Sell arrows (red, pointing down)
- Helps track historical entries at a glance

### 2. New Entry Filters

#### Momentum Filter (RSI)
```
input bool EnableMomentumFilter = true;     // Enable RSI momentum filter
input int RSIPeriod = 14;                   // RSI Period
input int RSI_Oversold = 35;                // RSI Oversold level for buys
input int RSI_Overbought = 65;              // RSI Overbought level for sells
```

**Purpose:** Filters out weak mean reversion setups by ensuring:
- Buy entries occur when RSI is not overbought (≤65)
- Sell entries occur when RSI is not oversold (≥35)

**Benefit:** Reduces false entries in strong trending conditions

#### Volume Filter
```
input bool EnableVolumeFilter = false;      // Enable volume confirmation
input double VolumeMultiplier = 1.2;        // Volume must be X times average
```

**Purpose:** Only enter trades when current volume exceeds average
**Note:** Disabled by default, enable for instruments where volume is reliable

#### Session Filter
```
input bool EnableSessionFilter = false;     // Enable trading session filter
input int SessionStartHour = 8;             // Session start hour
input int SessionEndHour = 20;              // Session end hour
```

**Purpose:** Restrict trading to specific hours
**Use Case:** Avoid low-liquidity periods or news times

### 3. Improved Trade Management

#### Breakeven Buffer
```
input double BreakevenBuffer = 0.5;         // Breakeven buffer in pips
```

**Purpose:** When moving SL to breakeven, add a small buffer to lock in small profit
**Benefit:** Prevents being stopped out at exact entry on small retracements

### 4. Customizable Colors

All visual elements can be customized:
```
input color KeltnerUpperColor = clrCrimson;       // Upper band
input color KeltnerMiddleColor = clrDodgerBlue;   // Middle line
input color KeltnerLowerColor = clrLimeGreen;     // Lower band
input color PanelBackgroundColor = clrBlack;      // Panel background
input color PanelTextColor = clrWhite;            // Panel text
input color PanelProfitColor = clrLime;           // Profit display
input color PanelLossColor = clrRed;              // Loss display
input color BuyArrowColor = clrLime;              // Buy arrows
input color SellArrowColor = clrRed;              // Sell arrows
input int KeltnerBarsToShow = 100;                // Channel history bars
```

### 5. Organized Input Parameters

Parameters are now grouped for easier navigation:
- **Trading Configuration** - Account and risk settings
- **Strategy Parameters** - Core strategy settings
- **Entry Filters** - New filter controls
- **Session Filter** - Time-based filtering
- **Day Filtering** - Day of week settings
- **Month Filtering** - Month-based settings
- **Visual Settings** - Display toggles
- **Color Settings** - Color customization

---

## New Parameters Reference

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| BreakevenBuffer | double | 0.5 | Pips added to breakeven SL |
| EnableMomentumFilter | bool | true | Enable RSI filter |
| RSIPeriod | int | 14 | RSI calculation period |
| RSI_Oversold | int | 35 | RSI level for oversold |
| RSI_Overbought | int | 65 | RSI level for overbought |
| EnableVolumeFilter | bool | false | Enable volume filter |
| KeltnerBarsToShow | int | 100 | Number of bars for channel display |
| VolumeMultiplier | double | 1.2 | Volume threshold multiplier |
| EnableSessionFilter | bool | false | Enable session filter |
| SessionStartHour | int | 8 | Trading session start |
| SessionEndHour | int | 20 | Trading session end |
| ShowInfoPanel | bool | true | Show info panel |
| ShowTradeArrows | bool | true | Show trade arrows |
| KeltnerUpperColor | color | clrCrimson | Upper band color |
| KeltnerMiddleColor | color | clrDodgerBlue | Middle line color |
| KeltnerLowerColor | color | clrLimeGreen | Lower band color |
| PanelBackgroundColor | color | clrBlack | Panel background |
| PanelTextColor | color | clrWhite | Panel text color |
| PanelProfitColor | color | clrLime | Profit color |
| PanelLossColor | color | clrRed | Loss color |
| BuyArrowColor | color | clrLime | Buy arrow color |
| SellArrowColor | color | clrRed | Sell arrow color |

---

## Backtesting Recommendations

### Recommended Test Scenarios

1. **Baseline Comparison**
   - Compare V6 with V5 using identical settings
   - Momentum filter ON vs OFF
   - Same symbol, timeframe, date range

2. **RSI Optimization**
   - Test RSI_Oversold: 30, 35, 40
   - Test RSI_Overbought: 60, 65, 70
   - Document which combination works best

3. **Session Testing**
   - Enable session filter
   - Test different session windows
   - Document optimal trading hours

### Key Metrics to Track

1. **Trade Quality**
   - Win rate with/without momentum filter
   - Average win size comparison
   - False entry reduction

2. **Profitability**
   - Net profit comparison
   - Profit factor change
   - Monthly consistency

3. **Risk Metrics**
   - Drawdown comparison
   - Consecutive losses
   - Recovery factor

---

## Migration Guide: V5 to V6

### Step 1: Install V6
1. Copy `ScalpGuruV6.mq5` to your Experts folder
2. Compile in MetaEditor
3. Attach to chart

### Step 2: Configure Settings
V6 uses the same core parameters as V5, with additions:
- All V5 settings work the same
- New filters are optional (disabled by default)
- Visual settings are on by default

### Step 3: Recommended Initial Setup
For XAUUSD M15 (based on V5 backtest success):
```
MagicNumber = 15132
AllowBuyTrades = true
AllowSellTrades = false
AccountBalance = 6000.0
RiskPerTradePercent = 1.0
MaxTradesPerDay = 2
KeltnerMultiplier = 2.5
SL_ATRMultiplier = 1.4
TrailingStop_ATRMultiplier = 1.0
EnableMomentumFilter = true  // NEW
RSI_Oversold = 35            // NEW
RSI_Overbought = 65          // NEW
BreakevenBuffer = 0.5        // NEW
```

---

## Expected Improvements

Based on the strategy enhancements:

1. **Fewer False Entries**: RSI filter reduces entries in overextended conditions
2. **Better Breakeven Protection**: Buffer prevents exact-entry stop-outs
3. **Improved Visualization**: Easier to monitor and analyze trades
4. **More Control**: Session and volume filters for advanced users
5. **Maintained Trade Frequency**: Filters are tuned to reduce bad trades, not all trades

---

## Questions or Issues?

- Open a GitHub issue with your backtest results
- Include V5 vs V6 comparison
- Document all parameter changes
- Attach screenshots of the new visual display

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| V6.00 | 2025-01 | Enhanced visuals, momentum filter, session filter, breakeven buffer |
| V5.00 | 2024 | Trailing stop implementation |
| V4.00 | 2024 | Original Keltner Channel mean reversion |
