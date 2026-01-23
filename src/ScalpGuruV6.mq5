#property strict
#property description "ScalpGuru V6 - Enhanced Keltner Channel Mean Reversion Strategy"
#property description "Professional visuals with improved trade logic"
#property version   "6.00"
#property copyright "Created by go0ph"

//+------------------------------------------------------------------+
//| Input Parameters                                                  |
//+------------------------------------------------------------------+

//--- Trading Configuration
input group "=== Trading Configuration ==="
input int MagicNumber = 15132;            // Magic Number
input bool AllowSellTrades = false;         // Enable/disable sell trades
input bool AllowBuyTrades = true;           // Enable/disable buy trades
input double AccountBalance = 6000.0;       // Account balance for risk calculation
input double RiskPerTradePercent = 1.0;     // Risk per trade %
input bool EnableRiskPerTrade = true;      // Enable risk per trade
input double ManualLotSize = 0.01;          // Manual lot size if risk per trade is disabled
input double MaxLossPercent = 1;         // Auto-close if loss exceeds % of balance
input int MaxTradesPerDay = 2;              // Max trades per day
input bool EnableMaxTradesPerDay = true;    // Enable/disable max trades per day limit

//--- Strategy Parameters
input group "=== Strategy Parameters ==="
input int ATRPeriod = 20;                   // ATR period
input int KeltnerPeriod = 20;               // Keltner Channel EMA period
input double KeltnerMultiplier = 2.5;       // Keltner ATR multiplier
input double SL_ATRMultiplier = 1.4;        // Initial SL ATR multiplier
input double TrailingStop_ATRMultiplier = 1.0;  // Trailing stop distance (ATR multiplier)
input double BreakevenBuffer = 0.5;         // Breakeven buffer in pips (adds profit cushion)

//--- Entry Filters
input group "=== Entry Filters ==="
input bool EnableMomentumFilter = true;     // Enable RSI momentum filter
input int RSIPeriod = 14;                   // RSI Period
input int RSI_Oversold = 35;                // RSI Oversold level for buys
input int RSI_Overbought = 65;              // RSI Overbought level for sells
input bool EnableVolumeFilter = false;      // Enable volume confirmation
input double VolumeMultiplier = 1.2;        // Volume must be X times average

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

//--- Global Variables
double atrValue, keltnerUpper, keltnerLower, keltnerMid;
bool inTrade = false;
ENUM_TIMEFRAMES timeframe;
int atrHandle, maHandle, rsiHandle;
double atrBuffer[], maBuffer[], closeBuffer[], rsiBuffer[];
int tradesToday = 0;
datetime lastTradeDay = 0;
bool trailingActive = false;
double entryPrice = 0;
double initialSL = 0;

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
   
   // Create info panel
   if(ShowInfoPanel)
   {
      CreateInfoPanel();
   }
   
   Print("[INIT] ScalpGuru V6 Started - Enhanced Edition");
   Print("[INIT] Timeframe: ", EnumToString(timeframe));
   Print("[INIT] ATR Period: ", ATRPeriod, ", Keltner Period: ", KeltnerPeriod);
   Print("[INIT] Keltner Multiplier: ", KeltnerMultiplier, ", SL ATR Multiplier: ", SL_ATRMultiplier);
   Print("[INIT] Trailing Stop ATR Multiplier: ", TrailingStop_ATRMultiplier);
   Print("[INIT] Breakeven Buffer: ", BreakevenBuffer, " pips");
   Print("[INIT] Momentum Filter: ", EnableMomentumFilter ? "Enabled" : "Disabled");
   Print("[INIT] Volume Filter: ", EnableVolumeFilter ? "Enabled" : "Disabled");
   Print("[INIT] Session Filter: ", EnableSessionFilter ? "Enabled" : "Disabled");
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
   
   Print("[DEINIT] ScalpGuru V6 Stopped, Reason: ", reason);
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
   CreateLabel("SG_Title", "═══ ScalpGuru V6 ═══", panelX + 25, panelY + 10, clrGold, 10, "Arial Bold");
   
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
   
   if(todayStart != lastTradeDay)
   {
      tradesToday = 0;
      lastTradeDay = todayStart;
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
   if(CopyBuffer(atrHandle, 0, 0, 3, atrBuffer) <= 0 || CopyClose(_Symbol, timeframe, 0, 3, closeBuffer) <= 0)
   {
      Print("[ERROR] Failed to update indicators: ", GetLastError());
      return;
   }
   atrValue = atrBuffer[0];
   
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
            // Buy entry condition
            if(AllowBuyTrades && close2 < keltnerLower && currentPrice > keltnerLower)
            {
               if(CheckMomentumFilter(true) && CheckVolumeFilter())
               {
                  OpenBuyTrade();
               }
            }
            // Sell entry condition
            else if(AllowSellTrades && close2 > keltnerUpper && currentPrice < keltnerUpper)
            {
               if(CheckMomentumFilter(false) && CheckVolumeFilter())
               {
                  OpenSellTrade();
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
   int barsToShow = 100;
   datetime times[];
   double highs[], lows[];
   
   ArraySetAsSeries(times, true);
   ArraySetAsSeries(highs, true);
   ArraySetAsSeries(lows, true);
   
   CopyTime(_Symbol, timeframe, 0, barsToShow, times);
   CopyHigh(_Symbol, timeframe, 0, barsToShow, highs);
   CopyLow(_Symbol, timeframe, 0, barsToShow, lows);
   
   // Delete old channel lines
   ObjectDelete(0, "KC_Upper");
   ObjectDelete(0, "KC_Middle");
   ObjectDelete(0, "KC_Lower");
   
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
   
   // Draw upper band as trend line segments
   for(int i = 0; i < barsToShow - 1; i++)
   {
      string objName = "KC_U" + IntegerToString(i);
      ObjectDelete(0, objName);
      ObjectCreate(0, objName, OBJ_TREND, 0, times[i+1], upperBand[i+1], times[i], upperBand[i]);
      ObjectSetInteger(0, objName, OBJPROP_COLOR, KeltnerUpperColor);
      ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, objName, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, objName, OBJPROP_RAY, false);
      ObjectSetInteger(0, objName, OBJPROP_BACK, true);
   }
   
   // Draw middle band
   for(int i = 0; i < barsToShow - 1; i++)
   {
      string objName = "KC_M" + IntegerToString(i);
      ObjectDelete(0, objName);
      ObjectCreate(0, objName, OBJ_TREND, 0, times[i+1], middleBand[i+1], times[i], middleBand[i]);
      ObjectSetInteger(0, objName, OBJPROP_COLOR, KeltnerMiddleColor);
      ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, objName, OBJPROP_RAY, false);
      ObjectSetInteger(0, objName, OBJPROP_BACK, true);
   }
   
   // Draw lower band
   for(int i = 0; i < barsToShow - 1; i++)
   {
      string objName = "KC_L" + IntegerToString(i);
      ObjectDelete(0, objName);
      ObjectCreate(0, objName, OBJ_TREND, 0, times[i+1], lowerBand[i+1], times[i], lowerBand[i]);
      ObjectSetInteger(0, objName, OBJPROP_COLOR, KeltnerLowerColor);
      ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, objName, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, objName, OBJPROP_RAY, false);
      ObjectSetInteger(0, objName, OBJPROP_BACK, true);
   }
   
   // Draw current price level indicator
   double currentBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   string priceLabel = "KC_PriceLevel";
   ObjectDelete(0, priceLabel);
   ObjectCreate(0, priceLabel, OBJ_HLINE, 0, 0, currentBid);
   ObjectSetInteger(0, priceLabel, OBJPROP_COLOR, clrGray);
   ObjectSetInteger(0, priceLabel, OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(0, priceLabel, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, priceLabel, OBJPROP_BACK, true);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Draw Trade Entry Arrow                                           |
//+------------------------------------------------------------------+
void DrawTradeArrow(bool isBuy, double price, datetime time)
{
   if(!ShowTradeArrows) return;
   
   static int arrowCount = 0;
   string arrowName = "SG_Arrow" + IntegerToString(arrowCount++);
   
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
   
   if(trade.Buy(lotSize, _Symbol, price, sl, takeProfit, "ScalpGuru V6 Buy"))
   {
      inTrade = true;
      tradesToday++;
      trailingActive = false;
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
   
   if(trade.Sell(lotSize, _Symbol, price, sl, takeProfit, "ScalpGuru V6 Sell"))
   {
      inTrade = true;
      tradesToday++;
      trailingActive = false;
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
      return;
   }
   
   if(!PositionSelectByTicket(posTicket))
   {
      inTrade = false;
      trailingActive = false;
      return;
   }
   
   ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   double entry = PositionGetDouble(POSITION_PRICE_OPEN);
   double currentSL = PositionGetDouble(POSITION_SL);
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
         Print("[TRADE] Closed: Loss protection triggered, Loss: ", DoubleToString(floating, 2));
      }
      return;
   }
   
   // Activate trailing stop at 1:1 RR
   if(!trailingActive && ((type == POSITION_TYPE_BUY && currentPrice >= rr1Price) || 
                          (type == POSITION_TYPE_SELL && currentPrice <= rr1Price)))
   {
      // Move SL to breakeven with buffer
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double bufferInPrice = BreakevenBuffer * point * 10; // Convert pips to price
      
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
      double trailingDistance = TrailingStop_ATRMultiplier * atrValue;
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
//+------------------------------------------------------------------+
double GetTrendVelocity()
{
   double priceChange = closeBuffer[0] - closeBuffer[1];
   double timeInterval = PeriodSeconds(timeframe) / 60.0;
   return priceChange / timeInterval;
}

double GetATR(string symbol, ENUM_TIMEFRAMES tf, int period)
{
   return atrValue;
}

double GetMA(string symbol, ENUM_TIMEFRAMES tf, int period, int shift, ENUM_MA_METHOD method, int applied_price)
{
   return maBuffer[shift];
}

double GetClose(string symbol, ENUM_TIMEFRAMES tf, int shift)
{
   return closeBuffer[shift];
}
