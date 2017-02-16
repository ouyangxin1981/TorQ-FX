// TorQ-FX downloader config

files:`:files			//Table to save a list of already downloaded files in

/
The following is a list of currently available currency pairs:
`AUDCAD`AUDCHF`AUDJPY`AUDNZD`AUDUSD`AUXAUD`BCOUSD`CADCHF`CADJPY`CHFJPY`CORUSD`COTUSD`CUUUSD`ETXEUR`EURAUD`EURCAD`EURCHF`EURCZK`EURDKK`EURGBP`EURHUF`EURJPY`EURNOK`EURNZD`EURPLN`EURSEK`EURTRY`EURUSD`FRXEUR`GBPAUD`GBPCAD`GBPCHF`GBPJPY`GBPNZD`GBPUSD`GRXEUR`HGOUSD`HKXHKD`JPXJPY`NSXUSD`NTGUSD`NZDCAD`NZDCHF`NZDJPY`NZDUSD`PDUUSD`PTUUSD`SGDJPY`SOYUSD`SPXUSD`SUGUSD`UDXUSD`UKXGBP`USDCAD`USDCHF`USDCNH`USDCZK`USDDKK`USDHKD`USDHUF`USDJPY`USDMXN`USDNOK`USDPLN`USDRUB`USDSEK`USDSGD`USDTRY`USDZAR`WHTUSD`WTIUSD`XAGUSD`XAUAUD`XAUCHF`XAUEUR`XAUGBP`XAUJPY`XAUUSD`ZARJPY
\

//List of currency pairs to download
allcpairs:`EURGBP`EURJPY`EURUSD`GBPJPY`GBPUSD`USDJPY

//The download function runs at runtime each day. This will look for any new files over the last month
runtime:19:00:00		//Time for the automatic download each day

//Whether to download from a certain date on startup. Data is available from 2000.05.30 onwards.
//The first files downloaded will be those containing the data for the initialrunstart.
//From February 2003 onwards, this will be the first week to get data from. Before this there is one zip file per currency pair per year
initialrun:1b
//First available date is 2000.05.30
initialrunstart:2017.01.01

//Email addresses to send emails to when new files are successfully downloaded, if enabled. Email server settings should be set in config/settings/default.q
emailaddresses:("test@aquaq.co.uk";"test1@aquaq.co.uk")		//Email addresses as string or list of strings
emailsenabled:0b		//Whether to enable emails
