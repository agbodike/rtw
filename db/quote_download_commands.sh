#!/bin/bash

#Statistical Data
##Hi/ Lo
#curl http://unicorn.us.com/advdec/NYSE_newhi.csv   > market_stats/NYSE_newhi.csv
#curl http://unicorn.us.com/advdec/NYSE_newlo.csv   > market_stats/NYSE_newlo.csv
#curl http://unicorn.us.com/advdec/AMEX_newhi.csv   > market_stats/AMEX_newhi.csv
#curl http://unicorn.us.com/advdec/AMEX_newlo.csv   > market_stats/AMEX_newlo.csv
#curl http://unicorn.us.com/advdec/NASDAQ_newhi.csv > market_stats/NASDAQ_newhi.csv
#curl http://unicorn.us.com/advdec/NASDAQ_newlo.csv > market_stats/NASDAQ_newlo.csv
##Advance/ Decline/ Unchanged Issues
#curl http://unicorn.us.com/advdec/NYSE_advn.csv    > market_stats/NYSE_advn.csv
#curl http://unicorn.us.com/advdec/NYSE_decln.csv   > market_stats/NYSE_decln.csv
#curl http://unicorn.us.com/advdec/NYSE_unchn.csv   > market_stats/NYSE_unchn.csv
#curl http://unicorn.us.com/advdec/AMEX_advn.csv    > market_stats/AMEX_advn.csv
#curl http://unicorn.us.com/advdec/AMEX_decln.csv   > market_stats/AMEX_decln.csv
#curl http://unicorn.us.com/advdec/AMEX_unchn.csv   > market_stats/AMEX_unchn.csv
#curl http://unicorn.us.com/advdec/NASDAQ_advn.csv  > market_stats/NASDAQ_advn.csv
#curl http://unicorn.us.com/advdec/NASDAQ_decln.csv > market_stats/NASDAQ_decln.csv
#curl http://unicorn.us.com/advdec/NASDAQ_unchn.csv > market_stats/NASDAQ_unchn.csv
##Advance/ Decline/ Unchanged Volume
#curl http://unicorn.us.com/advdec/NYSE_advv.csv    > market_stats/NYSE_advv.csv
#curl http://unicorn.us.com/advdec/NYSE_declv.csv   > market_stats/NYSE_declv.csv
#curl http://unicorn.us.com/advdec/NYSE_unchv.csv   > market_stats/NYSE_unchv.csv
#curl http://unicorn.us.com/advdec/AMEX_advv.csv    > market_stats/AMEX_advv.csv
#curl http://unicorn.us.com/advdec/AMEX_declv.csv   > market_stats/AMEX_declv.csv
#curl http://unicorn.us.com/advdec/AMEX_unchv.csv   > market_stats/AMEX_unchv.csv
#curl http://unicorn.us.com/advdec/NASDAQ_advv.csv  > market_stats/NASDAQ_advv.csv
#curl http://unicorn.us.com/advdec/NASDAQ_declv.csv > market_stats/NASDAQ_declv.csv
#curl http://unicorn.us.com/advdec/NASDAQ_unchv.csv > market_stats/NASDAQ_unchv.csv

#Quote Data
./yahoofinance.rb -z -d 6500 AGG > csv_files/AGG.csv
./yahoofinance.rb -z -d 6500 BIL > csv_files/BIL.csv
./yahoofinance.rb -z -d 6500 BLV > csv_files/BLV.csv
./yahoofinance.rb -z -d 6500 BSV > csv_files/BSV.csv
./yahoofinance.rb -z -d 6500 BTTRX > csv_files/BTTRX.csv
./yahoofinance.rb -z -d 6500 DBA > csv_files/DBA.csv
./yahoofinance.rb -z -d 6500 DBC > csv_files/DBC.csv
./yahoofinance.rb -z -d 6500 DBO > csv_files/DBO.csv
./yahoofinance.rb -z -d 6500 ECH > csv_files/ECH.csv        # Chile
./yahoofinance.rb -z -d 6500 EEM > csv_files/EEM.csv
./yahoofinance.rb -z -d 6500 EFA > csv_files/EFA.csv
./yahoofinance.rb -z -d 6500 EPP > csv_files/EPP.csv
./yahoofinance.rb -z -d 6500 EWA > csv_files/EWA.csv
./yahoofinance.rb -z -d 6500 EWD > csv_files/EWD.csv
./yahoofinance.rb -z -d 6500 EWG > csv_files/EWG.csv
./yahoofinance.rb -z -d 6500 EWH > csv_files/EWH.csv
./yahoofinance.rb -z -d 6500 EWI > csv_files/EWI.csv
./yahoofinance.rb -z -d 6500 EWJ > csv_files/EWJ.csv
./yahoofinance.rb -z -d 6500 EWK > csv_files/EWK.csv
./yahoofinance.rb -z -d 6500 EWL > csv_files/EWL.csv
./yahoofinance.rb -z -d 6500 EWM > csv_files/EWM.csv        # Malaysia
./yahoofinance.rb -z -d 6500 EWN > csv_files/EWN.csv
./yahoofinance.rb -z -d 6500 EWO > csv_files/EWO.csv
./yahoofinance.rb -z -d 6500 EWP > csv_files/EWP.csv
./yahoofinance.rb -z -d 6500 EWQ > csv_files/EWQ.csv
./yahoofinance.rb -z -d 6500 EWS > csv_files/EWS.csv
./yahoofinance.rb -z -d 6500 EWT > csv_files/EWT.csv
./yahoofinance.rb -z -d 6500 EWU > csv_files/EWU.csv
./yahoofinance.rb -z -d 6500 EWW > csv_files/EWW.csv
./yahoofinance.rb -z -d 6500 EWY > csv_files/EWY.csv
./yahoofinance.rb -z -d 6500 EWZ > csv_files/EWZ.csv        # Brazil
./yahoofinance.rb -z -d 6500 EZA > csv_files/EZA.csv
./yahoofinance.rb -z -d 6500 FEZ > csv_files/FEZ.csv
./yahoofinance.rb -z -d 6500 FIEUX > csv_files/FIEUX.csv
./yahoofinance.rb -z -d 6500 FXI > csv_files/FXI.csv
./yahoofinance.rb -z -d 6500 GDX > csv_files/GDX.csv
./yahoofinance.rb -z -d 6500 GLD > csv_files/GLD.csv
./yahoofinance.rb -z -d 6500 GMF > csv_files/GMF.csv
./yahoofinance.rb -z -d 6500 GML > csv_files/GML.csv
./yahoofinance.rb -z -d 6500 GSG > csv_files/GSG.csv
./yahoofinance.rb -z -d 6500 ICF > csv_files/ICF.csv
./yahoofinance.rb -z -d 6500 IDX > csv_files/IDX.csv
./yahoofinance.rb -z -d 6500 IEF > csv_files/IEF.csv
./yahoofinance.rb -z -d 6500 IEV > csv_files/IEV.csv
./yahoofinance.rb -z -d 6500 ILF > csv_files/ILF.csv
./yahoofinance.rb -z -d 6500 IOO > csv_files/IOO.csv
./yahoofinance.rb -z -d 6500 IPE > csv_files/IPE.csv
./yahoofinance.rb -z -d 6500 IVW > csv_files/IVW.csv
./yahoofinance.rb -z -d 6500 IWB > csv_files/IWB.csv
./yahoofinance.rb -z -d 6500 IWD > csv_files/IWD.csv
./yahoofinance.rb -z -d 6500 IWF > csv_files/IWF.csv
./yahoofinance.rb -z -d 6500 IWM > csv_files/IWM.csv
./yahoofinance.rb -z -d 6500 IWN > csv_files/IWN.csv
./yahoofinance.rb -z -d 6500 IWO > csv_files/IWO.csv
./yahoofinance.rb -z -d 6500 IWP > csv_files/IWP.csv
./yahoofinance.rb -z -d 6500 IWR > csv_files/IWR.csv
./yahoofinance.rb -z -d 6500 IWV > csv_files/IWV.csv
./yahoofinance.rb -z -d 6500 IXC > csv_files/IXC.csv
./yahoofinance.rb -z -d 6500 IXJ > csv_files/IXJ.csv
./yahoofinance.rb -z -d 6500 IXP > csv_files/IXP.csv
./yahoofinance.rb -z -d 6500 IYR > csv_files/IYR.csv
./yahoofinance.rb -z -d 6500 LAQ > csv_files/LAQ.csv
./yahoofinance.rb -z -d 6500 OIL > csv_files/OIL.csv        # First oil ETF
./yahoofinance.rb -z -d 6500 PBW > csv_files/PBW.csv
./yahoofinance.rb -z -d 6500 PGJ > csv_files/PGJ.csv
./yahoofinance.rb -z -d 6500 PHYS > csv_files/PHYS.csv
./yahoofinance.rb -z -d 6500 PSLV > csv_files/PSLV.csv
./yahoofinance.rb -z -d 6500 PZD > csv_files/PZD.csv
./yahoofinance.rb -z -d 6500 QQQQ > csv_files/QQQQ.csv
./yahoofinance.rb -z -d 6500 RWR > csv_files/RWR.csv
./yahoofinance.rb -z -d 6500 RSP > csv_files/RSP.csv
./yahoofinance.rb -z -d 6500 RSX > csv_files/RSX.csv
./yahoofinance.rb -z -d 6500 SASPX > csv_files/SASPX.csv
./yahoofinance.rb -z -d 6500 SHV > csv_files/SHV.csv
./yahoofinance.rb -z -d 6500 SLV > csv_files/SLV.csv
./yahoofinance.rb -z -d 6500 SPY > csv_files/SPY.csv
./yahoofinance.rb -z -d 6500 SWPIX > csv_files/SWPIX.csv
./yahoofinance.rb -z -d 6500 SWSMX > csv_files/SWSMX.csv
./yahoofinance.rb -z -d 6500 TIP > csv_files/TIP.csv
./yahoofinance.rb -z -d 6500 TLO > csv_files/TLO.csv
./yahoofinance.rb -z -d 6500 TLT > csv_files/TLT.csv
./yahoofinance.rb -z -d 6500 THD > csv_files/THD.csv        # Thailand
./yahoofinance.rb -z -d 6500 UNG > csv_files/UNG.csv
./yahoofinance.rb -z -d 6500 USL > csv_files/USL.csv
./yahoofinance.rb -z -d 6500 USO > csv_files/USO.csv
./yahoofinance.rb -z -d 6500 VEA > csv_files/VEA.csv
./yahoofinance.rb -z -d 6500 VNQ > csv_files/VNQ.csv
./yahoofinance.rb -z -d 6500 VWO > csv_files/VWO.csv
./yahoofinance.rb -z -d 6500 XLB > csv_files/XLB.csv
./yahoofinance.rb -z -d 6500 XLE > csv_files/XLE.csv
./yahoofinance.rb -z -d 6500 XLF > csv_files/XLF.csv
./yahoofinance.rb -z -d 6500 XLI > csv_files/XLI.csv
./yahoofinance.rb -z -d 6500 XLK > csv_files/XLK.csv
./yahoofinance.rb -z -d 6500 XLP > csv_files/XLP.csv
./yahoofinance.rb -z -d 6500 XLU > csv_files/XLU.csv
./yahoofinance.rb -z -d 6500 XLV > csv_files/XLV.csv
./yahoofinance.rb -z -d 6500 XLY > csv_files/XLY.csv
# Currency ETFs
#   CurrencyShares
./yahoofinance.rb -z -d 6500 FXA > csv_files/FXA.csv
./yahoofinance.rb -z -d 6500 FXB > csv_files/FXB.csv
./yahoofinance.rb -z -d 6500 FXC > csv_files/FXC.csv
./yahoofinance.rb -z -d 6500 FXE > csv_files/FXE.csv
./yahoofinance.rb -z -d 6500 FXY > csv_files/FXY.csv
./yahoofinance.rb -z -d 6500 FXM > csv_files/FXM.csv
./yahoofinance.rb -z -d 6500 FXS > csv_files/FXS.csv
./yahoofinance.rb -z -d 6500 FXF > csv_files/FXF.csv
#   WisdomTree
./yahoofinance.rb -z -d 6500 BZF > csv_files/BZF.csv
./yahoofinance.rb -z -d 6500 CYB > csv_files/CYB.csv
./yahoofinance.rb -z -d 6500 CEW > csv_files/CEW.csv
./yahoofinance.rb -z -d 6500 EU  > csv_files/EU.csv
./yahoofinance.rb -z -d 6500 ICN > csv_files/ICN.csv
./yahoofinance.rb -z -d 6500 JYF > csv_files/JYF.csv
./yahoofinance.rb -z -d 6500 BNZ > csv_files/BNZ.csv
./yahoofinance.rb -z -d 6500 SZR > csv_files/SZR.csv
./yahoofinance.rb -z -d 6500 USY > csv_files/USY.csv
# Biotech
./yahoofinance.rb -z -d 6500 BBH > csv_files/BBH.csv
# Pharma
./yahoofinance.rb -z -d 6500 PPH > csv_files/PPH.csv
# Individual Stocks
./yahoofinance.rb -z -d 6500 AAPL > csv_files/AAPL.csv
./yahoofinance.rb -z -d 6500 ABX > csv_files/ABX.csv
./yahoofinance.rb -z -d 6500 COP > csv_files/COP.csv
./yahoofinance.rb -z -d 6500 GOOG > csv_files/GOOG.csv
./yahoofinance.rb -z -d 6500 IBM > csv_files/IBM.csv
./yahoofinance.rb -z -d 6500 XOM > csv_files/XOM.csv
# Short
./yahoofinance.rb -z -d 6500 SH > csv_files/SH.csv
# Levereged
./yahoofinance.rb -z -d 6500 BGU > csv_files/BGU.csv         # 3x Russell 1000 - large cap
./yahoofinance.rb -z -d 6500 TNA > csv_files/TNA.csv         # 3x Russell 2000 - small cap
./yahoofinance.rb -z -d 6500 QLD > csv_files/QLD.csv         # 2x Nasdaq 100
./yahoofinance.rb -z -d 6500 UPRO > csv_files/UPRO.csv       # 3x S&P 500
# Indices
./yahoofinance.rb -z -d 12500 ^GSPC > csv_files/^GSPC.csv    # S&P 500
./yahoofinance.rb -z -d 12500 ^NYA > csv_files/^NYA.csv      # NYSE Composite Index
./yahoofinance.rb -z -d 12500 ^DJI > csv_files/^DJI.csv      # Dow Jones Industrials
./yahoofinance.rb -z -d 12500 ^IXIC > csv_files/^IXIC.csv    # Nasdaq
./yahoofinance.rb -z -d 12500 ^NDX > csv_files/^NDX.csv      # Nasdaq 100
./yahoofinance.rb -z -d 12500 ^TNX > csv_files/^TNX.csv      # 10 Year Bond
./yahoofinance.rb -z -d 12500 ^RUI > csv_files/^RUI.csv      # Russel 1000
./yahoofinance.rb -z -d 12500 ^RUT > csv_files/^RUT.csv      # Russel 2000
#./yahoofinance.rb -z -d 12500 ^ > csv_files/^.csv      # 
./yahoofinance.rb -z -d 6500 ^VIX > csv_files/^VIX.csv
