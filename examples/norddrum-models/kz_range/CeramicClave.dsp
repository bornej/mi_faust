// Model: Ceramic Clave
// Description: From a clave, to a ceramic bowl.
// Parameters:
//  - Stiffness -> ND-tone:spectra
//  - Damping -> ND-tone:decay
//  - Internal Damping -> ND-tone:bend
//  - Mass -> ND-tone:pitch
//  - Gain -> ND-tone:volume

import("stdfaust.lib");
mo = library("./mi_mod.lib");
import("../utils.lib");
declare options "[midi:on]";

// Let's say we expect our model to receive values from ND voice 1
listeningVoice = 1;

cc70 = nentry("cc70[midi:ctrl 70][hidden:1]", 26, 0, 127, 1);
voice_selector(s) = *(s==0),*(s==26),*(s==51),*(s==77),*(s==102),*(s==127) :> _;
focusedVoice = 1,2,3,4,5,6 :  voice_selector(cc70) :hbargraph("focusedVoice",1,6);

// Our model will listen to incomming CC message only if focus == 1
focus = (listeningVoice == focusedVoice);

ccToVal(ccMin,ccMax,cc) = cc * ((ccMax - ccMin) / 127) + ccMin;

// Stability conditions for the model:
// Let M_max, the mass with most neighbourghs in the model
// Let n = Card(V(M_max)) with V(x) the Neighbourhood of x
// M_max stable <=> Model Stable <=> Σ Ki + 2ΣZi < 4M
// With Ki in V(M_max) and Zi in V(M_max).
// We suppose all springs have the same K and Z so
// The stability condition for the model is:
// (K < 1/n * (4M - 2*n*Z)) && ( Z < 1/n * (2M - 1/2 * n * K))

// We assume a mass in the system has at most 4 neighbors
n = 4;

// We use unitary masses (inertia = 1)
m = 1;

// We set the limits for K and Z
// k, z must be strictly positive!
// 0 < k < 4m
// 0 < z < 2m

K_min = 0.0001;
K_max = 4*m;

Z_min = 0.0001;
Z_max = 2*m;

// We let the user control K and Z values with two sliders
kx = hslider("stiffness [midi:ctrl 30]", 0, 0, 127, 1);
k = (kx,focus : holdAndJoin) : ccToVal(K_min, K_max);
zx = hslider("damping [midi:ctrl 50]", 0, 0, 127, 1);
z = (zx,focus : holdAndJoin) : ccToVal(Z_min, Z_max);

G_min = 0;
G_max = 0.7;
gx = hslider("gain [midi:ctrl 19]", 127, 0, 127, 1); 
OutGain = (gx,focus : holdAndJoin) : ccToVal(G_min, G_max) : hbargraph("Out Gain",G_min,G_max);

gateT = nentry("gate[midi:key %listeningVoice]",0,0,127,1):ba.impulsify; // ND midi note 60
in_min = 0;
in_max = 0.01;
in1 = gateT : ccToVal(in_min,in_max);

model = (RoutingLinkToMass: 
mo.ground(0.),
mo.mass(m, 0., 0.),
mo.mass(m, 0., 0.),
mo.mass(m, 0., 0.),
_, _:
RoutingMassToLink : 
mo.spring(0., 0., 0.05,0.01),
mo.spring(0., 0.),
mo.spring(0., 0.),
mo.spring(0., 0.),         par(i, 1,_)
)~par(i, 8, _):         par(i, 8,!), par(i,  1, _)
with{
RoutingLinkToMass(l0_f1,l0_f2,l1_f1,l1_f2,l2_f1,l2_f2,l3_f1,l3_f2, f_in1, k, z) = l0_f1, l0_f2+l1_f1+l3_f2, f_in1+l1_f2+l2_f1, l2_f2+l3_f1, k, z;
RoutingMassToLink(m0,m1,m2,m3, k, z) = m0, m1, k, z, m1, m2, k, z, m2, m3, k, z, m3, m1, m3;
};

// ---------------
// * Process
// Finding correct parameters range can be hard.
// When doing fine tuning on the model it can be helpfull to add a limiter
// and a bandpass/lowpass/highpass filter to avoid clipping.

process = in1, ((k,z,m,n:kz_range): (hbargraph("k",K_min, K_max), hbargraph("z",Z_min, Z_max))) : model : *(OutGain) <: co.limiter_1176_R4_stereo;
