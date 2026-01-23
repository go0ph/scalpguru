#property strict
#property description "ScalpGuru V7 - Optimized for Maximum Profitability"
#property description "Enhanced entry filters, improved trailing, and partial profit taking"
#property version   "7.00"
#property copyright "Created by go0ph"

//+------------------------------------------------------------------+
//| Input Parameters                                                  |
//+------------------------------------------------------------------+

//--- Trading Configuration
input group "=== Trading Configuration ==="
input int MagicNumber = 15137;            // Magic Number (V7)
input bool AllowSellTrades = false;         // Enable/disable sell trades
input bool AllowBuyTrades = true;           // Enable/disable buy trades
input double AccountBalance = 6000.0;       // Account balance for risk calculation
input double RiskPerTradePercent = 0.5;     // Risk per trade % (reduced for funded accounts)
input bool EnableRiskPerTrade = true;      // Enable risk per trade
input double ManualLotSize = 0.01;          // Manual lot size if risk per trade is disabled
input double MaxLossPercent = 1;         // Auto-close if loss exceeds % of balance
input int MaxTradesPerDay = 2;              // Max trades per day
input bool EnableMaxTradesPerDay = true;    // Enable/disable max trades per day limit

//--- Funded Account Protection (V7 - FundedNext Stellar 1-Step Compatible)
input group "=== Funded Account Protection ==="
input bool EnableFundedMode = true;          // Enable funded account protection
input double DailyLossLimitPercent = 2.5;    // Max daily loss % (FundedNext limit: 3%)
input double MaxDrawdownPercent = 5.5;       // Max overall drawdown % (FundedNext limit: 6%)
input double ProfitTargetPercent = 10.0;     // Profit target % (FundedNext target: 10%)

//--- Strategy Parameters
input group "=== Strategy Parameters ==="
input int ATRPeriod = 20;                   // ATR period
input int KeltnerPeriod = 20;               // Keltner Channel EMA period
input double KeltnerMultiplier = 2.5;       // Keltner ATR multiplier
input double SL_ATRMultiplier = 1.3;        // Initial SL ATR multiplier (tighter for better R:R)
input double TrailingStop_ATRMultiplier = 0.8;  // Trailing stop distance (ATR multiplier - tighter trail)
input double BreakevenBuffer = 0.3;         // Breakeven buffer in pips (reduced for earlier protection)

//--- Profit Taking Parameters (V7 NEW)
input group "=== Profit Taking (V7) ==="
input bool EnablePartialProfit = true;      // Enable partial profit at 1:1 R:R
input double PartialProfitPercent = 50.0;   // Percentage of position to close at 1:1 R:R
input double ExtendedTrailMultiplier = 1.5; // Extended trailing for remaining position after partial

//--- Entry Filters
input group "=== Entry Filters ==="
input bool EnableMomentumFilter = true;     // Enable RSI momentum filter
input int RSIPeriod = 14;                   // RSI Period
input int RSI_Oversold = 30;                // RSI Oversold level for buys (tighter for quality entries)
input int RSI_Overbought = 70;              // RSI Overbought level for sells (tighter for quality entries)
input bool EnableVolumeFilter = false;      // Enable volume confirmation
input double VolumeMultiplier = 1.2;        // Volume must be X times average
input bool EnableCandleConfirmation = true; // V7: Require bullish/bearish candle pattern for entry
input bool RequireKeltnerRetest = true;     // V7: Require price to retest Keltner after initial break

//--- Session Filter
input group "=== Session Filter ==="
input bool EnableSessionFilter = false;     // Enable trading session filter
input int SessionStartHour = 8;             // Session start hour (server time)
input int SessionEndHour = 20;              // Session end hour (server time)

//--- Day Filtering
input group "=== Day Filtering ==="
input bool EnableDaySkip = true;           // Enable/disable day skipping
input bool SkipMonday = false;              // Skip Monday (1)
input bool SkipTuesday = false;             // Skip Tuesday (2)
input bool SkipWednesday = false;           // Skip Wednesday (3)
input bool SkipThursday = false;            // Skip Thursday (4)
input bool SkipFriday = true;               // Skip Friday (5)

//--- Month Filtering
input group "=== Month Filtering ==="
input bool EnableMonthSkip = false;         // Enable/disable month skipping
input bool SkipJanuary = false;             // Skip January (1)
input bool SkipFebruary = false;            // Skip February (2)
input bool SkipMarch = false;               // Skip March (3)
input bool SkipApril = false;               // Skip April (4)
input bool SkipMay = false;                 // Skip May (5)
input bool SkipJune = false;                // Skip June (6)
input bool SkipJuly = false;                // Skip July (7)
input bool SkipAugust = false;              // Skip August (8)
input bool SkipSeptember = false;           // Skip September (9)
input bool SkipOctober = false;             // Skip October (10)
input bool SkipNovember = false;            // Skip November (11)
input bool SkipDecember = false;            // Skip December (12)

//--- Visual Settings
input group "=== Visual Settings ==="
input bool ShowKeltnerOnChart = true;       // Display Keltner Channel on Chart
input bool ShowInfoPanel = true;            // Display info panel
input bool ShowTradeArrows = true;          // Show entry/exit arrows on chart

//--- Color Settings
input group "=== Color Settings ==="
input color KeltnerUpperColor = clrCrimson;       // Upper band color
input color KeltnerMiddleColor = clrDodgerBlue;   // Middle line color
input color KeltnerLowerColor = clrLimeGreen;     // Lower band color
input color KeltnerFillColor = clrLavender;       // Channel fill color (semi-transparent)
input color PanelBackgroundColor = clrBlack;      // Info panel background
input color PanelTextColor = clrWhite;            // Info panel text color
input color PanelProfitColor = clrLime;           // Profit text color
input color PanelLossColor = clrRed;              // Loss text color
input color BuyArrowColor = clrLime;              // Buy entry arrow color
input color SellArrowColor = clrRed;              // Sell entry arrow color
input int KeltnerBarsToShow = 100;                // Number of historical bars for channel display

//--- Global Variables
double atrValue, keltnerUpper, keltnerLower, keltnerMid;
bool inTrade = false;
ENUM_TIMEFRAMES timeframe;
int atrHandle, maHandle, rsiHandle;
double atrBuffer[], maBuffer[], closeBuffer[], rsiBuffer[], highBuffer[], lowBuffer[], openBuffer[];
int tradesToday = 0;
datetime lastTradeDay = 0;
bool trailingActive = false;
double entryPrice = 0;
double initialSL = 0;
datetime lastBarTime = 0;  // Track bar changes for efficient redraw
bool partialProfitTaken = false;  // V7: Track if partial profit has been taken
double originalLotSize = 0;       // V7: Store original position size

// V7 Funded Account Protection Variables
double dailyStartBalance = 0;      // Balance at start of day
double overallStartBalance = 0;    // Balance at start of challenge
double dailyPnL = 0;               // Today's realized P/L
bool dailyLimitHit = false;        // Flag when daily limit is reached
bool drawdownLimitHit = false;     // Flag when overall drawdown limit is reached
bool profitTargetReached = false;  // Flag when profit target is reached

// Constants
#define PIPS_TO_POINTS 10  // Multiplier to convert pips to points
#define CANDLE_WICK_RATIO 0.6    // Wick must be >= 60% of candle range for hammer/shooting star
#define CANDLE_BODY_RATIO 0.4    // Body must be <= 40% of candle range for hammer/shooting star

//--- Include Libraries
#include <Trade\Trade.mqh>
CTrade trade;

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit()
{
   timeframe = Period();
   trade.SetExpertMagicNumber(MagicNumber);
   
   // Initialize ATR indicator
   atrHandle = iATR(_Symbol, timeframe, ATRPeriod);
   if(atrHandle == INVALID_HANDLE)
   {
      Print("[ERROR] Failed to create ATR indicator handle");
      return INIT_FAILED;
   }
   
   // Initialize MA indicator
   maHandle = iMA(_Symbol, timeframe, KeltnerPeriod, 0, MODE_EMA, PRICE_CLOSE);
   if(maHandle == INVALID_HANDLE)
   {
      Print("[ERROR] Failed to create MA indicator handle");
      IndicatorRelease(atrHandle);
      return INIT_FAILED;
   }
   
   // Initialize RSI indicator if enabled
   if(EnableMomentumFilter)
   {
      rsiHandle = iRSI(_Symbol, timeframe, RSIPeriod, PRICE_CLOSE);
      if(rsiHandle == INVALID_HANDLE)
      {
         Print("[ERROR] Failed to create RSI indicator handle");
         IndicatorRelease(atrHandle);
         IndicatorRelease(maHandle);
         return INIT_FAILED;
      }
      ArraySetAsSeries(rsiBuffer, true);
   }
   
   ArraySetAsSeries(atrBuffer, true);
   ArraySetAsSeries(maBuffer, true);
   ArraySetAsSeries(closeBuffer, true);
   ArraySetAsSeries(highBuffer, true);    // V7: For candle confirmation
   ArraySetAsSeries(lowBuffer, true);     // V7: For candle confirmation
   ArraySetAsSeries(openBuffer, true);    // V7: For candle confirmation
   
   // Validate input parameters
   if(ATRPeriod <= 0 || KeltnerPeriod <= 0)
   {
      Print("[ERROR] Invalid indicator periods. ATRPeriod and KeltnerPeriod must be > 0");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(SL_ATRMultiplier <= 0 || KeltnerMultiplier <= 0 || TrailingStop_ATRMultiplier <= 0)
   {
      Print("[ERROR] Invalid multipliers. SL_ATRMultiplier, KeltnerMultiplier, and TrailingStop_ATRMultiplier must be > 0");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(ManualLotSize <= 0)
   {
      Print("[ERROR] Invalid ManualLotSize: ", ManualLotSize, ". Must be > 0");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(MaxLossPercent <= 0 || MaxLossPercent > 100)
   {
      Print("[ERROR] Invalid MaxLossPercent: ", MaxLossPercent, ". Must be between 0 and 100");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(RiskPerTradePercent <= 0 || RiskPerTradePercent > 100)
   {
      Print("[ERROR] Invalid RiskPerTradePercent: ", RiskPerTradePercent, ". Must be between 0 and 100");
      return INIT_PARAMETERS_INCORRECT;
   }
   
   // V7: Validate funded account protection parameters
   if(EnableFundedMode)
   {
      if(DailyLossLimitPercent <= 0 || DailyLossLimitPercent > 100)
      {
         Print("[ERROR] Invalid DailyLossLimitPercent: ", DailyLossLimitPercent, ". Must be between 0 and 100");
         return INIT_PARAMETERS_INCORRECT;
      }
      if(MaxDrawdownPercent <= 0 || MaxDrawdownPercent > 100)
      {
         Print("[ERROR] Invalid MaxDrawdownPercent: ", MaxDrawdownPercent, ". Must be between 0 and 100");
         return INIT_PARAMETERS_INCORRECT;
      }
      if(ProfitTargetPercent <= 0)
      {
         Print("[ERROR] Invalid ProfitTargetPercent: ", ProfitTargetPercent, ". Must be > 0");
         return INIT_PARAMETERS_INCORRECT;
      }
   }
   
   // V7: Validate partial profit parameters
   if(EnablePartialProfit)
   {
      if(PartialProfitPercent <= 0 || PartialProfitPercent > 100)
      {
         Print("[ERROR] Invalid PartialProfitPercent: ", PartialProfitPercent, ". Must be between 0 and 100");
         return INIT_PARAMETERS_INCORRECT;
      }
      if(ExtendedTrailMultiplier <= 0)
      {
         Print("[ERROR] Invalid ExtendedTrailMultiplier: ", ExtendedTrailMultiplier, ". Must be > 0");
         return INIT_PARAMETERS_INCORRECT;
      }
   }
   
   if(!AllowBuyTrades && !AllowSellTrades)
   {
      Print("[ERROR] Both AllowBuyTrades and AllowSellTrades are disabled. At least one must be enabled");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(MaxTradesPerDay <= 0)
   {
      Print("[ERROR] Invalid MaxTradesPerDay: ", MaxTradesPerDay, ". Must be > 0");
      return INIT_PARAMETERS_INCORRECT;
   }
   
   MqlDateTime dt;
   TimeToStruct(TimeTradeServer(), dt);
   dt.hour = 0; dt.min = 0; dt.sec = 0;
   lastTradeDay = StructToTime(dt);
   
   // V7: Initialize funded account protection
   if(EnableFundedMode)
   {
      overallStartBalance = AccountBalance;  // Use input balance as challenge start
      dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      dailyPnL = 0;
      dailyLimitHit = false;
      drawdownLimitHit = false;
      profitTargetReached = false;
      Print("[FUNDED] Mode enabled - Daily limit: ", DailyLossLimitPercent, "%, Max DD: ", MaxDrawdownPercent, "%, Target: ", ProfitTargetPercent, "%");
      Print("[FUNDED] For $", AccountBalance, " account: Daily limit $", DoubleToString(AccountBalance * DailyLossLimitPercent / 100, 2),
            ", Max DD $", DoubleToString(AccountBalance * MaxDrawdownPercent / 100, 2),
            ", Target $", DoubleToString(AccountBalance * ProfitTargetPercent / 100, 2));
   }
   
   // Create info panel
   if(ShowInfoPanel)
   {
      CreateInfoPanel();
   }
   
   Print("[INIT] ScalpGuru V7 Started - Funded Account Edition");
   Print("[INIT] Timeframe: ", EnumToString(timeframe));
   Print("[INIT] ATR Period: ", ATRPeriod, ", Keltner Period: ", KeltnerPeriod);
   Print("[INIT] Keltner Multiplier: ", KeltnerMultiplier, ", SL ATR Multiplier: ", SL_ATRMultiplier);
   Print("[INIT] Trailing Stop ATR Multiplier: ", TrailingStop_ATRMultiplier);
   Print("[INIT] Breakeven Buffer: ", BreakevenBuffer, " pips");
   Print("[INIT] Momentum Filter: ", EnableMomentumFilter ? "Enabled" : "Disabled");
   Print("[INIT] Volume Filter: ", EnableVolumeFilter ? "Enabled" : "Disabled");
   Print("[INIT] Session Filter: ", EnableSessionFilter ? "Enabled" : "Disabled");
   Print("[INIT] Partial Profit: ", EnablePartialProfit ? "Enabled" : "Disabled");
   Print("[INIT] Candle Confirmation: ", EnableCandleConfirmation ? "Enabled" : "Disabled");
   Print("[INIT] Funded Mode: ", EnableFundedMode ? "Enabled" : "Disabled");
   Print("[INIT] Max Trades Per Day: ", MaxTradesPerDay);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Clean up chart objects
   ObjectsDeleteAll(0, "KC_");
   ObjectsDeleteAll(0, "SG_");
   
   IndicatorRelease(atrHandle);
   IndicatorRelease(maHandle);
   if(EnableMomentumFilter && rsiHandle != INVALID_HANDLE)
      IndicatorRelease(rsiHandle);
   
   Print("[DEINIT] ScalpGuru V7 Stopped, Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Create Info Panel on Chart                                        |
//+------------------------------------------------------------------+
void CreateInfoPanel()
{
   int panelX = 10;
   int panelY = 30;
   int panelWidth = 220;
   int panelHeight = 200;
   
   // Create background rectangle
   if(!ObjectCreate(0, "SG_PanelBG", OBJ_RECTANGLE_LABEL, 0, 0, 0))
   {
      ObjectDelete(0, "SG_PanelBG");
      ObjectCreate(0, "SG_PanelBG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   }
   ObjectSetInteger(0, "SG_PanelBG", OBJPROP_XDISTANCE, panelX);
   ObjectSetInteger(0, "SG_PanelBG", OBJPROP_YDISTANCE, panelY);
   ObjectSetInteger(0, "SG_PanelBG", OBJPROP_XSIZE, panelWidth);
   ObjectSetInteger(0, "SG_PanelBG", OBJPROP_YSIZE, panelHeight);
   ObjectSetInteger(0, "SG_PanelBG", OBJPROP_BGCOLOR, PanelBackgroundColor);
   ObjectSetInteger(0, "SG_PanelBG", OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, "SG_PanelBG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "SG_PanelBG", OBJPROP_COLOR, clrDodgerBlue);
   ObjectSetInteger(0, "SG_PanelBG", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, "SG_PanelBG", OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, "SG_PanelBG", OBJPROP_BACK, false);
   ObjectSetInteger(0, "SG_PanelBG", OBJPROP_SELECTABLE, false);
   
   // Create title
   CreateLabel("SG_Title", "═══ ScalpGuru V7 ═══", panelX + 25, panelY + 10, clrGold, 10, "Arial Bold");
   
   // Create status labels
   CreateLabel("SG_Status", "Status: Scanning", panelX + 10, panelY + 35, PanelTextColor, 9, "Arial");
   CreateLabel("SG_Symbol", "Symbol: " + _Symbol, panelX + 10, panelY + 55, PanelTextColor, 9, "Arial");
   CreateLabel("SG_TF", "Timeframe: " + EnumToString(Period()), panelX + 10, panelY + 75, PanelTextColor, 9, "Arial");
   CreateLabel("SG_ATR", "ATR: --", panelX + 10, panelY + 95, clrCyan, 9, "Arial");
   CreateLabel("SG_RSI", "RSI: --", panelX + 10, panelY + 115, clrCyan, 9, "Arial");
   CreateLabel("SG_Trades", "Trades Today: 0/" + IntegerToString(MaxTradesPerDay), panelX + 10, panelY + 135, PanelTextColor, 9, "Arial");
   CreateLabel("SG_PnL", "Floating P/L: $0.00", panelX + 10, panelY + 155, PanelTextColor, 9, "Arial");
   CreateLabel("SG_Progress", "Entry Progress: 0%", panelX + 10, panelY + 175, clrYellow, 9, "Arial");
}

//+------------------------------------------------------------------+
//| Create Label Helper Function                                      |
//+------------------------------------------------------------------+
void CreateLabel(string name, string text, int x, int y, color clr, int fontSize, string fontName)
{
   if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
   {
      ObjectDelete(0, name);
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   }
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, fontName);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Update Info Panel                                                 |
//+------------------------------------------------------------------+
void UpdateInfoPanel()
{
   if(!ShowInfoPanel) return;
   
   // Update status
   string status = inTrade ? "In Trade" : "Scanning";
   if(trailingActive) status = "Trailing";
   ObjectSetString(0, "SG_Status", OBJPROP_TEXT, "Status: " + status);
   ObjectSetInteger(0, "SG_Status", OBJPROP_COLOR, inTrade ? clrLime : clrYellow);
   
   // Update ATR
   ObjectSetString(0, "SG_ATR", OBJPROP_TEXT, "ATR: " + DoubleToString(atrValue, _Digits));
   
   // Update RSI if enabled
   if(EnableMomentumFilter && ArraySize(rsiBuffer) > 0)
   {
      double rsi = rsiBuffer[0];
      string rsiText = "RSI: " + DoubleToString(rsi, 1);
      ObjectSetString(0, "SG_RSI", OBJPROP_TEXT, rsiText);
      color rsiColor = clrCyan;
      if(rsi < RSI_Oversold) rsiColor = clrLime;
      else if(rsi > RSI_Overbought) rsiColor = clrRed;
      ObjectSetInteger(0, "SG_RSI", OBJPROP_COLOR, rsiColor);
   }
   else
   {
      ObjectSetString(0, "SG_RSI", OBJPROP_TEXT, "RSI: N/A");
   }
   
   // Update trades count
   ObjectSetString(0, "SG_Trades", OBJPROP_TEXT, "Trades Today: " + IntegerToString(tradesToday) + "/" + IntegerToString(MaxTradesPerDay));
   
   // Update floating P/L
   double floatingPnL = GetFloatingPnL();
   string pnlText = "Floating P/L: $" + DoubleToString(floatingPnL, 2);
   ObjectSetString(0, "SG_PnL", OBJPROP_TEXT, pnlText);
   ObjectSetInteger(0, "SG_PnL", OBJPROP_COLOR, floatingPnL >= 0 ? PanelProfitColor : PanelLossColor);
   
   // Update entry progress
   double progress = CalculateTradeProgress();
   ObjectSetString(0, "SG_Progress", OBJPROP_TEXT, "Entry Progress: " + DoubleToString(progress, 0) + "%");
   color progressColor = clrYellow;
   if(progress >= 90) progressColor = clrLime;
   else if(progress >= 50) progressColor = clrOrange;
   ObjectSetInteger(0, "SG_Progress", OBJPROP_COLOR, progressColor);
}

//+------------------------------------------------------------------+
//| Get Floating P/L for all positions                                |
//+------------------------------------------------------------------+
double GetFloatingPnL()
{
   double pnl = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber)
      {
         pnl += PositionGetDouble(POSITION_PROFIT);
      }
   }
   return pnl;
}

//+------------------------------------------------------------------+
//| Calculate Trade Progress Percentage                                |
//+------------------------------------------------------------------+
double CalculateTradeProgress()
{
   if(inTrade) return 100.0;
   
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double progress = 0.0;
   
   // Buy trade progress: 0% at keltnerMid, 100% when entry triggers
   if(AllowBuyTrades && currentPrice <= keltnerMid)
   {
      double distanceToLower = MathMax(keltnerMid - currentPrice, 0);
      double totalDistance = MathMax(keltnerMid - keltnerLower, 0.01);
      if(totalDistance > 0)
      {
         progress = MathMin((distanceToLower / totalDistance) * 90.0, 90.0);
         if(ArraySize(closeBuffer) > 2 && closeBuffer[2] < keltnerLower)
         {
            progress = MathMin(progress + 9.0, 99.0);
         }
      }
   }
   
   // Sell trade progress
   if(AllowSellTrades && currentPrice >= keltnerMid)
   {
      double distanceToUpper = MathMax(currentPrice - keltnerMid, 0);
      double totalDistance = MathMax(keltnerUpper - keltnerMid, 0.01);
      if(totalDistance > 0)
      {
         double sellProgress = MathMin((distanceToUpper / totalDistance) * 90.0, 90.0);
         if(ArraySize(closeBuffer) > 2 && closeBuffer[2] > keltnerUpper)
         {
            sellProgress = MathMin(sellProgress + 9.0, 99.0);
         }
         progress = MathMax(progress, sellProgress);
      }
   }
   
   return progress;
}

//+------------------------------------------------------------------+
//| Count open positions for this EA                                  |
//+------------------------------------------------------------------+
int CountOpenPositions()
{
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber)
      {
         count++;
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| Check if momentum filter passes                                   |
//+------------------------------------------------------------------+
bool CheckMomentumFilter(bool isBuy)
{
   if(!EnableMomentumFilter) return true;
   
   if(CopyBuffer(rsiHandle, 0, 0, 3, rsiBuffer) <= 0)
   {
      Print("[WARNING] Failed to get RSI data, allowing trade");
      return true;
   }
   
   double rsi = rsiBuffer[0];
   
   if(isBuy)
   {
      // For buys, RSI should be oversold or neutral (not overbought)
      return rsi <= RSI_Overbought;
   }
   else
   {
      // For sells, RSI should be overbought or neutral (not oversold)
      return rsi >= RSI_Oversold;
   }
}

//+------------------------------------------------------------------+
//| Check if volume filter passes                                     |
//+------------------------------------------------------------------+
bool CheckVolumeFilter()
{
   if(!EnableVolumeFilter) return true;
   
   // Get current and average volume
   long currentVolume = iVolume(_Symbol, timeframe, 0);
   
   // Calculate average volume over last 20 bars
   long totalVolume = 0;
   for(int i = 1; i <= 20; i++)
   {
      totalVolume += iVolume(_Symbol, timeframe, i);
   }
   double avgVolume = totalVolume / 20.0;
   
   return (currentVolume >= avgVolume * VolumeMultiplier);
}

//+------------------------------------------------------------------+
//| V7: Check candle pattern confirmation for entry                   |
//+------------------------------------------------------------------+
bool CheckCandleConfirmation(bool isBuy)
{
   if(!EnableCandleConfirmation) return true;
   
   // Need at least 3 candles of data
   if(ArraySize(closeBuffer) < 3 || ArraySize(openBuffer) < 3) return true;
   
   double close1 = closeBuffer[1];  // Previous closed candle
   double open1 = openBuffer[1];
   double high1 = highBuffer[1];
   double low1 = lowBuffer[1];
   double candleBody = MathAbs(close1 - open1);
   double candleRange = high1 - low1;
   
   if(isBuy)
   {
      // For buys, look for bullish candle patterns:
      // 1. Bullish candle (close > open)
      // 2. Or hammer pattern (small body at top, long lower wick)
      bool isBullish = close1 > open1;
      bool isHammer = (candleRange > 0) && 
                      ((close1 - low1) > CANDLE_WICK_RATIO * candleRange) && 
                      (candleBody < CANDLE_BODY_RATIO * candleRange);
      
      // Also accept if current candle is showing bullish momentum
      double currentClose = closeBuffer[0];
      double currentOpen = openBuffer[0];
      bool currentBullish = currentClose > currentOpen;
      
      return isBullish || isHammer || currentBullish;
   }
   else
   {
      // For sells, look for bearish candle patterns:
      // 1. Bearish candle (close < open)
      // 2. Or shooting star pattern (small body at bottom, long upper wick)
      bool isBearish = close1 < open1;
      bool isShootingStar = (candleRange > 0) && 
                            ((high1 - close1) > CANDLE_WICK_RATIO * candleRange) && 
                            (candleBody < CANDLE_BODY_RATIO * candleRange);
      
      // Also accept if current candle is showing bearish momentum
      double currentClose = closeBuffer[0];
      double currentOpen = openBuffer[0];
      bool currentBearish = currentClose < currentOpen;
      
      return isBearish || isShootingStar || currentBearish;
   }
}

//+------------------------------------------------------------------+
//| Check if within trading session                                   |
//+------------------------------------------------------------------+
bool CheckSessionFilter()
{
   if(!EnableSessionFilter) return true;
   
   MqlDateTime dt;
   TimeToStruct(TimeTradeServer(), dt);
   int currentHour = dt.hour;
   
   if(SessionStartHour < SessionEndHour)
   {
      return (currentHour >= SessionStartHour && currentHour < SessionEndHour);
   }
   else
   {
      // Handle overnight sessions (e.g., 20:00 - 08:00)
      return (currentHour >= SessionStartHour || currentHour < SessionEndHour);
   }
}

//+------------------------------------------------------------------+
//| V7: Check funded account limits and protection                    |
//+------------------------------------------------------------------+
bool CheckFundedAccountLimits()
{
   if(!EnableFundedMode) return true;  // No restrictions
   
   double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   double floatingPnL = GetFloatingPnL();
   
   // Use the lower of balance or equity for drawdown calculation
   double effectiveEquity = MathMin(currentBalance, currentEquity);
   
   // Calculate overall drawdown from challenge start (ensure non-negative)
   double overallDrawdown = MathMax(0, overallStartBalance - effectiveEquity);
   double overallDrawdownPercent = (overallDrawdown / overallStartBalance) * 100;
   double maxAllowedDrawdown = overallStartBalance * (MaxDrawdownPercent / 100);
   
   // Check if profit target reached (use effectiveEquity for consistency)
   double profit = effectiveEquity - overallStartBalance;
   double targetAmount = overallStartBalance * (ProfitTargetPercent / 100);
   if(profit >= targetAmount && !profitTargetReached)
   {
      profitTargetReached = true;
      Print("[FUNDED] 🎉 PROFIT TARGET REACHED! Profit: $", DoubleToString(profit, 2), " (", DoubleToString((profit/overallStartBalance)*100, 2), "%)");
   }
   
   // Check overall drawdown limit - CRITICAL
   if(overallDrawdown >= maxAllowedDrawdown * 0.9)  // Warning at 90% of limit
   {
      if(!drawdownLimitHit)
      {
         Print("[FUNDED] ⚠️ WARNING: Approaching max drawdown! Current DD: ", DoubleToString(overallDrawdownPercent, 2), "%, Limit: ", MaxDrawdownPercent, "%");
      }
   }
   
   if(overallDrawdown >= maxAllowedDrawdown)
   {
      if(!drawdownLimitHit)
      {
         drawdownLimitHit = true;
         Print("[FUNDED] 🛑 MAX DRAWDOWN LIMIT HIT! Stopping all trading. DD: $", DoubleToString(overallDrawdown, 2));
         // Close any open positions to prevent further loss
         CloseAllPositions();
      }
      return false;
   }
   
   // Calculate daily P/L (realized + floating)
   double dailyEquityChange = effectiveEquity - dailyStartBalance;
   double dailyLossLimit = overallStartBalance * (DailyLossLimitPercent / 100);
   
   // Check daily loss limit
   if(dailyEquityChange <= -dailyLossLimit * 0.8)  // Warning at 80% of limit
   {
      if(!dailyLimitHit)
      {
         Print("[FUNDED] ⚠️ WARNING: Approaching daily loss limit! Daily loss: $", DoubleToString(-dailyEquityChange, 2), ", Limit: $", DoubleToString(dailyLossLimit, 2));
      }
   }
   
   if(dailyEquityChange <= -dailyLossLimit)
   {
      if(!dailyLimitHit)
      {
         dailyLimitHit = true;
         Print("[FUNDED] 🛑 DAILY LOSS LIMIT HIT! No more trades today. Loss: $", DoubleToString(-dailyEquityChange, 2));
         // Close any open positions
         CloseAllPositions();
      }
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| V7: Close all open positions (for funded account protection)      |
//+------------------------------------------------------------------+
void CloseAllPositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber)
      {
         if(trade.PositionClose(ticket))
         {
            Print("[FUNDED] Emergency close position #", ticket);
         }
      }
   }
   inTrade = false;
   trailingActive = false;
   partialProfitTaken = false;
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick()
{
   datetime serverTime = TimeTradeServer();
   MqlDateTime timeStruct;
   TimeToStruct(serverTime, timeStruct);
   int currentDay = timeStruct.day_of_week;
   int currentMonth = timeStruct.mon;
   
   MqlDateTime dt;
   TimeToStruct(serverTime, dt);
   dt.hour = 0; dt.min = 0; dt.sec = 0;
   datetime todayStart = StructToTime(dt);
   
   // Reset daily counters at start of new day
   if(todayStart != lastTradeDay)
   {
      tradesToday = 0;
      lastTradeDay = todayStart;
      
      // V7: Reset daily funded account limits
      if(EnableFundedMode)
      {
         dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
         dailyLimitHit = false;
         Print("[FUNDED] New trading day - Daily balance reset to $", DoubleToString(dailyStartBalance, 2));
      }
   }
   
   // V7: Check funded account limits FIRST
   if(EnableFundedMode && !CheckFundedAccountLimits())
   {
      // Still manage existing trades but don't open new ones
      ManageTrades();
      if(ShowInfoPanel) UpdateInfoPanel();
      return;
   }
   
   // Check for month skip
   bool skipCurrentMonth = false;
   if(EnableMonthSkip)
   {
      if((currentMonth == 1 && SkipJanuary) ||
         (currentMonth == 2 && SkipFebruary) ||
         (currentMonth == 3 && SkipMarch) ||
         (currentMonth == 4 && SkipApril) ||
         (currentMonth == 5 && SkipMay) ||
         (currentMonth == 6 && SkipJune) ||
         (currentMonth == 7 && SkipJuly) ||
         (currentMonth == 8 && SkipAugust) ||
         (currentMonth == 9 && SkipSeptember) ||
         (currentMonth == 10 && SkipOctober) ||
         (currentMonth == 11 && SkipNovember) ||
         (currentMonth == 12 && SkipDecember))
      {
         skipCurrentMonth = true;
      }
   }
   
   // Check for day skip
   bool skipCurrentDay = false;
   if(EnableDaySkip)
   {
      if((currentDay == 1 && SkipMonday) ||
         (currentDay == 2 && SkipTuesday) ||
         (currentDay == 3 && SkipWednesday) ||
         (currentDay == 4 && SkipThursday) ||
         (currentDay == 5 && SkipFriday))
      {
         skipCurrentDay = true;
      }
   }
   
   bool isSkipped = skipCurrentMonth || skipCurrentDay;
   
   // Always update indicators for trade management
   if(CopyBuffer(atrHandle, 0, 0, 3, atrBuffer) <= 0 || CopyClose(_Symbol, timeframe, 0, 5, closeBuffer) <= 0)
   {
      Print("[ERROR] Failed to update indicators: ", GetLastError());
      return;
   }
   atrValue = atrBuffer[0];
   
   // V7: Copy OHLC data for candle confirmation
   CopyHigh(_Symbol, timeframe, 0, 5, highBuffer);
   CopyLow(_Symbol, timeframe, 0, 5, lowBuffer);
   CopyOpen(_Symbol, timeframe, 0, 5, openBuffer);
   ArraySetAsSeries(highBuffer, true);
   ArraySetAsSeries(lowBuffer, true);
   ArraySetAsSeries(openBuffer, true);
   
   // Update RSI if enabled
   if(EnableMomentumFilter)
   {
      CopyBuffer(rsiHandle, 0, 0, 3, rsiBuffer);
   }
   
   if(!isSkipped)
   {
      if(CopyBuffer(maHandle, 0, 0, 3, maBuffer) <= 0)
      {
         Print("[ERROR] Failed to update MA buffer: ", GetLastError());
         return;
      }
      
      double ema = maBuffer[0];
      keltnerUpper = MathMax(ema + KeltnerMultiplier * atrValue, 0);
      keltnerLower = MathMax(ema - KeltnerMultiplier * atrValue, 0);
      keltnerMid = ema;
      
      double close2 = closeBuffer[2];
      double close1 = closeBuffer[1];
      double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      
      // Draw Keltner Channels
      if(ShowKeltnerOnChart)
      {
         DrawKeltnerChannels();
      }
      else
      {
         ObjectsDeleteAll(0, "KC_");
         ChartRedraw();
      }
      
      // Check for new trade entries
      if(!inTrade && (!EnableMaxTradesPerDay || tradesToday < MaxTradesPerDay))
      {
         // Check session filter
         if(CheckSessionFilter())
         {
            // V7 Enhanced Buy entry condition with candle confirmation
            if(AllowBuyTrades && close2 < keltnerLower && currentPrice > keltnerLower)
            {
               if(CheckMomentumFilter(true) && CheckVolumeFilter() && CheckCandleConfirmation(true))
               {
                  // V7: Optional Keltner retest requirement
                  bool retestOk = !RequireKeltnerRetest || (close1 <= keltnerLower);
                  if(retestOk)
                  {
                     OpenBuyTrade();
                  }
               }
            }
            // V7 Enhanced Sell entry condition with candle confirmation
            else if(AllowSellTrades && close2 > keltnerUpper && currentPrice < keltnerUpper)
            {
               if(CheckMomentumFilter(false) && CheckVolumeFilter() && CheckCandleConfirmation(false))
               {
                  // V7: Optional Keltner retest requirement
                  bool retestOk = !RequireKeltnerRetest || (close1 >= keltnerUpper);
                  if(retestOk)
                  {
                     OpenSellTrade();
                  }
               }
            }
         }
      }
   }
   
   ManageTrades();
   
   // Update info panel
   if(ShowInfoPanel)
   {
      UpdateInfoPanel();
   }
}

//+------------------------------------------------------------------+
//| Draw Keltner Channels on Chart - Enhanced Visuals                 |
//+------------------------------------------------------------------+
void DrawKeltnerChannels()
{
   // Only redraw channel when a new bar forms to improve performance
   datetime currentBarTime = iTime(_Symbol, timeframe, 0);
   bool isNewBar = (currentBarTime != lastBarTime);
   
   if(isNewBar)
   {
      lastBarTime = currentBarTime;
      
      int barsToShow = KeltnerBarsToShow;
      datetime times[];
      
      ArraySetAsSeries(times, true);
      CopyTime(_Symbol, timeframe, 0, barsToShow, times);
      
      // Create arrays for channel values
      double upperBand[], middleBand[], lowerBand[];
      double tempATR[], tempMA[];
      ArrayResize(upperBand, barsToShow);
      ArrayResize(middleBand, barsToShow);
      ArrayResize(lowerBand, barsToShow);
      
      // Get historical ATR and MA values
      CopyBuffer(atrHandle, 0, 0, barsToShow, tempATR);
      CopyBuffer(maHandle, 0, 0, barsToShow, tempMA);
      ArraySetAsSeries(tempATR, true);
      ArraySetAsSeries(tempMA, true);
      
      // Calculate channel values for each bar
      for(int i = 0; i < barsToShow; i++)
      {
         middleBand[i] = tempMA[i];
         upperBand[i] = tempMA[i] + KeltnerMultiplier * tempATR[i];
         lowerBand[i] = tempMA[i] - KeltnerMultiplier * tempATR[i];
      }
      
      // Draw or update upper band segments
      for(int i = 0; i < barsToShow - 1; i++)
      {
         string objName = "KC_U" + IntegerToString(i);
         if(ObjectFind(0, objName) < 0)
         {
            ObjectCreate(0, objName, OBJ_TREND, 0, times[i+1], upperBand[i+1], times[i], upperBand[i]);
            ObjectSetInteger(0, objName, OBJPROP_COLOR, KeltnerUpperColor);
            ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, objName, OBJPROP_WIDTH, 2);
            ObjectSetInteger(0, objName, OBJPROP_RAY, false);
            ObjectSetInteger(0, objName, OBJPROP_BACK, true);
         }
         else
         {
            ObjectMove(0, objName, 0, times[i+1], upperBand[i+1]);
            ObjectMove(0, objName, 1, times[i], upperBand[i]);
         }
      }
      
      // Draw or update middle band segments
      for(int i = 0; i < barsToShow - 1; i++)
      {
         string objName = "KC_M" + IntegerToString(i);
         if(ObjectFind(0, objName) < 0)
         {
            ObjectCreate(0, objName, OBJ_TREND, 0, times[i+1], middleBand[i+1], times[i], middleBand[i]);
            ObjectSetInteger(0, objName, OBJPROP_COLOR, KeltnerMiddleColor);
            ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_DOT);
            ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
            ObjectSetInteger(0, objName, OBJPROP_RAY, false);
            ObjectSetInteger(0, objName, OBJPROP_BACK, true);
         }
         else
         {
            ObjectMove(0, objName, 0, times[i+1], middleBand[i+1]);
            ObjectMove(0, objName, 1, times[i], middleBand[i]);
         }
      }
      
      // Draw or update lower band segments
      for(int i = 0; i < barsToShow - 1; i++)
      {
         string objName = "KC_L" + IntegerToString(i);
         if(ObjectFind(0, objName) < 0)
         {
            ObjectCreate(0, objName, OBJ_TREND, 0, times[i+1], lowerBand[i+1], times[i], lowerBand[i]);
            ObjectSetInteger(0, objName, OBJPROP_COLOR, KeltnerLowerColor);
            ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, objName, OBJPROP_WIDTH, 2);
            ObjectSetInteger(0, objName, OBJPROP_RAY, false);
            ObjectSetInteger(0, objName, OBJPROP_BACK, true);
         }
         else
         {
            ObjectMove(0, objName, 0, times[i+1], lowerBand[i+1]);
            ObjectMove(0, objName, 1, times[i], lowerBand[i]);
         }
      }
   }
   
   // Always update current price level indicator (lightweight operation)
   double currentBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   string priceLabel = "KC_PriceLevel";
   if(ObjectFind(0, priceLabel) < 0)
   {
      ObjectCreate(0, priceLabel, OBJ_HLINE, 0, 0, currentBid);
      ObjectSetInteger(0, priceLabel, OBJPROP_COLOR, clrGray);
      ObjectSetInteger(0, priceLabel, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, priceLabel, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, priceLabel, OBJPROP_BACK, true);
   }
   else
   {
      ObjectSetDouble(0, priceLabel, OBJPROP_PRICE, currentBid);
   }
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Draw Trade Entry Arrow                                           |
//+------------------------------------------------------------------+
void DrawTradeArrow(bool isBuy, double price, datetime time)
{
   if(!ShowTradeArrows) return;
   
   // Use timestamp-based naming to avoid unbounded counter growth
   string arrowName = "SG_Arrow_" + IntegerToString((long)time);
   
   ObjectCreate(0, arrowName, OBJ_ARROW, 0, time, price);
   ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, isBuy ? 233 : 234); // Up/Down arrows
   ObjectSetInteger(0, arrowName, OBJPROP_COLOR, isBuy ? BuyArrowColor : SellArrowColor);
   ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, 3);
   ObjectSetInteger(0, arrowName, OBJPROP_ANCHOR, isBuy ? ANCHOR_TOP : ANCHOR_BOTTOM);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Open Buy Trade                                                    |
//+------------------------------------------------------------------+
void OpenBuyTrade()
{
   double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double lotSize = CalculateLotSize(price);
   double sl = NormalizeDouble(price - SL_ATRMultiplier * atrValue, _Digits);
   double takeProfit = 0;
   double margin;
   
   if(!OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lotSize, price, margin))
   {
      Print("[ERROR] Failed to calculate margin for Buy trade: ", GetLastError());
      return;
   }
   
   if(AccountInfoDouble(ACCOUNT_MARGIN_FREE) < margin)
   {
      Print("[ERROR] Insufficient margin for Buy trade. Required: ", margin, ", Available: ", AccountInfoDouble(ACCOUNT_MARGIN_FREE));
      return;
   }
   
   if(trade.Buy(lotSize, _Symbol, price, sl, takeProfit, "ScalpGuru V7 Buy"))
   {
      inTrade = true;
      tradesToday++;
      trailingActive = false;
      partialProfitTaken = false;  // V7: Reset partial profit flag
      originalLotSize = lotSize;    // V7: Store original lot size
      entryPrice = price;
      initialSL = sl;
      
      // Draw entry arrow
      DrawTradeArrow(true, price, TimeCurrent());
      
      Print("[TRADE] Buy opened: Price=", DoubleToString(price, _Digits), 
            ", Lots=", DoubleToString(lotSize, 2), 
            ", SL=", DoubleToString(sl, _Digits), 
            ", Trades today: ", tradesToday);
   }
   else
   {
      Print("[ERROR] Failed to open Buy trade: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Open Sell Trade                                                   |
//+------------------------------------------------------------------+
void OpenSellTrade()
{
   double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double lotSize = CalculateLotSize(price);
   double sl = NormalizeDouble(price + SL_ATRMultiplier * atrValue, _Digits);
   double takeProfit = 0;
   double margin;
   
   if(!OrderCalcMargin(ORDER_TYPE_SELL, _Symbol, lotSize, price, margin))
   {
      Print("[ERROR] Failed to calculate margin for Sell trade: ", GetLastError());
      return;
   }
   
   if(AccountInfoDouble(ACCOUNT_MARGIN_FREE) < margin)
   {
      Print("[ERROR] Insufficient margin for Sell trade. Required: ", margin, ", Available: ", AccountInfoDouble(ACCOUNT_MARGIN_FREE));
      return;
   }
   
   if(trade.Sell(lotSize, _Symbol, price, sl, takeProfit, "ScalpGuru V7 Sell"))
   {
      inTrade = true;
      tradesToday++;
      trailingActive = false;
      partialProfitTaken = false;  // V7: Reset partial profit flag
      originalLotSize = lotSize;    // V7: Store original lot size
      entryPrice = price;
      initialSL = sl;
      
      // Draw entry arrow
      DrawTradeArrow(false, price, TimeCurrent());
      
      Print("[TRADE] Sell opened: Price=", DoubleToString(price, _Digits), 
            ", Lots=", DoubleToString(lotSize, 2), 
            ", SL=", DoubleToString(sl, _Digits), 
            ", Trades today: ", tradesToday);
   }
   else
   {
      Print("[ERROR] Failed to open Sell trade: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Calculate Lot Size                                                |
//+------------------------------------------------------------------+
double CalculateLotSize(double price)
{
   if(EnableRiskPerTrade)
   {
      double riskAmount = AccountBalance * (RiskPerTradePercent / 100.0);
      double slDistance = SL_ATRMultiplier * atrValue;
      double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      
      if(tickSize == 0 || tickValue == 0)
      {
         Print("[ERROR] Invalid tick size or tick value");
         return NormalizeDouble(ManualLotSize, 2);
      }
      
      double slPoints = slDistance / tickSize;
      double lotSize = NormalizeDouble(riskAmount / (slPoints * tickValue), 2);
      
      double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      if(lotSize < minLot)
      {
         Print("[WARNING] Calculated lot size (", lotSize, ") below minimum (", minLot, "). Using minimum.");
         lotSize = minLot;
      }
      
      double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
      if(lotSize > maxLot)
      {
         Print("[WARNING] Calculated lot size (", lotSize, ") above maximum (", maxLot, "). Using maximum.");
         lotSize = maxLot;
      }
      
      return lotSize;
   }
   else
   {
      return NormalizeDouble(ManualLotSize, 2);
   }
}

//+------------------------------------------------------------------+
//| Manage Open Trades - Enhanced trailing logic                      |
//+------------------------------------------------------------------+
void ManageTrades()
{
   ulong posTicket = 0;
   
   // Find position for this symbol and magic number
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber)
      {
         posTicket = ticket;
         break;
      }
   }
   
   if(posTicket == 0)
   {
      inTrade = false;
      trailingActive = false;
      partialProfitTaken = false;  // V7: Reset partial profit flag
      return;
   }
   
   if(!PositionSelectByTicket(posTicket))
   {
      inTrade = false;
      trailingActive = false;
      partialProfitTaken = false;  // V7: Reset partial profit flag
      return;
   }
   
   ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   double entry = PositionGetDouble(POSITION_PRICE_OPEN);
   double currentSL = PositionGetDouble(POSITION_SL);
   double currentVolume = PositionGetDouble(POSITION_VOLUME);
   double currentPrice = (type == POSITION_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double riskDistance = MathAbs(entry - currentSL);
   double rr1Price = (type == POSITION_TYPE_BUY) ? entry + riskDistance : entry - riskDistance;
   
   // Max loss protection
   double floating = PositionGetDouble(POSITION_PROFIT);
   double threshold = -MaxLossPercent / 100.0 * AccountBalance;
   if(floating < threshold)
   {
      if(trade.PositionClose(posTicket))
      {
         inTrade = false;
         trailingActive = false;
         partialProfitTaken = false;
         Print("[TRADE] Closed: Loss protection triggered, Loss: ", DoubleToString(floating, 2));
      }
      return;
   }
   
   // V7: Check for partial profit taking at 1:1 RR
   if(EnablePartialProfit && !partialProfitTaken && 
      ((type == POSITION_TYPE_BUY && currentPrice >= rr1Price) || 
       (type == POSITION_TYPE_SELL && currentPrice <= rr1Price)))
   {
      // Calculate partial close volume
      double closeVolume = NormalizeDouble(currentVolume * (PartialProfitPercent / 100.0), 2);
      double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double remainingVolume = currentVolume - closeVolume;
      
      // Only do partial close if remaining volume is above minimum
      if(closeVolume >= minLot && remainingVolume >= minLot)
      {
         if(trade.PositionClosePartial(posTicket, closeVolume))
         {
            partialProfitTaken = true;
            Print("[TRADE] V7 Partial profit taken: Closed ", DoubleToString(PartialProfitPercent, 0), 
                  "% (", DoubleToString(closeVolume, 2), " lots) at 1:1 RR");
         }
      }
      else
      {
         // Position too small for partial, mark as done to avoid repeated checks
         partialProfitTaken = true;
      }
   }
   
   // Activate trailing stop at 1:1 RR
   if(!trailingActive && ((type == POSITION_TYPE_BUY && currentPrice >= rr1Price) || 
                          (type == POSITION_TYPE_SELL && currentPrice <= rr1Price)))
   {
      // Move SL to breakeven with buffer
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      // Convert pips to price: 1 pip = 10 points for 5-digit brokers
      double bufferInPrice = BreakevenBuffer * point * PIPS_TO_POINTS;
      
      double newSL;
      if(type == POSITION_TYPE_BUY)
      {
         newSL = NormalizeDouble(entry + bufferInPrice, _Digits);
      }
      else
      {
         newSL = NormalizeDouble(entry - bufferInPrice, _Digits);
      }
      
      if(trade.PositionModify(posTicket, newSL, 0))
      {
         trailingActive = true;
         Print("[TRADE] 1:1 RR reached! SL moved to breakeven + ", BreakevenBuffer, " pips. Trailing stop activated.");
      }
   }
   
   // Apply trailing stop logic
   if(trailingActive)
   {
      // V7: Use tighter trailing initially, then extend after partial profit
      double trailMultiplier = partialProfitTaken ? ExtendedTrailMultiplier : TrailingStop_ATRMultiplier;
      double trailingDistance = trailMultiplier * atrValue;
      double newSL = 0;
      
      if(type == POSITION_TYPE_BUY)
      {
         // For buy trades, trail stop below current price
         newSL = NormalizeDouble(currentPrice - trailingDistance, _Digits);
         
         // Only move stop loss up, never down
         if(newSL > currentSL)
         {
            if(trade.PositionModify(posTicket, newSL, 0))
            {
               Print("[TRADE] Trailing stop updated: New SL = ", DoubleToString(newSL, _Digits));
            }
         }
      }
      else if(type == POSITION_TYPE_SELL)
      {
         // For sell trades, trail stop above current price
         newSL = NormalizeDouble(currentPrice + trailingDistance, _Digits);
         
         // Only move stop loss down, never up
         if(newSL < currentSL)
         {
            if(trade.PositionModify(posTicket, newSL, 0))
            {
               Print("[TRADE] Trailing stop updated: New SL = ", DoubleToString(newSL, _Digits));
            }
         }
      }
   }
   
   inTrade = true;
}

//+------------------------------------------------------------------+
//| Helper Functions                                                  |
//| Note: These functions return pre-computed global buffer values    |
//| for the current symbol and timeframe. Parameters are retained     |
//| for API compatibility but not used.                               |
//+------------------------------------------------------------------+
double GetTrendVelocity()
{
   double priceChange = closeBuffer[0] - closeBuffer[1];
   double timeInterval = PeriodSeconds(timeframe) / 60.0;
   return priceChange / timeInterval;
}

// Returns current ATR value from global buffer
double GetATR()
{
   return atrValue;
}

// Returns MA value from global buffer at specified shift
double GetMA(int shift)
{
   if(shift >= 0 && shift < ArraySize(maBuffer))
      return maBuffer[shift];
   return 0;
}

// Returns close price from global buffer at specified shift
double GetClose(int shift)
{
   if(shift >= 0 && shift < ArraySize(closeBuffer))
      return closeBuffer[shift];
   return 0;
}
