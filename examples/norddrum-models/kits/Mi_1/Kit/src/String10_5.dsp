// Model: Ceramic Clave
// Description: From a clave, to a ceramic bowl, to a deep bass drum.
// Parameters:
//  - Stiffness -> ND-tone:spectra
//  - Damping -> ND-tone:decay
//  - Mass -> ND-tone:pitch
//  - Gain -> ND-tone:volume

import("stdfaust.lib");
mo = library("./mi_mod.lib");
import("./utils.lib");
declare options "[midi:on]";

// ----------------------------
// Nord Drum related Midi logic
// ----------------------------

// Receive values from ND voice 1
listeningVoice = 5;

// Find which Nord Drum voice has the focus.
cc70 = nentry("cc70[midi:ctrl 70][hidden:1]", 0, 0, 127, 1);
voice_selector(s) = *(s==0),*(s==26),*(s==51),*(s==77),*(s==102),*(s==127) :> _;
focusedVoice = 1,2,3,4,5,6 :  voice_selector(cc70) :hbargraph("focusedVoice",1,6);

// Our model will listen to incomming CC message only if focus == 1
focus = (listeningVoice == focusedVoice);

ccToVal(ccMin,ccMax,cc) = cc * ((ccMax - ccMin) / 127) + ccMin;

// -----------------------------------
// Stability conditions for the model:
// -----------------------------------

// Let M_max, the mass with most neighbourghs in the model
// Let n = Card(V(M_max)) with V(x) the Neighbourhood of x
// M_max stable <=> Model Stable <=> Σ Ki + 2ΣZi < 4M
// With Ki in V(M_max) and Zi in V(M_max).
// We suppose all springs have the same K and Z so
// The stability condition for the model is:
// (K < 1/n * (4M - 2*n*Z)) && ( Z < 1/n * (2M - 1/2 * n * K))


// A mass has at most 4 neighbors in our model
// (Actually 2) but condition is still true.
n = 4;

mkz_range(mx,kx,zx,n) = equation
with{
    security = 0.2;
    equation = m,k,z
    letrec{
    'm = max(mx, security + n*((1/2)*z + (1/4)*k));
       'k = min(kx, 1/n * (4*m - 2*n*z));
       'z = min(zx, 1/n * (2*m - (1/2)*n*k));
    };
};

// Setting the limits for K and Z
// k, z must be strictly positive!
// 0 < k < 4m
// 0 < z < 2m
// This implies
// 0 < K_max <<<< 4 * M_min
// 0 < Z_max <<<< 2 * M_min
// /!\ It appears that if K_max and Z_max come too close from
// the limit the model crashes

// Physical parameters
M_min = 1;
M_max = 10;

K_min = 0.0001;
K_max = 3.5;

Z_min = 0.0001;
Z_max = 0.1;

// stiffness
K_preset = 18;

// Damping
Z_preset = 127;

// Mass inertia
M_preset = 25;

// Gain
G_preset = 10;

// Midi controled sliders for M, K and Z values
mx = hslider("mass[midi:ctrl 31]", M_preset, 0, 127, 1);
m = (mx,focus : holdOrJoin) : ccToVal(M_min, M_max);
kx = hslider("stiffness [midi:ctrl 30]", K_preset, 0, 127, 1);
k = (kx,focus : holdOrJoin) : ccToVal(K_min, K_max);
zx = hslider("damping [midi:ctrl 50]", Z_preset, 0, 127, 1);
z = (zx,focus : holdOrJoin) : ccToVal(Z_min, Z_max);
// Volume and Input force parameters
G_min = 0;
G_max = 0.7;

in_min = 0;
in_max = 10;

gx = hslider("gain [midi:ctrl 19]", G_preset, 0, 127, 1); 
OutGain = (gx,focus : holdOrJoin) : ccToVal(G_min, G_max) : hbargraph("Out Gain",G_min,G_max);
gateT = nentry("gate[midi:key %listeningVoice]",0,0,127,1):ba.impulsify;
in1 = gateT : ccToVal(in_min,in_max);

model = (RoutingLinkToMass: 
mo.ground(0.),
mo.ground(0.),
mo.mass(0., 0.),
mo.mass(0., 0.),
mo.mass(0., 0.),
mo.mass(0., 0.),
mo.mass(0., 0.),
mo.mass(0., 0.),
mo.mass(0., 0.),
mo.mass(0., 0.),
mo.mass(0., 0.),
mo.mass(0., 0.),
mo.mass(0., 0.),
mo.mass(0., 0.),
mo.mass(0., 0.),
mo.mass(0., 0.),
mo.mass(0., 0.),
mo.mass(0., 0.),
mo.mass(0., 0.),
mo.mass(0., 0.),
mo.mass(0., 0.),
mo.mass(0., 0.),
_,_:
RoutingMassToLink : 
mo.spring(0., 0.),
mo.spring(0., 0.),
mo.spring(0., 0.),
mo.spring(0., 0.),
mo.spring(0., 0.),
mo.spring(0., 0.),
mo.spring(0., 0.),
mo.spring(0., 0.),
mo.spring(0., 0.),
mo.spring(0., 0.),
mo.spring(0., 0.),
mo.spring(0., 0.),
mo.spring(0., 0.),
mo.spring(0., 0.),
mo.spring(0., 0.),
mo.spring(0., 0.),
mo.spring(0., 0.),
mo.spring(0., 0.),
mo.spring(0., 0.),
mo.spring(0., 0.),
mo.spring(0., 0.),         par(i, 1,_)
)~par(i, 42, _):         par(i, 42,!), par(i,  1, _)
with{
RoutingLinkToMass(l0_f1,l0_f2,l1_f1,l1_f2,l2_f1,l2_f2,l3_f1,l3_f2,l4_f1,l4_f2,l5_f1,l5_f2,l6_f1,l6_f2,l7_f1,l7_f2,l8_f1,l8_f2,l9_f1,l9_f2,l10_f1,l10_f2,l11_f1,l11_f2,l12_f1,l12_f2,l13_f1,l13_f2,l14_f1,l14_f2,l15_f1,l15_f2,l16_f1,l16_f2,l17_f1,l17_f2,l18_f1,l18_f2,l19_f1,l19_f2,l20_f1,l20_f2, f_in1, m, k, z) =
l0_f1,
l20_f2,
m, l0_f2+l1_f1,
m,l1_f2+l2_f1,
m,l2_f2+l3_f1,
m,f_in1+l3_f2+l4_f1,
m,l4_f2+l5_f1,
m,l5_f2+l6_f1,
m,l6_f2+l7_f1,
m,l7_f2+l8_f1,
m,l8_f2+l9_f1,
m,l9_f2+l10_f1,
m,l10_f2+l11_f1,
m,l11_f2+l12_f1,
m,l12_f2+l13_f1,
m,l13_f2+l14_f1,
m,l14_f2+l15_f1,
m,l15_f2+l16_f1,
m,l16_f2+l17_f1,
m,l17_f2+l18_f1,
m,l18_f2+l19_f1,
m,l19_f2+l20_f1,
k,z;
RoutingMassToLink(m0,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,m16,m17,m18,m19,m20,m21,k,z) =
k, z, m0, m2,
k, z, m2, m3,
k, z, m3, m4,
k, z, m4, m5,
k, z, m5, m6,
k, z, m6, m7,
k, z, m7, m8,
k, z, m8, m9,
k, z, m9, m10,
k, z, m10, m11,
k, z, m11, m12,
k, z, m12, m13,
k, z, m13, m14,
k, z, m14, m15,
k, z, m15, m16,
k, z, m16, m17,
k, z, m17, m18,
k, z, m18, m19,
k, z, m19, m20,
k, z, m20, m21,
k, z, m21, m1,
m19;
};
process =
in1,
(
    (m,k,z,n:mkz_range):
    (
        hbargraph("m",M_min, M_max),
        hbargraph("k",K_min, K_max),
        hbargraph("z",Z_min, Z_max)
    )
)
: model : *(OutGain) <: co.limiter_1176_R4_stereo;
