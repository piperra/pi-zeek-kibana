#!/bin/bash

# Update and install dialog for configuration
apt update
apt -y install dialog

clear

##########################################
#        1. ACCES POINT CONFIG           #
##########################################

############################################################
# Install the access point and network management software #
############################################################

apt -y install hostapd
clear
systemctl unmask hostapd
sstemctl enable hostapd
apt -y install dnsmasq
DEBIAN_FRONTEND=noninteractive apt install -y netfilter-persistent iptables-persistent
clear

#############################
# Set up the network router #
#############################

#Define the wireless interface IP configuration
#
#In /etc/dhcpcd.conf add the following lines
#interface wlan0
#	static ip_address=192.168.4.1/24
#	nohook wpa_supplicant

printf 'interface wlan0\n\tstatic ip_address=192.168.4.1/24\n\tnohook wpa_supplicant\n' >> /etc/dhcpcd.conf

#Enable routing and IP masquerading
#
#Create /etc/sysctl.d/routed-ap.conf file and add the following lines
## https://www.raspberrypi.org/documentation/configuration/wireless/access-point-routed.md
## Enable IPv4 routing
#net.ipv4.ip_forward=1
printf '# https://www.raspberrypi.org/documentation/configuration/wireless/access-point-routed.md\n# Enable IPv4 routing\nnet.ipv4.ip_forward=1\n' > /etc/sysctl.d/routed-ap.conf

#Add a single firewall rule
iptables -P FORWARD ACCEPT
iptables -F FORWARD
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
netfilter-persistent save

################################################################
# Configure the DHCP and DNS services for the wireless network #
################################################################

#Backup the original dnsmasq configuration
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig

#Create a new one adding the following lines
#interface=wlan0 # Listening interface
#dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
#                # Pool of IP addresses served via DHCP
#domain=wlan     # Local wireless DNS domain
#address=/gw.wlan/192.168.4.1
#                # Alias for this router
printf 'interface=wlan0 # Listening interface\ndhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h\n\t\t# Pool of IP addresses served via DHCP\ndomain=wlan\t# Local wireless DNS domain\naddress=/gw.wlan/192.168.4.1\n\t\t# Alias for this router\n' > /etc/dnsmasq.conf

#############################
# Ensure wireless operation #
#############################

rfkill unblock wlan

#######################################
# Configure the access point software #
#######################################

# Display ssid

HEIGHT=10
WIDTH=40
BACKTITLE="SSID"
TITLE="SSID"
MENU="Write a name for the Wifi network:"

CHOICE=""
while [[ -z "$CHOICE" ]]
do
        CHOICE=$(dialog --clear \
                        --nocancel \
                        --backtitle "$BACKTITLE" \
                        --title "$TITLE" \
                        --inputbox "$MENU" \
                        $HEIGHT $WIDTH \
                        2>&1 >/dev/tty)
done

SSID=$CHOICE

clear


# Display wpa_passphrase

HEIGHT=10
WIDTH=60
BACKTITLE="WPA-PSK"
TITLE="WPA2 passphrase"
MENU="Write a WPA passphrase for the Wifi network:"

CHOICE=""
while [[ -z "$CHOICE" ]]
do
        CHOICE=$(dialog --clear \
                        --nocancel \
                        --backtitle "$BACKTITLE" \
                        --title "$TITLE" \
                        --inputbox "$MENU" \
                        $HEIGHT $WIDTH \
                        2>&1 >/dev/tty)
done

WPA=$CHOICE

clear


# Display hw_mode

HEIGHT=11
WIDTH=45
CHOICE_HEIGHT=4
BACKTITLE="IEEE 802.11"
TITLE="Configure wireless standard"
MENU="Choose one of the following standards:"

OPTIONS=(
1 "g = IEEE 802.11g (2.4 GHz)"
2 "b = IEEE 802.11b (2.4 GHz)"
3 "a = IEEE 802.11a (5 GHz)"
4 "ad = IEEE 802.11ad (60 GHz)"
)

CHOICE=$(dialog --clear \
		--nocancel \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
	1)
		HW="g"
		;;
	2)
		HW="b"
		;;
	3)
		HW="a"
		;;
	4)
		HW="ad"
		;;
esac

# Display country_code
# Choose one of the two-letter ISO 3166-1 country codes
# More info: https://en.wikipedia.org/wiki/ISO_3166-1

HEIGHT=40
WIDTH=100
CHOICE_HEIGHT=40
BACKTITLE="List of two-letter ISO 3166-1 country codes"
TITLE="Configure the computer to use the correct wireless frequencies in your country"
MENU="Choose one of the following country codes:"

OPTIONS=(
1 "AD - Andorra"
2 "AE - United Arab Emirates"
3 "AF - Afghanistan"
4 "AG - Antigua and Barbuda"
5 "AI - Anguilla"
6 "AL - Albania"
7 "AM - Armenia"
8 "AO - Angola"
9 "AQ - Antarctica"
10 "AR - Argentina"
11 "AS - American Samoa"
12 "AT - Austria"
13 "AU - Australia"
14 "AW - Aruba"
15 "AX - Åland Islands"
16 "AZ - Azerbaijan"
17 "BA - Bosnia and Herzegovina"
18 "BB - Barbados"
19 "BD - Bangladesh"
20 "BE - Belgium"
21 "BF - Burkina Faso"
22 "BG - Bulgaria"
23 "BH - Bahrain"
24 "BI - Burundi"
25 "BJ - Benin"
26 "BL - Saint Barthélemy"
27 "BM - Bermuda"
28 "BN - Brunei Darussalam"
29 "BO - Bolivia"
30 "BQ - Bonaire"
31 "BR - Brazil"
32 "BS - Bahamas"
33 "BT - Bhutan"
34 "BV - Bouvet Island"
35 "BW - Botswana"
36 "BY - Belarus"
37 "BZ - Belize"
38 "CA - Canada"
39 "CC - Cocos (Keeling) Islands"
40 "CD - Congo"
41 "CF - Central African Republic"
42 "CG - Congo"
43 "CH - Switzerland"
44 "CI - Côte d'Ivoire"
45 "CK - Cook Islands"
46 "CL - Chile"
47 "CM - Cameroon"
48 "CN - China"
49 "CO - Colombia"
50 "CR - Costa Rica"
51 "CU - Cuba"
52 "CV - Cabo Verde"
53 "CW - Curaçao"
54 "CX - Christmas Island"
55 "CY - Cyprus"
56 "CZ - Czechia"
57 "DE - Germany"
58 "DJ - Djibouti"
59 "DK - Denmark"
60 "DM - Dominica"
61 "DO - Dominican Republic"
62 "DZ - Algeria"
63 "EC - Ecuador"
64 "EE - Estonia"
65 "EG - Egypt"
66 "EH - Western Sahara"
67 "ER - Eritrea"
68 "ES - Spain"
69 "ET - Ethiopia"
70 "FI - Finland"
71 "FJ - Fiji"
72 "FK - Falkland Islands (Malvinas)"
73 "FM - Micronesia (Federated States of)"
74 "FO - Faroe Islands"
75 "FR - France"
76 "GA - Gabon"
77 "GB - United Kingdom of Great Britain and Northern Ireland"
78 "GD - Grenada"
79 "GE - Georgia"
80 "GF - French Guiana"
81 "GG - Guernsey"
82 "GH - Ghana"
83 "GI - Gibraltar"
84 "GL - Greenland"
85 "GM - Gambia"
86 "GN - Guinea"
87 "GP - Guadeloupe"
88 "GQ - Equatorial Guinea"
89 "GR - Greece"
90 "GS - South Georgia and the South Sandwich Islands"
91 "GT - Guatemala"
92 "GU - Guam"
93 "GW - Guinea-Bissau"
94 "GY - Guyana"
95 "HK - Hong Kong"
96 "HM - Heard Island and McDonald Islands"
97 "HN - Honduras"
98 "HR - Croatia"
99 "HT - Haiti"
100 "HU - Hungary"
101 "ID - Indonesia"
102 "IE - Ireland"
103 "IL - Israel"
104 "IM - Isle of Man"
105 "IN - India"
106 "IO - British Indian Ocean Territory"
107 "IQ - Iraq"
108 "IR - Iran (Islamic Republic of)"
109 "IS - Iceland"
110 "IT - Italy"
111 "JE - Jersey"
112 "JM - Jamaica"
113 "JO - Jordan"
114 "JP - Japan"
115 "KE - Kenya"
116 "KG - Kyrgyzstan"
117 "KH - Cambodia"
118 "KI - Kiribati"
119 "KM - Comoros"
120 "KN - Saint Kitts and Nevis"
121 "KP - Korea (Democratic People's Republic of)"
122 "KR - Korea"
123 "KW - Kuwait"
124 "KY - Cayman Islands"
125 "KZ - Kazakhstan"
126 "LA - Lao People's Democratic Republic"
127 "LB - Lebanon"
128 "LC - Saint Lucia"
129 "LI - Liechtenstein"
130 "LK - Sri Lanka"
131 "LR - Liberia"
132 "LS - Lesotho"
133 "LT - Lithuania"
134 "LU - Luxembourg"
135 "LV - Latvia"
136 "LY - Libya"
137 "MA - Morocco"
138 "MC - Monaco"
139 "MD - Moldova"
140 "ME - Montenegro"
141 "MF - Saint Martin (French part)"
142 "MG - Madagascar"
143 "MH - Marshall Islands"
144 "MK - North Macedonia"
145 "ML - Mali"
146 "MM - Myanmar"
147 "MN - Mongolia"
148 "MO - Macao"
149 "MP - Northern Mariana Islands"
150 "MQ - Martinique"
151 "MR - Mauritania"
152 "MS - Montserrat"
153 "MT - Malta"
154 "MU - Mauritius"
155 "MV - Maldives"
156 "MW - Malawi"
157 "MX - Mexico"
158 "MY - Malaysia"
159 "MZ - Mozambique"
160 "NA - Namibia"
161 "NC - New Caledonia"
162 "NE - Niger"
163 "NF - Norfolk Island"
164 "NG - Nigeria"
165 "NI - Nicaragua"
166 "NL - Netherlands"
167 "NO - Norway"
168 "NP - Nepal"
169 "NR - Nauru"
170 "NU - Niue"
171 "NZ - New Zealand"
172 "OM - Oman"
173 "PA - Panama"
174 "PE - Peru"
175 "PF - French Polynesia"
176 "PG - Papua New Guinea"
177 "PH - Philippines"
178 "PK - Pakistan"
179 "PL - Poland"
180 "PM - Saint Pierre and Miquelon"
181 "PN - Pitcairn"
182 "PR - Puerto Rico"
183 "PS - Palestine"
184 "PT - Portugal"
185 "PW - Palau"
186 "PY - Paraguay"
187 "QA - Qatar"
188 "RE - Réunion"
189 "RO - Romania"
190 "RS - Serbia"
191 "RU - Russian Federation"
192 "RW - Rwanda"
193 "SA - Saudi Arabia"
194 "SB - Solomon Islands"
195 "SC - Seychelles"
196 "SD - Sudan"
197 "SE - Sweden"
198 "SG - Singapore"
199 "SH - Saint Helena"
200 "SI - Slovenia"
201 "SJ - Svalbard and Jan Mayen"
202 "SK - Slovakia"
203 "SL - Sierra Leone"
204 "SM - San Marino"
205 "SN - Senegal"
206 "SO - Somalia"
207 "SR - Suriname"
208 "SS - South Sudan"
209 "ST - Sao Tome and Principe"
210 "SV - El Salvador"
211 "SX - Sint Maarten (Dutch part)"
212 "SY - Syrian Arab Republic"
213 "SZ - Eswatini"
214 "TC - Turks and Caicos Islands"
215 "TD - Chad"
216 "TF - French Southern Territories"
217 "TG - Togo"
218 "TH - Thailand"
219 "TJ - Tajikistan"
220 "TK - Tokelau"
221 "TL - Timor-Leste"
222 "TM - Turkmenistan"
223 "TN - Tunisia"
224 "TO - Tonga"
225 "TR - Turkey"
226 "TT - Trinidad and Tobago"
227 "TV - Tuvalu"
228 "TW - Taiwan"
229 "TZ - Tanzania"
230 "UA - Ukraine"
231 "UG - Uganda"
232 "UM - United States Minor Outlying Islands"
233 "US - United States of America"
234 "UY - Uruguay"
235 "UZ - Uzbekistan"
236 "VA - Holy See"
237 "VC - Saint Vincent and the Grenadines"
238 "VE - Venezuela (Bolivarian Republic of)"
239 "VG - Virgin Islands (British)"
240 "VI - Virgin Islands (U.S.)"
241 "VN - Viet Nam"
242 "VU - Vanuatu"
243 "WF - Wallis and Futuna"
244 "WS - Samoa"
245 "YE - Yemen"
246 "YT - Mayotte"
247 "ZA - South Africa"
248 "ZM - Zambia"
249 "ZW - Zimbabwe"
)

CHOICE=$(dialog --clear \
		--nocancel \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear

case $CHOICE in
	1)
		COUNTRY="AD"
		;;
	2)
		COUNTRY="AE"
		;;
	3)
		COUNTRY="AF"
		;;
	4)
		COUNTRY="AG"
		;;
	5)
		COUNTRY="AI"
		;;
	6)
		COUNTRY="AL"
		;;
	7)
		COUNTRY="AM"
		;;
	8)
		COUNTRY="AO"
		;;
	9)
		COUNTRY="AQ"
		;;
	10)
		COUNTRY="AR"
		;;
	11)
		COUNTRY="AS"
		;;
	12)
		COUNTRY="AT"
		;;
	13)
		COUNTRY="AU"
		;;
	14)
		COUNTRY="AW"
		;;
	15)
		COUNTRY="AX"
		;;
	16)
		COUNTRY="AZ"
		;;
	17)
		COUNTRY="BA"
		;;
	18)
		COUNTRY="BB"
		;;
	19)
		COUNTRY="BD"
		;;
	20)
		COUNTRY="BE"
		;;
	21)
		COUNTRY="BF"
		;;
	22)
		COUNTRY="BG"
		;;
	23)
		COUNTRY="BH"
		;;
	24)
		COUNTRY="BI"
		;;
	25)
		COUNTRY="BJ"
		;;
	26)
		COUNTRY="BL"
		;;
	27)
		COUNTRY="BM"
		;;
	28)
		COUNTRY="BN"
		;;
	29)
		COUNTRY="BO"
		;;
	30)
		COUNTRY="BQ"
		;;
	31)
		COUNTRY="BR"
		;;
	32)
		COUNTRY="BS"
		;;
	33)
		COUNTRY="BT"
		;;
	34)
		COUNTRY="BV"
		;;
	35)
		COUNTRY="BW"
		;;
	36)
		COUNTRY="BY"
		;;
	37)
		COUNTRY="BZ"
		;;
	38)
		COUNTRY="CA"
		;;
	39)
		COUNTRY="CC"
		;;
	40)
		COUNTRY="CD"
		;;
	41)
		COUNTRY="CF"
		;;
	42)
		COUNTRY="CG"
		;;
	43)
		COUNTRY="CH"
		;;
	44)
		COUNTRY="CI"
		;;
	45)
		COUNTRY="CK"
		;;
	46)
		COUNTRY="CL"
		;;
	47)
		COUNTRY="CM"
		;;
	48)
		COUNTRY="CN"
		;;
	49)
		COUNTRY="CO"
		;;
	50)
		COUNTRY="CR"
		;;
	51)
		COUNTRY="CU"
		;;
	52)
		COUNTRY="CV"
		;;
	53)
		COUNTRY="CW"
		;;
	54)
		COUNTRY="CX"
		;;
	55)
		COUNTRY="CY"
		;;
	56)
		COUNTRY="CZ"
		;;
	57)
		COUNTRY="DE"
		;;
	58)
		COUNTRY="DJ"
		;;
	59)
		COUNTRY="DK"
		;;
	60)
		COUNTRY="DM"
		;;
	61)
		COUNTRY="DO"
		;;
	62)
		COUNTRY="DZ"
		;;
	63)
		COUNTRY="EC"
		;;
	64)
		COUNTRY="EE"
		;;
	65)
		COUNTRY="EG"
		;;
	66)
		COUNTRY="EH"
		;;
	67)
		COUNTRY="ER"
		;;
	68)
		COUNTRY="ES"
		;;
	69)
		COUNTRY="ET"
		;;
	70)
		COUNTRY="FI"
		;;
	71)
		COUNTRY="FJ"
		;;
	72)
		COUNTRY="FK"
		;;
	73)
		COUNTRY="FM"
		;;
	74)
		COUNTRY="FO"
		;;
	75)
		COUNTRY="FR"
		;;
	76)
		COUNTRY="GA"
		;;
	77)
		COUNTRY="GB"
		;;
	78)
		COUNTRY="GD"
		;;
	79)
		COUNTRY="GE"
		;;
	80)
		COUNTRY="GF"
		;;
	81)
		COUNTRY="GG"
		;;
	82)
		COUNTRY="GH"
		;;
	83)
		COUNTRY="GI"
		;;
	84)
		COUNTRY="GL"
		;;
	85)
		COUNTRY="GM"
		;;
	86)
		COUNTRY="GN"
		;;
	87)
		COUNTRY="GP"
		;;
	88)
		COUNTRY="GQ"
		;;
	89)
		COUNTRY="GR"
		;;
	90)
		COUNTRY="GS"
		;;
	91)
		COUNTRY="GT"
		;;
	92)
		COUNTRY="GU"
		;;
	93)
		COUNTRY="GW"
		;;
	94)
		COUNTRY="GY"
		;;
	95)
		COUNTRY="HK"
		;;
	96)
		COUNTRY="HM"
		;;
	97)
		COUNTRY="HN"
		;;
	98)
		COUNTRY="HR"
		;;
	99)
		COUNTRY="HT"
		;;
	100)
		COUNTRY="HU"
		;;
	101)
		COUNTRY="ID"
		;;
	102)
		COUNTRY="IE"
		;;
	103)
		COUNTRY="IL"
		;;
	104)
		COUNTRY="IM"
		;;
	105)
		COUNTRY="IN"
		;;
	106)
		COUNTRY="IO"
		;;
	107)
		COUNTRY="IQ"
		;;
	108)
		COUNTRY="IR"
		;;
	109)
		COUNTRY="IS"
		;;
	110)
		COUNTRY="IT"
		;;
	111)
		COUNTRY="JE"
		;;
	112)
		COUNTRY="JM"
		;;
	113)
		COUNTRY="JO"
		;;
	114)
		COUNTRY="JP"
		;;
	115)
		COUNTRY="KE"
		;;
	116)
		COUNTRY="KG"
		;;
	117)
		COUNTRY="KH"
		;;
	118)
		COUNTRY="KI"
		;;
	119)
		COUNTRY="KM"
		;;
	120)
		COUNTRY="KN"
		;;
	121)
		COUNTRY="KP"
		;;
	122)
		COUNTRY="KR"
		;;
	123)
		COUNTRY="KW"
		;;
	124)
		COUNTRY="KY"
		;;
	125)
		COUNTRY="KZ"
		;;
	126)
		COUNTRY="LA"
		;;
	127)
		COUNTRY="LB"
		;;
	128)
		COUNTRY="LC"
		;;
	129)
		COUNTRY="LI"
		;;
	130)
		COUNTRY="LK"
		;;
	131)
		COUNTRY="LR"
		;;
	132)
		COUNTRY="LS"
		;;
	133)
		COUNTRY="LT"
		;;
	134)
		COUNTRY="LU"
		;;
	135)
		COUNTRY="LV"
		;;
	136)
		COUNTRY="LY"
		;;
	137)
		COUNTRY="MA"
		;;
	138)
		COUNTRY="MC"
		;;
	139)
		COUNTRY="MD"
		;;
	140)
		COUNTRY="ME"
		;;
	141)
		COUNTRY="MF"
		;;
	142)
		COUNTRY="MG"
		;;
	143)
		COUNTRY="MH"
		;;
	144)
		COUNTRY="MK"
		;;
	145)
		COUNTRY="ML"
		;;
	146)
		COUNTRY="MM"
		;;
	147)
		COUNTRY="MN"
		;;
	148)
		COUNTRY="MO"
		;;
	149)
		COUNTRY="MP"
		;;
	150)
		COUNTRY="MQ"
		;;
	151)
		COUNTRY="MR"
		;;
	152)
		COUNTRY="MS"
		;;
	153)
		COUNTRY="MT"
		;;
	154)
		COUNTRY="MU"
		;;
	155)
		COUNTRY="MV"
		;;
	156)
		COUNTRY="MW"
		;;
	157)
		COUNTRY="MX"
		;;
	158)
		COUNTRY="MY"
		;;
	159)
		COUNTRY="MZ"
		;;
	160)
		COUNTRY="NA"
		;;
	161)
		COUNTRY="NC"
		;;
	162)
		COUNTRY="NE"
		;;
	163)
		COUNTRY="NF"
		;;
	164)
		COUNTRY="NG"
		;;
	165)
		COUNTRY="NI"
		;;
	166)
		COUNTRY="NL"
		;;
	167)
		COUNTRY="NO"
		;;
	168)
		COUNTRY="NP"
		;;
	169)
		COUNTRY="NR"
		;;
	170)
		COUNTRY="NU"
		;;
	171)
		COUNTRY="NZ"
		;;
	172)
		COUNTRY="OM"
		;;
	173)
		COUNTRY="PA"
		;;
	174)
		COUNTRY="PE"
		;;
	175)
		COUNTRY="PF"
		;;
	176)
		COUNTRY="PG"
		;;
	177)
		COUNTRY="PH"
		;;
	178)
		COUNTRY="PK"
		;;
	179)
		COUNTRY="PL"
		;;
	180)
		COUNTRY="PM"
		;;
	181)
		COUNTRY="PN"
		;;
	182)
		COUNTRY="PR"
		;;
	183)
		COUNTRY="PS"
		;;
	184)
		COUNTRY="PT"
		;;
	185)
		COUNTRY="PW"
		;;
	186)
		COUNTRY="PY"
		;;
	187)
		COUNTRY="QA"
		;;
	188)
		COUNTRY="RE"
		;;
	189)
		COUNTRY="RO"
		;;
	190)
		COUNTRY="RS"
		;;
	191)
		COUNTRY="RU"
		;;
	192)
		COUNTRY="RW"
		;;
	193)
		COUNTRY="SA"
		;;
	194)
		COUNTRY="SB"
		;;
	195)
		COUNTRY="SC"
		;;
	196)
		COUNTRY="SD"
		;;
	197)
		COUNTRY="SE"
		;;
	198)
		COUNTRY="SG"
		;;
	199)
		COUNTRY="SH"
		;;
	200)
		COUNTRY="SI"
		;;
	201)
		COUNTRY="SJ"
		;;
	202)
		COUNTRY="SK"
		;;
	203)
		COUNTRY="SL"
		;;
	204)
		COUNTRY="SM"
		;;
	205)
		COUNTRY="SN"
		;;
	206)
		COUNTRY="SO"
		;;
	207)
		COUNTRY="SR"
		;;
	208)
		COUNTRY="SS"
		;;
	209)
		COUNTRY="ST"
		;;
	210)
		COUNTRY="SV"
		;;
	211)
		COUNTRY="SX"
		;;
	212)
		COUNTRY="SY"
		;;
	213)
		COUNTRY="SZ"
		;;
	214)
		COUNTRY="TC"
		;;
	215)
		COUNTRY="TD"
		;;
	216)
		COUNTRY="TF"
		;;
	217)
		COUNTRY="TG"
		;;
	218)
		COUNTRY="TH"
		;;
	219)
		COUNTRY="TJ"
		;;
	220)
		COUNTRY="TK"
		;;
	221)
		COUNTRY="TL"
		;;
	222)
		COUNTRY="TM"
		;;
	223)
		COUNTRY="TN"
		;;
	224)
		COUNTRY="TO"
		;;
	225)
		COUNTRY="TR"
		;;
	226)
		COUNTRY="TT"
		;;
	227)
		COUNTRY="TV"
		;;
	228)
		COUNTRY="TW"
		;;
	229)
		COUNTRY="TZ"
		;;
	230)
		COUNTRY="UA"
		;;
	231)
		COUNTRY="UG"
		;;
	232)
		COUNTRY="UM"
		;;
	233)
		COUNTRY="US"
		;;
	234)
		COUNTRY="UY"
		;;
	235)
		COUNTRY="UZ"
		;;
	236)
		COUNTRY="VA"
		;;
	237)
		COUNTRY="VC"
		;;
	238)
		COUNTRY="VE"
		;;
	239)
		COUNTRY="VG"
		;;
	240)
		COUNTRY="VI"
		;;
	241)
		COUNTRY="VN"
		;;
	242)
		COUNTRY="VU"
		;;
	243)
		COUNTRY="WF"
		;;
	244)
		COUNTRY="WS"
		;;
	245)
		COUNTRY="YE"
		;;
	246)
		COUNTRY="YT"
		;;
	247)
		COUNTRY="ZA"
		;;
	248)
		COUNTRY="ZM"
		;;
	249)
		COUNTRY="ZW"
		;;
esac

printf "country_code=$COUNTRY\ninterface=wlan0\nssid=$SSID\nhw_mode=$HW\nchannel=7\nmacaddr_acl=0\nauth_algs=1\nignore_broadcast_ssid=0\nwpa=2\nwpa_passphrase=$WPA\nwpa_key_mgmt=WPA-PSK\nwpa_pairwise=TKIP\nrsn_pairwise=CCMP\n" > /etc/hostapd/hostapd.conf


curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker pi
rm get-docker.sh
apt install -y libffi-dev libssl-dev
clear
apt install -y python3-dev
clear
apt install -y python3 python3-pip
clear
pip3 install docker-compose
clear
apt install -y git
clear

git clone https://github.com/piperra/pi-zeek-kibana.git

cd ./pi-zeek-kibana

systemctl reboot
