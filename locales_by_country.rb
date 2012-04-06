# encoding: utf-8
ary = DATA.read.split("\n")
ary.each_slice(3).each do |item|
  lang, country, locale = *item
  puts locale
end
__END__
Arabic
Saudi Arabia
ar_SA
Chinese (Simplified)
China
zh_CN
Chinese (Traditional)
Taiwan
zh_TW
Dutch
Netherlands
nl_NL
English
Australia
en_AU
English
Canada
en_CA
English
United Kingdom
en_GB
English
United States
en_US
French
Canada
fr_CA
French
France
fr_FR
German
Germany
de_DE
Hebrew
Israel
iw_IL
Hindi
India
hi_IN
Italian
Italy
it_IT
Japanese
Japan
ja_JP
Korean
South Korea
ko_KR
Portuguese
Brazil
pt_BR
Spanish
Spain
es_ES
Swedish
Sweden
sv_SE
Thai (Western digits)
Thailand
th_TH
Thai (Thai digits)
Thailand
th_TH_TH
Albanian
Albania
sq_AL
Arabic
Algeria
ar_DZ
Arabic
Bahrain
ar_BH
Arabic
Egypt
ar_EG
Arabic
Iraq
ar_IQ
Arabic
Jordan
ar_JO
Arabic
Kuwait
ar_KW
Arabic
Lebanon
ar_LB
Arabic
Libya
ar_LY
Arabic
Morocco
ar_MA
Arabic
Oman
ar_OM
Arabic
Qatar
ar_QA
Arabic
Sudan
ar_SD
Arabic
Syria
ar_SY
Arabic
Tunisia
ar_TN
Arabic
United Arab Emirates
ar_AE
Arabic
Yemen
ar_YE
Belorussian
Belorussia
be_BY
Bulgarian
Bulgaria
bg_BG
Catalan
Spain
ca_ES
Chinese
Hong Kong
zh_HK
Croatian
Croatia
hr_HR
Czech
Czech Republic
cs_CZ
Danish
Denmark
da_DK
Dutch
Belgium
nl_BE
English
India
en_IN
English
Ireland
en_IE
English
New Zealand
en_NZ
English
South Africa
en_ZA
Estonian
Estonia
et_EE
Finnish
Finland
fi_FI
French
Belgium
fr_BE
French
Luxembourg
fr_LU
French
Switzerland
fr_CH
German
Austria
de_AT
German
Luxembourg
de_LU
German
Switzerland
de_CH
Greek
Greece
el_GR
Hungarian
Hungary
hu_HU
Icelandic
Iceland
is_IS
Italian
Switzerland
it_CH
Latvian
Latvia
lv_LV
Lithuanian
Lithuania
lt_LT
Macedonian
Macedonia
mk_MK
Norwegian (Bokmål)
Norway
no_NO
Norwegian (Nynorsk)
Norway
no_NO_NY
Polish
Poland
pl_PL
Portuguese
Portugal
pt_PT
Romanian
Romania
ro_RO
Russian
Russia
ru_RU
Serbian (Cyrillic)
Yugoslavia
sr_YU
Serbo-Croatian
Yugoslavia
sh_YU
Slovak
Slovakia
sk_SK
Slovenian
Slovenia
sl_SI
Spanish
Argentina
es_AR
Spanish
Bolivia
es_BO
Spanish
Chile
es_CL
Spanish
Colombia
es_CO
Spanish
Costa Rica
es_CR
Spanish
Dominican Republic
es_DO
Spanish
Ecuador
es_EC
Spanish
El Salvador
es_SV
Spanish
Guatemala
es_GT
Spanish
Honduras
es_HN
Spanish
Mexico
es_MX
Spanish
Nicaragua
es_NI
Spanish
Panama
es_PA
Spanish
Paraguay
es_PY
Spanish
Peru
es_PE
Spanish
Puerto Rico
es_PR
Spanish
Uruguay
es_UY
Spanish
Venezuela
es_VE
Turkish
Turkey
tr_TR
Ukrainian
Ukraine
uk_UA
