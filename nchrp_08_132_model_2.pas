program nchrp_08_132_model_2;

{$APPTYPE CONSOLE}

uses
  SysUtils, Math;

const
    nnumas=4486;    {number of numa zones}
    maxparks=200;   {maximum number of park records}
    maxstate=56;    {highest state code}
    maxparkaps=26;  {maximum airports in choice set for a park}
    maxnights=15;   {maximum nights stay}

var
inf,ouf,ouf2,ouf3:text;
v,pnuma,numa,numax,pz,park,quarter,nparks,st:integer;
stfrac:array[1..maxstate] of double;

pstate,
pavgtemp,
pmintemp,
pmaxtemp,
pavgprec,
pelevatn,
pcoastal,
ppopdens,
pempdens,
pentdens,
pskiindex    ,
pcoaindex    ,
phikindex    ,
photindex    ,
capark,
napark,
papark,
janmar,
aprjun,
julsep,
octdec:single;


parktype,
park_numaindex:array[1..maxparks] of integer;

park_tractgeoid,
park_sqm,
founded,
frwcaccess,
hascamping,
hasrvcamping,
haslodging,
halopop,
halohh,
haloemp,
haloentemp,
halowater,
haloprotl,
haloarea,
leent1,
leent2,
leent3,
greatsmoky,
wateraccess,
utahbig5,
arizonanp,
californianp,
coloradonp,
newmexiconp,
orwashnp,
wymontnp,
fcmonum,
othmonum,

fr_foreign,
phawaii,
palaska,
halofrwater,
halofrprotl,
logarea,
logage:array[1..maxparks] of double;

visits:array[1..maxparks,1..4] of double;

parkCode:array[1..maxparks] of string[4];
parkName:array[1..maxparks] of string[80];


zone_sqm     ,
hholds       ,
persons    ,
adults    ,
ffamcu6   ,
ffamc6p   ,
ffamnoc   ,
fnonfam   ,
fage017   ,
fage1834  ,
fage3549  ,
fage5064  ,
fage6579  ,
fage80up  ,
fincu25    ,
finc2550    ,
finc5075    ,
finc75100    ,
finc100150    ,
finc150200    ,
finco200    ,
fwhite  ,
fblack    ,
fhisp    ,
fasian    ,
fothrc    ,
f0veh    ,
fwathome    ,
femployed    ,

state        ,
popden       ,
hhden        ,
empden       ,
enteden      ,
fracwater    ,
fracprotl    ,
coast        ,
elevation    ,
avgtemp1     ,
maxtemp1     ,
mintemp1     ,
avgprec1     ,
avgtemp2     ,
maxtemp2     ,
mintemp2     ,
avgprec2     ,
avgtemp3     ,
maxtemp3     ,
mintemp3     ,
avgprec3     ,
avgtemp4     ,
maxtemp4     ,
mintemp4     ,
avgprec4     ,
samestate    ,

samenuma     ,
cdist        ,
noland       ,
cdistto50    ,
cdistto100   ,
cdistto200   ,
cdistto400   ,
cdistto800   ,
cdisto1600   ,
cdisov1600   ,
logadults    ,

havgtemp    ,
hmintemp    ,
hmaxtemp    ,
havgprec    ,
skiindex    ,
coaindex    ,
hikindex    ,
hotindex    ,
skidiff    ,
coadiff    ,
hikdiff    ,
hotdiff    ,
avail
: array[1..nnumas] of single;

cardist:array[1..nnumas,1..nnumas] of single;

eutil,nresprob:array[1..nnumas] of double;
eutilsum,prob,haloutil:double;
avgdist,
dist0to50,
dist50to100,
dist100to200,
dist200to400,
dist400to800,
dist800to1600,
distover1600,
nolanddist:single;

parkx,pap,nightsmodel,thold:integer;
nparkaps:array[1..maxparks] of integer;
parkapnum:array[1..maxparks,1..maxparkaps] of integer;
{parkapdis,parkappax:array[1..maxparks,1..maxparkaps] of single;}
aputil,approb:array[1..maxparkaps] of double;
airshare,airdist,aputilsum,aplogsum,carutil,airutil,airprob,logvisits,
parkapdis,parkradius,pzoneradius,nightsutil:double;
blank:string[1];

ninpark,ninhalo,maxnightsinhalo,ntotal,daytrip,halores,vmtarea,vmtmodel:integer;
nentries,logvmt,durfact:double;
tholdutil:array[0..maxnights,1..3] of double;
ninparkprob:array[1..3,0..maxnights] of double;
ninhaloprob:array[0..maxnights] of double;
nightsprob:array[1..2,0..maxnights,0..maxnights] of double;

haloprob:array[1..2] of double;
vmt:array[1..2,1..2] of double;

{NEW VARIABLES}
const ndow=7;
dowlab:array[1..ndow] of string[3]=('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
ntodpers=6;
todperlab:array[1..ntodpers] of string=('before 6 am','6-9 am','9 am-noon','noon-3 pm','3-6 pm','after 6 pm');

maxaps=300;

var apcode:array[1..maxaps] of string[3];
    apnuma:array[1..maxaps] of integer;
    appax19:array[1..maxaps] of double;
    naports:integer;
    dow,todper:integer;

    resprob:array[1..nnumas] of double;
    zoneairprob:array[1..nnumas] of double;
    zoneapprob:array[1..nnumas,1..maxparkaps] of double;
    adultVisits:double;

{NEW VARIABLES 2}
const
   adultsPerVehicle= 2.25;

   childrenPerAdult:array[0..6] of single=(
    0.211,  {0 nights}
    0.225,  {1 nights}
    0.234,  {2 nights}
    0.259,  {3 nights}
    0.266,  {4 nights}
    0.268,  {5 nights}
    0.311); {6+ nights}

   parkEntriesCoef:array[1..4] of single= (
    1.146,  {constant}
    0.454,  {nights in park}
    0.303,  {nights in halo}
    0.440); {day trip}

   var
       arriveFrac,departFrac:array[1..nnumas,1..ndow,1..ntodpers] of double;
       ntotal6,tnights,tnights5,arrper,depper,arrdow,depdow,apzn,apnum:integer;
       avgEntries:array[1..nnumas,0..2] of double;
       personEntries,vehTrips,totVehicleVisits:double;
       vehicleVisits:array[1..nnumas] of double;
       vehArrive,vehDepart:array[1..nnumas,1..ndow,1..ntodpers] of double;
       pcodein:string[4];
       apcodein:string[3];
       localVMT:array[1..2,1..2,0..maxnights,0..maxnights,0..ndow] of double;
       dowfrac:array[0..ndow] of double;


const
    {home model location coefficients}
          hlcoef:array[1..45] of double=
     (-2.86002482115      ,              { 1 ffamcu6 [numa]                         }
      -0.655453304372     ,              { 2 ffamc6p [numa]                         }
       0.000000000000     ,              { 3 ffamnoc [numa]                         }
      -1.29240090234      ,              { 4 fnonfam [numa]                         }
      -4.26904612643      ,              { 5 fage017 [numa]                         }
      -3.34217630869      ,              { 6 fage1834 [numa]                        }
       0.000000000000     ,              { 7 fage3549 [numa]                        }
      -3.36943693108      ,              { 8 fage5064 [numa]                        }
      -4.25710998463      ,              { 9 (fage6579 [numa]+fage80up [numa])      }
       0.671629839321     ,              {10 fincu25  [numa]                        }
       1.10526020834      ,              {11 finc2550 [numa]                        }
       0.000000000000     ,              {12 (finc5075 [numa]+finc75100 [numa])     }
      -2.47830118931      ,              {13 finc100150 [numa]                      }
       0.565702216924E-01 ,              {14 (finc150200 [numa]+finco200 [numa])    }
       0.425672297625     ,              {15 samenuma [numa]                        }
      -7.63318694981      ,              {16 noland [numa]                          }
      -0.308756740360E-01 ,              {17 (cdistto50 [numa]+cdistto100 [numa])   }
      -0.141750259623E-01 ,              {18 cdistto200 [numa]                      }
      -0.542993364078E-02 ,              {19 cdistto400 [numa]                      }
      -0.340307852431E-02 ,              {20 cdistto800 [numa]                      }
      -0.829896711473E-03 ,              {21 cdisto1600 [numa]                      }
      -0.219385313371E-03 ,              {22 cdisov1600 [numa]                      }
       1.00000000000      ,              {23 logadults [numa]                       }
       0.000000000000     ,              {24 f0veh [numa]                           }
      -1.34036242168      ,              {25 fblack [numa]                          }
      -0.570788067501     ,              {26 fhisp [numa]                           }
      -0.784198312164     ,              {27 fasian [numa]                          }
      -1.03631283012      ,              {28 fothrc [numa]                          }
       0.709636197720     ,              {29 fwathome [numa]                        }
       2.69149375888      ,              {30 femployed [numa]                       }
      -0.2                ,              {31 (samestate [numa])                     }
      -0.114954844956     ,              {32 ln(1+popden [numa])                    }
       0.000000000000     ,              {33 ln(1+empden [numa])                    }
       0.000000000000     ,              {34 (enteden [numa]/max(1,empden [numa]))  }
       0.880669213081     ,              {35 coast [numa]                           }
      -0.582271744729     ,              {36 (samestate [numa]*capark)              }
       1.46199533562      ,              {37 (samestate [numa]*papark)              }
      -0.147925523944E-03 ,              {38 (cdist [numa]*capark)                  }
      -0.313935979289E-02 ,              {39 (cdist [numa]*papark)                  }
       0.864674771142E-04 ,              {40 (cdist [numa]*julsep)                  }
      -0.379571807060E-03 ,              {41 (cdist [numa]*janmar)                  }
       0.504287993884E-02 ,              {42 (skidiff[numa])                        }
       0.178458862515     ,              {43 (coadiff[numa])                        }
       0.612519736215E-01 ,              {44 (hikdiff[numa])                        }
      -0.702670230460E-01 );             {45 (hotdiff[numa])                        }


{visit generation model coefficients}
     vgcoef:array[1..39] of double=
          (0.295,  {1 Constant}
           0.400,  {2 logsum	}
           0.006,  {3 aplogsum}
          -1.022,  {4 winter	}
           0.425,  {5 spring	}
           1.852,  {6 summer	}
           0.555,  {7 frwcaccess	}
           0.389,  {8 hasrvcamping	}
           0.659,  {9 haslodging	}
           0.126,  {10 wtrskiindex	}
           0.074,  {11 sprskiindex	}
           0.029,  {12 autskiindex	}
           0.725,  {13 wtrcoastindex}
           0.498,  {14 sprcoastindex}
           0.318,  {15 sumcoastindex}
           0.509,  {16 autcoastindex}
           0.277,  {17 wtrhikeindex	}
           0.177,  {18 sprhikeindex	}
           0.029,  {19 sumhikeindex	}
           0.161,  {20 authikeindex	}
          -0.454,  {21 lnvhot	}
           0.203,  {22 lnarea	}
           1.146,  {23 lnage	}
          -1.450,  {24 phawaii	}
          -2.331,  {25 palaska	}
           0.114,  {26 leent2	}
          -0.217,  {27 leent3	}
           0.077,  {28 lhaloentemp	}
           1.989,  {29 greatsmoky	}
          -2.620,  {30 wateraccess	}
           1.287,  {31 utahbig5	}
           0.883,  {32 arizonanp	}
           0.506,  {33 californianp	}
           0.163,  {34 coloradonp	}
           0.418,  {35 newmexiconp	}
          -1.349,  {36 orwashnp	}
           0.491,  {37 wymontnp	}
          -0.306,  {38 fcmonum	}
          -0.097); {39 othmonum	}

{coefficients for nights stay models}
 tholdsexponentiated:boolean=false;

 nightsthold:array[0..maxnights,1..3] of double=(
{H-Park  N-Park  N-Halo   Thresholds }
(0.737,	1.285,	1.608),  {0 nights  }
(2.285,	2.599,	2.580),  {1 night   }
(3.004,	3.355,	3.330),  {2 nights  }
(3.521,	3.961,	3.928),  {3 nights  }
(3.925,	4.448,	4.421),  {4 nights  }
(4.247,	4.850,	4.841),  {5 nights  }
(4.530,	5.190,	5.220),  {6 nights  }
(4.789,	5.510,	5.584),  {7 nights  }
(5.027,	5.727,	5.856),  {8 nights  }
(5.261,	5.920,	6.085),  {9 nights  }
(5.464,	6.097,	6.287),  {10 nights }
(5.664,	6.258,	6.476),  {11 nights }
(5.850,	6.412,	6.649),  {12 nights }
(6.000,	6.564,	6.801),  {13 nights }
(6.185,	6.717,	6.955),  {14 nights }
(0.000,	0.000,	0.000)); {15+nights }

 {H-Park   N-Park  N-Halo   Variable }
 nightscoef:array[1..21,1..3] of double=(
(-0.009	 , -0.191  ,-0.349	 ), {1 Live in same zone        }
( 0.263	 , -0.089  ,-0.306	 ), {2 Jan-Mar                  }
( 0.009	 , -0.296  ,-0.158	 ), {3 Apr-Jun                  }
(-0.278	 , -0.050  , 0.162	 ), {4 Jul-Aug                  }
( 0.049	 , -0.267  , 2.011	 ), {5 Park in Hawaii           }
( 0.059	 ,  0.237  , 0.595	 ), {6 Park in Alaska           }
( 0.0060 ,  0.0036  ,-0.0038     ), {7 Coast index             }
(0.00024 ,  0.00049 , 0.00034    ), {8 Mountain hike index      }
(-0.0002 ,  0.00135 , 0.00014    ), {9 Winter sport index       }
(-0.301	 , -0.064  , 0.289	 ), {10 Has lodging              }
( 0.114	 ,  0.126  ,-0.116	 ), {11 Log of land area         }
(-0.096	 ,  0.166  , 0.350	 ), {12 Log of age of park       }
( 0.117	 , -0.326  ,-0.116	 ), {13 National monument        }
( 0.013	 , -0.047  ,-0.015	 ), {14 Very hot                 }
( 0.000	 ,  0.156  , 0.988	 ), {15 Car distance/1000        }
( 0.000	 , -0.066  ,-0.307	 ), {16 (Car distance/1000) squar}
( 0.000	 , -0.111  , 0.473	 ), {17 Traveled by air          }
(-2.3E-06,  3.7E-07 , 5.4E-06    ), {18 Halo area food lodging em}
(-1.746	 , -0.785  , 0.475	 ), {19 Halo area frac. water    }
( 0.107	 , -0.877  , 0.020	 ), {20 Halo area frac. protected}
( 0.000	 ,  0.000  ,-0.071	)); {21 Nights in park           }

 {H-Park   N-Park  N-Halo   Variable }
 vmtcoef:array[1..19,1..3] of double=(
 ( 4.123,  2.975, 5.143	), {1 Constant   }
 ( 0.085,  0.832,-0.777 ), {2 lpnights   }
 ( 0.353, -0.266, 0.807	), {3 lpnightssq }
 ( 0.000, -0.437, 3.050 ), {4 lhnights   }
 ( 0.000,  0.218,-0.995 ), {5 lhnightssq }
 ( 0.000,  0.028,-0.123 ), {6 lbnights   }
 ( 0.546,  0.649,-0.305 ), {7 winter     }
 ( 0.436,  0.507, 0.373	), {8 spring     }
 ( 0.101,  0.154, 0.191	), {9 summer     }
 (-0.004, -0.018,-0.0004), {10 veryhot    }
 ( 0.128,  0.225,-0.116 ), {11 lnarea     }
 (-0.447,  0.001,-0.066 ), {12 lnage      }
 ( 0.315,  0.253,-0.269 ), {13 monument   }
 ( 0.668,  0.264, 0.068	), {14 phawaii    }
 (-0.452, -1.452, 0.633	), {15 palaska    }
 ( 0.548,  1.880,-1.236 ), {16 halofrwater}
 ( 0.900,  0.808,-0.710 ), {17 halofrprotl}
 (-0.068, -0.153, 0.024	), {18 lhaloentemp}
 ( 1.648,  0.090, 0.280	)); {19 lncdist    }


arrivedaypct:array[1..2,0..5,1..ndow] of double=(
{SUN	MON	  TUE	  WED	  THU	  FRI	   SAT	halo res park}
((15.3,	13.3,	12.8,	13.2,	13.3,	14.3,	17.8),	{0 nights  }
(13.0,	13.5,	13.0,	13.4,	13.6,	16.3,	17.1),	{1 night   }
(11.2,	12.3,	13.0,	13.1,	13.2,	23.9,	13.3),	{2 nights  }
(12.6,	15.6,	13.8,	14.0,	16.4,	16.3,	11.2),	{3 nights}
(12.6,	15.6,	13.8,	14.0,	16.4,	16.3,	11.2),	{4 nights}
(13.9,	16.3,	14.7,	14.0,	13.9,	13.8,	13.4)),	{5+ nights }
{SUN	MON	  TUE	  WED	  THU	  FRI	   SAT	non-res-halo}
((15.7,	12.7,	10.9,	11.3,	13.0,	16.8,	19.6),	{0 nights  }
(13.7,	12.4,	10.8,	11.9,	13.3,	19.1,	18.7),	{1 night   }
(11.9,	11.3,	9.9,	11.3,	14.1,	27.2,	14.2),	{2 nights  }
(13.4,	13.2,	10.4,	14.4,	18.5,	16.6,	13.4),	{3 nights}
(13.4,	13.2,	10.4,	14.4,	18.5,	16.6,	13.4),	{4 nights}
(18.1,	13.0,	11.4,	12.1,	11.8,	13.6,	20.0)));{5+ nights }

todperpcts:array[1..2,1..2,1..ntodpers,1..ntodpers] of double=(
{d b 6  d 6-9 d 9-n d n-3 d 3-6 d a 6   halo res day trip   }
(((0.25,0.38,	0.56,	0.53,	0.53,	0.24),	{arrive before 6 am	}
(0.00,	1.44,	6.79,	9.00,  10.06,   3.17),	{arrive 6-9 am	    }
(0.00,	0.00,	2.48,  13.62,  11.51,   3.74),	{arrive 9 am-noon	  }
(0.00,	0.00,	0.00,	2.84,  12.62,   5.77),	{arrive noon-3 pm	  }
(0.00,	0.00,	0.00,	0.00,	2.38,	8.03),	{arrive 3-6 pm	    }
(0.00,	0.00,	0.00,	0.00,	0.00,	4.06)),	{arrive after 6 pm	}
{d b 6  d 6-9 d 9-n d n-3 d 3-6 d a 6   halo res overnight  }
((4.78,	4.75,	3.55,	2.52,	2.16,	1.83),	{arrive before 6 am	}
(0.70,	2.67,	1.79,	1.70,	2.03,	1.69),	{arrive 6-9 am	    }
(0.64,	1.88,	2.86,	2.62,	2.44,	1.95),	{arrive 9 am-noon	  }
(0.78,	1.95,	2.96,	3.14,	2.62,	2.10),	{arrive noon-3 pm	  }
(0.99,	2.85,	3.25,	3.11,	3.38,	2.92),	{arrive 3-6 pm	    }
(2.71,	5.05,	4.23,	3.61,	3.60,	8.19))),{arrive after 6 pm	}
{d b 6  d 6-9 d 9-n d n-3 d 3-6 d a 6   non-halo day trip   }
(((0.07,0.19,	0.53,	0.79,	0.38,	0.12),	{arrive before 6 am	}
(0.00,	1.02,	4.33,	7.74,	5.22,	1.52),	{arrive 6-9 am	    }
(0.00,	0.00,	3.51,  16.97,  14.67,	3.97),	{arrive 9 am-noon	  }
(0.00,	0.00,	0.00,	4.46,  16.97,	5.60),	{arrive noon-3 pm	  }
(0.00,	0.00,	0.00,	0.00,	3.34,	6.45),	{arrive 3-6 pm	    }
(0.00,	0.00,	0.00,	0.00,	0.00,	2.16)),	{arrive after 6 pm	}
{d b 6  d 6-9 d 9-n d n-3 d 3-6 d a 6   non-halo overnight  }
((1.68,	1.71,	3.20,	2.34,	1.42,	0.75),	{arrive before 6 am	}
(0.30,	1.44,	2.15,	1.87,	1.58,	1.01),	{arrive 6-9 am	    }
(0.38,	2.23,	5.01,	4.47,	3.87,	2.10),	{arrive 9 am-noon	  }
(0.44,	2.48,	5.80,	5.01,	4.10,	2.41),	{arrive noon-3 pm	  }
(0.56,	2.96,	6.30,	4.93,	4.21,	2.64),	{arrive 3-6 pm	    }
(1.19,	3.14,	4.95,	3.81,	3.19,	4.36))));{arrive after 6 pm	}

function max(a,b:single):single;
begin
  if a>b then max:=a else max:=b;
end;
function ifinx(v,a,b:single):single;
begin
  if (v>=a) and (v<b) then ifinx:=1 else ifinx:=0;
end;
function ifge(a,b:single):single;
begin
  if a>=b then ifge:=1 else ifge:=0;
end;
function iflt(a,b:single):single;
begin
  if a<b then iflt:=1 else iflt:=0;
end;
function ifeq(a,b:single):single;
begin
  if a=b then ifeq:=1 else ifeq:=0;
end;
function qrecode(q:integer; v1,v2,v3,v4:single):single;
begin
  if q=1 then qrecode:=v1 else
  if q=2 then qrecode:=v2 else
  if q=3 then qrecode:=v3 else qrecode:=v4;
end;
procedure getConfigLine(var inf:text; var clabel,carg:string);
var s:string; p1,p2:byte;
begin
  readln(inf,s);
  if length(s)=0 then readln(inf) else begin
    for p1:=1 to length(s) do s[p1]:=lowercase(s[p1]);
    writeln(s,' ',length(s));
    p1:=1;
    while s[p1]=' ' do p1:=p1+1;
    p2:=p1;
    repeat p2:=p2+1 until s[p2]=' ';
    clabel:=copy(s,p1,p2-p1);

    p1:=p2;
    while s[p1]=' ' do p1:=p1+1;
    p2:=p1;
    repeat p2:=p2+1 until (p2>length(s)) or (s[p2]=' ');
    if p2>length(s) then p2:=p2+1;
    carg:=copy(s,p1,p2-p1);
  end;
end;


const
pruncode:string='zion';
sruncode:string='sum';
runvmodel:string='y';
parkdatafile:string='nps_parkdata.dat';
airportdatafile:string='apDat_19.dat';
parkapdatafile:string='parkAPs_19.csv';
zonaldatafile:string='zone_acs_19.dat';
roaddistdatafile:string='roaddistancematrix.dat';
homelocandmodeoutfile:string='vishomelocandmode_out.csv';
tripstoandfromparkoutfile:string='tripstoandfrompark_out.csv';
localvmtoutfile:string='localvmt_out.csv';

var clabel,carg:string;  prunnum,qstart,qstop:integer; pcode2:string[4];

begin
  {read configuration file}
  assign(inf,'nchrp_08-132_model_1_config.txt'); reset(inf);
  repeat
    getConfigLine(inf,clabel,carg);
    if clabel='parkcode' then pruncode:=copy(carg,1,4) else
    if clabel='season' then sruncode:=copy(carg,1,3) else
    if clabel='runvisitmodel' then runvmodel:=copy(carg,1,1) else
    if clabel='parkdatafile' then parkdatafile:=carg else
    if clabel='airportdatafile' then airportdatafile:=carg else
    if clabel='parkapdatafile' then parkapdatafile:=carg else
    if clabel='zonaldatafile' then zonaldatafile:=carg else
    if clabel='roaddistdatafile' then roaddistdatafile:=carg else
    if clabel='homelocandmodeoutfile' then homelocandmodeoutfile:=carg else
    if clabel='tripstoandfromparkoutfile' then tripstoandfromparkoutfile:=carg else
    if clabel='localvmtoutfile' then localvmtoutfile:=carg else
    writeln('Invalid label read from configuration file : ',clabel);
  until eof(inf);

  write('Reading park specific data ... ');
  assign(inf,parkdatafile); reset(inf); readln(inf);
  park:=0;
  repeat
     park:=park+1;
     readln(inf,
     parkcode[park],blank,
     parktype[park],
     park_tractgeoid[park],
     park_numaindex[park],
     park_sqm[park],
     founded[park],
     frwcaccess[park],
     hascamping[park],
     hasrvcamping[park],
     haslodging[park],
     halopop[park],
     halohh[park],
     haloemp[park],
     haloentemp[park],
     halowater[park],
     haloprotl[park],
     haloarea[park],
     leent1[park],
     leent2[park],
     leent3[park],
     wateraccess[park],
     visits[park,1],
     visits[park,2],
     visits[park,3],
     visits[park,4],
     fr_foreign[park],
     blank,parkName[park]);
     writeln(park:3,' ',parkName[park]);

     if (parkcode[park]='grsm') then greatsmoky[park]:=1 else greatsmoky[park]:=0;
     if (parkcode[park]='arch') or (parkcode[park]='brca') or (parkcode[park]='cany')
     or (parkcode[park]='care') or (parkcode[park]='zion') then utahbig5[park]:=1 else utahbig5[park]:=0;
     if (parkcode[park]='grca') or (parkcode[park]='pefo') or (parkcode[park]='sagu') then arizonanp[park]:=1 else arizonanp[park]:=0;
     if (parkcode[park]='chis') or (parkcode[park]='deva') or (parkcode[park]='jotr')
     or (parkcode[park]='lavo') or (parkcode[park]='pinn')
     or (parkcode[park]='seki') or (parkcode[park]='yose') then californianp[park]:=1 else californianp[park]:=0;
     if (parkcode[park]='blca') or (parkcode[park]='grsa')
     or (parkcode[park]='meve') or (parkcode[park]='romo') then coloradonp[park]:=1 else coloradonp[park]:=0;
     if (parkcode[park]='cave') or (parkcode[park]='whsa') then newmexiconp[park]:=1 else newmexiconp[park]:=0;
     if (parkcode[park]='crla') or (parkcode[park]='mora')
     or (parkcode[park]='noca') or (parkcode[park]='olym') then orwashnp[park]:=1 else orwashnp[park]:=0;
     if (parkcode[park]='glac') or (parkcode[park]='grte')
     or (parkcode[park]='yell') then wymontnp[park]:=1 else wymontnp[park]:=0;
     if (parkcode[park]='band') or (parkcode[park]='cach') or (parkcode[park]='cavo')
     or (parkcode[park]='cebr') or (parkcode[park]='colm')
     or (parkcode[park]='dino') or (parkcode[park]='elma')
     or (parkcode[park]='elmo') or (parkcode[park]='flfo')
     or (parkcode[park]='moca') or (parkcode[park]='orpi')
     or (parkcode[park]='tont') or (parkcode[park]='tuzi')
     or (parkcode[park]='waca') or (parkcode[park]='wupa') then fcmonum[park]:=1 else fcmonum[park]:=0;
     if (parktype[park]=2) then othmonum[park]:=1 - fcmonum[park];
  until eof(inf);
  nparks:=park;
  writeln('Done. Records read for ',nparks,' parks');

{ NEW INPUT FILE! }
  write('Reading airport data ... ');
  assign(inf,airportdatafile); reset(inf); readln(inf); {header}
  pap:=0;
  repeat
    pap:=pap+1;
    readln(inf,apcode[pap],apnuma[pap],appax19[pap]);
  until eof(inf);
  naports:=pap;
  close(inf);
  writeln('Done');
{end of new read}

{NEW AP INPUT FILE 2}
  write('Reading park airport choice sets ... ');
  assign(inf,parkAPdatafile); reset(inf);     readln(inf); {header}

  repeat
    read(inf,pcodein);
    park:=0;
    repeat park:=park+1 until (park>nparks) or (pcodein=parkCode[park]);
    if park>nparks then begin
      writeln('park ',pcodein,' is not found.');
    end else for pap:=1 to maxparkaps do begin
      read(inf,blank,apcodein);
      if apcodein<>'n/a' then begin
         apnum:=0;
         repeat apnum:=apnum+1 until (apnum>naports) or (apcodein=apcode[apnum]);
         if apnum>naports then begin
            writeln('apcode ',apcodein,' not is not valid');
         end else begin
            parkapnum[park,pap]:=apnum;
            nparkaps[park]:=pap;
         end;
      end;
    end;
    readln(inf);
    {writeln(pcodein);}
  until eof(inf);
  close(inf);
  writeln('Done');


(* OLD AP file no longer used
  write('Reading park access airport data ... ');
  assign(inf,'parkairports_alogit.dat'); reset(inf);
  park:=0;
  repeat
      park:=park+1;
      {skip over any records that are not in the main park file}
      repeat
        read(inf,parkx);
        if parkx<>parknum[park] then readln(inf);
      until (parkx=parknum[park]);
      for pap:=1 to maxparkaps do read(inf,parkapnum[park,pap]);
      for pap:=1 to maxparkaps do read(inf,parkapdis[park,pap]);
      for pap:=1 to maxparkaps do read(inf,parkappax[park,pap]);
      readln(inf);
      nparkaps[park]:=0;
      for pap:=1 to maxparkaps do if parkapnum[park,pap]>0 then nparkaps[park]:=pap;
   until eof (inf);
   close(inf);
   writeln('Done');
*)



  write('Reading zonal data ... ');
  assign(inf,zonaldatafile); reset(inf);
  readln(inf); {header}

  for numa:=1 to nnumas do begin
     readln(inf,numax,
     zone_sqm[numa],
     hholds[numa],
     persons[numa],
     adults[numa],
     ffamcu6[numa],
     ffamc6p[numa],
     ffamnoc[numa],
     fnonfam[numa],
     fage017[numa],
     fage1834[numa],
     fage3549[numa],
     fage5064[numa],
     fage6579[numa],
     fage80up[numa],
     fwhite[numa],
     fblack[numa],
     fhisp[numa],
     fasian[numa],
     fothrc[numa],
     f0veh[numa],
     fwathome[numa],
     femployed[numa],
     fincu25[numa],
     finc2550[numa],
     finc5075[numa],
     finc75100[numa],
     finc100150[numa],
     finc150200[numa],
     finco200[numa],
     state[numa],
     popden[numa],
     empden[numa],
     enteden[numa],+
     fracwater[numa],
     fracprotl[numa],
     coast[numa],
     elevation[numa],
     avgtemp1[numa],
     maxtemp1[numa],
     mintemp1[numa],
     avgprec1[numa],
     avgtemp2[numa],
     maxtemp2[numa],
     mintemp2[numa],
     avgprec2[numa],
     avgtemp3[numa],
     maxtemp3[numa],
     mintemp3[numa],
     avgprec3[numa],
     avgtemp4[numa],
     maxtemp4[numa],
     mintemp4[numa],
     avgprec4[numa]);
  end;
  close(inf);
  writeln('Done');


  write('Reading zone to zone car distance matrix ... ');
  assign(inf,roaddistdatafile); reset(inf);
  for pnuma:=1 to nnumas do begin
    for numa:=1 to nnumas do read(inf,cardist[pnuma,numa]);
    readln(inf);
  end;
  close(inf);
  writeln('Done');


{NEW CODE!}
  assign(ouf,homelocandmodeoutfile); rewrite(ouf);
  write(ouf,'parkcode,quarter,resZone,resState,roadDistance,adultVisits,adultVisitsViaRoad,adultVisitsViaAir');
  for pap:=1 to maxparkaps do write(ouf,',apcode',pap,',adultVisitsAirport',pap);
  writeln(ouf);

  assign(ouf2,tripstoandfromparkoutfile); rewrite(ouf2);
  write(ouf2,'parkcode,quarter,originZone,originState,roadDistance,totalVehicleVisits');
  for dow:=1 to ndow do for todper:=1 to ntodpers do
    write(ouf2,',arrive',dowlab[dow],'-',todperlab[todper],',depart',dowlab[dow],'-',todperlab[todper]);
  writeln(ouf2);

  assign(ouf3,localvmtoutfile); rewrite(ouf3);
  write(ouf3,'parkcode,quarter,restype,nightsinpark,nightsinhalo,VMTinPark,VMTimHalo');
  for dow:=1 to ndow do write(ouf3,',parkVMT_',dowlab[dow],',haloVMT_',dowlab[dow]);
  writeln(ouf3);

(* old code to write headers
 {open output files}
  assign(ouf1,'modapply4x_sum1.csv'); rewrite(ouf);
  writeln(ouf,'parknum,quarter,logvisits,logsum,aplogsum,avgdist,dist0to50,dist50to100',
  ',dist100to200,dist200to400,dist400to800,dist800to1600,distover1600,nolanddist');

  assign(ouf2,'modapply4x_states1.csv'); rewrite(ouf2);
  write(ouf2,'parknum,quarter');
  for st:=1 to maxstate do write(ouf2,',',st);
  writeln(ouf2);

  assign(ouf3,'modapply4x_aports1.csv'); rewrite(ouf3);
  write(ouf3,'parknum,quarter,airshare');
  for pap:=1 to maxparkaps do write(ouf3,',apnum',pap);
  for pap:=1 to maxparkaps do write(ouf3,',apshare',pap);
  writeln(ouf3);
*)

{get park and seasons to run}
  prunnum:=0;
  for park:=1 to nparks do begin
     pcode2:=copy(parkcode[park],1,4);
     for pap:=1 to 4 do pcode2[pap]:=lowercase(pcode2[pap]);
     if pruncode=pcode2 then prunnum:=park;
  end;
  if (prunnum<1) then writeln('Parkcode ',pruncode,' is not in the data file.');

  if sruncode='win' then qstart:=1 else
  if sruncode='spr' then qstart:=2 else
  if sruncode='sum' then qstart:=3 else
  if sruncode='aut' then qstart:=4 else qstart:=0;
  if qstart>0 then qstop:=qstart else begin qstart:=1; qstop:=4; end;

  {loop on parks and quarters and apply the model}
  writeln('Running models for parkcode ',pruncode,' and season(s) ',sruncode);

  if prunnum>0 then
  for park:=prunnum to prunnum do
  for quarter:=qstart to qstop do begin

  {NEW code to select 5 specific parks for testing
  if (parkcode[park]='acad')
  or (parkcode[park]='bisc')
  or (parkcode[park]='glba')
  or (parkcode[park]='glac')
  or (parkcode[park]='grca')
  then   }


  {main park/quarter loop}

    airshare:=0;
    for pap:=1 to maxparkaps do approb[pap]:=0;

    {more transformations}

    pnuma:= park_numaindex[park];
    parkradius:=sqrt(park_sqm[park])/3.14;
    pzoneradius:=sqrt(zone_sqm[pnuma])/3.14;
    pstate:= state[pnuma];
    pavgtemp:=qrecode(quarter,avgtemp1[pnuma],avgtemp2[pnuma],avgtemp3[pnuma],avgtemp4[pnuma]);
    pmintemp:=qrecode(quarter,mintemp1[pnuma],mintemp2[pnuma],mintemp3[pnuma],mintemp4[pnuma]);
    pmaxtemp:=qrecode(quarter,maxtemp1[pnuma],maxtemp2[pnuma],maxtemp3[pnuma],maxtemp4[pnuma]);
    pavgprec:=qrecode(quarter,avgprec1[pnuma],avgprec2[pnuma],avgprec3[pnuma],avgprec4[pnuma]);
    pelevatn:=elevation[pnuma];
    pcoastal:=coast[pnuma];
    ppopdens:=popden[pnuma];
    pempdens:=empden[pnuma];
    pentdens:=enteden[pnuma];
    pskiindex := ln((max(60 - pavgtemp,0) * max(((pelevatn-500)/100),0)) + 1);
    pcoaindex := ln((max(pavgtemp - 32,0) * pcoastal) + 1);
    phikindex := ln((max(pavgtemp - 32,0) * (pelevatn/100)) + 1);
    photindex := ln((max(pmaxtemp - 85,0)) + 1);

    phawaii[park]:=ifeq(pstate,15);
    palaska[park]:=ifeq(pstate,2);
    halofrwater[park]:=halowater[park]/haloarea[park];
    halofrprotl[park]:=haloprotl[park]/max(haloarea[park]-halowater[park],haloprotl[park]);
    logarea[park]:= ln(park_sqm[park]+1);
    logage[park]:= ln(2019-founded[park]+1);

    capark := ifeq(parktype[park],3);
    napark := ifeq(parktype[park],1);
    papark := ifeq(parktype[park],4);

    janmar := ifeq(quarter,1);
    aprjun := ifeq(quarter,2);
    julsep := ifeq(quarter,3);
    octdec := ifeq(quarter,4);


    for numa:=1 to nnumas do begin
    {1st numa loop}

      logadults [numa]:= ln(max(adults[numa],1));
      avail [numa]:= ifge(adults[numa],1);

      havgtemp[numa]:=qrecode(quarter,avgtemp1[numa],avgtemp2[numa],avgtemp3[numa],avgtemp4[numa]);
      hmintemp[numa]:=qrecode(quarter,mintemp1[numa],mintemp2[numa],mintemp3[numa],mintemp4[numa]);
      hmaxtemp[numa]:=qrecode(quarter,maxtemp1[numa],maxtemp2[numa],maxtemp3[numa],maxtemp4[numa]);
      havgprec[numa]:=qrecode(quarter,avgprec1[numa],avgprec2[numa],avgprec3[numa],avgprec4[numa]);

      samestate [numa]:= ifeq(state[numa], pstate);
      samenuma [numa]:= ifeq(numa , pnuma);

      cdist [numa]:= cardist[pnuma,numa];
      noland [numa]:= iflt(cdist[numa],0);
      cdistto50 [numa]:= max(0,min(cdist[numa],50));
      cdistto100 [numa]:= max(0,min(cdist[numa]-50,50));
      cdistto200 [numa]:= max(0,min(cdist[numa]-100,100));
      cdistto400 [numa]:= max(0,min(cdist[numa]-200,200));
      cdistto800 [numa]:= max(0,min(cdist[numa]-400,400));
      cdisto1600 [numa]:= max(0,min(cdist[numa]-800,800));
      cdisov1600 [numa]:= max(0,min(cdist[numa]-1600,1600));

      skiindex[numa] := ln((max(60 - havgtemp[numa],0) * max(((elevation[numa]-500)/100),0)) + 1);
      coaindex[numa] := ln((max(havgtemp[numa] - 32,0) * coast[numa]) + 1);
      hikindex[numa] := ln((max(havgtemp[numa] - 32,0) * (elevation[numa]/100)) + 1);
      hotindex[numa] := ln((max(hmaxtemp[numa] - 85,0)) + 1);

      skidiff[numa] := (pskiindex - skiindex[numa])* (1 - julsep);
      coadiff[numa] := (pcoaindex - coaindex[numa]);
      hikdiff[numa] := (phikindex - hikindex[numa]);
      hotdiff[numa] := (photindex - hotindex[numa]);

    end; {1st numa loop}

    {home location model utility calculations}
    eutilsum:=0;
    for numa:=1 to nnumas do begin
      {2nd numa loop}

      if avail[numa]>0 then
      eutil [numa]:= exp( 0
      + hlcoef[ 1]*ffamcu6 [numa]
      + hlcoef[ 2]*ffamc6p [numa]
      + hlcoef[ 3]*ffamnoc [numa]
      + hlcoef[ 4]*fnonfam [numa]
      + hlcoef[ 5]*fage017 [numa]
      + hlcoef[ 6]*fage1834 [numa]
      + hlcoef[ 7]*fage3549 [numa]
      + hlcoef[ 8]*fage5064 [numa]
      + hlcoef[ 9]*(fage6579 [numa]+fage80up [numa])
      + hlcoef[10]*fincu25  [numa]
      + hlcoef[11]*finc2550 [numa]
      + hlcoef[12]*(finc5075 [numa]+finc75100 [numa])
      + hlcoef[13]*finc100150 [numa]
      + hlcoef[14]*(finc150200 [numa]+finco200 [numa])
      + hlcoef[15]*samenuma [numa]
      + hlcoef[16]*noland [numa]
      + hlcoef[17]*(cdistto50 [numa]+cdistto100 [numa])
      + hlcoef[18]*cdistto200 [numa]
      + hlcoef[19]*cdistto400 [numa]
      + hlcoef[20]*cdistto800 [numa]
      + hlcoef[21]*cdisto1600 [numa]
      + hlcoef[22]*cdisov1600 [numa]
      + hlcoef[23]*logadults [numa]
      + hlcoef[24]*f0veh [numa]
      + hlcoef[25]*fblack [numa]
      + hlcoef[26]*fhisp [numa]
      + hlcoef[27]*fasian [numa]
      + hlcoef[28]*fothrc [numa]
      + hlcoef[29]*fwathome [numa]
      + hlcoef[30]*femployed [numa]
      + hlcoef[31]*(samestate [numa])
      + hlcoef[32]*ln(1+popden [numa])
      + hlcoef[33]*ln(1+empden [numa])
      + hlcoef[34]*(enteden [numa]/max(1,empden [numa]))
      + hlcoef[35]*coast [numa]
      + hlcoef[36]*(samestate [numa]*capark)
      + hlcoef[37]*(samestate [numa]*papark)
      + hlcoef[38]*(cdist [numa]*capark)
      + hlcoef[39]*(cdist [numa]*papark)
      + hlcoef[40]*(cdist [numa]*julsep)
      + hlcoef[41]*(cdist [numa]*janmar)
      + hlcoef[42]*(skidiff[numa])
      + hlcoef[43]*(coadiff[numa])
      + hlcoef[44]*(hikdiff[numa])
      + hlcoef[45]*(hotdiff[numa])
     )
      else eutil[numa]:=0;

      eutilsum:=eutilsum + eutil[numa];
    end;  {2nd numa loop}

    {initialize new outputs}
    for numa:=1 to nnumas do
    for dow:=1 to ndow do
    for todper:=1 to ntodpers do begin
      arrivefrac[numa,dow,todper]:=0;
      departfrac[numa,dow,todper]:=0;
    end;
    for vmtarea:=1 to 2 do
    for halores:=1 to 2 do
    for ninpark:=0 to maxnights do
    for ninhalo:=0 to maxnights do
    for dow:=0 to ndow do begin
      localVMT[vmtarea,halores,ninpark,ninhalo,dow]:=0;
    end;

    {calculate average distance and distance bands}
    avgdist:=0;
    dist0to50:=0;
    dist50to100:=0;
    dist100to200:=0;
    dist200to400:=0;
    dist400to800:=0;
    dist800to1600:=0;
    distover1600:=0;
    nolanddist:=0;

    for st:=1 to maxstate do stfrac[st]:=0;

    for numa:=1 to nnumas do begin
      prob:=eutil[numa]/eutilsum;
      avgdist:=avgdist + prob*cdist[numa];
      dist0to50 := dist0to50 + prob*ifinx(cdist[numa],0,50);
      dist50to100 := dist50to100 + prob*ifinx(cdist[numa],50,100);
      dist100to200 := dist100to200 + prob*ifinx(cdist[numa],100,200);
      dist200to400 := dist200to400 + prob*ifinx(cdist[numa],200,400);
      dist400to800 := dist400to800 + prob*ifinx(cdist[numa],400,800);
      dist800to1600 := dist800to1600 + prob*ifinx(cdist[numa],800,1600);
      distover1600 := distover1600 + prob*ifge(cdist[numa],1600);
      nolanddist := nolanddist + prob*iflt(cdist[numa],0);
      st:=round(state[numa]);
      if st>0 then stfrac[st]:=stfrac[st]+prob;
      resprob[numa]:=prob;

      {if there are foreign visitors, adjust probabilities}
      if (fr_foreign[park]>0) and (fr_foreign[park]<1) then begin
        resprob [numa]:=resprob[numa] * (1.0 - fr_foreign[park]);
        if numa=477 then resprob[numa]:=resprob[numa] + fr_foreign[park];
      end;

      {calculate airport shares and logsum and add to park totals}
      zoneairprob[numa]:=0;
      for pap:=1 to maxparkaps do zoneapprob[numa,pap]:=0;
      aplogsum:=0.0;
      if cdist[numa]<0 then airdist:=3000 else airdist:=cdist[numa];
      if (airdist>100) then begin
        aputilsum:=0;
        for pap:=1 to nparkaps[park] do begin
          parkapdis:=cardist[pnuma,apnuma[pap]];
          if (parkapdis<(airdist/2)) and (parkapdis>=0) then begin
            aputil[pap]:=-0.01219 * parkapdis
                    +0.000006638 * (parkapdis * parkapdis)
                    +0.8308 * ln(appax19[parkapnum[park,pap]] + 1.0);
            {write(aputil[pap]:8:2); readln;}
            aputil[pap]:=exp(aputil[pap]);
            aputilsum:=aputilsum + aputil[pap];
          end else aputil[pap]:=-999;
        end;
        if aputilsum>0 then begin
            aplogsum:=ln(aputilsum);
            carutil:=23.41
                  -0.01004 * airdist
                  +0.000002192 * (airdist*airdist)
                  -0.9985 * capark
                  +0.6562 * papark;
            carutil:=exp(0.4305*carutil);
            airutil:=exp(0.4305*aplogsum);
            if cdist[numa]<0 then airprob:=1.0 else airprob:=airutil/max(airutil + carutil,1.0E-20);
            zoneairprob[numa]:=airprob;
            airshare:=airshare + prob*airprob;
            for pap:=1 to nparkaps[park] do if aputil[pap]>-998 then begin
              zoneapprob[numa,pap]:=aputil[pap]/aputilsum;
              approb[pap]:=approb[pap]+ prob*airprob*aputil[pap]/aputilsum;
            end;
          end;
      end;




      {apply auxilliary models}


      {probability of living in the halo area}
      if (cdist[numa]>150) or (cdist[numa]<0) then begin
        haloprob[1]:=0.0;
        haloprob[2]:=1.0;
      end else begin
        haloutil:=
       {constant - is in halo area}	         6.406
       {car distance miles in range 0.50}	-0.064 * cdistto50 [numa]
       {car distance miles in range 50-100}	-0.060 * cdistto100[numa]
       {car distance miles in range 100-150}	-0.080 * cdistto200[numa]
       {park zone approximate radius}        	-0.033 * pzoneradius
       {park zone radius * live in park zone}	-0.019 * pzoneradius*samenuma[numa]
       {park approximate radius}	        +0.039 * parkradius
       {park radius * live in park zone}	-0.058 * parkradius*samenuma[numa];

        haloprob[2]:= 1.0/(1.0 + exp(haloutil));
        haloprob[1]:= 1.0 - haloprob[2];
      end;

      {nights stay models}
      {just exponentiate the thresholds once}
      if not(tholdsexponentiated) then begin
         for nightsmodel:=1 to 3 do
         for thold:=0 to maxnights-1 do
            tholdutil[thold,nightsmodel]:=exp(nightsthold[thold,nightsmodel]);
         tholdsexponentiated:=true;
      end;

      for nightsmodel:=1 to 3 do begin

        nightsutil:=
                    nightscoef[ 1,nightsmodel] * samenuma[numa]
                   +nightscoef[ 2,nightsmodel] * janmar
                   +nightscoef[ 3,nightsmodel] * aprjun
                   +nightscoef[ 4,nightsmodel] * julsep
                   +nightscoef[ 5,nightsmodel] * phawaii[park]
                   +nightscoef[ 6,nightsmodel] * palaska[park]
                   +nightscoef[ 7,nightsmodel] * pcoaindex
                   +nightscoef[ 8,nightsmodel] * phikindex
                   +nightscoef[ 9,nightsmodel] * pskiindex
                   +nightscoef[10,nightsmodel]* haslodging[park]
                   +nightscoef[11,nightsmodel]* logarea[park]
                   +nightscoef[12,nightsmodel]* logage[park]
                   +nightscoef[13,nightsmodel]* (fcmonum[park]+othmonum[park])
                   +nightscoef[14,nightsmodel]* photindex
                   +nightscoef[15,nightsmodel]* (cdist[numa]/1000)
                   +nightscoef[16,nightsmodel]* (cdist[numa]/1000) * (cdist[numa]/1000)
                   +nightscoef[17,nightsmodel]* airshare
                   +nightscoef[18,nightsmodel]* haloentemp[park]
                   +nightscoef[19,nightsmodel]* halofrwater[park]
                   +nightscoef[20,nightsmodel]* halofrprotl[park];


        if nightsmodel<=2 then begin
        {nights in park}
          halores:=nightsmodel;
          ninhalo:=0;

          for ninpark:=0 to maxnights-1 do begin
            ninparkprob[halores,ninpark]:=tholdutil[ninpark,nightsmodel] /
                                         (tholdutil[ninpark,nightsmodel] + exp(nightsutil));
          end;
          ninparkprob[halores,maxnights]:=1.0;
          for ninpark:=maxnights downto 1 do begin
            ninparkprob[halores,ninpark]:=ninparkprob[halores,ninpark]
                                        - ninparkprob[halores,ninpark-1];
          end;
          if halores=1 then begin
            for ninpark:=0 to maxnights do begin
              nightsprob[halores,ninpark,ninhalo]:=ninparkprob[halores,ninpark];
            end;
          end;
        end else if nightsmodel=3 then begin
        {nights in halo for non-residents - depends on nights in park}
          halores:=2;
          for ninpark:=0 to maxnights do begin
            for ninhalo:=0 to maxnights-1 do begin
              ninhaloprob[ninhalo]:= tholdutil[ninhalo,nightsmodel] /
                                    (tholdutil[ninhalo,nightsmodel]
                                    + exp(nightsutil + nightscoef[21,nightsmodel] * ninpark));
            end;
            ninhaloprob[maxnights]:=1.0;
            for ninhalo:=maxnights downto 1 do begin
              ninhaloprob[ninhalo]:=ninhaloprob[ninhalo] - ninhaloprob[ninhalo-1];
            end;

            for ninhalo:=0 to maxnights do begin
              nightsprob[halores,ninpark,ninhalo]:=ninparkprob[halores,ninpark] * ninhaloprob[ninhalo];
            end;
          end;
        end;
      end;

      {calculate average # of person-entries into park per visitor}
      for halores:=0 to 2 do avgentries[numa,halores]:=0;

      {loop on residence area- only run for halo residents if prob > 0}
      for halores:=1 to 2 do
      if (halores=2) or (haloprob[1]>1.0E-20) then begin

        {loop over combinations of park nights and halo nights}
        if halores=1 then maxnightsinhalo:=0 else maxnightsinhalo:=maxnights;
        for ninpark:=0 to maxnights do
        for ninhalo:=0 to maxnightsinhalo do begin

          tnights5:=ninpark+ninhalo;
          if tnights5>5 then tnights5:=5;
          if ninpark+ninhalo=0 then daytrip:=1 else daytrip:=2;

         {update dow and todper fractions}
          for dow:=1 to ndow do
          for arrper:=1 to ntodpers do
          for depper:=1 to ntodpers do begin
            arrdow:=dow;
            depdow:=arrdow+ninpark+ninhalo; {set departure dow based on arrive dow and nights stay}
            while depdow>ndow do depdow:=depdow-ndow;

            arrivefrac[numa,arrdow,arrper]:=arrivefrac[numa,arrdow,arrper]
            + nightsprob[halores,ninpark,ninhalo]*haloprob[halores]   {probability}
            * arrivedaypct[halores,tnights5,dow]/100.0                {arrive dow fraction}
            * todperpcts[halores,daytrip,arrper,depper]/100.0;        {add across arrive period fractions}

            departfrac[numa,depdow,depper]:=departfrac[numa,depdow,depper]
            + nightsprob[halores,ninpark,ninhalo]*haloprob[halores]   {probability}
            * arrivedaypct[halores,tnights5,dow]/100.0                {use arrive dow fraction}
            * todperpcts[halores,daytrip,arrper,depper]/100.0;        {add across depart period fractions}
          end;

          {apply regression model for number of park entries}
          ntotal:=ninpark+ninhalo;
          if ntotal=0 then daytrip:=1 else daytrip:=0;
          nentries:=parkEntriesCoef[1]
                  + parkEntriesCoef[2]*ninpark
                  + parkEntriesCoef[3]*ninhalo
                  + parkEntriesCoef[4]*daytrip;


          {adjust for children per adult}
          if ntotal>6 then ntotal6:=6 else ntotal6:=ntotal;
          nentries:=nentries*(1+childrenPerAdult[ntotal6]);

          avgentries[numa,halores]:=avgentries[numa,halores]+nentries*nightsprob[halores,ninpark,ninhalo];
          avgentries[numa,0      ]:=avgentries[numa,0      ]+nentries*nightsprob[halores,ninpark,ninhalo]*haloprob[halores];

          {apply the vmt models}
          for vmtarea:=1 to 2 do
          if (halores=2) or (vmtarea=1) then begin
            if halores=1 then vmtmodel:=1 else vmtmodel:=1+vmtarea;

            logvmt:= vmtcoef[1,vmtmodel]  {1 Constant   }
                   + vmtcoef[2,vmtmodel] *ln(ninpark+1)         {2 lpnights   }
                   + vmtcoef[3,vmtmodel] *ln(ninpark*ninpark+1) {3 lpnightssq }
                   + vmtcoef[4,vmtmodel] *ln(ninhalo+1)         {4 lhnights   }
                   + vmtcoef[5,vmtmodel] *ln(ninhalo*ninhalo+1) {5 lpnightssq }
                   + vmtcoef[6,vmtmodel] *ln(ninpark*ninhalo+1) {6 lbnights   }
                   + vmtcoef[7,vmtmodel] *janmar                {7 winter     }
                   + vmtcoef[8,vmtmodel] *aprjun                {8 spring     }
                   + vmtcoef[9,vmtmodel] *julsep                {9 summer     }
                   + vmtcoef[10,vmtmodel]*photindex             {10 veryhot   }
                   + vmtcoef[11,vmtmodel]*logarea[park]         {11 lnarea    }
                   + vmtcoef[12,vmtmodel]*logage[park]          {12 lnage     }
                   + vmtcoef[13,vmtmodel]*(fcmonum[park]+othmonum[park]) {13 monument}
                   + vmtcoef[14,vmtmodel]*phawaii[park]         {14 phawaii   }
                   + vmtcoef[15,vmtmodel]*palaska[park]         {15 palaska   }
                   + vmtcoef[16,vmtmodel]*halofrwater[park]     {16 halofrwater}
                   + vmtcoef[17,vmtmodel]*halofrprotl[park]     {17 halofrprotl}
                   + vmtcoef[18,vmtmodel]*ln(haloentemp[park]+1){18 lhaloentemp}
                   + vmtcoef[19,vmtmodel]*ln(max(cdist[numa],0)+1);{19 lncdist}
             vmt[halores,vmtarea]:=exp(logvmt);

             {calculate dow fractions}
             for dow:=0 to ndow do dowfrac[dow]:=0;
             for arrdow:=1 to ndow do begin
               for tnights:=0 to ninpark+ninhalo do begin
                 dow:=arrdow+tnights; while dow>ndow do dow:=dow-ndow;
                 dowfrac[dow]:=dowfrac[dow]+arrivedaypct[halores,tnights5,arrdow];
                 dowfrac[0  ]:=dowfrac[0  ]+arrivedaypct[halores,tnights5,arrdow];
               end;
             end;

             if halores=1 then begin
                dow:=0;
             end;

             {add to the local VMT}
             for dow:=0 to ndow do begin
               dowfrac[dow]:=dowfrac[dow]/dowfrac[0];
               localvMT[vmtarea,halores,ninpark,ninhalo,dow]:=
               localvMT[vmtarea,halores,ninpark,ninhalo,dow] +
                vmt[halores,vmtarea]  {vmt estimate}
               *nightsprob[halores,ninpark,ninhalo]*haloprob[halores] {prob in stay segment}
               *dowfrac[dow]  {dow fractions}
               *resprob[numa]; {res zone probability}

             end;
          end;
        end;
      end;
    end; {numa loop}

    {apply the park visit trip generation model, if specified - else use input data}
    if (runvmodel='n') and (visits[park,quarter]>0) then personEntries:=visits[park,quarter] else
    begin
      logvisits:= 0
      + vgcoef[ 1]                            { 1 Constant}
      + vgcoef[ 2] * ln(eutilsum)             { 2 logsum	}
      + vgcoef[ 3] * aplogsum                 { 3 aplogsum}
      + vgcoef[ 4] * janmar                   { 4 winter	}
      + vgcoef[ 5] * aprjun                   { 5 spring	}
      + vgcoef[ 6] * julsep                   { 6 summer	}
      + vgcoef[ 7] * frwcaccess[park]         { 7 frwcaccess	}
      + vgcoef[ 8] * hasrvcamping[park]       { 8 hasrvcamping	}
      + vgcoef[ 9] * haslodging[park]         { 9 haslodging	}
      + vgcoef[10] * pskiindex*janmar         {10 wtrskiindex	}
      + vgcoef[11] * pskiindex*aprjun         {11 sprskiindex	}
      + vgcoef[12] * pskiindex*octdec         {12 autskiindex	}
      + vgcoef[13] * pcoaindex*janmar         {13 wtrcoastindex}
      + vgcoef[14] * pcoaindex*aprjun         {14 sprcoastindex}
      + vgcoef[15] * pcoaindex*julsep         {15 sumcoastindex}
      + vgcoef[16] * pcoaindex*octdec         {16 autcoastindex}
      + vgcoef[17] * phikindex*janmar         {17 wtrhikeindex	}
      + vgcoef[18] * phikindex*aprjun         {18 sprhikeindex	}
      + vgcoef[19] * phikindex*julsep         {19 sumhikeindex	}
      + vgcoef[20] * phikindex*octdec         {20 authikeindex	}
      + vgcoef[21] * photindex                {21 lnvhot	}
      + vgcoef[22] * logarea[park]            {22 lnarea	}
      + vgcoef[23] * logage[park]             {23 lnage	}
      + vgcoef[24] * phawaii[park]            {24 phawaii	}
      + vgcoef[25] * palaska[park]            {25 palaska	}
      + vgcoef[26] * leent2[park]             {26 leent2	}
      + vgcoef[27] * leent3[park]             {27 leent3	}
      + vgcoef[28] * ln(haloentemp[park]+1)   {28 lhaloentemp	}
      + vgcoef[29] * greatsmoky[park]         {29 greatsmoky	}
      + vgcoef[30] * wateraccess[park]        {30 wateraccess	}
      + vgcoef[31] * utahbig5[park]           {31 utahbig5	}
      + vgcoef[32] * arizonanp[park]          {32 arizonanp	}
      + vgcoef[33] * californianp[park]       {33 californianp	}
      + vgcoef[34] * coloradonp[park]         {34 coloradonp	}
      + vgcoef[35] * newmexiconp[park]        {35 newmexiconp	}
      + vgcoef[36] * orwashnp[park]           {36 orwashnp	}
      + vgcoef[37] * wymontnp[park]           {37 wymontnp	}
      + vgcoef[38] * fcmonum[park]            {38 fcmonum	}
      + vgcoef[39] * othmonum[park];          {39 othmonum	}

      personEntries:=exp(logvisits) - 1.0;
    end;

    writeln('Writting output files');

    {NEW CODE FOR OUTPUT FILE 1 COMPLETE}
    {write a record to file 1 for each residence zone}
    totVehicleVisits:=0;
    for numa:=1 to nnumas do begin
      adultVisits:=personEntries*resprob[numa]/max(avgentries[numa,0],1.0);
      totVehicleVisits:=totVehicleVisits + adultVisits / adultsPerVehicle;
      write(ouf,parkcode[park],
      ',',quarter,
      ',',numa,
      ',',state[numa]:1:0,
      ',',cdist[numa]:1:0,
      ',',adultVisits:9:8,
      ',',adultVisits*(1.0-zoneairprob[numa]):9:8,
      ',',adultVisits*zoneairprob[numa]:9:8);
      for pap:=1 to nparkaps[park] do write(ouf,
      ',',apcode[parkapnum[park,pap]],
      ',',adultVisits*zoneairprob[numa]*zoneapprob[numa,pap]:9:8);
      for pap:=nparkaps[park]+1 to maxparkaps do write(ouf,',n/a,0.0');
      writeln(ouf);
    end;

    {NEW CODE FOR OUTPUT FILE 2 TO BE WRITTEN}
    {compute trips from origin zones or airports}
    for numa:=1 to nnumas do begin
      vehicleVisits[numa]:=0;
      for dow:=1 to ndow do
      for todper:=1 to ntodpers do begin
        vehArrive[numa,dow,todper]:=0;
        vehDepart[numa,dow,todper]:=0;
      end;
    end;

    for numa:=1 to nnumas do begin
      adultVisits:=personEntries*resprob[numa]/max(avgentries[numa,0],1.0);
      vehTrips:=adultVisits/adultsPerVehicle * (1.0-zoneairprob[numa]); {car trips from residence zone}
      vehicleVisits[numa]:=vehicleVisits[numa] + vehTrips;
      for dow:=1 to ndow do
      for todper:=1 to ntodpers do begin
         vehArrive[numa,dow,todper]:=vehArrive[numa,dow,todper] + vehTrips * arriveFrac[numa,dow,todper];
         vehDepart[numa,dow,todper]:=vehDepart[numa,dow,todper] + vehTrips * departFrac[numa,dow,todper];
      end;
      for pap:=1 to nparkaps[park] do begin
        vehtrips:=adultVisits/adultsPerVehicle * zoneairprob[numa]*zoneapprob[numa,pap];  {car trips from intermediate airports}
        apzn:=apnuma[parkapnum[park,pap]];
        vehicleVisits[apzn]:=vehicleVisits[apzn]+vehTrips;
        for dow:=1 to ndow do
        for todper:=1 to ntodpers do begin
           vehArrive[apzn,dow,todper]:=vehArrive[apzn,dow,todper] + vehTrips * arriveFrac[numa,dow,todper];  {uses fractions from residence zone}
           vehDepart[apzn,dow,todper]:=vehDepart[apzn,dow,todper] + vehTrips * departFrac[numa,dow,todper];  {not the airport zone}
        end;
      end;
    end;


    for numa:=1 to nnumas do begin
      write(ouf2,parkcode[park],
      ',',quarter,
      ',',numa,
      ',',state[numa]:1:0,
      ',',cdist[numa]:1:0,
      ',',vehicleVisits[numa]:9:8);
      for dow:=1 to ndow do for todper:=1 to ntodpers do
       write(ouf2,',',vehArrive[numa,dow,todper]:9:8,',',vehDepart[numa,dow,todper]:9:8);
      writeln(ouf2);
     end;

    (*old code
    write(ouf2,park,
     ',',quarter);
     for st:=1 to maxstate do write(ouf2,',',stfrac[st]:8:7);
     writeln(ouf2)*)

     {NEW CODE FOR OUTPUT FILE 3 TO BE WRITTEN}

     for halores:=1 to 2 do
     for ninpark:=0 to maxnights do
     for ninhalo:=0 to maxnights do
     if (halores=2) or (ninhalo=0) then begin
       write(ouf3,parkcode[park],',',quarter,',',halores,',',ninpark,',',ninhalo);
       for dow:=0 to ndow do
       for vmtarea:=1 to 2 do begin
         if dow=0 then durfact:=1.0 else durfact:=1.0/(100*(ninpark+ninhalo+1));
         write(ouf3,',',totVehicleVisits* localVMT[vmtarea,halores,ninpark,ninhalo,dow]*durfact:9:8);
       end;
       writeln(ouf3);
     end;

  end;
  close(ouf);
  close(ouf2);
  close(ouf3);
  write('Done.  Press Enter to exit program.'); readln;
end.








