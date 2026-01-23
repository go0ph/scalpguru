#property strict
#property description "ScalpGuru V5 - Keltner Channel Mean Reversion Strategy"
#property description "Simplified strategy with trailing stop at 1:1 RR"
#property version   "5.00"
#property copyright "Created by go0ph"

//+------------------------------------------------------------------+
//| Input Parameters                                                  |
//+------------------------------------------------------------------+

//--- Trading Configuration
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
input int ATRPeriod = 20;                   // ATR period
input int KeltnerPeriod = 20;               // Keltner Channel EMA period
input double KeltnerMultiplier = 2.5;       // Keltner ATR multiplier
input double SL_ATRMultiplier = 1.4;        // Initial SL ATR multiplier
input double TrailingStop_ATRMultiplier = 1.0;  // Trailing stop distance (ATR multiplier)

//--- Day Filtering
input bool EnableDaySkip = true;           // Enable/disable day skipping
input bool SkipMonday = false;              // Skip Monday (1)
input bool SkipTuesday = false;             // Skip Tuesday (2)
input bool SkipWednesday = false;           // Skip Wednesday (3)
input bool SkipThursday = false;            // Skip Thursday (4)
input bool SkipFriday = true;               // Skip Friday (5)

//--- Month Filtering
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
input bool ShowKeltnerOnChart = true;      // Enable/disable Display on Chart
//--- Global Variables
double atrValue, keltnerUpper, keltnerLower, keltnerMid;
bool inTrade = false;
ENUM_TIMEFRAMES timeframe;
int atrHandle, maHandle;
double atrBuffer[], maBuffer[], closeBuffer[];
int tradesToday = 0;
datetime lastTradeDay = 0;
bool trailingActive = false;  // Track if trailing stop is active
//--- Include Libraries
#include <Trade\Trade.mqh>
CTrade trade;
//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit()
{
   timeframe = Period(); // Use chart's timeframe (e.g., M15)
   trade.SetExpertMagicNumber(MagicNumber); // Unique identifier for trades
   
   // Initialize indicators with error checking
   atrHandle = iATR(_Symbol, timeframe, ATRPeriod);
   if(atrHandle == INVALID_HANDLE)
   {
      Print("[ERROR] Failed to create ATR indicator handle");
      return INIT_FAILED;
   }
   
   maHandle = iMA(_Symbol, timeframe, KeltnerPeriod, 0, MODE_EMA, PRICE_CLOSE);
   if(maHandle == INVALID_HANDLE)
   {
      Print("[ERROR] Failed to create MA indicator handle");
      IndicatorRelease(atrHandle);
      return INIT_FAILED;
   }
   
   ArraySetAsSeries(atrBuffer, true);
   ArraySetAsSeries(maBuffer, true);
   ArraySetAsSeries(closeBuffer, true);
   
   // Validate input parameters
   if(ATRPeriod <= 0 || KeltnerPeriod <= 0)
   {
      Print("[ERROR] Invalid indicator periods. ATRPeriod and KeltnerPeriod must be > 0");
      IndicatorRelease(atrHandle);
      IndicatorRelease(maHandle);
      return INIT_PARAMETERS_INCORRECT;
   }
   if(SL_ATRMultiplier <= 0 || KeltnerMultiplier <= 0)
   {
      Print("[ERROR] Invalid multipliers. SL_ATRMultiplier and KeltnerMultiplier must be > 0");
      IndicatorRelease(atrHandle);
      IndicatorRelease(maHandle);
      return INIT_PARAMETERS_INCORRECT;
   }
   if(ManualLotSize <= 0)
   {
      Print("[ERROR] Invalid ManualLotSize: ", ManualLotSize, ". Must be > 0");
      IndicatorRelease(atrHandle);
      IndicatorRelease(maHandle);
      return INIT_PARAMETERS_INCORRECT;
   }
   if(MaxLossPercent <= 0 || MaxLossPercent > 100)
   {
      Print("[ERROR] Invalid MaxLossPercent: ", MaxLossPercent, ". Must be between 0 and 100");
      IndicatorRelease(atrHandle);
      IndicatorRelease(maHandle);
      return INIT_PARAMETERS_INCORRECT;
   }
   if(RiskPerTradePercent <= 0 || RiskPerTradePercent > 100)
   {
      Print("[ERROR] Invalid RiskPerTradePercent: ", RiskPerTradePercent, ". Must be between 0 and 100");
      IndicatorRelease(atrHandle);
      IndicatorRelease(maHandle);
      return INIT_PARAMETERS_INCORRECT;
   }
   if(!AllowBuyTrades && !AllowSellTrades)
   {
      Print("[ERROR] Both AllowBuyTrades and AllowSellTrades are disabled. At least one must be enabled");
      IndicatorRelease(atrHandle);
      IndicatorRelease(maHandle);
      return INIT_PARAMETERS_INCORRECT;
   }
   if(MaxTradesPerDay <= 0)
   {
      Print("[ERROR] Invalid MaxTradesPerDay: ", MaxTradesPerDay, ". Must be > 0");
      IndicatorRelease(atrHandle);
      IndicatorRelease(maHandle);
      return INIT_PARAMETERS_INCORRECT;
   }
   
   MqlDateTime dt;
   TimeToStruct(TimeTradeServer(), dt);
   dt.hour = 0; dt.min = 0; dt.sec = 0;
   lastTradeDay = StructToTime(dt);
   
   Print("[INIT] Scalp Guru V5 Started");
   Print("[INIT] Timeframe: ", EnumToString(timeframe));
   Print("[INIT] ATR Period: ", ATRPeriod, ", Keltner Period: ", KeltnerPeriod);
   Print("[INIT] Keltner Multiplier: ", KeltnerMultiplier, ", SL ATR Multiplier: ", SL_ATRMultiplier);
   Print("[INIT] Trailing Stop ATR Multiplier: ", TrailingStop_ATRMultiplier);
   Print("[INIT] Risk Per Trade: ", EnableRiskPerTrade ? "Enabled" : "Disabled", ", Manual Lot Size: ", DoubleToString(ManualLotSize, 3));
   Print("[INIT] Allow Buys: ", AllowBuyTrades, ", Allow Sells: ", AllowSellTrades);
   Print("[INIT] Max Trades Per Day: ", MaxTradesPerDay);
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
ObjectDelete(0, "KeltnerUpper");
ObjectDelete(0, "KeltnerMiddle");
ObjectDelete(0, "KeltnerLower");
IndicatorRelease(atrHandle);
IndicatorRelease(maHandle);
Print("EA Deinitialized, Reason: ", reason);
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
if (todayStart != lastTradeDay)
{
tradesToday = 0;
lastTradeDay = todayStart;
}
// Check for month skip
bool skipCurrentMonth = false;
if (EnableMonthSkip)
{
if ((currentMonth == 1 && SkipJanuary) ||
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
if (skipCurrentMonth)
{
static int lastMonthSkip = 0;
if (currentMonth != lastMonthSkip)
{
string monthNames[] = {"", "January", "February", "March", "April", "May", "June",
"July", "August", "September", "October", "November", "December"};
Print("Skipping trading in ", monthNames[currentMonth], " (Month ", currentMonth, ")");
lastMonthSkip = currentMonth;
}
}
// Check for day skip
bool skipCurrentDay = false;
if (EnableDaySkip)
{
if ((currentDay == 1 && SkipMonday) ||
(currentDay == 2 && SkipTuesday) ||
(currentDay == 3 && SkipWednesday) ||
(currentDay == 4 && SkipThursday) ||
(currentDay == 5 && SkipFriday))
{
skipCurrentDay = true;
}
}
if (skipCurrentDay)
{
static int lastDaySkip = 0;
if (timeStruct.day != lastDaySkip)
{
string dayNames[] = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};
Print("Skipping trading on ", dayNames[currentDay], " (Day ", currentDay, ")");
lastDaySkip = timeStruct.day;
}
}
bool isSkipped = skipCurrentMonth || skipCurrentDay;
// Always update essential indicators for trade management
if (CopyBuffer(atrHandle, 0, 0, 3, atrBuffer) <= 0 || CopyClose(_Symbol, timeframe, 0, 3, closeBuffer) <= 0)
{
Print("[ERROR] Failed to update indicators: ", GetLastError());
return;
}
atrValue = atrBuffer[0];
double close2 = closeBuffer[2];
if (!isSkipped)
{
if (CopyBuffer(maHandle, 0, 0, 3, maBuffer) <= 0)
{
Print("[ERROR] Failed to update MA buffer: ", GetLastError());
return;
}
double ema = maBuffer[0];
keltnerUpper = MathMax(ema + KeltnerMultiplier * atrValue, 0);
keltnerLower = MathMax(ema - KeltnerMultiplier * atrValue, 0);
keltnerMid = ema;
double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
// Manage Keltner Channel display
if (ShowKeltnerOnChart)
{
DrawKeltnerChannels();
}
else
{
ObjectDelete(0, "KeltnerUpper");
ObjectDelete(0, "KeltnerMiddle");
ObjectDelete(0, "KeltnerLower");
ChartRedraw();
}

// Check for entry signals if not in trade
if (!inTrade && (!EnableMaxTradesPerDay || tradesToday < MaxTradesPerDay))
{
if (AllowBuyTrades && close2 < keltnerLower && currentPrice > keltnerLower)
{
OpenBuyTrade();
}
else if (AllowSellTrades && close2 > keltnerUpper && currentPrice < keltnerUpper)
{
OpenSellTrade();
}
}
}
ManageTrades();
}
//+------------------------------------------------------------------+
//| Draw Keltner Channels on Chart                                    |
//+------------------------------------------------------------------+
void DrawKeltnerChannels()
{
datetime currentBarTime = iTime(_Symbol, timeframe, 0);
datetime lastBarTime = iTime(_Symbol, timeframe, 1);
// Update or create Keltner Upper line
if (ObjectFind(0, "KeltnerUpper") >= 0)
{
ObjectMove(0, "KeltnerUpper", 0, lastBarTime, keltnerUpper);
ObjectMove(0, "KeltnerUpper", 1, currentBarTime, keltnerUpper);
}
else
{
ObjectCreate(0, "KeltnerUpper", OBJ_TREND, 0, lastBarTime, keltnerUpper, currentBarTime, keltnerUpper);
ObjectSetInteger(0, "KeltnerUpper", OBJPROP_COLOR, clrRed);
ObjectSetInteger(0, "KeltnerUpper", OBJPROP_STYLE, STYLE_SOLID);
ObjectSetInteger(0, "KeltnerUpper", OBJPROP_WIDTH, 1);
ObjectSetInteger(0, "KeltnerUpper", OBJPROP_RAY, true); // Extend to the right
}
// Update or create Keltner Middle line
if (ObjectFind(0, "KeltnerMiddle") >= 0)
{
ObjectMove(0, "KeltnerMiddle", 0, lastBarTime, keltnerMid);
ObjectMove(0, "KeltnerMiddle", 1, currentBarTime, keltnerMid);
}
else
{
ObjectCreate(0, "KeltnerMiddle", OBJ_TREND, 0, lastBarTime, keltnerMid, currentBarTime, keltnerMid);
ObjectSetInteger(0, "KeltnerMiddle", OBJPROP_COLOR, clrBlue);
ObjectSetInteger(0, "KeltnerMiddle", OBJPROP_STYLE, STYLE_SOLID);
ObjectSetInteger(0, "KeltnerMiddle", OBJPROP_WIDTH, 1);
ObjectSetInteger(0, "KeltnerMiddle", OBJPROP_RAY, true); // Extend to the right
}
// Update or create Keltner Lower line
if (ObjectFind(0, "KeltnerLower") >= 0)
{
ObjectMove(0, "KeltnerLower", 0, lastBarTime, keltnerLower);
ObjectMove(0, "KeltnerLower", 1, currentBarTime, keltnerLower);
}
else
{
ObjectCreate(0, "KeltnerLower", OBJ_TREND, 0, lastBarTime, keltnerLower, currentBarTime, keltnerLower);
ObjectSetInteger(0, "KeltnerLower", OBJPROP_COLOR, clrGreen);
ObjectSetInteger(0, "KeltnerLower", OBJPROP_STYLE, STYLE_SOLID);
ObjectSetInteger(0, "KeltnerLower", OBJPROP_WIDTH, 1);
ObjectSetInteger(0, "KeltnerLower", OBJPROP_RAY, true); // Extend to the right
}
ChartRedraw();
}
//+------------------------------------------------------------------+
